From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH/RFC] openvswitch: Retain parsed IPv6 header fields in flow
 on error skipping extension headers
Date: Fri, 28 Aug 2015 11:11:08 -0700
Message-ID: <CALnjE+qPPoguVDAmCozjqp5bS3aGO72Y0oxUM45=C1OOdXx28Q@mail.gmail.com>
References: <1439515813-29406-1-git-send-email-simon.horman@netronome.com>
	<CALnjE+owxmLQXLZoAU4oNXToDA1hb4uvr8nj9KXCiKgcRhEOvQ@mail.gmail.com>
	<20150827070959.GA25311@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34685 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbbH1SLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 14:11:08 -0400
Received: by iofe124 with SMTP id e124so36358701iof.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 11:11:08 -0700 (PDT)
In-Reply-To: <20150827070959.GA25311@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 12:10 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi Pravin,
>
> On Mon, Aug 17, 2015 at 11:33:59AM -0700, Pravin Shelar wrote:
>> On Thu, Aug 13, 2015 at 6:30 PM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>> > When an error occurs skipping IPv6 extension headers retain the already
>> > parsed IP protocol and IPv6 addresses in the flow. Also assume that the
>> > packet is not a fragment in the absence of information to the contrary;

...
> -- >8 --
> Subject: [PATCH v1.1] openvswitch: Retain parsed IPv6 header fields in flow on error skipping extension headers
>
> When an error occurs skipping IPv6 extension headers retain the already
> parsed IP protocol and IPv6 addresses in the flow. Also assume that the
> packet is not a fragment in the absence of information to the contrary;
> that is always use the frag_off value set by ipv6_skip_exthdr().
>
> This allows matching on the IP protocol and IPv6 addresses of packets
> with malformed extension headers.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>
> ---
>
> * Some consideration should be given to unwanted side effects of this patch
>   as it affects the handling of malformed packets.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  net/openvswitch/flow.c | 21 +++++++++++++++------
>  1 file changed, 15 insertions(+), 6 deletions(-)
>
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 8db22ef73626..de4366f81b11 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -271,8 +271,6 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
>         key->ipv6.addr.dst = nh->daddr;
>
>         payload_ofs = ipv6_skip_exthdr(skb, payload_ofs, &nexthdr, &frag_off);
> -       if (unlikely(payload_ofs < 0))
> -               return -EINVAL;
>
>         if (frag_off) {
>                 if (frag_off & htons(~0x7))
> @@ -283,6 +281,13 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
>                 key->ip.frag = OVS_FRAG_TYPE_NONE;
>         }
>
> +       /* Delayed handling of error in ipv6_skip_exthdr() as it
> +        * always sets frag_off to a valid value which may be
> +        * used to set key->ip.frag above.
> +        */
> +       if (unlikely(payload_ofs < 0))
> +               return -EPROTO;
> +
>         nh_len = payload_ofs - nh_ofs;
>         skb_set_transport_header(skb, nh_ofs + nh_len);
>         key->ip.proto = nexthdr;
> @@ -622,12 +627,16 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>
>                 nh_len = parse_ipv6hdr(skb, key);
>                 if (unlikely(nh_len < 0)) {
> -                       memset(&key->ip, 0, sizeof(key->ip));
> -                       memset(&key->ipv6.addr, 0, sizeof(key->ipv6.addr));
> -                       if (nh_len == -EINVAL) {
> +                       switch (nh_len) {
> +                       case -EINVAL:
> +                               memset(&key->ip, 0, sizeof(key->ip));
> +                               memset(&key->ipv6.addr, 0, sizeof(key->ipv6.addr));
> +                               /* fall-through */
> +                       case -EPROTO:
>                                 skb->transport_header = skb->network_header;
>                                 error = 0;
> -                       } else {
> +                               break;
> +                       default:
>                                 error = nh_len;
>                         }
>                         return error;
Looks good to me.

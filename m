From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH/RFC] openvswitch: Retain parsed IPv6 header fields in flow
 on error skipping extension headers
Date: Mon, 17 Aug 2015 11:33:59 -0700
Message-ID: <CALnjE+owxmLQXLZoAU4oNXToDA1hb4uvr8nj9KXCiKgcRhEOvQ@mail.gmail.com>
References: <1439515813-29406-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33978 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbbHQSeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 14:34:00 -0400
Received: by iodb91 with SMTP id b91so161240476iod.1
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 11:33:59 -0700 (PDT)
In-Reply-To: <1439515813-29406-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2015 at 6:30 PM, Simon Horman
<simon.horman@netronome.com> wrote:
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
>  net/openvswitch/flow.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 8db22ef73626..3c5336c5d4ea 100644
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
> +               return -EINVAL;
> +
check_header() function called above also return -EINVAL, That could
confuse caller checking for error code. So we need different error
code here.

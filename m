From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use skb_zerocopy() to prepare
 skb for upcall
Date: Thu, 25 Jul 2013 18:39:42 -0700
Message-ID: <CAEP_g=_ExeJ+pJ4KU7+=vdyFgLQtY2v6fiK0GzLKpeNF8NULbw@mail.gmail.com>
References: <cover.1374756042.git.tgraf@suug.ch> <9d4aaa5319c684e14721e0bed2ef22ddc409caf1.1374756042.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:56723 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756785Ab3GZBkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 21:40:03 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd20so3105501obb.19
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 18:40:02 -0700 (PDT)
In-Reply-To: <9d4aaa5319c684e14721e0bed2ef22ddc409caf1.1374756042.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 5:43 AM, Thomas Graf <tgraf@suug.ch> wrote:
> From: Thomas Graf <tgraf@rhlap.localdomain>
>
> Use of skb_zerocopy() avoids the expensive call to memcpy() when
> copying the packet data into the Netlink skb. Completes checksum
> through skb_checksum_help() if needed (typicall packet input from
> software device) which invalidates some of the gains again.
>
> Stock-RX
> -  38.30%       swapper  [kernel.kallsyms]  [k] memcpy
>    - memcpy
>       + 87.46% queue_userspace_packet
>       + 12.54% nla_put
> +  24.72%  ovs-vswitchd  libc-2.17.so       [.] __memcpy_ssse3_back
> +  13.80%  ovs-vswitchd  [kernel.kallsyms]  [k] memcpy
> -   7.68%   ksoftirqd/2  [kernel.kallsyms]  [k] memcpy
>    - memcpy
>       + 85.83% queue_userspace_packet
>       + 14.17% nla_put
> -   7.06%   ksoftirqd/3  [kernel.kallsyms]  [k] memcpy
>    - memcpy
>       + 84.85% queue_userspace_packet
>       + 15.15% nla_put
> -   4.41%   ksoftirqd/0  [kernel.kallsyms]  [k] memcpy
>    - memcpy
>       + 83.48% queue_userspace_packet
>       + 16.52% nla_put
>
> Zerocopy-RX
> +  50.35%  ovs-vswitchd  libc-2.17.so       [.] __memcpy_ssse3_back
> -  27.78%  ovs-vswitchd  [kernel.kallsyms]  [k] memcpy
>    - memcpy
>       + 74.53% ovs_packet_cmd_execute
>       + 24.11% nla_put
>       + 0.93% ovs_flow_cmd_new_or_set
> +  13.49%       swapper  [kernel.kallsyms]  [k] memcpy
> +   1.45%   ksoftirqd/3  [kernel.kallsyms]  [k] memcpy
> +   1.20%   ksoftirqd/2  [kernel.kallsyms]  [k] memcpy
>
> 10Gb remote pktgen, 1200 bytes, randomized flows, w/ UDPCSUM:
>                                 Hits               Missed          Lost
> Stock RX                     731'945            6'315'739     3'606'678
> Zerocopy RX                  764'041            6'442'761     3'947'451
>
> local pktgen, 4/6 CPUs, 1200 bytes, randomized flows, UDPCSUM:
>                                 Hits               Missed          Lost
> Stock TX                   2'071'030           17'929'192    16'807'785
> Zerocopy TX                1'951'142           18'049'056    16'977'296
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Thanks for the new version and performance numbers.

Reading the numbers that you provided it seems like this is a win for
received packets and basically a wash for outgoing packets (assuming
that they are using checksum offloading, which I suspect is most of
them). Is that also your conclusion?

A couple of comments:

> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index f7e3a0d..c5927ad 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -383,10 +383,11 @@ static size_t key_attr_size(void)
>  }
>
>  static size_t upcall_msg_size(const struct sk_buff *skb,
> -                             const struct nlattr *userdata)
> +                             const struct nlattr *userdata,
> +                             unsigned int hdrlen)

I think the skb parameter is no longer used by this function.

> @@ -443,11 +450,39 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
>                           nla_len(upcall_info->userdata),
>                           nla_data(upcall_info->userdata));
>
> -       nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
> +       if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
> +               goto out;

Do we expect that this might fail now?

> +       nla->nla_len = nla_attr_size(skb->len);
> +
> +       skb_zerocopy(user_skb, skb, skb->len, hlen);
> +
> +       /* Align the end of the attribute to NLA_ALIGNTO */
> +       plen = NLA_ALIGN(user_skb->len) - user_skb->len;
> +       if (plen > 0) {
> +               int nr_frags = skb_shinfo(user_skb)->nr_frags;
>
> -       skb_copy_and_csum_dev(skb, nla_data(nla));
> +               if (nr_frags) {
> +                       skb_frag_t *frag;
> +
> +                       /* Assumption is made that PAGE_SIZE is always alligned
> +                        * to at least NLA_ALIGNTO (4) which means that we it
> +                        * should be safe to add the padding bytes to the frag
> +                        */

I agree that it should be safe to assume that PAGE_SIZE is a multiple
of the netlink alignment requirements. However, we are calculating the
alignment over the total packet payload but applying the alignment to
the paged portion. Couldn't we have a non-aligned potion in the linear
data area followed by a full page?

> +       /* Fix alignment of .nlmsg_len, OVS user space enforces a strict
> +        * total message size alignment.
> +        */
> +       ((struct nlmsghdr *) user_skb->data)->nlmsg_len = NLA_ALIGN(user_skb->len);

Do we still need to do this manually now that we are enforcing
alignment of the payload above?

From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Thu, 25 Jun 2015 17:20:47 -0700
Message-ID: <CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	pradeeps@linux.vnet.ibm.com, jkidambi@us.ibm.com
To: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36800 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbFZAUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 20:20:48 -0400
Received: by igbiq7 with SMTP id iq7so3349973igb.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 17:20:47 -0700 (PDT)
In-Reply-To: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2015 at 5:03 PM, Ramu Ramamurthy
<sramamur@linux.vnet.ibm.com> wrote:
> Problem:
> -------
>
> GRO is enabled on the interfaces in the following test,
> but GRO does not take effect for vxlan-encapsulated tcp streams. The root
> cause of why GRO does not take effect is described below.
>
> VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|
> VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|
>
> Because gro is not effective, the throughput for vxlan-encapsulated
> tcp-stream is around 3 Gbps.
>
> With the proposed patch, gro takes effect for vxlan-encapsulated tcp
> streams,
> and performance in the same test is around 8.6 Gbps.
>
>
> Root Cause:
> ----------
>
>
> At entry to udp4_gro_receive(), the gro parameters are set as follows:
>
>     skb->ip_summed  == 0 (CHECKSUM_NONE)
>     NAPI_GRO_CB(skb)->csum_cnt == 0
>     NAPI_GRO_CB(skb)->csum_valid == 0
>
>     UDH header checksum is 0.
>
> static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
>                                          struct sk_buff *skb)
> {
>
>          <snip>
>
>         if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP,
> uh->check,
>                                                  inet_gro_compute_pseudo))
>
>>>>             This calls __skb_incr_checksum_unnecessary which sets
>>>>                     skb->ip_summed to  CHECKSUM_UNNECESSARY
>>>>
>
>                 goto flush;
>         else if (uh->check)
>                 skb_gro_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
>                                              inet_gro_compute_pseudo);
> skip:
>         NAPI_GRO_CB(skb)->is_ipv6 = 0;
>         return udp_gro_receive(head, skb, uh);
>
> }
>
> struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>                                  struct udphdr *uh)
> {
>         struct udp_offload_priv *uo_priv;
>         struct sk_buff *p, **pp = NULL;
>         struct udphdr *uh2;
>         unsigned int off = skb_gro_offset(skb);
>         int flush = 1;
>
>         if (NAPI_GRO_CB(skb)->udp_mark ||
>             (skb->ip_summed != CHECKSUM_PARTIAL &&
>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>              !NAPI_GRO_CB(skb)->csum_valid))
>                 goto out;
>>>>
>>>>
>>>>      vxlan GRO gets skipped due to the above condition because here,:
>>>>          skb->ip_summed == CHECKSUM_UNNECESSARY
>>>>          NAPI_GRO_CB(skb)->csum_cnt == 0
>>>>          NAPI_GRO_CB(skb)->csum_valid == 0
>
>
> There is no reason for skipping vxlan gro in the above combination of
> conditions,
> because, tcp4_gro_receive() validates the inner tcp checksum anyway !
>
>
> Patch:
> ------
>
> Signed-off-by: Ramu Ramamurthy <ramu.ramamurthy@us.ibm.com>
> ---
>  net/ipv4/udp_offload.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index f938616..17fc12b 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -301,6 +301,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head,
> struct sk_buff *skb,
>
>         if (NAPI_GRO_CB(skb)->udp_mark ||
>             (skb->ip_summed != CHECKSUM_PARTIAL &&
> +            skb->ip_summed != CHECKSUM_UNNECESSARY &&
>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>              !NAPI_GRO_CB(skb)->csum_valid))
>                 goto out;
> --

This isn't right. The CHECKSUM_UNNECESSARY only refers to the outer
checksum which is zero in this case so it is trivially unnecessary.
The inner checksum still needs to be computed on the host. By
convention, we do not do GRO if it is required to compute the inner
checksum (csum_cnt == 0 checks that). If we want to allow checksum
calculation to occur in the GRO path, meaning we understand the
ramifications and can show this is better for performance, then all
the checks about checksum here should be removed.

> 1.7.1
>
>
>
>
>
> Notes:
> -------
>
> The above gro fix applies to all udp-encapsulation protocols (vxlan, geneve)
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

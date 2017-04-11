From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: calculate L4 checksums also for GSO case
 before encrypting packets
Date: Tue, 11 Apr 2017 09:07:55 +0200
Message-ID: <20170411070755.GW5092@secunet.com>
References: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Ansis Atteka <aatteka@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58288 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753243AbdDKHIo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 03:08:44 -0400
Content-Disposition: inline
In-Reply-To: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 11:42:07AM -0700, Ansis Atteka wrote:
> Otherwise, if L4 checksum calculation is done after encryption,
> then all ESP packets end up being corrupted at the location
> where pre-encryption L4 checksum field resides.
> 
> One of the ways to reproduce this bug is to have a VM with virtio_net
> driver (UFO set to ON in the guest VM); and then encapsulate all guest's
> Ethernet frames in GENEVE; and then further encrypt GENEVE with IPsec.
> In this case following symptoms are observed:
> 1. If using ixgbe NIC, then the driver will also emit following
>    warning message:
>    ixgbe 0000:01:00.1: partial checksum but l4 proto=32!
> 2. Receiving VM will drop all the corrupted ESP packets, hence UDP iperf test
>    with large packets will fail completely or TCP iperf will get ridiculously
>    low performance because TCP window will never grow above MTU.
> 
> Signed-off-by: Ansis Atteka <aatteka@ovn.org>
> ---
>  net/xfrm/xfrm_output.c | 19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index 8ba29fe..7ad7e5f 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -168,7 +168,8 @@ static int xfrm_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
>  
>  static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb)
>  {
> -	struct sk_buff *segs;
> +	struct sk_buff *segs, *nskb;
> +	int err;
>  
>  	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
>  	BUILD_BUG_ON(sizeof(*IP6CB(skb)) > SKB_SGO_CB_OFFSET);
> @@ -180,21 +181,27 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
>  		return -EINVAL;
>  
>  	do {
> -		struct sk_buff *nskb = segs->next;
> -		int err;
> +		nskb = segs->next;
>  
>  		segs->next = NULL;
> -		err = xfrm_output2(net, sk, segs);
> +		err = skb_checksum_help(segs);

What's wrong with the checksum provided by the GSO layer and
why we have to do this unconditionally here?

We don't announce any checksum capabilities, so the GSO
layer should provide the checksum. If this is not the case,
something along the path is taking wrong assumptions.

Btw. all GSO packets on a standard IPv4 xfrm tunnel are getting
dropped with your patch applied.

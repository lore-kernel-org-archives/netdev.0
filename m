From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Thu, 6 Oct 2011 07:00:47 -0400
Message-ID: <20111006110047.GA22462@hmsreliant.think-freely.org>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Yinglin Sun <Yinglin.Sun@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51337 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701Ab1JFLBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 07:01:16 -0400
Content-Disposition: inline
In-Reply-To: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote:
> Steps to reproduce this issue:
> 1. create bond0 over eth0 and eth1, set the mode to balance-xor
> 2. add an IPv6 address to bond0
> 3. DAD packet is sent out from one slave and then is looped back from
> the other slave. Therefore, it is treated as a duplicate address and
> stays tentative afterwards:
>    kern.info:
>        Oct  5 11:50:18 testvm1 kernel: [  129.224353] bond0: IPv6 duplicate address 1234::1 detected!
> 
> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
> ---
>  net/ipv6/ndisc.c |   15 +++++++++++++--
>  1 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 9da6e02..c82f4c7 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -809,9 +809,10 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  
>  		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>  			if (dad) {
> +				const unsigned char *sadr;
> +				sadr = skb_mac_header(skb);
> +
>  				if (dev->type == ARPHRD_IEEE802_TR) {
> -					const unsigned char *sadr;
> -					sadr = skb_mac_header(skb);
>  					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
>  					    sadr[9] == dev->dev_addr[1] &&
>  					    sadr[10] == dev->dev_addr[2] &&
> @@ -821,6 +822,16 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  						/* looped-back to us */
>  						goto out;
>  					}
> +				} else if (dev->type == ARPHRD_ETHER) {
> +					if (sadr[6] == dev->dev_addr[0] &&
> +					    sadr[7] == dev->dev_addr[1] &&
> +					    sadr[8] == dev->dev_addr[2] &&
> +					    sadr[9] == dev->dev_addr[3] &&
> +					    sadr[10] == dev->dev_addr[4] &&
> +					    sadr[11] == dev->dev_addr[5]) {
> +						/* looped-back to us */
> +						goto out;
> +					}
>  				}
>  
>  				/*
> -- 
> 1.7.4.1
> 
Nack, This seems like it will just completely break DAD.  What if theres another
system out there with the same mac address.  A response from that system would
get dropped by this filter, instead of causing The local system to stop using
the address.  What you really want to do is modify
bond_should_deliver_exact_match to detect this frame on the inactive slave or
some such, and drop the frame there.

Neil

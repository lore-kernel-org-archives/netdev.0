From: Chris Lalancette <clalance@redhat.com>
Subject: Re: [PATCH]: Fix netpoll arp_reply for multiple routers
Date: Thu, 07 Dec 2006 16:44:45 -0500
Message-ID: <45788B4D.2020403@redhat.com>
References: <4576EFD2.1070100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163447AbWLGVor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 16:44:47 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id kB7LikLx028756
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 16:44:46 -0500
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id kB7LikGZ021715
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 16:44:46 -0500
To: Chris Lalancette <clalance@redhat.com>
In-Reply-To: <4576EFD2.1070100@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Lalancette wrote:
> All,
>      Attached is a patch to fix arp_reply when you have multiple possible routers doing ARP requests to you.  Currently arp_reply always replies to the MAC address that it was given when it starts.  However, if you have multiple routers that can ARP request you, you might respond to the wrong router; in which case the other router will eventually drop you from it's ARP cache and stop delivering packets to you.  The fix is to always reply to the router that asked you, not the one you have hard-coded.
>      I do not have the setup to test this; the customer that does have the setup has tested the patch and reports that it fixes the problems they were having.
> 
> 
> Signed-off-by: Chris Lalancette <clalance@redhat.com>
> 
> 
> ------------------------------------------------------------------------
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 3c58846..5833b21 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -331,6 +331,7 @@ static void arp_reply(struct sk_buff *sk
>  	unsigned char *arp_ptr;
>  	int size, type = ARPOP_REPLY, ptype = ETH_P_ARP;
>  	__be32 sip, tip;
> +	unsigned char *sha;
>  	struct sk_buff *send_skb;
>  	struct netpoll *np = NULL;
>  
> @@ -357,9 +358,14 @@ static void arp_reply(struct sk_buff *sk
>  	    arp->ar_op != htons(ARPOP_REQUEST))
>  		return;
>  
> -	arp_ptr = (unsigned char *)(arp+1) + skb->dev->addr_len;
> +	arp_ptr = (unsigned char *)(arp+1);
> +	/* save the location of the src hw addr */
> +	sha = arp_ptr;
> +	arp_ptr += skb->dev->addr_len;
>  	memcpy(&sip, arp_ptr, 4);
> -	arp_ptr += 4 + skb->dev->addr_len;
> +	arp_ptr += 4;
> +	/* if we actually cared about dst hw addr, it would get copied here */
> +	arp_ptr += skb->dev->addr_len;
>  	memcpy(&tip, arp_ptr, 4);
>  
>  	/* Should we ignore arp? */
> @@ -382,7 +388,7 @@ static void arp_reply(struct sk_buff *sk
>  
>  	if (np->dev->hard_header &&
>  	    np->dev->hard_header(send_skb, skb->dev, ptype,
> -				 np->remote_mac, np->local_mac,
> +				 sha, np->local_mac,
>  				 send_skb->len) < 0) {
>  		kfree_skb(send_skb);
>  		return;
> @@ -406,7 +412,7 @@ static void arp_reply(struct sk_buff *sk
>  	arp_ptr += np->dev->addr_len;
>  	memcpy(arp_ptr, &tip, 4);
>  	arp_ptr += 4;
> -	memcpy(arp_ptr, np->remote_mac, np->dev->addr_len);
> +	memcpy(arp_ptr, sha, np->dev->addr_len);
>  	arp_ptr += np->dev->addr_len;
>  	memcpy(arp_ptr, &sip, 4);
>  

All,
     Sorry for the confusion...this was already picked up by akpm on linux-net.  Please don't take the patch.

Thanks,
Chris Lalancette

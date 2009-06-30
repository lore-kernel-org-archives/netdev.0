From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Tue, 30 Jun 2009 15:55:59 -0700
Message-ID: <m1r5x1z5z4.fsf@fess.ebiederm.org>
References: <200903011344.45814.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38924 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759254AbZF3W4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 18:56:02 -0400
In-Reply-To: <200903011344.45814.denys@visp.net.lb> (Denys Fedoryschenko's message of "Sun\, 1 Mar 2009 13\:44\:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

> Windows (XP at least) hosts on boot, with configured static ip, performing 
> address conflict detection, which is defined in RFC3927.
> Here is quote of important information:
>
> "
> An ARP announcement is identical to the ARP Probe described above, 
> except    that now the sender and target IP addresses are both set 
> to the host's newly selected IPv4 address. 
> "
>
> But it same time this goes wrong with RFC5227.
> "
> The 'sender IP address' field MUST be set to all zeroes; this is to avoid
> polluting ARP caches in other hosts on the same link in the case
> where the address turns out to be already in use by another host.
> "
>
> When ARP proxy configured, it must not answer to both cases, because 
> it is address conflict verification in any case. For Windows it is just 
> causing to detect false "ip conflict". Already there is code for RFC5227, so 
> just trivially we just check also if source ip == target ip.

I have a problem with this patch.  It stops gratuitous arps updating
my arp cache.  I'm still trying to figure out what the correct behaviour
should be.

Perhaps making the goto out; become if (sip == 0) goto out;

Eric



>
> Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>
> ---
>
> diff --git a/net-next-2.6/net/ipv4/arp.c b/linux-net-next-a/net/ipv4/arp.c
> index 3f6b735..5afaf2a 100644
> --- a/net-next-2.6/net/ipv4/arp.c
> +++ b/linux-net-next-a/net/ipv4/arp.c
> @@ -801,8 +801,11 @@ static int arp_process(struct sk_buff *skb)
>   *  cache.
>   */
>  
> -	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
> -	if (sip == 0) {
> +	/* 
> +	*  Special case: IPv4 duplicate address detection packet (RFC2131)
> +	*  and Gratuitous ARP/ARP Announce. (RFC3927, Section 2.4) 
> +	*/
> +	if (sip == 0 || tip == sip) {
>  		if (arp->ar_op == htons(ARPOP_REQUEST) &&
>  		    inet_addr_type(net, tip) == RTN_LOCAL &&
>  		    !arp_ignore(in_dev, sip, tip))

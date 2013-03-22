From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Fri, 22 Mar 2013 12:39:35 +0900
Message-ID: <1363923575.16608.17.camel@cirrhata>
References: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Meng, Jilin" <Jilin.Meng@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45951 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932460Ab3CVDgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 23:36:23 -0400
In-Reply-To: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meng, Jilin wrote:
> we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
> This occurs when a bonding interface with roundrobin mode is being configured an IPv6 address 
> while the switch side isn't configured bonding/channel yet.
> 
> Signed-off-by: Jilin Meng <jilin.meng@emc.com>
> Signed-off-by: Yinglin Sun <yinglin.sun@emc.com>
> Signed-off-by: Lakshmanan Prithviraj <lakshmanan.prithviraj@emc.com>
> ---
> --- linux/net/ipv6/ndisc.c.orig	2013-03-12 17:16:18.000000000 +0800
> +++ linux/net/ipv6/ndisc.c	2013-03-21 10:37:06.000000000 +0800
> @@ -757,6 +757,24 @@ static void ndisc_recv_ns(struct sk_buff
>  
>  		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>  			if (dad) {
> +				if (dev->type == ARPHRD_ETHER) {
> +					const unsigned char *sadr;
> +					sadr = skb_mac_header(skb);
> +					if (sadr[6] == dev->dev_addr[0] &&
> +					    sadr[7] == dev->dev_addr[1] &&
> +					    sadr[8] == dev->dev_addr[2] &&
> +					    sadr[9] == dev->dev_addr[3] &&
> +					    sadr[10] == dev->dev_addr[4] &&
> +					    sadr[11] == dev->dev_addr[5]) {
> +					/*
> +					 * looped-back to us. This occurs when
> +					 * a bonding interface with roundrobin
> +					 * mode is being configured while the
> +					 * switch side isn't configured yet.
> +					 */
> +						goto out;
> +				}
> +
>  				/*
>  				 * We are colliding with another node
>  				 * who is doing DAD

I would say that it is a configuration error.

--yoshfuji

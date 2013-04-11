From: "Meng, Jilin" <Jilin.Meng@emc.com>
Subject: RE: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Thu, 11 Apr 2013 03:11:28 +0000
Message-ID: <027526AF93736D4380632CD4F3B42B8002FEAD@MX101CL02.corp.emc.com>
References: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
 <1363923575.16608.17.camel@cirrhata>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hop-nat-141.emc.com ([168.159.213.141]:29638 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752127Ab3DKDMf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 23:12:35 -0400
In-Reply-To: <1363923575.16608.17.camel@cirrhata>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yoshfuji,

Partially you are correct. 
But at least this fix removes the limitation that we must configure the switch for bonding first then host in this case.

-Jilin

-----Original Message-----
From: YOSHIFUJI Hideaki [mailto:yoshfuji@linux-ipv6.org] 
Sent: Friday, March 22, 2013 11:40 AM
To: Meng, Jilin
Cc: davem@davemloft.net; kuznet@ms2.inr.ac.ru; jmorris@namei.org; kaber@trash.net; Sun, Yinglin; Prithviraj, Lakshmanan; netdev@vger.kernel.org
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back

Meng, Jilin wrote:
> we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
> This occurs when a bonding interface with roundrobin mode is being 
> configured an IPv6 address while the switch side isn't configured bonding/channel yet.
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

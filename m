From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] [POWERPC] ucc_geth: Fix build break introduced by commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
Date: Mon, 15 Oct 2007 19:17:58 +0800
Message-ID: <989B956029373F45A0B8AF0297081890019B590C@zch01exm26.fsl.freescale.net>
References: <1192231588-17516-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>,
	<akpm@linux-foundation.org>, <jgarzik@pobox.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:33147 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756437AbXJOLSU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 07:18:20 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id l9FBIGo0026677
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 04:18:16 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id l9FBIF97000800
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 06:18:15 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1192231588-17516-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Medve Emilian-EMMEDVE1 
> Sent: Saturday, October 13, 2007 7:26 AM
> To: akpm@linux-foundation.org; jgarzik@pobox.com; Li 
> Yang-r58472; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
> Cc: Medve Emilian-EMMEDVE1
> Subject: [PATCH] [POWERPC] ucc_geth: Fix build break 
> introduced by commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
> 
> 
>   CC      drivers/net/ucc_geth.o
> drivers/net/ucc_geth.c: In function 'ucc_geth_startup':
> drivers/net/ucc_geth.c:2614: warning: assignment makes 
> integer from pointer without a cast
> drivers/net/ucc_geth.c:2651: warning: assignment makes 
> integer from pointer without a cast
> drivers/net/ucc_geth.c: In function 'ucc_geth_rx':
> drivers/net/ucc_geth.c:3483: error: 'dev' undeclared (first 
> use in this function)
> drivers/net/ucc_geth.c:3483: error: (Each undeclared 
> identifier is reported only once
> drivers/net/ucc_geth.c:3483: error: for each function it appears in.)
> make[2]: *** [drivers/net/ucc_geth.o] Error 1

Thanks for the patch.  Here are some comments.

The patch fixes the dev undeclared compile error not the warnings.  So
they shouldn't be listed here.

> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> ---
> 
> Here is a convenient link for the culprit patch: 
> http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.g
> it;a=commit;h=09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
> 
> netdev-2.6> scripts/checkpatch.pl 
> 0001-POWERPC-ucc_geth-Fix-build-break-introduced-by-co.patch
> Your patch has no obvious style problems and is ready for submission.
> 
>  drivers/net/ucc_geth.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c 
> index d00e7d4..c43d4d1 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -63,7 +63,7 @@
>  #define UGETH_MSG_DEFAULT	(NETIF_MSG_IFUP << 1 ) - 1
>  
>  void uec_set_ethtool_ops(struct net_device *netdev);
> -	
> +
>  static DEFINE_SPINLOCK(ugeth_lock);
>  
>  static struct {

There are quite a few references to the dev structure.  I would prefer
to add a new variable dev here.

- Leo

> @@ -3480,9 +3480,9 @@ static int ucc_geth_rx(struct 
> ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
>  				dev_kfree_skb_any(skb);
>  
>  			
> ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = NULL;
> -			dev->stats.rx_dropped++;
> +			ugeth->dev->stats.rx_dropped++;
>  		} else {
> -			dev->stats.rx_packets++;
> +			ugeth->dev->stats.rx_packets++;
>  			howmany++;
>  
>  			/* Prep the skb for the packet */
> @@ -3491,7 +3491,7 @@ static int ucc_geth_rx(struct 
> ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
>  			/* Tell the skb what kind of packet this is */
>  			skb->protocol = eth_type_trans(skb, ugeth->dev);
>  
> -			dev->stats.rx_bytes += length;
> +			ugeth->dev->stats.rx_bytes += length;
>  			/* Send the packet up the stack */
>  #ifdef CONFIG_UGETH_NAPI
>  			netif_receive_skb(skb);
> @@ -3506,7 +3506,7 @@ static int ucc_geth_rx(struct 
> ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
>  		if (!skb) {
>  			if (netif_msg_rx_err(ugeth))
>  				ugeth_warn("%s: No Rx Data 
> Buffer", __FUNCTION__);
> -			dev->stats.rx_dropped++;
> +			ugeth->dev->stats.rx_dropped++;
>  			break;
>  		}
>  
> --
> 1.5.3.GIT
> 
> 

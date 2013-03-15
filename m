From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: DaVinci platform unable to boot via NFS
Date: Fri, 15 Mar 2013 19:47:35 +0530
Message-ID: <51432D7F.4090001@ti.com>
References: <CA+V-a8sNLBi1zB942ZbK26POrzcq7oOpNW9yPG5dG_gX7ZZ1oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, Daniel Mack <zonque@gmail.com>,
	Mark Jackson <mpfj-list@mimc.co.uk>
To: Prabhakar Lad <prabhakar.csengg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:54289 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753867Ab3COOSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 10:18:07 -0400
In-Reply-To: <CA+V-a8sNLBi1zB942ZbK26POrzcq7oOpNW9yPG5dG_gX7ZZ1oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prabhakar,

On 3/15/2013 7:11 PM, Prabhakar Lad wrote:
> Hi Mugunthan,
> 
> With 3.9 release I am not able to boot any davinci board via nfs, finally
> digging Into I found that there were recent changes for Ethernet davinci.
> Finally I reverting this to some safe commit I was able to boot via nfs.
> I reverted back as following:-
> git checkout  f9a8f83b04e0c362a2fc660dbad980d24af209fc  drivers/net/ethernet/ti/
> 
> Can you please take a look at and fix it.
> 
> Cheers,
> --Prabhakar Lad
> http://in.linkedin.com/pub/prabhakar-lad/19/92b/955
> 

A similar bug was reported on cpsw and the following patch from Daniel 
seems to have helped.

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=d35162f89b8f00537d7b240b76d2d0e8b8d29aa0

I made a similar fix for davinci_emac.c and the resulting diff is below 
(not tested or built).

Can you please check if this helps in DaVinci case?

Thanks,
Sekhar

----8<----
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 52c0536..ae1b77a 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1102,7 +1102,7 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
        /* If there is no more tx desc left free then we need to
         * tell the kernel to stop sending us tx frames.
         */
-       if (unlikely(cpdma_check_free_tx_desc(priv->txchan)))
+       if (unlikely(!cpdma_check_free_tx_desc(priv->txchan)))
                netif_stop_queue(ndev);

        return NETDEV_TX_OK;

From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: mv643xx broken on pegasos
Date: Mon, 19 Jan 2009 10:45:23 +0100
Message-ID: <20090119094523.GE17124@xi.wantstofly.org>
References: <20090115012232.3852.qmail@kosh.dhis.org> <20090115203214.GB18393@deprecation.cyrius.com> <20090118.215911.110220539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tbm@cyrius.com, pacman@kosh.dhis.org, netdev@vger.kernel.org,
	Matt Sealey <matt@genesi-usa.com>,
	Gabriel Paubert <paubert@iram.es>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:55980 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758739AbZASJpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 04:45:24 -0500
Content-Disposition: inline
In-Reply-To: <20090118.215911.110220539.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 09:59:11PM -0800, David Miller wrote:

> > I just noticed that this bug has also been reported on the Pegasos
> > forum: http://www.powerdeveloper.org/forums/viewtopic.php?p=11849
> > The discussion doesn't contain a lot of information, except for this
> > observation:
> > 
> > "I've been bisecting the problem today and the regression is indeed
> > with one of Lennert's changes, but I would certainly not have bet on
> > the innocent looking "mv643xx_eth: use longer DMA bursts" patch (git
> > commit identifier cd4ccf76bfd2c36d351e68be7e6a597268f98a1a).
> > 
> > With this commit reverted, Gb ethernet is working again with kernel
> > 2.6.27 on Pegasos."
> 
> Lennert, please work to resolve this problem.  If you don't
> have time, I'm just going to revert that DMA burst change.

Hi David,

Reverting indeed seems the right thing to do (commit below), but
even with that patch it's apparently still broken in 2.6.28, I'm
still looking into that.


thanks,
Lennert



>From a8907f45652a3a331b83d8b8b830750a5a82ed23 Mon Sep 17 00:00:00 2001
From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 19 Jan 2009 10:33:21 +0100
Subject: [PATCH] Revert "mv643xx_eth: use longer DMA bursts".

This reverts commit cd4ccf76bfd2c36d351e68be7e6a597268f98a1a.

On the Pegasos board, we can't do DMA burst that are longer than
one cache line.  For now, go back to using 32 byte DMA bursts for
all mv643xx_eth platforms -- we can switch the ARM-based platforms
back to doing long 128 byte bursts in the next development cycle.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Reported-by: Alan Curry <pacman@kosh.dhis.org>
Reported-by: Gabriel Paubert <paubert@iram.es>
---
 drivers/net/mv643xx_eth.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 7253a49..e2aa468 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -136,21 +136,23 @@ static char mv643xx_eth_driver_version[] = "1.4";
 /*
  * SDMA configuration register.
  */
+#define RX_BURST_SIZE_4_64BIT		(2 << 1)
 #define RX_BURST_SIZE_16_64BIT		(4 << 1)
 #define BLM_RX_NO_SWAP			(1 << 4)
 #define BLM_TX_NO_SWAP			(1 << 5)
+#define TX_BURST_SIZE_4_64BIT		(2 << 22)
 #define TX_BURST_SIZE_16_64BIT		(4 << 22)
 
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		(RX_BURST_SIZE_16_64BIT	|	\
-		TX_BURST_SIZE_16_64BIT)
+		(RX_BURST_SIZE_4_64BIT	|	\
+		 TX_BURST_SIZE_4_64BIT)
 #elif defined(__LITTLE_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		(RX_BURST_SIZE_16_64BIT	|	\
-		BLM_RX_NO_SWAP		|	\
-		BLM_TX_NO_SWAP		|	\
-		TX_BURST_SIZE_16_64BIT)
+		(RX_BURST_SIZE_4_64BIT	|	\
+		 BLM_RX_NO_SWAP		|	\
+		 BLM_TX_NO_SWAP		|	\
+		 TX_BURST_SIZE_4_64BIT)
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
-- 
1.5.6.4

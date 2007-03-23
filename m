From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH 1/2] mv643xx_eth: Fix use of uninitialized port_num field
Date: Fri, 23 Mar 2007 12:03:52 -0700
Message-ID: <20070323190351.GB28209@xyzzy.farnsworth.org>
References: <20070323123002.GA23436@iram.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel Paubert <paubert@iram.es>,
	Manish Lachwani <mlachwani@mvista.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:4008 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932240AbXCWTD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 15:03:56 -0400
Content-Disposition: inline
In-Reply-To: <20070323123002.GA23436@iram.es>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gabriel Paubert <paubert@iram.es>

In this driver, the default ethernet address is first set by by calling
eth_port_uc_addr_get() which reads the relevant registers of the
corresponding port as initially set by firmware. However that function
used the port_num field accessed through the private area of net_dev
before it was set.

The result was that one board I have ended up with the unicast address
set to 00:00:00:00:00:00 (only port 1 is connected on this board). The
problem appeared after commit 84dd619e4dc3b0b1c40dafd98c90fd950bce7bc5.

This patch fixes the bug by setting mp->port_num prior to calling
eth_port_uc_get_addr().

Signed-off-by: Gabriel Paubert <paubert@iram.es>
Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
---

This fixes a serious bug and should expeditiously pushed upstream.

 drivers/net/mv643xx_eth.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1ee27c3..643ea31 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1379,7 +1379,7 @@ #endif
 
 	spin_lock_init(&mp->lock);
 
-	port_num = pd->port_number;
+	port_num = mp->port_num = pd->port_number;
 
 	/* set default config values */
 	eth_port_uc_addr_get(dev, dev->dev_addr);
@@ -1411,8 +1411,6 @@ #endif
 	duplex = pd->duplex;
 	speed = pd->speed;
 
-	mp->port_num = port_num;
-
 	/* Hook up MII support for ethtool */
 	mp->mii.dev = dev;
 	mp->mii.mdio_read = mv643xx_mdio_read;

From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Fix use of uninitialized field in mv643xx_eth
Date: Fri, 23 Mar 2007 08:38:02 -0700
Message-ID: <20070323153802.GA675@xyzzy.farnsworth.org>
References: <20070323123002.GA23436@iram.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manish Lachwani <mlachwani@mvista.com>, netdev@vger.kernel.org
To: Gabriel Paubert <paubert@iram.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:3018 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934281AbXCWPiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 11:38:05 -0400
Content-Disposition: inline
In-Reply-To: <20070323123002.GA23436@iram.es>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 23, 2007 at 01:30:02PM +0100, Gabriel Paubert wrote:
> In this driver, the default ethernet address is first set by by calling
> eth_port_uc_addr_get() which reads the relevant registers of the 
> corresponding port as initially set by firmware. However that function 
> used the port_num field accessed through the private area of net_dev 
> before it was set.  

Gabriel, you're right.  I introduced the bug and I'm sorry for your
trouble.

> The result was that one board I have ended up with the unicast address 
> set to 00:00:00:00:00:00 (only port 1 is connected on this board). The
> problem appeared after commit 84dd619e4dc3b0b1c40dafd98c90fd950bce7bc5.
> 
> This patch fixes the bug by making eth_port_uc_get_addr() more similar 
> to eth_port_uc_set_addr(), i.e., by using the port number as the first
> parameter instead of a pointer to struct net_device.
> 
> Signed-off-by: Gabriel Paubert <paubert@iram.es>
> 
> --
> 
> The minimal patch I first tried consisted in just moving mp->port_num
> to before the call to eth_port_uc_get_addr().

Hmm.  That should have fixed it.  I reproduced the problem here and
this fixed it for me:

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

Would you please confirm that this fixes it for you?  If so, I'll submit
it upstream as coming from you, since you did all the work.  OK?

> The other question is why
> the driver never gets the info from the device tree on this PPC board,
> but that's for another list despite the fact I lost some time looking 
> for bugs in the OF interface before stumbling on this use of a field
> before it was initialized.

Probably just because the mac address in the hardware was correct and
it didn't seem necessary to overwrite it.

Thank you,
-Dale

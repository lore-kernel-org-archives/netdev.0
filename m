From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Thu, 15 Nov 2007 20:35:08 -0800
Message-ID: <20071115203508.4ad025f2@freepuppy.rosehill>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	<20071115082600.GA2366@ff.dom.local>
	<20071115102005.0cf46f9a@freepuppy.rosehill>
	<473CD1F6.9030709@o2.pl>
	<cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: "Jon Nelson" <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46845 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757192AbXKPEh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 23:37:29 -0500
In-Reply-To: <cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 20:42:55 -0600
"Jon Nelson" <jnelson@jamponi.net> wrote:

> On 11/15/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> ..
> 
> > Sure! I was only worried velocity_open() treats dev->mtu
> > a bit different than velocity_change_mtu(), so eg. after:
> >
> > velocity_change_mtu() // dev is down
> > velocity_open()
> > velocity_change_mtu() // dev is up
> >
> > with the same mtu, vptr->rx_buf_sz could be different than after:
> >
> > velocity_open()
> > velocity_change_mtu() // dev is up
> >
> > But, probably, I miss someting.
> 
> There is a snag here: if I change the MTU after the device is UP
> something ends up rather broken. A tcpdump shows nearly every outgoing
> frame has a bad TCP checksum (and the card does not support H/W
> checksumming or it is turned off as reported by ethtool).
> 

Does this fix the problem.

Note: reading the code the driver has other problems (besides crappy
style). It does pci_map_single()/unmap in a way that doesn't account
correctly for the padding that was added.

--- a/drivers/net/via-velocity.c	2007-11-15 20:11:12.000000000 -0800
+++ b/drivers/net/via-velocity.c	2007-11-15 20:32:14.000000000 -0800
@@ -1242,6 +1242,9 @@ static int velocity_rx_refill(struct vel
 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
 	int ret;
+	int mtu = vptr->dev->mtu;
+
+	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
 
 	vptr->rd_info = kcalloc(vptr->options.numrx,
 				sizeof(struct velocity_rd_info), GFP_KERNEL);
@@ -1898,8 +1901,6 @@ static int velocity_open(struct net_devi
 	struct velocity_info *vptr = netdev_priv(dev);
 	int ret;
 
-	vptr->rx_buf_sz = (dev->mtu <= 1504 ? PKT_BUF_SZ : dev->mtu + 32);
-
 	ret = velocity_init_rings(vptr);
 	if (ret < 0)
 		goto out;
@@ -1978,12 +1979,6 @@ static int velocity_change_mtu(struct ne
 		velocity_free_rd_ring(vptr);
 
 		dev->mtu = new_mtu;
-		if (new_mtu > 8192)
-			vptr->rx_buf_sz = 9 * 1024;
-		else if (new_mtu > 4096)
-			vptr->rx_buf_sz = 8192;
-		else
-			vptr->rx_buf_sz = 4 * 1024;
 
 		ret = velocity_init_rd_ring(vptr);
 		if (ret < 0)


-- 
Stephen Hemminger <shemminger@linux-foundation.org>

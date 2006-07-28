From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 28 Jul 2006 21:49:33 +0200
Message-ID: <20060728194933.GA14222@electric-eye.fr.zoreil.com>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060728104946.GA6710@electric-eye.fr.zoreil.com> <20060728111534.GD25854@xi.wantstofly.org> <20060728115237.GF21733@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:4062 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1161190AbWG1Ttp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 15:49:45 -0400
To: Martin Michlmayr <tbm@cyrius.com>
Content-Disposition: inline
In-Reply-To: <20060728115237.GF21733@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Michlmayr <tbm@cyrius.com> :
[...]
> Here's the output using the r8169 driver:
> 
> RealTek RTL-8110 registers:
> ------------------------------

The (untested) patch below should apply to the source code that Realtek
included in linux-r1000(103).zip, wherence supporting the extraction
of the same info.

--- r1000/src/r1000_ioctl.c	2006-07-28 21:35:25.000000000 +0200
+++ r1000/src/r1000_ioctl.c	2006-07-28 21:38:17.000000000 +0200
@@ -4,6 +4,27 @@ extern int R1000_READ_GMII_REG(unsigned 
 extern int R1000_WRITE_GMII_REG(unsigned long ioaddr, int RegAddr, int value);
 extern int r1000_set_speed_duplex(unsigned long ioaddr, unsigned long anar, unsigned long gbcr, unsigned long bmcr);
 
+#define R1000_REGS_SIZE 256
+
+static int r1000_get_regs_len(struct net_device *dev)
+{
+	return R1000_REGS_SIZE;
+}
+
+static void r1000_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			   void *p)
+{
+	struct r1000_private *priv = netdev_priv(dev);
+	unsigned long flags;
+
+	if (regs->len > R1000_REGS_SIZE)
+		regs->len = R1000_REGS_SIZE;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	memcpy_fromio(p, (void __iomem *)priv->ioaddr, regs->len);
+	spin_unlock_irqrestore(&priv->lock, flags);
+}
+
 static int ethtool_get_settings(struct net_device *netdev,struct ethtool_cmd *ecmd){
 	struct r1000_private *priv = (struct r1000_private *)(netdev->priv);
 	unsigned long ioaddr = priv->ioaddr;
@@ -136,6 +157,8 @@ int ethtool_ioctl(struct ifreq *ifr){
 
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,0)
 struct ethtool_ops r1000_ethtool_ops = {
+	.get_regs_len	= r1000_get_regs_len,
+	.get_regs	= r1000_get_regs,
 	.get_settings	= ethtool_get_settings,
 	.set_settings	= ethtool_set_settings,
 };

From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: RFC: dsa slave open handling
Date: Mon, 07 Mar 2011 17:46:08 +0100
Message-ID: <871v2inajz.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, buytenh@wantstofly.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61709 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab1CGQqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 11:46:21 -0500
Received: by wyg36 with SMTP id 36so4328145wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 08:46:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently the state of the dsa master device and slave devices are not
synchronized which leads to various issues. With dsa, the master device
needs to be running before you can use the slave devices, but it
shouldn't be used directly for I/O.

As an example, I have a device with a single network interface connected
to a mv88e6060 switch. This is nicely handled through dsa, but with this
setup, IP autoconfiguration doesn't work:

If you boot with ip=on (E.G. use any device) eth0 is first brought up
and then the dsa slave devices. DHCP/bootp requests are sent out on both
the dsa slaves and the master eth0 interface. This is not optimal as the
mv88e6060 uses the trailer tag format, so it ends up stripping the
trailing 4 bytes of the requests sent directly on eth0 (and then sends
out on port 0), which leads to invalid UDP checksum, but that's worse -
Once a reply has been received on one of the dsa ports, autoconfig
closes all other devices including eth0, which also brings down the dsa
ports so nfs mount fails.

If on the other hand you boot with ip=:::::<dsa port name>
(E.G. explicitly force autoconfig to use that port), then it fails when
it tries to open the device because eth0 isn't up:

static int dsa_slave_open(struct net_device *dev)
{
	struct dsa_slave_priv *p = netdev_priv(dev);
	struct net_device *master = p->parent->dst->master_netdev;
	int err;

	if (!(master->flags & IFF_UP))
		return -ENETDOWN;


How should this preferably be handled? We could either automatically
bring up the master device whenever a dsa slave is brought up:

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 64ca2a6..dfc7558 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -63,8 +63,9 @@ static int dsa_slave_open(struct net_device *dev)
        struct net_device *master = p->parent->dst->master_netdev;
        int err;
 
-       if (!(master->flags & IFF_UP))
-               return -ENETDOWN;
+       err = dev_change_flags(master, master->flags | IFF_UP);
+       if (err < 0)
+               return err;
 
        if (compare_ether_addr(dev->dev_addr, master->dev_addr)) {
                err = dev_uc_add(master, dev->dev_addr);

      dev_change_flags(master, master->flags | IFF_UP);

Or we could simply handle it in ipconfig by not closing dsa master devices:

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 2b09775..4d4474b 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -277,6 +277,11 @@ static void __init ic_close_devs(void)
                next = d->next;
                dev = d->dev;
                if (dev != ic_dev) {
+#ifdef CONFIG_NET_DSA
+                       /* master device might be needed for dsa access */
+                       if (dev->dsa_ptr)
+                               continue;
+#endif
                        DBG(("IP-Config: Downing %s\n", dev->name));
                        dev_change_flags(dev, d->flags);
                }

Which is preferred?

-- 
Bye, Peter Korsgaard

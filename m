From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC/PATCH] Add support for setting net_device flags via RTM_SETLINK
Date: Mon, 23 Aug 2004 23:16:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823211611.GC19921@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

The patch below extends RTM_SETLINK to change net_device flags if
a new value is provided via ifinfomsg and modifies the way flags
are shown to userspace to maintain balance and only show flags
which can be modified (as in ioctl handlers):

The change in behaviour:

old:
    r->ifi_flags = dev->flags;

    if (!netif_running(dev) || !netif_carrier_ok(dev))
        r->ifi_flags &= ~IFF_RUNNING;
    else
        r->ifi_flags |= IFF_RUNNING;

new:
    flags = (dev->flags & ~(IFF_PROMISC | IFF_ALLMULTI | IFF_RUNNING)) | 
            (dev->gflags & (IFF_PROMISC | IFF_ALLMULTI));

    if (netif_running(dev) && netif_carrier_ok(dev))
        flags |= IFF_RUNNING;

I will implement the 2 hidden flags IFF_PROMISC and IFF_ALLMULTI as separate
message attributes (IFLA_PROMISC and IFLA_ALLMULTI) as soon as I get some
comments on this idea.


--- 1.20/net/core/rtnetlink.c	Sun Aug 22 18:11:03 2004
+++ 1.21/net/core/rtnetlink.c	Mon Aug 23 22:32:39 2004
@@ -166,14 +166,9 @@
 	r->ifi_family = AF_UNSPEC;
 	r->ifi_type = dev->type;
 	r->ifi_index = dev->ifindex;
-	r->ifi_flags = dev->flags;
+	r->ifi_flags = dev_get_flags(dev);
 	r->ifi_change = change;
 
-	if (!netif_running(dev) || !netif_carrier_ok(dev))
-		r->ifi_flags &= ~IFF_RUNNING;
-	else
-		r->ifi_flags |= IFF_RUNNING;
-
 	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
 	RTA_PUT(skb, IFLA_TXQLEN, sizeof(unsigned long), &dev->tx_queue_len);
 	if (dev->addr_len) {
@@ -246,6 +241,9 @@
 		return -ENODEV;
 
 	err = -EINVAL;
+
+	if (ifm->ifi_flags)
+		dev_change_flags(dev, ifm->ifi_flags);
 
 	if (ida[IFLA_ADDRESS - 1]) {
 		if (!dev->set_mac_address) {

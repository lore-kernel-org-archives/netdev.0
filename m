From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [RFC, PATCH]: Pass link level header from/to PPP interface
Date: 10 Feb 2008 10:48:51 +0100
Message-ID: <ygfprv55egs.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:57542 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbYBJJuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Feb 2008 04:50:05 -0500
Received: from oker.escape.de (localhost [127.0.0.1])
	(envelope-sender: urs@isnogud.escape.de)
	by oker.escape.de (8.13.4/8.13.4/$Revision: 1.72 $) with ESMTP id m1A9o3jW008670
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 10:50:03 +0100
Received: (from uucp@localhost)
	by oker.escape.de (8.13.4/8.13.4/Submit) with UUCP id m1A9o31j008625
	for netdev@vger.kernel.org; Sun, 10 Feb 2008 10:50:03 +0100
Received: from janus.isnogud.escape.de (localhost [127.0.0.1])
	by janus.isnogud.escape.de (8.13.8/8.13.8) with ESMTP id m1A9mpHx001741
	for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 10:48:51 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPP interface strips off the PPP header from the packet before
passing it up with netif_rx().  On the xmit path, it has to add the
PPP header itself because dev->header_ops is NULL.

This means that a PF_PACKET, SOCK_RAW socket can't get the link level
header and has to use the sll_protocol field of the sockaddr_ll to
know what type of packet is received with recvfrom(2).  I consider
this a design flaw since with most (all?) other interfaces you only
need to know the sll_hatype to know what type of packet you get.

I have patched the PPP code to include the PPP header.  I tried with
IP and IPv6 over PPP and it works as expected.  This patch, however,
changes the interface to the user space in an incompatible way.  But
IMHO we could include it, since

* PF_PACKET is Linux specific and not portable anyway.  Most apps use
  libpcap instead of opening PF_PACKET sockets themselves.

* Using strace on tcpdump, it seems that libpcap on Linux uses
  PF_PACKET/SOCK_DGRAM for PPP interfaces and thus is not affected by
  my patch.

* Other apps using PF_PACKET/SOCK_RAW can easily be changed to
  PF_PACKET/SOCK_DGRAM if they don't want to see the link level
  header.  After all, this is what SOCK_DGRAM is for.

Currently SOCK_RAW and SOCK_DGRAM are the same although the packet(7)
man page states that with SOCK_RAW packets are passed without any
changes.  This makes having SOCK_RAW besides SOCK_DGRAM useless for
PPP.

So what is your opinion about this change?


Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

---
 drivers/net/ppp_generic.c |   41 ++++++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 13 deletions(-)

Index: net-2.6/drivers/net/ppp_generic.c
===================================================================
--- net-2.6.orig/drivers/net/ppp_generic.c	2008-02-08 11:09:03.000000000 +0100
+++ net-2.6/drivers/net/ppp_generic.c	2008-02-08 13:27:29.000000000 +0100
@@ -873,12 +873,32 @@
 /*
  * Network interface unit routines.
  */
+
+/* Put the 2-byte PPP protocol number on the front of skb */
+static int ppp_header(struct sk_buff *skb, struct net_device *dev,
+		      unsigned short type,
+		      const void *daddr, const void *saddr, unsigned len)
+{
+	unsigned char *pp;
+	int npi, proto;
+
+	npi = ethertype_to_npindex(ntohs(skb->protocol));
+	if (npi < 0)
+		return -dev->hard_header_len;
+
+	pp = skb_push(skb, 2);
+	proto = npindex_to_proto[npi];
+	pp[0] = proto >> 8;
+	pp[1] = proto;
+
+	return dev->hard_header_len;
+}
+
 static int
 ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ppp *ppp = (struct ppp *) dev->priv;
-	int npi, proto;
-	unsigned char *pp;
+	int npi;
 
 	npi = ethertype_to_npindex(ntohs(skb->protocol));
 	if (npi < 0)
@@ -897,16 +917,6 @@
 		goto outf;
 	}
 
-	/* Put the 2-byte PPP protocol number on the front,
-	   making sure there is room for the address and control fields. */
-	if (skb_cow_head(skb, PPP_HDRLEN))
-		goto outf;
-
-	pp = skb_push(skb, 2);
-	proto = npindex_to_proto[npi];
-	pp[0] = proto >> 8;
-	pp[1] = proto;
-
 	netif_stop_queue(dev);
 	skb_queue_tail(&ppp->file.xq, skb);
 	ppp_xmit_process(ppp);
@@ -969,9 +979,14 @@
 	return err;
 }
 
+static const struct header_ops ppp_header_ops ____cacheline_aligned = {
+	.create		= ppp_header,
+};
+
 static void ppp_setup(struct net_device *dev)
 {
 	dev->hard_header_len = PPP_HDRLEN;
+	dev->header_ops = &ppp_header_ops;
 	dev->mtu = PPP_MTU;
 	dev->addr_len = 0;
 	dev->tx_queue_len = 3;
@@ -1677,10 +1692,10 @@
 			kfree_skb(skb);
 		} else {
 			/* chop off protocol */
+			skb_reset_mac_header(skb);
 			skb_pull_rcsum(skb, 2);
 			skb->dev = ppp->dev;
 			skb->protocol = htons(npindex_to_ethertype[npi]);
-			skb_reset_mac_header(skb);
 			netif_rx(skb);
 			ppp->dev->last_rx = jiffies;
 		}

From: "Simon Barber" <simon@instant802.com>
Subject: [PATCH 2.6.3-bk7] Allow ebtables module to change protocol in netif_receive_skb
Date: Wed, 25 Feb 2004 14:49:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <AC8C1F46CD753F4AAC8F890E35A9EB461C670C@webmail.instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Bart De Schuymer" <bdschuym@pandora.be>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Kernel Mailing List" <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Currently skb->protocol is read before the bridge is called, even though
it's not used until after. Hence if an ebtables module changes the
protocol of a frame the wrong protocol is interpreted.

Simon Barber

--- linux-2.6.3-bk7.orig/net/core/dev.c	2004-02-25 04:19:07.000000000
-0800
+++ linux-2.6.3-bk7/net/core/dev.c	2004-02-25 06:42:11.000000000
-0800
@@ -1725,7 +1725,7 @@
 {
 	struct packet_type *ptype, *pt_prev;
 	int ret = NET_RX_DROP;
-	unsigned short type = skb->protocol;
+	unsigned short type;
 
 	if (!skb->stamp.tv_sec)
 		do_gettimeofday(&skb->stamp);
@@ -1759,6 +1759,7 @@
 	if (__handle_bridge(skb, &pt_prev, &ret))
 		goto out;
 
+	type = skb->protocol;
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15],
list) {
 		if (ptype->type == type &&
 		    (!ptype->dev || ptype->dev == skb->dev)) {

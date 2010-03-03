From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-2.6 PATCH] af_packet: move strict addr_len check right before
 dev_[mc/unicast]_[add/del]
Date: Wed, 3 Mar 2010 07:40:01 +0100
Message-ID: <20100303064001.GB2648@psychotron.redhat.com>
References: <1267578048.14049.11.camel@mj>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org,
	proski@gnu.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711Ab0CCGkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 01:40:19 -0500
Content-Disposition: inline
In-Reply-To: <1267578048.14049.11.camel@mj>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [net-2.6 PATCH] af_packet: move strict addr_len check right before dev_[mc/unicast]_[add/del]

My previous patch 914c8ad2d18b62ad1420f518c0cab0b0b90ab308 incorrectly changed
the length check in packet_mc_add to be more strict. The problem is that
userspace is not filling this field (and it stays zeroed) in case of setting
PACKET_MR_PROMISC or PACKET_MR_ALLMULTI. So move the strict check to the point
in path where the addr_len must be set correctly.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 031a5e6..1612d41 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1688,6 +1688,8 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 {
 	switch (i->type) {
 	case PACKET_MR_MULTICAST:
+		if (i->alen != dev->addr_len)
+			return -EINVAL;
 		if (what > 0)
 			return dev_mc_add(dev, i->addr, i->alen, 0);
 		else
@@ -1700,6 +1702,8 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 		return dev_set_allmulti(dev, what);
 		break;
 	case PACKET_MR_UNICAST:
+		if (i->alen != dev->addr_len)
+			return -EINVAL;
 		if (what > 0)
 			return dev_unicast_add(dev, i->addr);
 		else
@@ -1734,7 +1738,7 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 		goto done;
 
 	err = -EINVAL;
-	if (mreq->mr_alen != dev->addr_len)
+	if (mreq->mr_alen > dev->addr_len)
 		goto done;
 
 	err = -ENOBUFS;

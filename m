From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 5/6] ieee802154: fix dgram socket sendmsg()
Date: Wed, 14 May 2014 17:43:10 +0200
Message-ID: <1400082191-16493-6-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:44114 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755971AbaENPn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 11:43:56 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4EFhok0014439
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 17:43:54 +0200
In-Reply-To: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

802.15.4 datagram sockets do not currently have a compliant sendmsg().
The destination address supplied is always ignored, and in unconnected
mode, packets are broadcast instead of dropped with -EDESTADDRREQ. This
patch fixes 802.15.4 dgram sockets to be compliant, i.e.

 !conn && !msg_name => -EDESTADDRREQ
 !conn &&  msg_name => send to msg_name
  conn && !msg_name => send to connected
  conn &&  msg_name => -EISCONN

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/dgram.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index d95e2e1b..76c7725 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -45,6 +45,7 @@ struct dgram_sock {
 	struct ieee802154_addr dst_addr;
 
 	unsigned int bound:1;
+	unsigned int connected:1;
 	unsigned int want_ack:1;
 };
 
@@ -73,10 +74,7 @@ static int dgram_init(struct sock *sk)
 {
 	struct dgram_sock *ro = dgram_sk(sk);
 
-	ro->dst_addr.mode = IEEE802154_ADDR_LONG;
-	ro->dst_addr.pan_id = cpu_to_le16(IEEE802154_PANID_BROADCAST);
 	ro->want_ack = 1;
-	memset(&ro->dst_addr.extended_addr, 0xff, IEEE802154_ADDR_LEN);
 	return 0;
 }
 
@@ -183,6 +181,7 @@ static int dgram_connect(struct sock *sk, struct sockaddr *uaddr,
 	}
 
 	ieee802154_addr_from_sa(&ro->dst_addr, &addr->addr);
+	ro->connected = 1;
 
 out:
 	release_sock(sk);
@@ -194,10 +193,7 @@ static int dgram_disconnect(struct sock *sk, int flags)
 	struct dgram_sock *ro = dgram_sk(sk);
 
 	lock_sock(sk);
-
-	ro->dst_addr.mode = IEEE802154_ADDR_LONG;
-	memset(&ro->dst_addr.extended_addr, 0xff, IEEE802154_ADDR_LEN);
-
+	ro->connected = 0;
 	release_sock(sk);
 
 	return 0;
@@ -211,6 +207,7 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct sk_buff *skb;
 	struct ieee802154_mac_cb *cb;
 	struct dgram_sock *ro = dgram_sk(sk);
+	struct ieee802154_addr dst_addr;
 	int hlen, tlen;
 	int err;
 
@@ -219,6 +216,11 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 		return -EOPNOTSUPP;
 	}
 
+	if (!ro->connected && !msg->msg_name)
+		return -EDESTADDRREQ;
+	else if (ro->connected && msg->msg_name)
+		return -EISCONN;
+
 	if (!ro->bound)
 		dev = dev_getfirstbyhwtype(sock_net(sk), ARPHRD_IEEE802154);
 	else
@@ -254,8 +256,16 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	cb->type = IEEE802154_FC_TYPE_DATA;
 	cb->ackreq = ro->want_ack;
 
-	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &ro->dst_addr,
-			ro->bound ? &ro->src_addr : NULL, size);
+	if (msg->msg_name) {
+		DECLARE_SOCKADDR(struct sockaddr_ieee802154*, daddr, msg->msg_name);
+
+		ieee802154_addr_from_sa(&dst_addr, &daddr->addr);
+	} else {
+		dst_addr = ro->dst_addr;
+	}
+
+	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &dst_addr,
+			      ro->bound ? &ro->src_addr : NULL, size);
 	if (err < 0)
 		goto out_skb;
 
-- 
1.7.9.5

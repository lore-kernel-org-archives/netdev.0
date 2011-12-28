From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH v2] packet: fix possible dev refcnt leak when bind fail
Date: Wed, 28 Dec 2011 10:53:05 +0800
Message-ID: <CAPgLHd98WPb3ieuka-qT50Va+Fx+YBroF92AfuAmKGW9a8-AKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:59255 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995Ab1L1CxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 21:53:06 -0500
Received: by qadc12 with SMTP id c12so7033670qad.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 18:53:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

If bind is fail when bind is called after set PACKET_FANOUT
sock option, the dev refcnt will leak.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/packet/af_packet.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3891702..d9d4970 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2448,8 +2448,12 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 {
 	struct packet_sock *po = pkt_sk(sk);
 
-	if (po->fanout)
+	if (po->fanout) {
+		if (dev)
+			dev_put(dev);
+
 		return -EINVAL;
+	}
 
 	lock_sock(sk);
 
-- 
1.7.7

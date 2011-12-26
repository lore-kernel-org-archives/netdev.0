From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] packet: fix dev refcnt leak when bind fail
Date: Mon, 26 Dec 2011 17:02:59 +0800
Message-ID: <CAPgLHd9KNN81cPYv3bGzoBwUtnJSAoX4NN0Fh+wNgoHE_t7d=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:41365 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647Ab1LZJDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 04:03:00 -0500
Received: by qcqz2 with SMTP id z2so6492644qcq.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 01:02:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

If bind is fail such as bind is called after set PACKET_FANOUT
sock option, the dev refcnt will leak.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/packet/af_packet.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3891702..b6ac234 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2501,8 +2501,11 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
 	strlcpy(name, uaddr->sa_data, sizeof(name));
 
 	dev = dev_get_by_name(sock_net(sk), name);
-	if (dev)
+	if (dev) {
 		err = packet_do_bind(sk, dev, pkt_sk(sk)->num);
+		if (err)
+			dev_put(dev);
+	}
 	return err;
 }
 
@@ -2530,6 +2533,8 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 			goto out;
 	}
 	err = packet_do_bind(sk, dev, sll->sll_protocol ? : pkt_sk(sk)->num);
+	if (err && dev)
+		dev_put(dev);
 
 out:
 	return err;
-- 
1.7.7

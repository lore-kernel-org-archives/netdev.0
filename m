From: Dan Carpenter <error27@gmail.com>
Subject: [patch] packet: add an unlock on error in fanout_add()
Date: Fri, 8 Jul 2011 10:28:12 +0300
Message-ID: <20110708072812.GX18655@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40272 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab1GHH32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 03:29:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to release the "fanout_mutex" here.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index aec50a1..3cbe950 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -589,8 +589,10 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 			break;
 		}
 	}
-	if (match && match->defrag != defrag)
-		return -EINVAL;
+	if (match && match->defrag != defrag) {
+		err = -EINVAL;
+		goto out_unlock;
+	}
 	if (!match) {
 		match = kzalloc(sizeof(*match), GFP_KERNEL);
 		if (match) {
@@ -626,6 +628,8 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 			}
 		}
 	}
+
+out_unlock:
 	mutex_unlock(&fanout_mutex);
 	return err;
 }

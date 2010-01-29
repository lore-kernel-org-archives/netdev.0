From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] xfrm: avoid spinlock in get_acqseq()
Date: Fri, 29 Jan 2010 15:05:52 +0100
Message-ID: <1264773952.3184.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:56301 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502Ab0A2OF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 09:05:56 -0500
Received: by bwz27 with SMTP id 27so1427354bwz.21
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 06:05:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use atomic_inc_return() in get_acqseq() to avoid taking a spinlock

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 4744b1f..e2aacf0 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3019,12 +3019,11 @@ static int pfkey_send_policy_notify(struct xfrm_policy *xp, int dir, struct km_e
 static u32 get_acqseq(void)
 {
 	u32 res;
-	static u32 acqseq;
-	static DEFINE_SPINLOCK(acqseq_lock);
+	static atomic_t acqseq;
 
-	spin_lock_bh(&acqseq_lock);
-	res = (++acqseq ? : ++acqseq);
-	spin_unlock_bh(&acqseq_lock);
+	do {
+		res = atomic_inc_return(&acqseq);
+	} while (!res);
 	return res;
 }
 



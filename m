From: jamal <hadi@cyberus.ca>
Subject: xfrm: avoid spinlock in get_acqseq() used by xfrm user
Date: Tue, 16 Feb 2010 07:01:22 -0500
Message-ID: <1266321682.6776.254.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Be5vrjv9C/OkRe8EAeza"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f178.google.com ([209.85.221.178]:56103 "EHLO
	mail-qy0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab0BPMB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 07:01:26 -0500
Received: by qyk8 with SMTP id 8so859182qyk.24
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 04:01:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Be5vrjv9C/OkRe8EAeza
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Eric's version fixed it for pfkey. This one is for xfrm user.
I thought about amortizing those two get_acqseq()s but it seems
reasonable to have two of these sequence spaces for the two different
interfaces.

cheers,
jamal


--=-Be5vrjv9C/OkRe8EAeza
Content-Disposition: attachment; filename="xfrmacqseq"
Content-Type: text/plain; name="xfrmacqseq"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit d5168d5addbc999c94aacda8f28a4a173756a72b
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Tue Feb 16 06:51:22 2010 -0500

    xfrm: avoid spinlock in get_acqseq() used by xfrm user
    
    This is in the same spirit as commit 28aecb9d7728dc26bf03ce7925fe622023a83a2a
    by Eric Dumazet.
    Use atomic_inc_return() in get_acqseq() to avoid taking a spinlock
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f50ee9b..96f2088 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1462,12 +1462,12 @@ EXPORT_SYMBOL(xfrm_find_acq_byseq);
 u32 xfrm_get_acqseq(void)
 {
 	u32 res;
-	static u32 acqseq;
-	static DEFINE_SPINLOCK(acqseq_lock);
+	static atomic_t acqseq;
+
+	do {
+		res = atomic_inc_return(&acqseq);
+	} while (!res);
 
-	spin_lock_bh(&acqseq_lock);
-	res = (++acqseq ? : ++acqseq);
-	spin_unlock_bh(&acqseq_lock);
 	return res;
 }
 EXPORT_SYMBOL(xfrm_get_acqseq);

--=-Be5vrjv9C/OkRe8EAeza--


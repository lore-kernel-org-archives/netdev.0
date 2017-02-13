From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] kcm: fix a null pointer dereference in kcm_sendmsg()
Date: Mon, 13 Feb 2017 11:13:16 -0800
Message-ID: <1487013196-2375-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:33775 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdBMTNa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 14:13:30 -0500
Received: by mail-ot0-f195.google.com with SMTP id f9so13083965otd.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 11:13:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 98e3862ca2b1 ("kcm: fix 0-length case for kcm_sendmsg()")
I tried to avoid skb allocation for 0-length case, but missed
a check for NULL pointer in the non EOR case.

Fixes: 98e3862ca2b1 ("kcm: fix 0-length case for kcm_sendmsg()")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/kcm/kcmsock.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 64f0e85..a646f34 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1044,8 +1044,10 @@ static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	} else {
 		/* Message not complete, save state */
 partial_message:
-		kcm->seq_skb = head;
-		kcm_tx_msg(head)->last_skb = skb;
+		if (head) {
+			kcm->seq_skb = head;
+			kcm_tx_msg(head)->last_skb = skb;
+		}
 	}
 
 	KCM_STATS_ADD(kcm->stats.tx_bytes, copied);
-- 
2.5.5

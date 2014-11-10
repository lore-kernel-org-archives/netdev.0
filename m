From: Takashi Iwai <tiwai@suse.de>
Subject: [PATCH resent] net: ppp: Don't call bpf_prog_create() in ppp_lock
Date: Mon, 10 Nov 2014 11:50:21 +0100
Message-ID: <1415616621-3481-1-git-send-email-tiwai@suse.de>
Cc: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linux-ppp@vger.kernel.org,
	Stefan Seyfried <stefan.seyfried@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35479 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676AbaKJKu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 05:50:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ppp_ioctl(), bpf_prog_create() is called inside ppp_lock, which
eventually calls vmalloc() and hits BUG_ON() in vmalloc.c.  This patch
works around the problem by moving the allocation outside the lock.

The bug was revealed by the recent change in net/core/filter.c, as it
allocates via vmalloc() instead of kmalloc() now.

Reported-and-tested-by: Stefan Seyfried <stefan.seyfried@googlemail.com>
Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 drivers/net/ppp/ppp_generic.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 68c3a3f4e0ab..794a47329368 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -755,23 +755,23 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		err = get_filter(argp, &code);
 		if (err >= 0) {
+			struct bpf_prog *pass_filter = NULL;
 			struct sock_fprog_kern fprog = {
 				.len = err,
 				.filter = code,
 			};
 
-			ppp_lock(ppp);
-			if (ppp->pass_filter) {
-				bpf_prog_destroy(ppp->pass_filter);
-				ppp->pass_filter = NULL;
+			err = 0;
+			if (fprog.filter)
+				err = bpf_prog_create(&pass_filter, &fprog);
+			if (!err) {
+				ppp_lock(ppp);
+				if (ppp->pass_filter)
+					bpf_prog_destroy(ppp->pass_filter);
+				ppp->pass_filter = pass_filter;
+				ppp_unlock(ppp);
 			}
-			if (fprog.filter != NULL)
-				err = bpf_prog_create(&ppp->pass_filter,
-						      &fprog);
-			else
-				err = 0;
 			kfree(code);
-			ppp_unlock(ppp);
 		}
 		break;
 	}
@@ -781,23 +781,23 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		err = get_filter(argp, &code);
 		if (err >= 0) {
+			struct bpf_prog *active_filter = NULL;
 			struct sock_fprog_kern fprog = {
 				.len = err,
 				.filter = code,
 			};
 
-			ppp_lock(ppp);
-			if (ppp->active_filter) {
-				bpf_prog_destroy(ppp->active_filter);
-				ppp->active_filter = NULL;
+			err = 0;
+			if (fprog.filter)
+				err = bpf_prog_create(&active_filter, &fprog);
+			if (!err) {
+				ppp_lock(ppp);
+				if (ppp->active_filter)
+					bpf_prog_destroy(ppp->active_filter);
+				ppp->active_filter = active_filter;
+				ppp_unlock(ppp);
 			}
-			if (fprog.filter != NULL)
-				err = bpf_prog_create(&ppp->active_filter,
-						      &fprog);
-			else
-				err = 0;
 			kfree(code);
-			ppp_unlock(ppp);
 		}
 		break;
 	}
-- 
2.1.3

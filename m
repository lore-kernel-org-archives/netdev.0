From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] isdn: Fix a sleep-in-atomic bug
Date: Wed, 31 May 2017 09:40:11 +0800
Message-ID: <1496194811-32297-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: isdn@linux-pingi.de, davem@davemloft.net, geliangtang@gmail.com,
        keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:60916 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdEaBiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 21:38:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver may sleep under a spin lock, the function call path is:
isdn_ppp_mp_receive (acquire the lock)
  isdn_ppp_mp_reassembly
    isdn_ppp_push_higher
      isdn_ppp_decompress
        isdn_ppp_ccp_reset_trans
          isdn_ppp_ccp_reset_alloc_state
            kzalloc(GFP_KERNEL) --> may sleep

To fixed it, the "GFP_KERNEL" is replaced with "GFP_ATOMIC".

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/isdn/i4l/isdn_ppp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index d07dd519..8aa158a 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -2364,7 +2364,7 @@ static struct ippp_ccp_reset_state *isdn_ppp_ccp_reset_alloc_state(struct ippp_s
 		       id);
 		return NULL;
 	} else {
-		rs = kzalloc(sizeof(struct ippp_ccp_reset_state), GFP_KERNEL);
+		rs = kzalloc(sizeof(struct ippp_ccp_reset_state), GFP_ATOMIC);
 		if (!rs)
 			return NULL;
 		rs->state = CCPResetIdle;
-- 
1.7.9.5

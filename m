From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] xfrm: fix policy unreferencing on larval drop
Date: Thu,  6 May 2010 14:52:14 +0300
Message-ID: <1273146734-8022-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:40691 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757477Ab0EFLwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 07:52:43 -0400
Received: by ewy20 with SMTP id 20so1640563ewy.1
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 04:52:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I mistakenly had the error path to use num_pols to decide how
many policies we need to drop (cruft from earlier patch set
version which did not handle socket policies right).

This is wrong since normally we do not keep explicit references
(instead we hold reference to the cache entry which holds references
to policies). drop_pols is set to num_pols if we are holding the
references, so use that. Otherwise we eventually BUG_ON inside
xfrm_policy_destroy due to premature policy deletion.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 31f4ba4..f4ea3a0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1805,7 +1805,7 @@ restart:
 			/* EREMOTE tells the caller to generate
 			 * a one-shot blackhole route. */
 			dst_release(dst);
-			xfrm_pols_put(pols, num_pols);
+			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 			return -EREMOTE;
 		}
-- 
1.6.3.3


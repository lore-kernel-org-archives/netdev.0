From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] Net: qla3xxx, remove sleeping in atomic
Date: Fri, 19 Jun 2009 17:13:32 +0200
Message-ID: <1245424412-15106-1-git-send-email-jirislaby@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
To: linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wellnetcz.com ([212.24.148.102]:59882 "EHLO
	smtp.wellnetcz.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbZFSPNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 11:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, we've found this sleep-inside-spinlock.

The fix below totally untested, please review carefully.

--

We cannot sleep in ql_reset_work under spinlock, unlock before sleep,
relock after.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
---
 drivers/net/qla3xxx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 8a823ec..bbc6d4d 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3837,7 +3837,9 @@ static void ql_reset_work(struct work_struct *work)
 						      16) | ISP_CONTROL_RI));
 			}
 
+			spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 			ssleep(1);
+			spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		} while (--max_wait_time);
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
-- 
1.6.3.2
caught by stanse

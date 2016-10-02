From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] ptp: Fix resource leak in case of error
Date: Sun,  2 Oct 2016 09:04:16 +0200
Message-ID: <1475391856-15046-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A call to 'ida_simple_remove()' is missing in the error handling path.

This as been spotted with the following coccinelle script which tries to
detect missing 'ida_simple_remove()' call in error handling paths.

///////////////
@@
expression x;
identifier l;
@@

*   x = ida_simple_get(...);
    ...
    if (...) {
    ...
    }
    ...
    if (...) {
       ...
       goto l;
    }
    ...
*   l: ... when != ida_simple_remove(...);

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
Compile-tested only
---
 drivers/ptp/ptp_clock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 2e481b9e8ea5..86280b7e41f3 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -263,6 +263,7 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 no_device:
 	mutex_destroy(&ptp->tsevq_mux);
 	mutex_destroy(&ptp->pincfg_mux);
+	ida_simple_remove(&ptp_clocks_map, index);
 no_slot:
 	kfree(ptp);
 no_memory:
-- 
2.7.4

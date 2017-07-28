From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v4 4/4] net: ethernet: ti: cpts: fix fifo read in cpts_find_ts
Date: Fri, 28 Jul 2017 17:30:05 -0500
Message-ID: <20170728223005.21420-5-grygorii.strashko@ti.com>
References: <20170728223005.21420-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728223005.21420-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now the call chain
 cpts_find_ts()
  |- cpts_fifo_read(cpts, CPTS_EV_PUSH)

will stop reading CPTS FIFO if PUSH event is found. But this is not
expected and CPTS FIFI should be completely drained here. This is most
probably copy-paste error and it has no negative impact as CPTS_EV_PUSH
should not be present in FIFO without TS_PUSH request and
cpts_systim_read() and cpts_find_ts() synchronized by spin_lock.

Correct above by calling cpts_fifo_read() with -1 parameter, so it will
read all CPTS event from FIFO.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 95a0076..c2121d2 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -364,7 +364,7 @@ static u64 cpts_find_ts(struct cpts *cpts, struct sk_buff *skb, int ev_type)
 		return 0;
 
 	spin_lock_irqsave(&cpts->lock, flags);
-	cpts_fifo_read(cpts, CPTS_EV_PUSH);
+	cpts_fifo_read(cpts, -1);
 	list_for_each_safe(this, next, &cpts->events) {
 		event = list_entry(this, struct cpts_event, list);
 		if (event_expired(event)) {
-- 
2.10.1

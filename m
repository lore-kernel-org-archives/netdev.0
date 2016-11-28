From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH  v2 09/13] net: ethernet: ti: cpts: clean up event list if event pool is empty
Date: Mon, 28 Nov 2016 17:03:33 -0600
Message-ID: <20161128230337.6731-10-grygorii.strashko@ti.com>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128230337.6731-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>

When a CPTS user does not exit gracefully by disabling cpts
timestamping and leaving a joined multicast group, the system
continues to receive and timestamps the ptp packets which eventually
occupy all the event list entries.  When this happns, the added code
tries to remove some list entries which are expired.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index e743361..1b766eb 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -57,6 +57,26 @@ static int cpts_fifo_pop(struct cpts *cpts, u32 *high, u32 *low)
 	return -1;
 }
 
+static int cpts_purge_events(struct cpts *cpts)
+{
+	struct list_head *this, *next;
+	struct cpts_event *event;
+	int removed = 0;
+
+	list_for_each_safe(this, next, &cpts->events) {
+		event = list_entry(this, struct cpts_event, list);
+		if (event_expired(event)) {
+			list_del_init(&event->list);
+			list_add(&event->list, &cpts->pool);
+			++removed;
+		}
+	}
+
+	if (removed)
+		dev_dbg(cpts->dev, "cpts: event pool cleaned up %d\n", removed);
+	return removed ? 0 : -1;
+}
+
 /*
  * Returns zero if matching event type was found.
  */
@@ -69,10 +89,12 @@ static int cpts_fifo_read(struct cpts *cpts, int match)
 	for (i = 0; i < CPTS_FIFO_DEPTH; i++) {
 		if (cpts_fifo_pop(cpts, &hi, &lo))
 			break;
-		if (list_empty(&cpts->pool)) {
-			pr_err("cpts: event pool is empty\n");
+
+		if (list_empty(&cpts->pool) && cpts_purge_events(cpts)) {
+			dev_err(cpts->dev, "cpts: event pool empty\n");
 			return -1;
 		}
+
 		event = list_first_entry(&cpts->pool, struct cpts_event, list);
 		event->tmo = jiffies + 2;
 		event->high = hi;
-- 
2.10.1

From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v5 07/13] net: ethernet: ti: cpts: clean up event list if event pool is empty
Date: Tue, 6 Dec 2016 18:00:39 -0600
Message-ID: <20161207000045.28333-8-grygorii.strashko@ti.com>
References: <20161207000045.28333-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161207000045.28333-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>

When a CPTS user does not exit gracefully by disabling cpts
timestamping and leaving a joined multicast group, the system
continues to receive and timestamps the ptp packets which eventually
occupy all the event list entries.  When this happns, the added code
tries to remove some list entries which are expired.

Signed-off-by: WingMan Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/cpts.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index d3c1ac5..7ab1fa7 100644
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
+		pr_debug("cpts: event pool cleaned up %d\n", removed);
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
+			pr_err("cpts: event pool empty\n");
 			return -1;
 		}
+
 		event = list_first_entry(&cpts->pool, struct cpts_event, list);
 		event->tmo = jiffies + 2;
 		event->high = hi;
-- 
2.10.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/decnet: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:49:41 -0700
Message-ID: <20171005004941.GA23095@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
Cc: linux-decnet-user@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 net/decnet/dn_dev.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 4d339de56862..92dbaa3f1eae 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1038,14 +1038,14 @@ static void dn_eth_down(struct net_device *dev)
 
 static void dn_dev_set_timer(struct net_device *dev);
 
-static void dn_dev_timer_func(unsigned long arg)
+static void dn_dev_timer_func(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)arg;
-	struct dn_dev *dn_db;
+	struct dn_dev *dn_db = from_timer(dn_db, t, timer);
+	struct net_device *dev;
 	struct dn_ifaddr *ifa;
 
 	rcu_read_lock();
-	dn_db = rcu_dereference(dev->dn_ptr);
+	dev = dn_db->dev;
 	if (dn_db->t3 <= dn_db->parms.t2) {
 		if (dn_db->parms.timer3) {
 			for (ifa = rcu_dereference(dn_db->ifa_list);
@@ -1070,8 +1070,6 @@ static void dn_dev_set_timer(struct net_device *dev)
 	if (dn_db->parms.t2 > dn_db->parms.t3)
 		dn_db->parms.t2 = dn_db->parms.t3;
 
-	dn_db->timer.data = (unsigned long)dev;
-	dn_db->timer.function = dn_dev_timer_func;
 	dn_db->timer.expires = jiffies + (dn_db->parms.t2 * HZ);
 
 	add_timer(&dn_db->timer);
@@ -1100,7 +1098,7 @@ static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
 
 	rcu_assign_pointer(dev->dn_ptr, dn_db);
 	dn_db->dev = dev;
-	init_timer(&dn_db->timer);
+	timer_setup(&dn_db->timer, dn_dev_timer_func, 0);
 
 	dn_db->uptime = jiffies;
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security

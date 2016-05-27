From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 2/2] net: pktgen: Call destroy_hrtimer_on_stack()
Date: Thu, 26 May 2016 17:21:06 -0700
Message-ID: <1464308466-16525-2-git-send-email-linux@roeck-us.net>
References: <1464308466-16525-1-git-send-email-linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464308466-16525-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_DEBUG_OBJECTS_TIMERS=y, hrtimer_init_on_stack() requires
a matching call to destroy_hrtimer_on_stack() to clean up timer
debug objects.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/core/pktgen.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8604ae245960..8b02df0d354d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2245,10 +2245,8 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 	hrtimer_set_expires(&t.timer, spin_until);
 
 	remaining = ktime_to_ns(hrtimer_expires_remaining(&t.timer));
-	if (remaining <= 0) {
-		pkt_dev->next_tx = ktime_add_ns(spin_until, pkt_dev->delay);
-		return;
-	}
+	if (remaining <= 0)
+		goto out;
 
 	start_time = ktime_get();
 	if (remaining < 100000) {
@@ -2273,7 +2271,9 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 	}
 
 	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(end_time, start_time));
+out:
 	pkt_dev->next_tx = ktime_add_ns(spin_until, pkt_dev->delay);
+	destroy_hrtimer_on_stack(&t.timer);
 }
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
-- 
2.5.0

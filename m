From: Mike Danese <mikedanese@google.com>
Subject: [PATCH] net: refactor icmp_global_allow to improve readability and performance.
Date: Thu, 31 Dec 2015 23:58:11 -0800
Message-ID: <1451635091-109673-1-git-send-email-mikedanese@google.com>
Cc: Mike Danese <mikedanese@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can reduce the number of operations performed by icmp_global_allow
and make the routine more readable by refactoring it in two ways:

First, this patch refactors the meaning of the "delta" variable. Before
this change, it meant min("time since last refill of token bucket", HZ).
After this change, it means "time since last refill". The original
definition is required only once but was being calculated twice. The new
meaning is also more intuitive for a variable named "delta".

Second, by calculating "delta" (time since last refill of token bucket)
and "cbr" (token bucket can be refilled) at the beginning of the
routine, we reduce the number of repeated calculations of these two
variables.

There should be no functional difference.

Signed-off-by: Mike Danese <mikedanese@google.com>
---
 net/ipv4/icmp.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 36e2697..4e5942d 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -252,22 +252,21 @@ static struct {
  */
 bool icmp_global_allow(void)
 {
-	u32 credit, delta, incr = 0, now = (u32)jiffies;
+	u32 credit, incr = 0, now = (u32)jiffies;
+	u32 delta = now - icmp_global.stamp;
 	bool rc = false;
+	/* Token bucket can be refilled every (HZ/50) jiffies if necessary. */
+	bool cbr = delta >= HZ / 50;
 
 	/* Check if token bucket is empty and cannot be refilled
 	 * without taking the spinlock.
 	 */
-	if (!icmp_global.credit) {
-		delta = min_t(u32, now - icmp_global.stamp, HZ);
-		if (delta < HZ / 50)
-			return false;
-	}
+	if (!icmp_global.credit && !cbr)
+		return false;
 
 	spin_lock(&icmp_global.lock);
-	delta = min_t(u32, now - icmp_global.stamp, HZ);
-	if (delta >= HZ / 50) {
-		incr = sysctl_icmp_msgs_per_sec * delta / HZ ;
+	if (cbr) {
+		incr = sysctl_icmp_msgs_per_sec * min_t(u32, delta, HZ) / HZ;
 		if (incr)
 			icmp_global.stamp = now;
 	}
-- 
2.5.0

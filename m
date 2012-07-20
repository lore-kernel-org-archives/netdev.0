From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC] net: further seperate dst_entry.__refcnt from cache contention
Date: Fri, 20 Jul 2012 14:46:27 -0500
Message-ID: <1342813587-31601-1-git-send-email-nzimmer@sgi.com>
Cc: Robin.Holt@sgi.com, Nathan Zimmer <nzimmer@sgi.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After some investigation on large machines I found that
dst_entry.__refcnt particpates in false cache sharing issues that show
when scaling past 12 threads who communicate via tcp with loopback addresses.
I adjusted refcnt to be on its own cache line and that helped quite a bit.
But perhaps a bit of a waste of space?  Is there some better way?

Here is some preliminary data I had gathered.  It shows nicely improved scaling.

Threads baseline   afterchange
2       1328.03    1340.67
4       2430.31    2282.09
6       3087.65    3258.12
8       3560.34    4165.88
10      3900.34    4962.28
12      3933.38    5613.76
14      3876.98    6113.85
16      3706.01    6338.00
18      3742.48    6634.77
20      3670.15    6641.25
22      3660.98    6799.55
24      3503.13    6613.45
26      3525.73    6702.67
28      3440.16    6801.27
30      3497.59    6911.52
32      3498.25    6540.06

I should say something about this test.  It is a dead simple test in which a
pair of threads simply pass data to each other.  They were placed in the same
socket to avoid cross node overhead.

CC: "David S. Miller" <davem@davemloft.net> 
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>

---
 include/net/dst.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 8197ead..3898643 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -84,7 +84,7 @@ struct dst_entry {
 	 * input/output/ops or performance tanks badly
 	 */
 	atomic_t		__refcnt;	/* client references	*/
-	int			__use;
+	int			__use	____cacheline_aligned;
 	unsigned long		lastuse;
 	union {
 		struct dst_entry	*next;
-- 
1.6.0.2

From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] net/ceph/osdmap.c: fix undefined behavior when using snprintf()
Date: Tue, 22 Jan 2013 19:20:29 +0000
Message-ID: <1358882429-19066-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable "str" is used as both the source and destination in function
snprintf(), which is undefined behavior based on C11. The original description
in C11 is:
	"If copying takes place between objects that
	overlap, the behavior is undefined."

And, the function of ceph_osdmap_state_str() is to return the osdmap state, so
it should return "doesn't exist" when all the conditions are not satisfied. I
fix it in this patch.

Based on C11, snprintf() does nothing if n==0:
	"If n is zero, nothing is written, and s may be a
	null pointer. Otherwise, output characters beyond
	the n-1st are discarded rather than being written to
	the array, and a null character is written at the
	end of the characters actually written into the
	array."
so I remove the unnecessary check of len (because it is not a busy path and
saves a few lines of code).

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 net/ceph/osdmap.c |   27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
index de73214..3131a99d3 100644
--- a/net/ceph/osdmap.c
+++ b/net/ceph/osdmap.c
@@ -13,26 +13,15 @@
 
 char *ceph_osdmap_state_str(char *str, int len, int state)
 {
-	int flag = 0;
-
-	if (!len)
-		goto done;
-
-	*str = '\0';
-	if (state) {
-		if (state & CEPH_OSD_EXISTS) {
-			snprintf(str, len, "exists");
-			flag = 1;
-		}
-		if (state & CEPH_OSD_UP) {
-			snprintf(str, len, "%s%s%s", str, (flag ? ", " : ""),
-				 "up");
-			flag = 1;
-		}
-	} else {
+	if ((state & CEPH_OSD_EXISTS) && (state & CEPH_OSD_UP))
+		snprintf(str, len, "exists, up");
+	else if (state & CEPH_OSD_EXISTS)
+		snprintf(str, len, "exists");
+	else if (state & CEPH_OSD_UP)
+		snprintf(str, len, "up");
+	else
 		snprintf(str, len, "doesn't exist");
-	}
-done:
+
 	return str;
 }
 
-- 
1.7.10.4

From: Jason Luan <jianhai.luan@oracle.com>
Subject: [PATCH net] xen-netback: add the scenario which now
	beyond the range time_after_eq().
Date: Thu, 17 Oct 2013 01:22:47 +0800
Message-ID: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: annie.li@oracle.com, wei.liu2@citrix.com, ian.campbell@citrix.com,
	Jason Luan <jianhai.luan@oracle.com>, david.vrabel@citrix.com
To: xen-devel@lists.xenproject.org, netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

time_after_eq() only works if the delta is < MAX_ULONG/2.

If netfront sends at a very low rate, the time between subsequent calls
to tx_credit_exceeded() may exceed MAX_ULONG/2 and the test for
timer_after_eq() will be incorrect.  Credit will not be replenished and
the guest may become unable to send (e.g., if prior to the long gap, all
credit was exhausted).

We should add the scenario which now beyond next_credit+MAX_UNLONG/2. Because
the fact now must be not before than expire, time_before(now, expire) == true
will verify the scenario.
    time_after_eq(now, next_credit) || time_before (now, expire)
    ==
    !time_in_range_open(now, expire, next_credit)

Signed-off-by: Jason Luan <jianhai.luan@oracle.com>
---
 drivers/net/xen-netback/netback.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f3e591c..31eedaf 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1194,8 +1194,11 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	if (timer_pending(&vif->credit_timeout))
 		return true;
 
-	/* Passed the point where we can replenish credit? */
-	if (time_after_eq(now, next_credit)) {
+	/* Credit should be replenished when now does not fall into the
+	 * range from expires to next_credit, and time_in_range_open()
+	 * is used to verify whether this case happens.
+	 */
+	if (!time_in_range_open(now, vif->credit_timeout.expires, next_credit)) {
 		vif->credit_timeout.expires = now;
 		tx_add_credit(vif);
 	}
-- 
1.7.6.5

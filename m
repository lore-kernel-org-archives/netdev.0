From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] cnic: don't take the rtnl_read_lock in
	cnic_rcv_netevent
Date: Fri, 30 May 2014 11:00:19 -0400
Message-ID: <1401462019-7958-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

The Cnic driver handles lots of ulp operations in its netdevice event hanlder.
To do this, it accesses the ulp_ops array, which is an rcu protected array.
However, some ulp operations (like bnx2fc_indicate_netevent) try to lock
mutexes, which might sleep (somthing that you can't do while holding rcu read
side locks if you've configured non-preemptive rcu.

Fix this by changing the dereference method.  All accesses to the ulp_ops array
for a cnic dev are modified under the protection of the rtnl lock, and so we can
safely just use rcu_dereference_rtnl, and remove the rcu_read_lock here

Signed-off-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
CC: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
CC: Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
CC: Vasu Dev <vasu.dev-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/broadcom/cnic.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index f58a8b8..bfdb9f0 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5622,12 +5622,11 @@ static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
 {
 	int if_type;
 
-	rcu_read_lock();
 	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
 		struct cnic_ulp_ops *ulp_ops;
 		void *ctx;
 
-		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
+		ulp_ops = rcu_dereference_rtnl(cp->ulp_ops[if_type]);
 		if (!ulp_ops || !ulp_ops->indicate_netevent)
 			continue;
 
@@ -5635,7 +5634,6 @@ static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
 
 		ulp_ops->indicate_netevent(ctx, event, vlan_id);
 	}
-	rcu_read_unlock();
 }
 
 /* netdev event handler */
-- 
1.8.3.1

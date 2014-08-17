From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH v2] cnic: Replace rcu_dereference() with rcu_access_pointer()
Date: Sun, 17 Aug 2014 13:12:09 +0300
Message-ID: <20140817101149.GA3692@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: davem@davemloft.net, mchan@broadcom.com, eddie.wai@broadcom.com,
	joe@perches.com, mingo@kernel.org, peterz@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "rcu_dereference()" calls are used directly in conditions.
Since their return values are never dereferenced it is recommended to use
"rcu_access_pointer()" instead of "rcu_dereference()".
Therefore, this patch makes the replacements.

The following Coccinelle semantic patch was used:
@@
@@

(
 if(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
|
 while(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
)

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
v2: Modified subject line from
 "rcu: Replace rcu_dereference() with rcu_access_pointer()"
 to
 "cnic: Replace rcu_dereference() with rcu_access_pointer()",
 noted by David Miller <davem@davemloft.net>

 drivers/net/ethernet/broadcom/cnic.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 8244e2b..dad9cb7 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -381,7 +381,7 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 			break;
 
 		rcu_read_lock();
-		if (!rcu_dereference(cp->ulp_ops[CNIC_ULP_L4])) {
+		if (!rcu_access_pointer(cp->ulp_ops[CNIC_ULP_L4])) {
 			rc = -ENODEV;
 			rcu_read_unlock();
 			break;
@@ -525,7 +525,7 @@ int cnic_unregister_driver(int ulp_type)
 	list_for_each_entry(dev, &cnic_dev_list, list) {
 		struct cnic_local *cp = dev->cnic_priv;
 
-		if (rcu_dereference(cp->ulp_ops[ulp_type])) {
+		if (rcu_access_pointer(cp->ulp_ops[ulp_type])) {
 			pr_err("%s: Type %d still has devices registered\n",
 			       __func__, ulp_type);
 			read_unlock(&cnic_dev_lock);
@@ -573,7 +573,7 @@ static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
 		mutex_unlock(&cnic_lock);
 		return -EAGAIN;
 	}
-	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
+	if (rcu_access_pointer(cp->ulp_ops[ulp_type])) {
 		pr_err("%s: Type %d has already been registered to this device\n",
 		       __func__, ulp_type);
 		mutex_unlock(&cnic_lock);
-- 
1.9.1

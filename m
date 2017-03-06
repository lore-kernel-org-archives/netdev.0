From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 02/29] drivers,
 firewire: convert fw_node.ref_count from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:49 +0200
Message-ID: <1488810076-3754-3-git-send-email-elena.reshetova@intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, linux-pci@vger.kernel.org,
 target-devel@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 Elena Reshetova <elena.reshetova@intel.com>, devel@driverdev.osuosl.org,
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-serial@vger.kernel.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, Kees Cook <keescook@chromium.org>,
 linux-raid@vger.kernel.org, linux-bcache@vger.kernel.org,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/firewire/core-topology.c | 2 +-
 drivers/firewire/core.h          | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/firewire/core-topology.c b/drivers/firewire/core-topology.c
index 0de8350..939d259 100644
--- a/drivers/firewire/core-topology.c
+++ b/drivers/firewire/core-topology.c
@@ -124,7 +124,7 @@ static struct fw_node *fw_node_create(u32 sid, int port_count, int color)
 	node->initiated_reset = SELF_ID_PHY_INITIATOR(sid);
 	node->port_count = port_count;
 
-	atomic_set(&node->ref_count, 1);
+	refcount_set(&node->ref_count, 1);
 	INIT_LIST_HEAD(&node->link);
 
 	return node;
diff --git a/drivers/firewire/core.h b/drivers/firewire/core.h
index e1480ff6..c07962e 100644
--- a/drivers/firewire/core.h
+++ b/drivers/firewire/core.h
@@ -12,7 +12,7 @@
 #include <linux/slab.h>
 #include <linux/types.h>
 
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 
 struct device;
 struct fw_card;
@@ -184,7 +184,7 @@ struct fw_node {
 			 * local node to this node. */
 	u8 max_depth:4;	/* Maximum depth to any leaf node */
 	u8 max_hops:4;	/* Max hops in this sub tree */
-	atomic_t ref_count;
+	refcount_t ref_count;
 
 	/* For serializing node topology into a list. */
 	struct list_head link;
@@ -197,14 +197,14 @@ struct fw_node {
 
 static inline struct fw_node *fw_node_get(struct fw_node *node)
 {
-	atomic_inc(&node->ref_count);
+	refcount_inc(&node->ref_count);
 
 	return node;
 }
 
 static inline void fw_node_put(struct fw_node *node)
 {
-	if (atomic_dec_and_test(&node->ref_count))
+	if (refcount_dec_and_test(&node->ref_count))
 		kfree(node);
 }
 
-- 
2.7.4

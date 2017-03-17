From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 10/18] net, atm: convert eg_cache_entry.use from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 13:12:51 +0200
Message-ID: <1489749179-12063-11-git-send-email-elena.reshetova@intel.com>
References: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        marcel@holtmann.org, johan.hedberg@gmail.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
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
 net/atm/mpoa_caches.c | 14 +++++++-------
 net/atm/mpoa_caches.h |  2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index 05e89e9..4ccaa16 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -339,7 +339,7 @@ static eg_cache_entry *eg_cache_get_by_cache_id(__be32 cache_id,
 	entry = mpc->eg_cache;
 	while (entry != NULL) {
 		if (entry->ctrl_info.cache_id == cache_id) {
-			atomic_inc(&entry->use);
+			refcount_inc(&entry->use);
 			read_unlock_irq(&mpc->egress_lock);
 			return entry;
 		}
@@ -360,7 +360,7 @@ static eg_cache_entry *eg_cache_get_by_tag(__be32 tag, struct mpoa_client *mpc)
 	entry = mpc->eg_cache;
 	while (entry != NULL) {
 		if (entry->ctrl_info.tag == tag) {
-			atomic_inc(&entry->use);
+			refcount_inc(&entry->use);
 			read_unlock_irqrestore(&mpc->egress_lock, flags);
 			return entry;
 		}
@@ -382,7 +382,7 @@ static eg_cache_entry *eg_cache_get_by_vcc(struct atm_vcc *vcc,
 	entry = mpc->eg_cache;
 	while (entry != NULL) {
 		if (entry->shortcut == vcc) {
-			atomic_inc(&entry->use);
+			refcount_inc(&entry->use);
 			read_unlock_irqrestore(&mpc->egress_lock, flags);
 			return entry;
 		}
@@ -402,7 +402,7 @@ static eg_cache_entry *eg_cache_get_by_src_ip(__be32 ipaddr,
 	entry = mpc->eg_cache;
 	while (entry != NULL) {
 		if (entry->latest_ip_addr == ipaddr) {
-			atomic_inc(&entry->use);
+			refcount_inc(&entry->use);
 			read_unlock_irq(&mpc->egress_lock);
 			return entry;
 		}
@@ -415,7 +415,7 @@ static eg_cache_entry *eg_cache_get_by_src_ip(__be32 ipaddr,
 
 static void eg_cache_put(eg_cache_entry *entry)
 {
-	if (atomic_dec_and_test(&entry->use)) {
+	if (refcount_dec_and_test(&entry->use)) {
 		memset(entry, 0, sizeof(eg_cache_entry));
 		kfree(entry);
 	}
@@ -468,7 +468,7 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 	dprintk("adding an egress entry, ip = %pI4, this should be our IP\n",
 		&msg->content.eg_info.eg_dst_ip);
 
-	atomic_set(&entry->use, 1);
+	refcount_set(&entry->use, 1);
 	dprintk("new_eg_cache_entry: about to lock\n");
 	write_lock_irq(&client->egress_lock);
 	entry->next = client->eg_cache;
@@ -484,7 +484,7 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 	dprintk("new_eg_cache_entry cache_id %u\n",
 		ntohl(entry->ctrl_info.cache_id));
 	dprintk("mps_ip = %pI4\n", &entry->ctrl_info.mps_ip);
-	atomic_inc(&entry->use);
+	refcount_inc(&entry->use);
 
 	write_unlock_irq(&client->egress_lock);
 	dprintk("new_eg_cache_entry: unlocked\n");
diff --git a/net/atm/mpoa_caches.h b/net/atm/mpoa_caches.h
index 38a4e7e..30fe348 100644
--- a/net/atm/mpoa_caches.h
+++ b/net/atm/mpoa_caches.h
@@ -59,7 +59,7 @@ typedef struct eg_cache_entry{
 	uint16_t             entry_state;
 	__be32             latest_ip_addr;    /* The src IP address of the last packet */
 	struct eg_ctrl_info  ctrl_info;
-	atomic_t             use;
+	refcount_t             use;
 } eg_cache_entry;
 
 struct eg_cache_ops{
-- 
2.7.4

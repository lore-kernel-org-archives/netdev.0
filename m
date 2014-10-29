From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] Bluetooth: 6lowpan: use after free in disconnect_devices()
Date: Wed, 29 Oct 2014 19:10:57 +0300
Message-ID: <20141029161057.GF5290@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was accidentally changed from list_for_each_entry_safe() to
list_for_each_entry() so now it has a use after free bug.  I've changed
it back.

Fixes: 90305829635d ('Bluetooth: 6lowpan: Converting rwlocks to use RCU')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 7254bdd..eef298d 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -1383,7 +1383,7 @@ static const struct file_operations lowpan_control_fops = {
 
 static void disconnect_devices(void)
 {
-	struct lowpan_dev *entry, *new_dev;
+	struct lowpan_dev *entry, *tmp, *new_dev;
 	struct list_head devices;
 
 	INIT_LIST_HEAD(&devices);
@@ -1408,7 +1408,7 @@ static void disconnect_devices(void)
 
 	rcu_read_unlock();
 
-	list_for_each_entry(entry, &devices, list) {
+	list_for_each_entry_safe(entry, tmp, &devices, list) {
 		ifdown(entry->netdev);
 		BT_DBG("Unregistering netdev %s %p",
 		       entry->netdev->name, entry->netdev);

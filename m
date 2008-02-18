From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 1/2] bluetooth : put hci dev after del conn
Date: Mon, 18 Feb 2008 15:55:55 +0800
Message-ID: <20080218075555.GA5940@darkstar.te-china.tietoenator.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bluez-devel@lists.sf.net, linux-kernel@vger.kernel.org
To: marcel@holtmann.org
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Move hci_dev_put to del_conn to avoid hci dev going away before hci conn.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 

---
net/bluetooth/hci_conn.c  |    1 -
net/bluetooth/hci_sysfs.c |    5 ++++-
2 files changed, 4 insertions(+), 2 deletions(-)

diff -upr linux/net/bluetooth/hci_conn.c linux.new/net/bluetooth/hci_conn.c
--- linux/net/bluetooth/hci_conn.c	2008-02-16 06:38:56.000000000 +0800
+++ linux.new/net/bluetooth/hci_conn.c	2008-02-16 06:54:17.000000000 +0800
@@ -260,7 +260,6 @@ int hci_conn_del(struct hci_conn *conn)
 	tasklet_enable(&hdev->tx_task);
 	skb_queue_purge(&conn->data_q);
 	hci_conn_del_sysfs(conn);
-	hci_dev_put(hdev);
 
 	return 0;
 }
diff -upr linux/net/bluetooth/hci_sysfs.c linux.new/net/bluetooth/hci_sysfs.c
--- linux/net/bluetooth/hci_sysfs.c	2008-02-16 06:38:56.000000000 +0800
+++ linux.new/net/bluetooth/hci_sysfs.c	2008-02-16 06:54:17.000000000 +0800
@@ -333,15 +333,18 @@ static int __match_tty(struct device *de
 
 static void del_conn(struct work_struct *work)
 {
-	struct device *dev;
 	struct hci_conn *conn = container_of(work, struct hci_conn, work);
+	struct hci_dev *hdev = conn->hdev;
+	struct device *dev;
 
 	while (dev = device_find_child(&conn->dev, NULL, __match_tty)) {
 		device_move(dev, NULL);
 		put_device(dev);
 	}
+
 	device_del(&conn->dev);
 	put_device(&conn->dev);
+	hci_dev_put(hdev);
 }
 
 void hci_conn_del_sysfs(struct hci_conn *conn)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/

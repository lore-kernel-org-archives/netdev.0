From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 3/3] rose: check rose_ndevs earlier
Date: Wed, 28 Sep 2005 02:23:40 +0400
Message-ID: <20050927222340.GC25047@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Don't bother with proto registering if rose_ndevs is bad.
* Make escape structure more coherent.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/rose/af_rose.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

--- linux-rose-002/net/rose/af_rose.c
+++ linux-rose-003/net/rose/af_rose.c
@@ -1472,24 +1472,25 @@ static const char banner[] = KERN_INFO "
 static int __init rose_proto_init(void)
 {
 	int i;
-	int rc = proto_register(&rose_proto, 0);
+	int rc;
 
+	if (rose_ndevs > 0x7FFFFFFF/sizeof(struct net_device *)) {
+		printk(KERN_ERR "ROSE: rose_proto_init - rose_ndevs parameter to large\n");
+		rc = -EINVAL;
+		goto out;
+	}
+
+	rc = proto_register(&rose_proto, 0);
 	if (rc != 0)
 		goto out;
 
 	rose_callsign = null_ax25_address;
 
-	if (rose_ndevs > 0x7FFFFFFF/sizeof(struct net_device *)) {
-		printk(KERN_ERR "ROSE: rose_proto_init - rose_ndevs parameter to large\n");
-		proto_unregister(&rose_proto);
-		return -EINVAL;
-	}
-
 	dev_rose = kmalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
 	if (dev_rose == NULL) {
 		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
-		proto_unregister(&rose_proto);
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto out_proto_unregister;
 	}
 
 	memset(dev_rose, 0x00, rose_ndevs * sizeof(struct net_device*));
@@ -1540,6 +1541,7 @@ fail:
 		free_netdev(dev_rose[i]);
 	}
 	kfree(dev_rose);
+out_proto_unregister:
 	proto_unregister(&rose_proto);
 	goto out;
 }


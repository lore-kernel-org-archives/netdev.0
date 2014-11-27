From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v6 37/46] tun: move internal flag defines out of uapi
Date: Thu, 27 Nov 2014 22:10:54 +0200
Message-ID: <1417118789-18231-38-git-send-email-mst@redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	netdev@vger.kernel.org, linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417118789-18231-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TUN_ flags are internal and never exposed
to userspace. Any application using it is almost
certainly buggy.

Move them out to tun.c, we'll remove them in follow-up patches.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/uapi/linux/if_tun.h | 16 ++--------
 drivers/net/tun.c           | 74 ++++++++++++++-------------------------------
 2 files changed, 26 insertions(+), 64 deletions(-)

diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index e9502dd..277a260 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -22,21 +22,11 @@
 
 /* Read queue size */
 #define TUN_READQ_SIZE	500
-
-/* TUN device flags */
-#define TUN_TUN_DEV 	0x0001	
-#define TUN_TAP_DEV	0x0002
+/* TUN device type flags: deprecated. Use IFF_TUN/IFF_TAP instead. */
+#define TUN_TUN_DEV 	IFF_TUN
+#define TUN_TAP_DEV	IFF_TAP
 #define TUN_TYPE_MASK   0x000f
 
-#define TUN_FASYNC	0x0010
-#define TUN_NOCHECKSUM	0x0020
-#define TUN_NO_PI	0x0040
-/* This flag has no real effect */
-#define TUN_ONE_QUEUE	0x0080
-#define TUN_PERSIST 	0x0100	
-#define TUN_VNET_HDR 	0x0200
-#define TUN_TAP_MQ      0x0400
-
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
 #define TUNSETDEBUG   _IOW('T', 201, int) 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9dd3746..bc89d07 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -103,6 +103,21 @@ do {								\
 } while (0)
 #endif
 
+/* TUN device flags */
+
+/* IFF_ATTACH_QUEUE is never stored in device flags,
+ * overload it to mean fasync when stored there.
+ */
+#define TUN_FASYNC	IFF_ATTACH_QUEUE
+#define TUN_NO_PI	IFF_NO_PI
+/* This flag has no real effect */
+#define TUN_ONE_QUEUE	IFF_ONE_QUEUE
+#define TUN_PERSIST 	IFF_PERSIST
+#define TUN_VNET_HDR 	IFF_VNET_HDR
+#define TUN_TAP_MQ      IFF_MULTI_QUEUE
+
+#define TUN_FEATURES (IFF_NO_PI | IFF_ONE_QUEUE | IFF_VNET_HDR | \
+		      IFF_MULTI_QUEUE)
 #define GOODCOPY_LEN 128
 
 #define FLT_EXACT_COUNT 8
@@ -1521,32 +1536,7 @@ static struct proto tun_proto = {
 
 static int tun_flags(struct tun_struct *tun)
 {
-	int flags = 0;
-
-	if (tun->flags & TUN_TUN_DEV)
-		flags |= IFF_TUN;
-	else
-		flags |= IFF_TAP;
-
-	if (tun->flags & TUN_NO_PI)
-		flags |= IFF_NO_PI;
-
-	/* This flag has no real effect.  We track the value for backwards
-	 * compatibility.
-	 */
-	if (tun->flags & TUN_ONE_QUEUE)
-		flags |= IFF_ONE_QUEUE;
-
-	if (tun->flags & TUN_VNET_HDR)
-		flags |= IFF_VNET_HDR;
-
-	if (tun->flags & TUN_TAP_MQ)
-		flags |= IFF_MULTI_QUEUE;
-
-	if (tun->flags & TUN_PERSIST)
-		flags |= IFF_PERSIST;
-
-	return flags;
+	return tun->flags & (TUN_FEATURES | IFF_PERSIST | IFF_TUN | IFF_TAP);
 }
 
 static ssize_t tun_show_flags(struct device *dev, struct device_attribute *attr,
@@ -1706,28 +1696,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
 
-	if (ifr->ifr_flags & IFF_NO_PI)
-		tun->flags |= TUN_NO_PI;
-	else
-		tun->flags &= ~TUN_NO_PI;
-
-	/* This flag has no real effect.  We track the value for backwards
-	 * compatibility.
-	 */
-	if (ifr->ifr_flags & IFF_ONE_QUEUE)
-		tun->flags |= TUN_ONE_QUEUE;
-	else
-		tun->flags &= ~TUN_ONE_QUEUE;
-
-	if (ifr->ifr_flags & IFF_VNET_HDR)
-		tun->flags |= TUN_VNET_HDR;
-	else
-		tun->flags &= ~TUN_VNET_HDR;
-
-	if (ifr->ifr_flags & IFF_MULTI_QUEUE)
-		tun->flags |= TUN_TAP_MQ;
-	else
-		tun->flags &= ~TUN_TAP_MQ;
+	tun->flags = (tun->flags & ~TUN_FEATURES) |
+		(ifr->ifr_flags & TUN_FEATURES);
 
 	/* Make sure persistent devices do not get stuck in
 	 * xoff state.
@@ -1890,9 +1860,11 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	if (cmd == TUNGETFEATURES) {
 		/* Currently this just means: "what IFF flags are valid?".
 		 * This is needed because we never checked for invalid flags on
-		 * TUNSETIFF. */
-		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR | IFF_MULTI_QUEUE,
+		 * TUNSETIFF.  Why do we report IFF_TUN and IFF_TAP which are
+		 * not legal for TUNSETIFF here?  It's probably a bug, but it
+		 * doesn't seem to be worth fixing.
+		 */
+		return put_user(IFF_TUN | IFF_TAP | TUN_FEATURES,
 				(unsigned int __user*)argp);
 	} else if (cmd == TUNSETQUEUE)
 		return tun_set_queue(file, &ifr);
-- 
MST

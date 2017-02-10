From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/2] afs: Use core kernel UUID generation
Date: Fri, 10 Feb 2017 16:46:26 +0000
Message-ID: <148674518601.6350.4805771073111871364.stgit@warthog.procyon.org.uk>
References: <148674517199.6350.17724845267620917182.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148674517199.6350.17724845267620917182.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

AFS uses a time based UUID to identify the host itself.  This requires
getting a timestamp which is currently done through the getnstimeofday()
interface that we want to eventually get rid of.

Instead of replacing it with a ktime-based interface, simply remove the
entire function and use generate_random_uuid() instead, which has a v4
("completely random") UUID instead of the time-based one.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/internal.h   |   11 +++++------
 fs/afs/main.c       |   48 +-----------------------------------------------
 fs/afs/netdevices.c |   21 ---------------------
 3 files changed, 6 insertions(+), 74 deletions(-)

diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 79061fa17168..8acf3670e756 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -561,6 +561,11 @@ extern int afs_mntpt_check_symlink(struct afs_vnode *, struct key *);
 extern void afs_mntpt_kill_timer(void);
 
 /*
+ * netdevices.c
+ */
+extern int afs_get_ipv4_interfaces(struct afs_interface *, size_t, bool);
+
+/*
  * proc.c
  */
 extern int afs_proc_init(void);
@@ -624,12 +629,6 @@ extern int afs_fs_init(void);
 extern void afs_fs_exit(void);
 
 /*
- * use-rtnetlink.c
- */
-extern int afs_get_ipv4_interfaces(struct afs_interface *, size_t, bool);
-extern int afs_get_MAC_address(u8 *, size_t);
-
-/*
  * vlclient.c
  */
 extern int afs_vl_get_entry_by_name(struct in_addr *, struct key *,
diff --git a/fs/afs/main.c b/fs/afs/main.c
index a07c14df3fd1..51d7d17bca57 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -35,50 +35,6 @@ struct uuid_v1 afs_uuid;
 struct workqueue_struct *afs_wq;
 
 /*
- * get a client UUID
- */
-static int __init afs_get_client_UUID(void)
-{
-	struct timespec ts;
-	u64 uuidtime;
-	u16 clockseq, hi_v;
-	int ret;
-
-	/* read the MAC address of one of the external interfaces and construct
-	 * a UUID from it */
-	ret = afs_get_MAC_address(afs_uuid.node, sizeof(afs_uuid.node));
-	if (ret < 0)
-		return ret;
-
-	getnstimeofday(&ts);
-	uuidtime = (u64) ts.tv_sec * 1000 * 1000 * 10;
-	uuidtime += ts.tv_nsec / 100;
-	uuidtime += UUID_TO_UNIX_TIME;
-	afs_uuid.time_low = htonl(uuidtime);
-	afs_uuid.time_mid = htons(uuidtime >> 32);
-	hi_v = (uuidtime >> 48) & UUID_TIMEHI_MASK;
-	hi_v |= UUID_VERSION_TIME;
-	afs_uuid.time_hi_and_version = htons(hi_v);
-
-	get_random_bytes(&clockseq, 2);
-	afs_uuid.clock_seq_low = clockseq;
-	afs_uuid.clock_seq_hi_and_reserved =
-		(clockseq >> 8) & UUID_CLOCKHI_MASK;
-	afs_uuid.clock_seq_hi_and_reserved |= UUID_VARIANT_STD;
-
-	_debug("AFS UUID: %08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
-	       ntohl(afs_uuid.time_low),
-	       ntohs(afs_uuid.time_mid),
-	       ntohs(afs_uuid.time_hi_and_version),
-	       afs_uuid.clock_seq_hi_and_reserved,
-	       afs_uuid.clock_seq_low,
-	       afs_uuid.node[0], afs_uuid.node[1], afs_uuid.node[2],
-	       afs_uuid.node[3], afs_uuid.node[4], afs_uuid.node[5]);
-
-	return 0;
-}
-
-/*
  * initialise the AFS client FS module
  */
 static int __init afs_init(void)
@@ -87,9 +43,7 @@ static int __init afs_init(void)
 
 	printk(KERN_INFO "kAFS: Red Hat AFS client v0.1 registering.\n");
 
-	ret = afs_get_client_UUID();
-	if (ret < 0)
-		return ret;
+	generate_random_uuid((unsigned char *)&afs_uuid);
 
 	/* create workqueue */
 	ret = -ENOMEM;
diff --git a/fs/afs/netdevices.c b/fs/afs/netdevices.c
index 7ad36506c256..40b2bab3e401 100644
--- a/fs/afs/netdevices.c
+++ b/fs/afs/netdevices.c
@@ -12,27 +12,6 @@
 #include "internal.h"
 
 /*
- * get a MAC address from a random ethernet interface that has a real one
- * - the buffer will normally be 6 bytes in size
- */
-int afs_get_MAC_address(u8 *mac, size_t maclen)
-{
-	struct net_device *dev;
-	int ret = -ENODEV;
-
-	BUG_ON(maclen != ETH_ALEN);
-
-	rtnl_lock();
-	dev = __dev_getfirstbyhwtype(&init_net, ARPHRD_ETHER);
-	if (dev) {
-		memcpy(mac, dev->dev_addr, maclen);
-		ret = 0;
-	}
-	rtnl_unlock();
-	return ret;
-}
-
-/*
  * get a list of this system's interface IPv4 addresses, netmasks and MTUs
  * - maxbufs must be at least 1
  * - returns the number of interface records in the buffer

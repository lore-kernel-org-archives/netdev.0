From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.69] pktgen module and dev cleanup
Date: Wed, 7 May 2003 14:29:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507142911.4a8a7573.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix pktgen so the /proc interface uses owner instead of inc/dec the
module ref count itself.  Gets rid of warnings, and properly ref counts
all readers/writers now.

Change how network device ref count is acquired. Instead of forced inc,
just get reference via dev_get_by_name. 

Use in_dev_get when looking at inet info, more race avoidance.

Built and tested with injection on gigabit ethernet and SMP machine.
Ref counts come out right during access, and can be unloaded fine.

diff -Nru a/net/core/pktgen.c b/net/core/pktgen.c
--- a/net/core/pktgen.c	Wed May  7 14:21:14 2003
+++ b/net/core/pktgen.c	Wed May  7 14:21:14 2003
@@ -226,21 +226,20 @@
 {
 	struct net_device *odev;
 
-	rtnl_lock();
-	odev = __dev_get_by_name(info->outdev);
+	odev = dev_get_by_name(info->outdev);
 	if (!odev) {
 		sprintf(info->result, "No such netdevice: \"%s\"", info->outdev);
-		goto out_unlock;
+		goto out;
 	}
 
 	if (odev->type != ARPHRD_ETHER) {
 		sprintf(info->result, "Not ethernet device: \"%s\"", info->outdev);
-		goto out_unlock;
+		goto out_put;
 	}
 
 	if (!netif_running(odev)) {
 		sprintf(info->result, "Device is down: \"%s\"", info->outdev);
-		goto out_unlock;
+		goto out_put;
 	}
 
 	/* Default to the interface's mac if not explicitly set. */
@@ -257,13 +256,13 @@
 	info->saddr_min = 0;
 	info->saddr_max = 0;
 	if (strlen(info->src_min) == 0) {
-		if (odev->ip_ptr) {
-			struct in_device *in_dev = odev->ip_ptr;
-
+		struct in_device *in_dev = in_dev_get(odev);
+		if (in_dev) {
 			if (in_dev->ifa_list) {
 				info->saddr_min = in_dev->ifa_list->ifa_address;
 				info->saddr_max = info->saddr_min;
 			}
+			in_dev_put(in_dev);
 		}
 	}
 	else {
@@ -282,13 +281,11 @@
 	info->cur_udp_dst = info->udp_dst_min;
 	info->cur_udp_src = info->udp_src_min;
 	
-	atomic_inc(&odev->refcnt);
-	rtnl_unlock();
-
 	return odev;
 
-out_unlock:
-	rtnl_unlock();
+out_put:
+	dev_put(odev);
+out:
 	return NULL;
 }
 
@@ -1258,7 +1255,6 @@
 	}
 
 	if (!strcmp(name, "inject") || !strcmp(name, "start")) {
-		MOD_INC_USE_COUNT;
 		if (info->busy) {
 			strcpy(info->result, "Already running...\n");
 		}
@@ -1268,7 +1264,6 @@
 			inject(info);
 			info->busy = 0;
 		}
-		MOD_DEC_USE_COUNT;
 		return count;
 	}
 
@@ -1337,6 +1332,7 @@
 		pginfos[i].proc_ent->read_proc = proc_read;
 		pginfos[i].proc_ent->write_proc = proc_write;
 		pginfos[i].proc_ent->data = (void*)(long)(i);
+		pginfos[i].proc_ent->owner = THIS_MODULE;
 
 		sprintf(pginfos[i].busy_fname, "net/%s/pg_busy%i",  PG_PROC_DIR, i);
 		pginfos[i].busy_proc_ent = create_proc_entry(pginfos[i].busy_fname, 0, 0);

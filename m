From: Simon Horman <horms@verge.net.au>
Subject: [patch 1/2] ipvs: Flag synced connections and expose them in proc
Date: Wed, 14 Nov 2007 10:24:40 -0800
Message-ID: <20071114182717.864165392@natsuko.shinjuku.tokyo.vergenet.net>
References: <20071114182439.821730508@natsuko.shinjuku.tokyo.vergenet.net>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	jmack@wm7d.net, graeme@graemef.net,
	Rumen Bogdanovski <rumen@voicecho.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36813 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbXKNS3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:29:07 -0500
Content-Disposition: inline; filename=ipvs-showsync.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rumen Bogdanovski <rumen@voicecho.com>

This patch labels the sync-created connections with IP_VS_CONN_F_SYNC
flag and creates /proc/net/ip_vs_conn_sync to enable monitoring of the
origin of the connections, if they are local or created by the 
synchronization.

Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

diff -Naur net-2.6_orig/net/ipv4/ipvs/ip_vs_conn.c net-2.6_work/net/ipv4/ipvs/ip_vs_conn.c
--- net-2.6_orig/net/ipv4/ipvs/ip_vs_conn.c	2007-11-13 12:37:07.000000000 +0200
+++ net-2.6_work/net/ipv4/ipvs/ip_vs_conn.c	2007-11-13 21:57:58.000000000 +0200
@@ -783,6 +783,57 @@
 	.llseek  = seq_lseek,
 	.release = seq_release,
 };
+
+static const char *ip_vs_origin_name(unsigned flags)
+{
+	if (flags & IP_VS_CONN_F_SYNC)
+		return "SYNC";
+	else
+		return "LOCAL";
+}
+
+static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
+{
+
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq,
+   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Origin Expires\n");
+	else {
+		const struct ip_vs_conn *cp = v;
+
+		seq_printf(seq,
+			"%-3s %08X %04X %08X %04X %08X %04X %-11s %-6s %7lu\n",
+				ip_vs_proto_name(cp->protocol),
+				ntohl(cp->caddr), ntohs(cp->cport),
+				ntohl(cp->vaddr), ntohs(cp->vport),
+				ntohl(cp->daddr), ntohs(cp->dport),
+				ip_vs_state_name(cp->protocol, cp->state),
+				ip_vs_origin_name(cp->flags),
+				(cp->timer.expires-jiffies)/HZ);
+	}
+	return 0;
+}
+
+static const struct seq_operations ip_vs_conn_sync_seq_ops = {
+	.start = ip_vs_conn_seq_start,
+	.next  = ip_vs_conn_seq_next,
+	.stop  = ip_vs_conn_seq_stop,
+	.show  = ip_vs_conn_sync_seq_show,
+};
+
+static int ip_vs_conn_sync_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ip_vs_conn_sync_seq_ops);
+}
+
+static const struct file_operations ip_vs_conn_sync_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ip_vs_conn_sync_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
 #endif
 
 
@@ -942,6 +993,7 @@
 	}
 
 	proc_net_fops_create(&init_net, "ip_vs_conn", 0, &ip_vs_conn_fops);
+	proc_net_fops_create(&init_net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
 
 	/* calculate the random value for connection hash */
 	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
@@ -958,5 +1010,6 @@
 	/* Release the empty cache */
 	kmem_cache_destroy(ip_vs_conn_cachep);
 	proc_net_remove(&init_net, "ip_vs_conn");
+	proc_net_remove(&init_net, "ip_vs_conn_sync");
 	vfree(ip_vs_conn_tab);
 }
diff -Naur net-2.6_orig/net/ipv4/ipvs/ip_vs_sync.c net-2.6_work/net/ipv4/ipvs/ip_vs_sync.c
--- net-2.6_orig/net/ipv4/ipvs/ip_vs_sync.c	2007-11-13 12:37:07.000000000 +0200
+++ net-2.6_work/net/ipv4/ipvs/ip_vs_sync.c	2007-11-13 21:42:59.000000000 +0200
@@ -308,7 +308,7 @@
 		unsigned flags;
 
 		s = (struct ip_vs_sync_conn *)p;
-		flags = ntohs(s->flags);
+		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			cp = ip_vs_conn_in_get(s->protocol,
 					       s->caddr, s->cport,

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/


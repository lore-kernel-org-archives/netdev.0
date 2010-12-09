From: Pavel Vasilyev <pavel@pavlinux.ru>
Subject: [PATCH] Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC v.2
Date: Thu, 09 Dec 2010 20:26:14 +0300
Message-ID: <4D011136.8030404@pavlinux.ru>
Reply-To: pavel@pavlinux.ru
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080708040106050503060507"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imp03.mtu.ru ([62.5.255.20]:52185 "EHLO imp03.mtu.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755901Ab0LIRay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 12:30:54 -0500
Received: from imp02.mtu.ru (alt-proxy-1.mtu.ru [62.5.255.74])
	by ss27-so02.mtu.ru (Postfix) with ESMTP id 82D88228571
	for <netdev@vger.kernel.org>; Thu,  9 Dec 2010 20:27:31 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080708040106050503060507
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC.
IMHO convenient for testing.



--------------080708040106050503060507
Content-Type: text/x-patch;
 name="sysctl.inflight_trigger_gc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="sysctl.inflight_trigger_gc.patch"

 Documentation/networking/ip-sysctl.txt |    4 ++++
 include/net/af_unix.h                  |    1 +
 net/unix/garbage.c                     |    5 ++---
 net/unix/sysctl_net_unix.c             |    9 +++++++++
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 3c5e465..11e6adf 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1463,6 +1463,10 @@ max_dgram_qlen - INTEGER
 
 	Default: 10
 
+inflight_trigger_gc - INTEGER
+	The maximal number of inflight sockets for force garbage collect.
+
+	Default: 16000
 
 UNDOCUMENTED:
 
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 18e5c3f..ea580e4 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -15,6 +15,7 @@ extern struct sock *unix_get_socket(struct file *filp);
 #define UNIX_HASH_SIZE	256
 
 extern unsigned int unix_tot_inflight;
+extern unsigned int sysctl_inflight_trigger_gc;
 
 struct unix_address {
 	atomic_t	refcnt;
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index f89f83b..c646c6b 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -94,7 +94,7 @@ static DEFINE_SPINLOCK(unix_gc_lock);
 static DECLARE_WAIT_QUEUE_HEAD(unix_gc_wait);
 
 unsigned int unix_tot_inflight;
-
+unsigned int sysctl_inflight_trigger_gc = 16000;
 
 struct sock *unix_get_socket(struct file *filp)
 {
@@ -259,7 +259,6 @@ static void inc_inflight_move_tail(struct unix_sock *u)
 }
 
 static bool gc_in_progress = false;
-#define UNIX_INFLIGHT_TRIGGER_GC 16000
 
 void wait_for_unix_gc(void)
 {
@@ -267,7 +266,7 @@ void wait_for_unix_gc(void)
 	 * If number of inflight sockets is insane,
 	 * force a garbage collect right now.
 	 */
-	if (unix_tot_inflight > UNIX_INFLIGHT_TRIGGER_GC && !gc_in_progress)
+	if (unix_tot_inflight > sysctl_inflight_trigger_gc && !gc_in_progress)
 		unix_gc();
 	wait_event(unix_gc_wait, gc_in_progress == false);
 }
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 397cffe..c807235 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -23,6 +23,13 @@ static ctl_table unix_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "inflight_trigger_gc",
+		.data		= &sysctl_inflight_trigger_gc,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -41,6 +48,8 @@ int __net_init unix_sysctl_register(struct net *net)
 		goto err_alloc;
 
 	table[0].data = &net->unx.sysctl_max_dgram_qlen;
+	table[1].data = &sysctl_inflight_trigger_gc;
+
 	net->unx.ctl = register_net_sysctl_table(net, unix_path, table);
 	if (net->unx.ctl == NULL)
 		goto err_reg;

--- 

Signed-off-by: Pavel Vasilyev <pavel@pavlinux.ru>

--------------080708040106050503060507--

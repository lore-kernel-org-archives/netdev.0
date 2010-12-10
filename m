From: Pavel Vasilyev <pavel@pavlinux.ru>
Subject: Re: [PATCH] Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC v.3
Date: Fri, 10 Dec 2010 15:48:34 +0300
Message-ID: <4D0221A2.4010602@pavlinux.ru>
References: <4D011136.8030404@pavlinux.ru> <4D01A26C.8060608@cn.fujitsu.com>
Reply-To: pavel@pavlinux.ru
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030401000404000907030400"
Cc: netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imp02.mtu.ru ([62.5.255.19]:36916 "EHLO imp02.mtu.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755762Ab0LJMtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 07:49:53 -0500
In-Reply-To: <4D01A26C.8060608@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030401000404000907030400
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 10.12.2010 06:45, Shan Wei wrote:
> Pavel Vasilyev wrote, at 12/10/2010 01:26 AM:
>> Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC.
>> IMHO convenient for testing.
>>
>> +inflight_trigger_gc - INTEGER
>> +	The maximal number of inflight sockets for force garbage collect.
>> +
>> +	Default: 16000
> 
> 1) For lower payload and enough memory, it's not necessary to force garbage collection.
> So set it to 0, disable gc.


May be, set default to 2000, and zero to disable


> 2) Copy your patch to the mail, for other guys to review it.

 Where me find other guys? :)



-- 

                                                         Pavel.

--------------030401000404000907030400
Content-Type: text/x-patch;
 name="sysctl.inflight_trigger_gc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="sysctl.inflight_trigger_gc.patch"

 
 Documentation/networking/ip-sysctl.txt |    6 ++++++
 include/net/af_unix.h                  |    1 +
 net/unix/garbage.c    	                |    8 +++++---
 net/unix/sysctl_net_unix.c             |    9 +++++++++
 4 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 3c5e465..f0c4b6b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1463,6 +1463,12 @@ max_dgram_qlen - INTEGER
 
 	Default: 10
 
+inflight_trigger_gc - INTEGER
+	The maximal number of inflight sockets for force garbage collect.
+
+	0 - disable force garbage collection.
+
+	Default: 2000
 
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
index f89f83b..c2f3e98 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -94,7 +94,7 @@ static DEFINE_SPINLOCK(unix_gc_lock);
 static DECLARE_WAIT_QUEUE_HEAD(unix_gc_wait);
 
 unsigned int unix_tot_inflight;
-
+unsigned int sysctl_inflight_trigger_gc = 2000;
 
 struct sock *unix_get_socket(struct file *filp)
 {
@@ -259,7 +259,6 @@ static void inc_inflight_move_tail(struct unix_sock *u)
 }
 
 static bool gc_in_progress = false;
-#define UNIX_INFLIGHT_TRIGGER_GC 16000
 
 void wait_for_unix_gc(void)
 {
@@ -267,8 +266,11 @@ void wait_for_unix_gc(void)
 	 * If number of inflight sockets is insane,
 	 * force a garbage collect right now.
 	 */
-	if (unix_tot_inflight > UNIX_INFLIGHT_TRIGGER_GC && !gc_in_progress)
+	if (!sysctl_inflight_trigger_gc && 
+		    (unix_tot_inflight > sysctl_inflight_trigger_gc 
+					&& !gc_in_progress))
 		unix_gc();
+
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


--------------030401000404000907030400--

From: Horms <horms@verge.net.au>
Subject: Re: [PATCH][RFC] Shrink ip_vs_*.c includes
Date: Mon, 6 Feb 2006 10:09:12 +0000 (UTC)
Message-ID: <ds7787$lnr$1@sea.gmane.org>
References: <43E69CE1.2030204@drugphish.ch>
	<20060206091319.GH27206@verge.net.au> <43E7163D.7080506@tac.ch>
Reply-To: "LinuxVirtualServer.org users mailing list." <lvs-users@LinuxVirtualServer.org>
Cc: netdev@vger.kernel.org
Return-path: <lvs-users-bounces@LinuxVirtualServer.org>
To: lvs-users@LinuxVirtualServer.org
List-Unsubscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=unsubscribe>
List-Archive: <http://www.in-addr.de/pipermail/lvs-users>
List-Post: <mailto:lvs-users@LinuxVirtualServer.org>
List-Help: <mailto:lvs-users-request@LinuxVirtualServer.org?subject=help>
List-Subscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=subscribe>
Sender: lvs-users-bounces@LinuxVirtualServer.org
Errors-To: lvs-users-bounces@LinuxVirtualServer.org
List-Id: netdev.vger.kernel.org

In gmane.comp.linux.lvs.user Roberto Nibali <ratz@tac.ch> wrote:
>> Hi Rats, 
>> 
>> I'm all for this patch, but I get horrible breakage with the following
>> config (I can give the rest if you need it).
> 
> Darn!
> 
>> CONFIG_IP_VS=m
>> # CONFIG_IP_VS_DEBUG is not set
>> CONFIG_IP_VS_TAB_BITS=12
>> CONFIG_IP_VS_PROTO_TCP=y
>> CONFIG_IP_VS_PROTO_UDP=y
>> CONFIG_IP_VS_PROTO_ESP=y
>> CONFIG_IP_VS_PROTO_AH=y
>> CONFIG_IP_VS_RR=m
>> CONFIG_IP_VS_WRR=m
>> CONFIG_IP_VS_LC=m
>> CONFIG_IP_VS_WLC=m
>> CONFIG_IP_VS_LBLC=m
>> CONFIG_IP_VS_LBLCR=m
>> CONFIG_IP_VS_DH=m
>> CONFIG_IP_VS_SH=m
>> CONFIG_IP_VS_SED=m
>> CONFIG_IP_VS_NQ=m
>> CONFIG_IP_VS_FTP=m
> 
> Ok, this is m/y mixed. Haven't tried it yet.

Actually, I think that its completely modular.

[snip]

> I'll reproduce it with your config. I didn't think of trying it with
> mixed y/m settings. Following include is missing then:
> 
> #include <linux/seq_file.h>

Thanks, I found that linux/module.h was also needed.
After putting those two back into ip_vs_conn.c the build went 
find. I also tried a few other combinations, all on ia64, without issue.
My diff is below. Could you recheck it?

> Or do you think we could put all the needed includes into ip_vs.h and
> simply be done with it?

I spoke breifly with Dave about this, and he isn't very keen on it.
The problem with that approach, is that while its less work to
maintain the headers by hand, it will likely result in uneeded
includes in some cases. So all of LVS will get built when
a given header is touched, where perhaps only half of it needed
to be built. So with that in mind, could you continue in the vein of
your original patch?

-- 
Horms

Hello,

This patch against the latest GIT HEAD reduces the includes to the
necessary ones. I've compile-tested it against following (and s/y/m/)
configuration on x86:

CONFIG_IP_VS=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y
CONFIG_IP_VS_FTP=y

Please consider applying (but test it first on your local tree since we
don't want stupid breakage resulting from such changes).

Alternatively/additionally I could envision a patch on top of this one
that completely removes the includes from the ../net/ipv4/ipvs/*.c
except the ../include/net/ip_vs.h, which would carry all the needed
header includes.

Signed-off-by: Roberto Nibali <ratz@drugphish.ch>
Signed-off-by: Horms <horms@verge.net.au>


diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index 9b176a9..9f5676b 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -20,17 +20,9 @@
  *
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/skbuff.h>
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <net/protocol.h>
 #include <net/tcp.h>
-#include <asm/system.h>
-#include <linux/stat.h>
 #include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 87b8381..157b9ad 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -24,13 +24,12 @@
  *
  */
 
-#include <linux/interrupt.h>
 #include <linux/in.h>
 #include <linux/net.h>
-#include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/slab.h>
 #include <linux/vmalloc.h>
-#include <linux/proc_fs.h>		/* for proc_net_* */
+#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/jhash.h>
 #include <linux/random.h>
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 3f47ad8..927fbc0 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -26,19 +26,13 @@
  *
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/icmp.h>
 
 #include <net/ip.h>
-#include <net/tcp.h>
-#include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
-#include <net/route.h>
+#include <net/route.h>			/* for inet_addr_type */
 
-#include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 7f0288b..a130c5f 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -20,26 +20,14 @@
  *
  */
 
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/types.h>
-#include <linux/capability.h>
-#include <linux/fs.h>
-#include <linux/sysctl.h>
 #include <linux/proc_fs.h>
-#include <linux/workqueue.h>
-#include <linux/swap.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-
-#include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/sock.h>
 
-#include <asm/uaccess.h>
+//#include <asm/uaccess.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
index 9fee19c..e40998c 100644
--- a/net/ipv4/ipvs/ip_vs_dh.c
+++ b/net/ipv4/ipvs/ip_vs_dh.c
@@ -38,8 +38,6 @@
  */
 
 #include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/skbuff.h>
 
 #include <net/ip_vs.h>
diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
index c453e1e..ce3d3c3 100644
--- a/net/ipv4/ipvs/ip_vs_est.c
+++ b/net/ipv4/ipvs/ip_vs_est.c
@@ -13,12 +13,8 @@
  * Changes:
  *
  */
-#include <linux/config.h>
-#include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/slab.h>
-#include <linux/types.h>
-#include <linux/interrupt.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index a19a33c..ab730b1 100644
--- a/net/ipv4/ipvs/ip_vs_ftp.c
+++ b/net/ipv4/ipvs/ip_vs_ftp.c
@@ -24,13 +24,7 @@
  *
  */
 
-#include <linux/module.h>
-#include <linux/moduleparam.h>
-#include <linux/kernel.h>
 #include <linux/skbuff.h>
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <net/protocol.h>
 #include <net/tcp.h>
 
 #include <net/ip_vs.h>
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 6e5cb92..ae51ae8 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -42,14 +42,8 @@
  */
 
 #include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/skbuff.h>
 
-/* for sysctl */
-#include <linux/fs.h>
-#include <linux/sysctl.h>
-
 #include <net/ip_vs.h>
 
 
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index 32ba37b..ebe05a8 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -40,16 +40,8 @@
  */
 
 #include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/skbuff.h>
 
-/* for sysctl */
-#include <linux/fs.h>
-#include <linux/sysctl.h>
-/* for proc_net_create/proc_net_remove */
-#include <linux/proc_fs.h>
-
 #include <net/ip_vs.h>
 
 
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index d88fef9..db63c0f 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -17,7 +17,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/kernel.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index bc2a9e5..f1b4341 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -34,7 +34,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/kernel.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 867d4e9..9084338 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -15,17 +15,8 @@
  *
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/skbuff.h>
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <net/protocol.h>
 #include <net/tcp.h>
-#include <net/udp.h>
-#include <asm/system.h>
-#include <linux/stat.h>
-#include <linux/proc_fs.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
index 8b0505b..cb95f58 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c
@@ -14,9 +14,6 @@
 
 #include <linux/in.h>
 #include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
diff --git a/net/ipv4/ipvs/ip_vs_proto_esp.c b/net/ipv4/ipvs/ip_vs_proto_esp.c
index c36ccf0..bcbad11 100644
--- a/net/ipv4/ipvs/ip_vs_proto_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_esp.c
@@ -14,9 +14,6 @@
 
 #include <linux/in.h>
 #include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index bc28b11..deb98e7 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -15,11 +15,7 @@
  *
  */
 
-#include <linux/kernel.h>
-#include <linux/ip.h>
-#include <linux/tcp.h>                  /* for tcphdr */
-#include <net/ip.h>
-#include <net/tcp.h>                    /* for csum_tcpudp_magic */
+#include <net/tcp.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 89d9175..7ffd5c2 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -17,9 +17,8 @@
 
 #include <linux/in.h>
 #include <linux/ip.h>
-#include <linux/kernel.h>
-#include <linux/netfilter_ipv4.h>
 #include <linux/udp.h>
+#include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index b23bab2..00ebed8 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -22,7 +22,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/kernel.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_sched.c b/net/ipv4/ipvs/ip_vs_sched.c
index 8bc42b7..8abc2e9 100644
--- a/net/ipv4/ipvs/ip_vs_sched.c
+++ b/net/ipv4/ipvs/ip_vs_sched.c
@@ -20,11 +20,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/sched.h>
-#include <linux/spinlock.h>
-#include <linux/interrupt.h>
-#include <asm/string.h>
-#include <linux/kmod.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index ff366f7..8269e6c 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -38,7 +38,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/kernel.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
index 7775e6c..878c63f 100644
--- a/net/ipv4/ipvs/ip_vs_sh.c
+++ b/net/ipv4/ipvs/ip_vs_sh.c
@@ -35,8 +35,6 @@
  */
 
 #include <linux/ip.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/skbuff.h>
 
 #include <net/ip_vs.h>
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 1bca714..8d2dba4 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -19,20 +19,13 @@
  *	Justin Ossevoort	:	Fix endian problem on sync message size.
  */
 
-#include <linux/module.h>
-#include <linux/slab.h>
 #include <linux/inetdevice.h>
-#include <linux/net.h>
-#include <linux/completion.h>
 #include <linux/delay.h>
-#include <linux/skbuff.h>
-#include <linux/in.h>
 #include <linux/igmp.h>                 /* for ip_mc_join_group */
 #include <linux/udp.h>
+#include <linux/sched.h>
 
 #include <net/ip.h>
-#include <net/sock.h>
-#include <asm/uaccess.h>                /* for get_fs and set_fs */
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 8a9d913..6d90a7c 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -22,7 +22,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/kernel.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 749fa04..bfcd5fb 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -21,7 +21,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/kernel.h>
 
 #include <net/ip_vs.h>
 
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 52c12e9..19d85e3 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -15,14 +15,9 @@
  *
  */
 
-#include <linux/kernel.h>
-#include <linux/ip.h>
-#include <linux/tcp.h>                  /* for tcphdr */
-#include <net/tcp.h>                    /* for csum_tcpudp_magic */
-#include <net/udp.h>
+#include <net/ip.h>
 #include <net/icmp.h>                   /* for icmp_send */
 #include <net/route.h>                  /* for ip_route_output */
-#include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>

From: Samuel Ortiz <samuel.ortiz-EmnPodGKVbzby3iVrkZq2A@public.gmane.org>
Subject: [PATCH] [IrDA] Fix IrDA build failure
Date: Mon, 16 Jul 2007 14:17:15 +0300
Message-ID: <20070716111715.GB22757@mail.solidboot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

When having built-in IrDA, we hit the following error:

`irda_sysctl_unregister' referenced in section `.init.text' of
net/built-in.o: defined in discarded section `.exit.text' of
net/built-in.o
`irda_proc_unregister' referenced in section `.init.text' of
net/built-in.o: defined in discarded section `.exit.text' of
net/built-in.o
`irsock_cleanup' referenced in section `.init.text' of net/built-in.o:
defined in discarded section `.exit.text' of net/built-in.o
`irttp_cleanup' referenced in section `.init.text' of net/built-in.o:
defined in discarded section `.exit.text' of net/built-in.o
`iriap_cleanup' referenced in section `.init.text' of net/built-in.o:
defined in discarded section `.exit.text' of net/built-in.o
`irda_device_cleanup' referenced in section `.init.text' of
net/built-in.o: defined in discarded section `.exit.text' of
net/built-in.o
`irlap_cleanup' referenced in section `.init.text' of net/built-in.o:
defined in discarded section `.exit.text' of net/built-in.o
`irlmp_cleanup' referenced in section `.init.text' of net/built-in.o:
defined in discarded section `.exit.text' of net/built-in.o
make[1]: *** [.tmp_vmlinux1] Error 1
make: *** [_all] Error 2

This is due to the irda_init fix recently added, where we call __exit
routines from an __init one. It is a build failure that I didn't catch
because it doesn't show up when building IrDA as a module. My apologies
for that.
The following patch fixes that failure and is against your net-2.6
tree. I hope it can make it to the merge window, and stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
is CCed on this mail.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index dcd7e32..4c670cf 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2567,7 +2567,7 @@ int __init irsock_init(void)
  *    Remove IrDA protocol
  *
  */
-void __exit irsock_cleanup(void)
+void irsock_cleanup(void)
 {
 	sock_unregister(PF_IRDA);
 	proto_unregister(&irda_proto);
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 7b5def1..435b563 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -95,14 +95,14 @@ int __init irda_device_init( void)
 	return 0;
 }
 
-static void __exit leftover_dongle(void *arg)
+static void leftover_dongle(void *arg)
 {
 	struct dongle_reg *reg = arg;
 	IRDA_WARNING("IrDA: Dongle type %x not unregistered\n",
 		     reg->type);
 }
 
-void __exit irda_device_cleanup(void)
+void irda_device_cleanup(void)
 {
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
 
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 774eb70..ee3889f 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -153,7 +153,7 @@ int __init iriap_init(void)
  *    Initializes the IrIAP layer, called by the module cleanup code in
  *    irmod.c
  */
-void __exit iriap_cleanup(void)
+void iriap_cleanup(void)
 {
 	irlmp_unregister_service(service_handle);
 
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 2fc9f51..3d76aaf 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -95,7 +95,7 @@ int __init irlap_init(void)
 	return 0;
 }
 
-void __exit irlap_cleanup(void)
+void irlap_cleanup(void)
 {
 	IRDA_ASSERT(irlap != NULL, return;);
 
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 24a5e3f..7efa930 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -116,7 +116,7 @@ int __init irlmp_init(void)
  *    Remove IrLMP layer
  *
  */
-void __exit irlmp_cleanup(void)
+void irlmp_cleanup(void)
 {
 	/* Check for main structure */
 	IRDA_ASSERT(irlmp != NULL, return;);
diff --git a/net/irda/irproc.c b/net/irda/irproc.c
index d6f9aba..181cb51 100644
--- a/net/irda/irproc.c
+++ b/net/irda/irproc.c
@@ -84,7 +84,7 @@ void __init irda_proc_register(void)
  *    Unregister irda entry in /proc file system
  *
  */
-void __exit irda_proc_unregister(void)
+void irda_proc_unregister(void)
 {
 	int i;
 
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index 2e968e7..957e04f 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -287,7 +287,7 @@ int __init irda_sysctl_register(void)
  *    Unregister our sysctl interface
  *
  */
-void __exit irda_sysctl_unregister(void)
+void irda_sysctl_unregister(void)
 {
 	unregister_sysctl_table(irda_table_header);
 }
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 7f50832..3d7ab03 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -109,7 +109,7 @@ int __init irttp_init(void)
  *    Called by module destruction/cleanup code
  *
  */
-void __exit irttp_cleanup(void)
+void irttp_cleanup(void)
 {
 	/* Check for main structure */
 	IRDA_ASSERT(irttp->magic == TTP_MAGIC, return;);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

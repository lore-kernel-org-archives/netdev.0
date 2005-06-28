From: Paolo Galtieri <pgaltieri@mvista.com>
Subject: Infinite loop in autoconfig with no dhcp server
Date: Tue, 28 Jun 2005 08:14:09 -0700
Message-ID: <1119971649.21672.12.camel@playin.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Folks,
  it appears that the attempt to do auto configuration will go on
forever if there is no DHCP server available.  The question I have is is
this the intended behavior when IPCONFIG_DYNAMIC is set, but
CONFIG_ROOT_NFS is not?

The function in question is ip_auto_config() in net/ipv4/ipconfig.c

Here is the situation:

At the top of ip_auto_config() we have:

#ifdef IPCONFIG_DYNAMIC
 try_try_again:
#endif

A bit further down we have:

    if (ic_myaddr == INADDR_NONE ||
#ifdef CONFIG_ROOT_NFS
        (MAJOR(ROOT_DEV) == UNNAMED_MAJOR
         && root_server_addr == INADDR_NONE
         && ic_servaddr == INADDR_NONE) ||
#endif
        ic_first_dev->next) {
#ifdef IPCONFIG_DYNAMIC

We are doing dynamic configuration so we drop into the if and initialize
the retry count:

        int retries = CONF_OPEN_RETRIES;

We call ic_dynamic() to attempt the connection:

        if (ic_dynamic() < 0) {
            ic_close_devs();

There is no DHCP server running so ic_dynamic() returns -1 indicating a
timeout occured.  We decrement retries to 1 and go to try_try_again.

            if (--retries) {
                printk(KERN_ERR
                       "IP-Config: Reopening network devices...\n");
                goto try_try_again;
            }

We drop back into the if set retries to 2 again, since it is a local
variable, call ic_dynamic() which returns -1 due to a timeout.
We decrement retries to 1 and go to try_try_again.  We drop into the if
again, set retries to 2, call ic_dynamic() ad infinitum.

We have the Energizer Bunny auto configuration :-), it goes on and on
and on.

We never reach the "Auto-configuration of network failed" printk.

One way to fix the problem is attached below.

Does this seem reasonable or should I go find a rock and crawl under it?


Please reply directly to me as I am not on this mailing list.

Paolo Galtieri

--- linux-2.6.12.1/net/ipv4/ipconfig.c  2005-06-23 06:49:56.000000000
-0700
+++ linux-2.6.12.1-new/net/ipv4/ipconfig.c      2005-06-28
08:09:11.143292280 -0700
@@ -1248,6 +1248,10 @@
 {
        u32 addr;

+#ifdef IPCONFIG_DYNAMIC
+       int retries = CONF_OPEN_RETRIES;
+#endif
+
 #ifdef CONFIG_PROC_FS
        proc_net_fops_create("pnp", S_IRUGO, &pnp_seq_fops);
 #endif /* CONFIG_PROC_FS */
@@ -1284,8 +1288,6 @@
            ic_first_dev->next) {
 #ifdef IPCONFIG_DYNAMIC

-               int retries = CONF_OPEN_RETRIES;
-
                if (ic_dynamic() < 0) {
                        ic_close_devs();

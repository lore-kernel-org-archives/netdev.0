From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 1/2] IPv6: add "disable" module parameter support to ipv6.ko
Date: Tue, 03 Mar 2009 21:37:19 -0500
Message-ID: <49ADE95F.8060607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrey Borzenkov <arvidjaar@mail.ru>,
	Vladislav Yasevich <vladislav.yasevich@hp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Theodore Tso <tytso@mit.edu>, Valdis.Kletnieks@vt.edu,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bonding-devel@lists.sourceforge.net,
	=?ISO-8859-1?Q?=22J=2EA=2E_Magall?= =?ISO-8859-1?Q?=F3n=22?=
	<jamagallon@ono.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:9313 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbZCDCiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 21:38:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add "disable" module parameter support to ipv6.ko by specifying
"disable=1" on module load.  We just do the minimum of initializing
inetsw6[] so calls from other modules to inet6_register_protosw()
won't OOPs, then bail out.  No IPv6 addresses or sockets can be
created as a result, and a reboot is required to enable IPv6.


Signed-off-by: Brian Haley <brian.haley@hp.com>
---
  Documentation/networking/ipv6.txt |   35 +++++++++++++++++++++++++++++++++++
  net/ipv6/af_inet6.c               |   22 ++++++++++++++++------
  2 files changed, 51 insertions(+), 6 deletions(-)
  create mode 100644 Documentation/networking/ipv6.txt

diff --git a/Documentation/networking/ipv6.txt b/Documentation/networking/ipv6.txt
new file mode 100644
index 0000000..268e5c1
--- /dev/null
+++ b/Documentation/networking/ipv6.txt
@@ -0,0 +1,35 @@
+
+Options for the ipv6 module are supplied as parameters at load time.
+
+Module options may be given as command line arguments to the insmod
+or modprobe command, but are usually specified in either the
+/etc/modules.conf or /etc/modprobe.conf configuration file, or in a
+distro-specific configuration file.
+
+The available ipv6 module parameters are listed below.  If a parameter
+is not specified the default value is used.
+
+The parameters are as follows:
+
+disable
+
+	Specifies whether to load the IPv6 module, but disable all
+	its functionality.  This might be used when another module
+	has a dependency on the IPv6 module being loaded, but no
+	IPv6 addresses or operations are desired.
+
+	The possible values and their effects are:
+
+	0
+		IPv6 is enabled.
+
+		This is the default value.
+
+	1
+		IPv6 is disabled.
+
+		No IPv6 addresses will be added to interfaces, and
+		it will not be possible to open an IPv6 socket.
+
+		A reboot is required to enable IPv6.
+
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index fa2ac7e..90f6d0c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -72,6 +72,10 @@ MODULE_LICENSE("GPL");
  static struct list_head inetsw6[SOCK_MAX];
  static DEFINE_SPINLOCK(inetsw6_lock);

+static int disable_ipv6 = 0;
+module_param_named(disable, disable_ipv6, int, 0);
+MODULE_PARM_DESC(disable, "Disable IPv6 such that it is non-functional");
+
  static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
  {
  	const int offset = sk->sk_prot->obj_size - sizeof(struct ipv6_pinfo);
@@ -1001,10 +1005,21 @@ static int __init inet6_init(void)
  {
  	struct sk_buff *dummy_skb;
  	struct list_head *r;
-	int err;
+	int err = 0;

  	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb));

+	/* Register the socket-side information for inet6_create.  */
+	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
+		INIT_LIST_HEAD(r);
+
+	if (disable_ipv6) {
+		printk(KERN_INFO
+		       "IPv6: Loaded, but administratively disabled, "
+		       "reboot required to enable\n");
+		goto out;
+	}
+
  	err = proto_register(&tcpv6_prot, 1);
  	if (err)
  		goto out;
@@ -1021,11 +1036,6 @@ static int __init inet6_init(void)
  	if (err)
  		goto out_unregister_udplite_proto;

-
-	/* Register the socket-side information for inet6_create.  */
-	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
-		INIT_LIST_HEAD(r);
-
  	/* We MUST register RAW sockets before we create the ICMP6,
  	 * IGMP6, or NDISC control sockets.
  	 */
-- 
1.5.4.3


From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] [NET]: Fix deletion of equal local IPv4 addresses only varying in prefix length
Date: Tue, 8 Mar 2005 17:01:49 +0100
Message-ID: <20050308160148.GD31837@postel.suug.ch>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch> <20050305005911.GA27804@gondor.apana.org.au> <20050305162323.GM31837@postel.suug.ch> <20050305183009.GA26438@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050305183009.GA26438@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The deletion of equal local IPv4 addresses only varying in prefix length
via netlink currently results in the deletion of the address that was added
first independently of the prefix length.

The fact that parts of the userspace, especially scripts, rely on the fact
that specifying no prefix has the meaning of a wildcard makes this fix non
trivial. In order to not break compatibilty the prefix length is only compared
if userspace explicitely requests an exact match by setting a flag or if
the prefix length is not 32 which means that it was specified by the user.

Assuming the addresses 1.1.1.1/1, 1.1.1.1/32, and 1.1.1.1/2 are added in
the given order the new behaviour looks as follows:

Deletion of            Unmodified userspace           Modified userspace
 1.1.1.1/2                   1.1.1.1/2                    1.1.1.1/2
 1.1.1.1                     1.1.1.1/1                    1.1.1.1/1
 1.1.1.1/32                  1.1.1.1/1                    1.1.1.1/32

While the old kernel behaviour would have deleted 1.1.1.1/1 in all
three cases.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-bk3.orig/include/linux/inetdevice.h linux-2.6.11-bk3/include/linux/inetdevice.h
--- linux-2.6.11-bk3.orig/include/linux/inetdevice.h	2005-03-08 13:10:37.000000000 +0100
+++ linux-2.6.11-bk3/include/linux/inetdevice.h	2005-03-08 16:29:27.000000000 +0100
@@ -7,6 +7,7 @@
 #include <linux/netdevice.h>
 #include <linux/rcupdate.h>
 #include <linux/timer.h>
+#include <linux/rtnetlink.h>
 
 struct ipv4_devconf
 {
@@ -131,6 +132,25 @@
 	return 0;
 }
 
+static inline int inet_ifa_match_local_prefixlen(struct ifaddrmsg *ifm,
+						 struct in_ifaddr *ifa)
+{
+	int real_prefixlen = IFA_REAL_DEL_PREFIX(ifm->ifa_prefixlen);
+
+	/*
+	 * Since the prefix length hasn't been taken into account in
+	 * previous kernel versions, parts of the userspace rely on the fact
+	 * that the deletion of an address without specifying a prefix works.
+	 * We cannot break this and thus a prefix length of 32 still represents
+	 * a wildcard if no exact match is requested.
+	 */
+	if (real_prefixlen != 32 || ifm->ifa_prefixlen & IFA_PREFIX_EXACT_DEL)
+		if (real_prefixlen != ifa->ifa_prefixlen)
+			return 0;
+
+	return 1;
+}
+
 #define for_primary_ifa(in_dev)	{ struct in_ifaddr *ifa; \
   for (ifa = (in_dev)->ifa_list; ifa && !(ifa->ifa_flags&IFA_F_SECONDARY); ifa = ifa->ifa_next)
 
diff -Nru linux-2.6.11-bk3.orig/include/linux/rtnetlink.h linux-2.6.11-bk3/include/linux/rtnetlink.h
--- linux-2.6.11-bk3.orig/include/linux/rtnetlink.h	2005-03-08 16:28:04.000000000 +0100
+++ linux-2.6.11-bk3/include/linux/rtnetlink.h	2005-03-08 14:17:49.000000000 +0100
@@ -396,6 +396,19 @@
 
 #define IFA_MAX (__IFA_MAX - 1)
 
+/*
+ * Quirk for IPv4 address deletion to allow exact deletion of equal
+ * addresses varying only in prefix length. A explicit exact comparison
+ * of the prefix length will only be done if IFA_PREFIX_EXACT_DEL is
+ * ORed to ifa_prefixlen.
+ *
+ * Note: This special treatment is only understood while deleting
+ *       addresses and will lead to unexpected behaviour if used
+ *       otherwise.
+ */
+#define IFA_PREFIX_EXACT_DEL	0x40
+#define IFA_REAL_DEL_PREFIX(l)	((l) & 0x3f)
+
 /* ifa_flags */
 
 #define IFA_F_SECONDARY		0x01
diff -Nru linux-2.6.11-bk3.orig/net/ipv4/devinet.c linux-2.6.11-bk3/net/ipv4/devinet.c
--- linux-2.6.11-bk3.orig/net/ipv4/devinet.c	2005-03-08 13:10:44.000000000 +0100
+++ linux-2.6.11-bk3/net/ipv4/devinet.c	2005-03-08 16:29:49.000000000 +0100
@@ -389,6 +389,7 @@
 	struct in_device *in_dev;
 	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
 	struct in_ifaddr *ifa, **ifap;
+	int real_prefixlen = IFA_REAL_DEL_PREFIX(ifm->ifa_prefixlen);
 
 	ASSERT_RTNL();
 
@@ -399,12 +400,13 @@
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
 		if ((rta[IFA_LOCAL - 1] &&
+		    (!inet_ifa_match_local_prefixlen(ifm, ifa) ||
 		     memcmp(RTA_DATA(rta[IFA_LOCAL - 1]),
-			    &ifa->ifa_local, 4)) ||
+			    &ifa->ifa_local, 4))) ||
 		    (rta[IFA_LABEL - 1] &&
 		     rtattr_strcmp(rta[IFA_LABEL - 1], ifa->ifa_label)) ||
 		    (rta[IFA_ADDRESS - 1] &&
-		     (ifm->ifa_prefixlen != ifa->ifa_prefixlen ||
+		     (real_prefixlen != ifa->ifa_prefixlen ||
 		      !inet_ifa_match(*(u32*)RTA_DATA(rta[IFA_ADDRESS - 1]),
 			      	      ifa))))
 			continue;

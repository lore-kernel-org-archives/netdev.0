From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: strategy hander for net.ipv6.conf.*.forwarding (is
 Re: problem setting net.ipvX.conf.all.forwarding via sysctl() system call)
Date: Fri, 08 Aug 2003 17:50:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808.175030.19527061.yoshfuji@linux-ipv6.org>
References: <20030803154427.GA12926@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, jan.oravec@6com.sk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030803154427.GA12926@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030803154427.GA12926@wsx.ksp.sk> (at Sun, 3 Aug 2003 17:44:27 +0200), Jan Oravec <jan.oravec@6com.sk> says:

> For IPv6, it is obviously because sysctl 'strategy' handler is not defined.

Here's tha patch to add strategy handler for 
net.ipv6.conf.*.forwarding.  Thanks.

Index: linux-2.6/net/ipv6/addrconf.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/addrconf.c,v
retrieving revision 1.48
diff -u -r1.48 addrconf.c
--- linux-2.6/net/ipv6/addrconf.c	25 Jul 2003 23:58:59 -0000	1.48
+++ linux-2.6/net/ipv6/addrconf.c	8 Aug 2003 07:12:13 -0000
@@ -2593,6 +2593,48 @@
         return ret;
 }
 
+static int addrconf_sysctl_forward_strategy(ctl_table *table, 
+					    int *name, int nlen,
+					    void *oldval, size_t *oldlenp,
+					    void *newval, size_t newlen,
+					    void **context)
+{
+	int *valp = table->data;
+	int new;
+
+	if (!newval || !newlen)
+		return 0;
+	if (newlen != sizeof(int))
+		return -EINVAL;
+	if (get_user(new, (int *)newval))
+		return -EFAULT;
+	if (new == *valp)
+		return 0;
+	if (oldval && oldlenp) {
+		size_t len;
+		if (get_user(len, oldlenp))
+			return -EFAULT;
+		if (len) {
+			if (len > table->maxlen)
+				len = table->maxlen;
+			if (copy_to_user(oldval, valp, len))
+				return -EFAULT;
+			if (put_user(len, oldlenp))
+				return -EFAULT;
+		}
+	}
+
+	*valp = new;
+	if (valp != &ipv6_devconf.forwarding &&
+	    valp != &ipv6_devconf_dflt.forwarding) {
+		struct inet6_dev *idev = (struct inet6_dev *)table->extra1;
+		if (!idev)
+			return -ENODEV;
+		addrconf_forward_change(idev);
+	}
+	return 0;
+}
+
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
@@ -2611,6 +2653,7 @@
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
          		.proc_handler	=	&addrconf_sysctl_forward,
+			.strategy	=	&addrconf_sysctl_forward_strategy,
 		},
 		{
 			.ctl_name	=	NET_IPV6_HOP_LIMIT,


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: strategy hander for net.ipv6.conf.*.forwarding
 (is Re: problem setting net.ipvX.conf.all.forwarding via sysctl() system
 call)
Date: Sat, 09 Aug 2003 19:21:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809.192158.47862071.yoshfuji@linux-ipv6.org>
References: <20030808093704.GA18131@wsx.ksp.sk>
	<20030808.185135.112441851.yoshfuji@linux-ipv6.org>
	<20030809010845.01ebcbe9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan.oravec@6com.sk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030809010845.01ebcbe9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030809010845.01ebcbe9.davem@redhat.com> (at Sat, 9 Aug 2003 01:08:45 -0700), "David S. Miller" <davem@redhat.com> says:

> As I mentioned for the ipv4 forwarding sysctl bug fix,
> if you will set table->data yourself you should return
> > 0 (for example "1") from your strategy handler.
:
> Please fix this, thank you.

Here it is.

Index: linux-2.6/net/ipv6/addrconf.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/addrconf.c,v
retrieving revision 1.48
diff -u -r1.48 addrconf.c
--- linux-2.6/net/ipv6/addrconf.c	25 Jul 2003 23:58:59 -0000	1.48
+++ linux-2.6/net/ipv6/addrconf.c	9 Aug 2003 08:51:42 -0000
@@ -2593,6 +2593,53 @@
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
+	if (valp != &ipv6_devconf_dflt.forwarding) {
+		struct inet6_dev *idev;
+		if (valp != &ipv6_devconf.forwarding) {
+			idev = (struct inet6_dev *)table->extra1;
+			if (unlikely(idev == NULL))
+				return -ENODEV;
+		} else
+			idev = NULL;
+		*valp = new;
+		addrconf_forward_change(idev);
+	} else
+		*valp = new;
+
+	return 1;
+}
+
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
@@ -2611,6 +2658,7 @@
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

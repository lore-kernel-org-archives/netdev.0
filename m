From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 NET] Adjust RTATTR_MAX to IFLA_* changes
Date: Thu, 9 Sep 2004 10:31:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909103149.248a603e.davem@davemloft.net>
References: <20040909163131.GA18951@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, eric.lemoine@gmail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040909163131.GA18951@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 18:31:31 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> IFLA_MAX is now bigger than RTA_MAX with the latest changes in IFLA_*.
> Adjust RTATTR to point to IFLA_MAX to have big enough buffer in
> rtnetlink_rcv_msg.

Ok, this is going to get silly if some other attribute gets
larger than IFLA_* next.

We should just compute this thing at run time.
Else, if the macro can't be deleted because there
are non-trivial other uses, use some expression
involving max().

I just checked iproute2 sources and it does not reference
this thing, so probably best to kill it off, like so.

===== include/linux/rtnetlink.h 1.42 vs edited =====
--- 1.42/include/linux/rtnetlink.h	2004-09-02 13:12:43 -07:00
+++ edited/include/linux/rtnetlink.h	2004-09-09 10:10:08 -07:00
@@ -660,10 +660,6 @@
 #define TCA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcmsg))
 
 
-/* SUMMARY: maximal rtattr understood by kernel */
-
-#define RTATTR_MAX		RTA_MAX
-
 /* RTnetlink multicast groups */
 
 #define RTMGRP_LINK		1
===== net/core/rtnetlink.c 1.24 vs edited =====
--- 1.24/net/core/rtnetlink.c	2004-09-02 13:12:43 -07:00
+++ edited/net/core/rtnetlink.c	2004-09-09 10:08:44 -07:00
@@ -401,6 +401,10 @@
 	return 0;
 }
 
+/* Protected by RTNL sempahore.  */
+static struct rtattr **rta_buf;
+static int rtattr_max;
+
 /* Process one rtnetlink message. */
 
 static __inline__ int
@@ -408,8 +412,6 @@
 {
 	struct rtnetlink_link *link;
 	struct rtnetlink_link *link_tab;
-	struct rtattr	*rta[RTATTR_MAX];
-
 	int sz_idx, kind;
 	int min_len;
 	int family;
@@ -476,7 +478,7 @@
 		return -1;
 	}
 
-	memset(&rta, 0, sizeof(rta));
+	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
 
 	min_len = rtm_min[sz_idx];
 	if (nlh->nlmsg_len < min_len)
@@ -491,7 +493,7 @@
 			if (flavor) {
 				if (flavor > rta_max[sz_idx])
 					goto err_inval;
-				rta[flavor-1] = attr;
+				rta_buf[flavor-1] = attr;
 			}
 			attr = RTA_NEXT(attr, attrlen);
 		}
@@ -501,7 +503,7 @@
 		link = &(rtnetlink_links[PF_UNSPEC][type]);
 	if (link->doit == NULL)
 		goto err_inval;
-	err = link->doit(skb, nlh, (void *)&rta);
+	err = link->doit(skb, nlh, (void *)&rta_buf[0]);
 
 	*errp = err;
 	return err;
@@ -621,6 +623,16 @@
 
 void __init rtnetlink_init(void)
 {
+	int i;
+
+	rtattr_max = 0;
+	for (i = 0; i < ARRAY_SIZE(rta_max); i++)
+		if (rta_max[i] > rtattr_max)
+			rtattr_max = rta_max[i];
+	rta_buf = kmalloc(rtattr_max * sizeof(struct rtattr *), GFP_KERNEL);
+	if (!rta_buf)
+		panic("rtnetlink_init: cannot allocate rta_buf\n");
+
 	rtnl = netlink_kernel_create(NETLINK_ROUTE, rtnetlink_rcv);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");

From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 2/4] O/M flags against 2.4.21
Date: Mon, 14 Jul 2003 15:39:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307141535210.5140-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>,
   <kuznet@ms2.inr.ac.ru>, <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ Sorry, PATCH 1/4 is a patch for O/M flags against 2.5.73, the subject
was wrong.]

------------------- PATCH for O/M flags against 2.4.21 ------------------
diff -ruN linux-2.4.21.org/include/linux/rtnetlink.h PATCHES/linux-2.4.21/include/linux/rtnetlink.h
--- linux-2.4.21.org/include/linux/rtnetlink.h	2002-11-28 15:53:15.000000000 -0800
+++ PATCHES/linux-2.4.21/include/linux/rtnetlink.h	2003-07-14 12:32:49.000000000 -0700
@@ -307,6 +307,7 @@
 	IFA_LABEL,
 	IFA_BROADCAST,
 	IFA_ANYCAST,
+	IFA_IFFLAGS,
 	IFA_CACHEINFO
 };

diff -ruN linux-2.4.21.org/include/net/if_inet6.h PATCHES/linux-2.4.21/include/net/if_inet6.h
--- linux-2.4.21.org/include/net/if_inet6.h	2003-06-13 07:51:39.000000000 -0700
+++ PATCHES/linux-2.4.21/include/net/if_inet6.h	2003-07-14 10:30:53.000000000 -0700
@@ -15,6 +15,8 @@
 #ifndef _NET_IF_INET6_H
 #define _NET_IF_INET6_H

+#define IF_RA_OTHERCONF	0x80
+#define IF_RA_MANAGED	0x40
 #define IF_RA_RCVD	0x20
 #define IF_RS_SENT	0x10

diff -ruN linux-2.4.21.org/net/ipv6/addrconf.c PATCHES/linux-2.4.21/net/ipv6/addrconf.c
--- linux-2.4.21.org/net/ipv6/addrconf.c	2003-06-13 07:51:39.000000000 -0700
+++ PATCHES/linux-2.4.21/net/ipv6/addrconf.c	2003-07-14 12:21:50.000000000 -0700
@@ -1879,6 +1879,7 @@
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 			     u32 pid, u32 seq, int event)
 {
+	int flags;
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	struct ifa_cacheinfo ci;
@@ -1909,6 +1910,8 @@
 		}
 		RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
 	}
+	flags = ifa->idev->if_flags;
+	RTA_PUT(skb, IFA_IFFLAGS, sizeof(flags), &flags);
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;

diff -ruN linux-2.4.21.org/net/ipv6/ndisc.c PATCHES/linux-2.4.21/net/ipv6/ndisc.c
--- linux-2.4.21.org/net/ipv6/ndisc.c	2003-06-13 07:51:39.000000000 -0700
+++ PATCHES/linux-2.4.21/net/ipv6/ndisc.c	2003-07-14 10:30:53.000000000 -0700
@@ -940,6 +940,16 @@
 		 */
 		in6_dev->if_flags |= IF_RA_RCVD;
 	}
+	/*
+	 * Remember the managed/otherconf flags from most recently
+	 * receieved RA message (RFC 2462) -- yoshfuji
+	 */
+	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED|
+				IF_RA_OTHERCONF)) |
+				(ra_msg->icmph.icmp6_addrconf_managed ?
+					IF_RA_MANAGED : 0) |
+				(ra_msg->icmph.icmp6_addrconf_other ?
+					IF_RA_OTHERCONF : 0);

 	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);

------------------------------------------------------------------------

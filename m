From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH/RFC] IPV6: Remember Manage/OtherConfig flags
Date: Wed, 11 Jun 2003 16:28:49 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030611.162849.52863261.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, krkumar@us.ibm.com
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@redhat.com
List-Id: netdev.vger.kernel.org

Hello.

Well, I reread the spec.

Managed flag and OtherConfig flag are maintained on a per-interface 
basis (RFC2462 5.2).

So, let's store them in inet6_dev{}.

Well, I haven't done kernel/userspace API for this;
We should do it via rtnetlink with IFLA_IF6INFO (struct ifla_if6info {
u32 ifla_if6flags; }) or something like this.
(Note: if_flags is type of u8, but It would be good to reserve 24bits for 
future extensions.)

If this idea seems ok, any voluteers? 
(I don't have enough time for writing this for now.)

Thanks.

Index: linux-2.5/include/net/if_inet6.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/if_inet6.h,v
retrieving revision 1.8
diff -u -r1.8 if_inet6.h
--- linux-2.5/include/net/if_inet6.h	16 May 2003 00:25:11 -0000	1.8
+++ linux-2.5/include/net/if_inet6.h	11 Jun 2003 05:40:20 -0000
@@ -17,6 +17,9 @@
 
 #include <net/snmp.h>
 
+/* inet6_dev.if_flags */
+#define IF_RA_OTHERCONF	0x80	/* Managed flag in RA */
+#define IF_RA_MANAGED	0x40	/* OtherConfig flag in RA */
 #define IF_RA_RCVD	0x20
 #define IF_RS_SENT	0x10
 
Index: linux-2.5/net/ipv6/ndisc.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ndisc.c,v
retrieving revision 1.38
diff -u -r1.38 ndisc.c
--- linux-2.5/net/ipv6/ndisc.c	7 Jun 2003 00:22:34 -0000	1.38
+++ linux-2.5/net/ipv6/ndisc.c	11 Jun 2003 05:40:20 -0000
@@ -1043,6 +1043,14 @@
 		in6_dev->if_flags |= IF_RA_RCVD;
 	}
 
+	/*
+	 * Remember the managed / otherconf flags from the most recently
+	 * received RA message (RFC2462) -- yoshfuji
+	 */
+	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED|IF_RA_OTHERCONF)) |
+			    (ra_msg->icmph.icmp6_addrconf_managed ? IF_RA_MANAGED : 0) |
+			    (ra_msg->icmph.icmp6_addrconf_other ? IF_RA_OTHERCONF : 0);
+
 	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);
 
 	rt = rt6_get_dflt_router(&skb->nh.ipv6h->saddr, skb->dev);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

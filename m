From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPV6: Incorrect hoplimit in ip6_push_pending_frames()
Date: Fri, 1 Aug 2003 14:15:21 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308011353520.16201-100000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0307041601570.15229-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org, <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0307041601570.15229-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I noticed the hop limit passed to ip6_append_data() isn't used by
ip6_push_pending_frames(), which might lead to unexpected behavior with
multicast and (ipv6-in-ipv6) tunneled packets. This patch (against Linux
2.6.0-test2 and cset 1.1595) fixes the problem.

Thanks,
Ville

diff -Nur linux-2.5.OLD/include/linux/ipv6.h linux-2.5/include/linux/ipv6.h
--- linux-2.5.OLD/include/linux/ipv6.h	Thu Jul 31 18:07:13 2003
+++ linux-2.5/include/linux/ipv6.h	Wed Jul 30 15:53:12 2003
@@ -189,6 +189,7 @@
 		struct ipv6_txoptions *opt;
 		struct rt6_info	*rt;
 		struct flowi *fl;
+		int hop_limit;
 	} cork;
 };

diff -Nur linux-2.5.OLD/net/ipv6/ip6_output.c linux-2.5/net/ipv6/ip6_output.c
--- linux-2.5.OLD/net/ipv6/ip6_output.c	Thu Jul 31 18:07:30 2003
+++ linux-2.5/net/ipv6/ip6_output.c	Wed Jul 30 22:11:51 2003
@@ -1243,6 +1243,7 @@
 		dst_hold(&rt->u.dst);
 		np->cork.rt = rt;
 		np->cork.fl = fl;
+		np->cork.hop_limit = hlimit;
 		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
 		inet->cork.length = 0;
 		inet->sndmsg_page = NULL;
@@ -1465,7 +1466,7 @@
 		hdr->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	else
 		hdr->payload_len = 0;
-	hdr->hop_limit = np->hop_limit;
+	hdr->hop_limit = np->cork.hop_limit;
 	hdr->nexthdr = proto;
 	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
 	ipv6_addr_copy(&hdr->daddr, final_dst);

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

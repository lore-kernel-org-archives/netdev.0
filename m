From: weidong <weid@nanjing-fnst.com>
Subject: [patch 1/1]SNMPv2 "ipv6IfStatsOutFragCreates" counter error
Date: Mon, 31 Jul 2006 09:23:13 +0000 (UTC)
Message-ID: <1154425539.3329.3.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:28818 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751332AbWGaJWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 05:22:33 -0400
To: netdev@vger.kernel.org, davem@davemloft.net
Date: Tue, 01 Aug 2006 05:45:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, All
  When I tested linux kernel 2.6.71.7 about statistics
"ipv6IfStatsOutFragCreates", and found that it couldn't increase
correctly. The criteria is RFC 2465:

  ipv6IfStatsOutFragCreates OBJECT-TYPE
      SYNTAX      Counter32
      MAX-ACCESS  read-only
      STATUS      current
      DESCRIPTION
         "The number of output datagram fragments that have
         been generated as a result of fragmentation at
         this output interface."
      ::= { ipv6IfStatsEntry 15 }

I think there are two issues in Linux kernel. 
1st:
RFC2465 specifies the counter is "The number of output datagram
fragments...". I think increasing this counter after output a fragment
successfully is better. And it should not be increased even though a
fragment is created but failed to output.

2nd:
If we send a big ICMP/ICMPv6 echo request to a host, and receive
ICMP/ICMPv6 echo reply consisted of some fragments. As we know that in
Linux kernel first fragmentation occurs in ICMP layer(maybe saying
transport layer is better), but this is not the "real"
fragmentation,just do some "pre-fragment" -- allocate space for date,
and form a frag_list, etc. The "real" fragmentation happens in IP layer
-- set offset and MF flag and so on. So I think in "fast path" for
ip_fragment/ip6_fragment, if we send a fragment which "pre-fragment" by
upper layer we should also increase "ipv6IfStatsOutFragCreates".

The following is the patch for the issues mentioned above:

diff -ruN old/net/ipv4/ip_output.c new/net/ipv4/ip_output.c
--- old/net/ipv4/ip_output.c	2006-07-25 11:36:01.000000000 +0800
+++ new/net/ipv4/ip_output.c	2006-07-31 16:24:57.000000000 +0800
@@ -527,6 +527,8 @@
 
 			err = output(skb);
 
+			if (!err)
+				IP_INC_STATS(IPSTATS_MIB_FRAGCREATES);
 			if (err || !frag)
 				break;
 
@@ -650,9 +652,6 @@
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
-
-		IP_INC_STATS(IPSTATS_MIB_FRAGCREATES);
-
 		iph->tot_len = htons(len + hlen);
 
 		ip_send_check(iph);
@@ -660,6 +659,8 @@
 		err = output(skb2);
 		if (err)
 			goto fail;
+
+		IP_INC_STATS(IPSTATS_MIB_FRAGCREATES);
 	}
 	kfree_skb(skb);
 	IP_INC_STATS(IPSTATS_MIB_FRAGOKS);
diff -ruN old/net/ipv6/ip6_output.c new/net/ipv6/ip6_output.c
--- old/net/ipv6/ip6_output.c	2006-07-25 11:36:01.000000000 +0800
+++ new/net/ipv6/ip6_output.c	2006-07-31 16:24:21.000000000 +0800
@@ -593,6 +593,9 @@
 			}
 			
 			err = output(skb);
+			if(!err)
+				IP6_INC_STATS(IPSTATS_MIB_FRAGCREATES);
+	
 			if (err || !frag)
 				break;
 
@@ -704,12 +707,11 @@
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
-
-		IP6_INC_STATS(IPSTATS_MIB_FRAGCREATES);
-
 		err = output(frag);
 		if (err)
 			goto fail;
+
+		IP6_INC_STATS(IPSTATS_MIB_FRAGCREATES);
 	}
 	kfree_skb(skb);
 	IP6_INC_STATS(IPSTATS_MIB_FRAGOKS);

signed-off-by: Wei Dong <weid@nanjing-fnst.com>
Regards
Wei Dong


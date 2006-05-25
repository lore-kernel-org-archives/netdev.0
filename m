From: Wei Dong <weid@nanjing-fnst.com>
Subject: MIB "ipInHdrErrors" error
Date: Thu, 25 May 2006 16:37:42 +0800
Message-ID: <1148546261.3038.14.camel@RHEL3GM>
Reply-To: weid@nanjing-fnst.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:9675 "EHLO localmail")
	by vger.kernel.org with ESMTP id S965084AbWEYIi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 04:38:27 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All:
    When I test linux kernel 2.6.9-34, and find that kernel statistics
about ipInHdrErrors which exsits in file /proc/net/snmp doesn't increase
correctly.  The criteria conform to RFC2011:

ipInHdrErrors OBJECT-TYPE
    SYNTAX      Counter32
    MAX-ACCESS  read-only
    STATUS      current
    DESCRIPTION
            "The number of input datagrams discarded due to errors in
            their IP headers, including bad checksums, version number
            mismatch, other format errors, time-to-live exceeded, errors
            discovered in processing their IP options, etc."

When kernel receives an IP packet containing error protocol in IP
header, kernel doesn't increase this counter "ipInHdrErrors". Also, when
kernel receives an IP packet and need to forward, but  TTL=1 or TTL=0,
kernel just sends an ICMP packet to inform the sender TTL count
exceeded, and doesn't increase this counter.

The patch for this problem is shown as the following:

diff -ruN old/net/ipv4/ip_forward.c new/net/ipv4/ip_forward.c
--- old/net/ipv4/ip_forward.c   2006-05-10 10:43:30.000000000 +0800
+++ new/net/ipv4/ip_forward.c   2006-05-12 15:06:57.000000000 +0800
@@ -120,6 +120,7 @@
 
 too_many_hops:
         /* Tell the sender its packet died... */
+        IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
         icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
        kfree_skb(skb);
diff -ruN old/net/ipv4/ip_input.c new/net/ipv4/ip_input.c
--- old/net/ipv4/ip_input.c     2006-05-10 10:43:31.000000000 +0800
+++ new/net/ipv4/ip_input.c     2006-05-12 15:07:27.000000000 +0800
@@ -249,6 +249,7 @@
                        if (!raw_sk) {
                                if (xfrm4_policy_check(NULL,
XFRM_POLICY_IN, skb)) {
                                        IP_INC_STATS_BH(IPSTATS_MIB_INUNKNOWNPROTOS);
+                                       IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
                                        icmp_send(skb,
ICMP_DEST_UNREACH,
                                                  ICMP_PROT_UNREACH, 0);
                                }

Signed-off-by: Wei Dong <weid@nanjing-fnst.com>

Regards
Wei Dong 



From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: flush cache according to 'preferred life time'
Date: Mon, 23 Jul 2012 07:36:52 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017DE48F@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:6970 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752073Ab2GWHhJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 03:37:09 -0400
Received: from mail189-tx2 (localhost [127.0.0.1])	by
 mail189-tx2-R.bigfish.com (Postfix) with ESMTP id 02B3D54022E	for
 <netdev@vger.kernel.org>; Mon, 23 Jul 2012 07:37:08 +0000 (UTC)
Received: from TX2EHSMHS041.bigfish.com (unknown [10.9.14.246])	by
 mail189-tx2.bigfish.com (Postfix) with ESMTP id 55BB2820045	for
 <netdev@vger.kernel.org>; Mon, 23 Jul 2012 07:37:06 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
    I am running test casees for IPv6 conformation on linux-3.0.26 kernel. Here I am facing a problem in routing advertisement. Once test case sets the 'preferred life time' to 20 seconds for a particular destination. And continuously sending ICMP REQUEST. It is expected that the ICMP_REPLY should stop in 20 seconds. But as because the default gc_interval is 30seconds, even after the timer expiry of the route, it is staying in the router cache. So even after 20 seconds, the nut(node under test) sends ICMP_REPLY. So if I changes gc_interval to 1, the test is getting passed.

    But if I changes gc_interval to 1 seconds another test case in pmtu section fails. It expects that the nut should hold pmtu(path mtu) information for different value. So if I flushes the cache, the pmtu value is turning back to default.

    So I made the kernel to alter its gc_interval value according to the 'preferred life time' of the path. Here is my path. Kindly tell me whether my idea is correct. Am I missing something?

--------------------------------------------------------------------------------------
--- ../linux-3.0.y-BRANCH_SS-RT.git.fresh/net/ipv6/ndisc.c.bak  2012-07-23 12:50:46.000000000 +0530
+++ ../linux-3.0.y-BRANCH_SS-RT.git.fresh/net/ipv6/ndisc.c      2012-07-23 12:54:17.000000000 +0530
@@ -1160,6 +1160,9 @@
 
        __u8 * opt = (__u8 *)(ra_msg + 1);
 
+        struct net *net = dev_net(skb->dev);
+        fib6_run_gc(1, net);
+
        optlen = (skb->tail - skb->transport_header) - sizeof(struct ra_msg);
 
        if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
@@ -1200,6 +1203,22 @@
                return;
        }
 
+        if (*opt == 3) {
+                printk("<8> IN OPT 3\n");
+                struct net *net = dev_net(skb->dev);
+                fib6_run_gc(1, net);
+                int pref_life_time =  ntohl(*((int *) (((char *) (opt)) + 8)));
+                if ((pref_life_time != 0) && (pref_life_time < 50)) {
+                        printk("<8> gc_interval CHANGED\n");
+                        //init_net.ipv6.sysctl.flush_delay = 1;
+                        init_net.ipv6.sysctl.ip6_rt_gc_interval = 1 * HZ;
+                }
+                else {
+                        init_net.ipv6.sysctl.ip6_rt_gc_interval = 30 * HZ;
+                }
+
+        }
+
        if (!accept_ra(in6_dev))
                goto skip_linkparms;
--------------------------------------------------------------------------------------

Note: This is not well structured. I just created it for temparory solution. Just clarify me whether this idea is right.

And Please let me know why pmtu value is not stored in routing table but only in cache.

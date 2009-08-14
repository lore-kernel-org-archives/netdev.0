From: Dmitry Labutcky <avl@strace.net>
Subject: ifb and gso problem
Date: Fri, 14 Aug 2009 12:50:11 +0300
Message-ID: <200908141250.11876.avl@strace.net>
Reply-To: avl@strace.net
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from debian.strace.net ([195.49.200.163]:42391 "EHLO
	debian.strace.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbZHNJ7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 05:59:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by debian.strace.net (Postfix) with ESMTP id E73D17B6BCD
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 12:50:12 +0300 (EEST)
Received: from debian.strace.net ([127.0.0.1])
	by localhost (debian.strace.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Syat1zDSVfDU for <netdev@vger.kernel.org>;
	Fri, 14 Aug 2009 12:50:12 +0300 (EEST)
Received: from mordor.strace.net (mordor.strace.net [195.49.201.22])
	by debian.strace.net (Postfix) with ESMTP id D5B207B00C7
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 12:50:12 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I found the problem when redirect egress traffic from ethernet device to ifb when gso is enabled
on ethernet device.

Scenario like this:

eth0: 192.168.1.1/24

# modprobe ifb
# ifconfig ifb0 up
# tc qdisc del dev eth0 root 2>/dev/null
# tc qdisc add dev eth0 root handle 1: htb
# tc qdisc add dev ifb0 root handle 1: prio
# tc filter add dev eth0 parent 1: protocol ip u32 match ip src 192.168.1.1/32 action mirred egress redirect dev ifb0

# ethtool -k eth0
Offload parameters for eth0:
Cannot get device flags: Operation not supported
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: off
large-receive-offload: off

When downloading from 192.168.1.1, speed not exceeds 256-300kbit/s on 100mbit link.
After disabling gso - speed becomes 100mbit/s.

Patch below fixed this problem.

# diff -u work/linux-source-2.6.30/net/core/skbuff.c linux-source-2.6.30/net/core/skbuff.c 
--- work/linux-source-2.6.30/net/core/skbuff.c  2009-06-10 06:05:27.000000000 +0300
+++ linux-source-2.6.30/net/core/skbuff.c       2009-08-14 08:54:21.000000000 +0300
@@ -518,6 +518,7 @@
 {
        new->tstamp             = old->tstamp;
        new->dev                = old->dev;
+       new->iif                = old->iif;
        new->transport_header   = old->transport_header;
        new->network_header     = old->network_header;
        new->mac_header         = old->mac_header;
@@ -569,7 +570,6 @@
        n->cloned = 1;
        n->nohdr = 0;
        n->destructor = NULL;
-       C(iif);
        C(tail);
        C(end);
        C(head);


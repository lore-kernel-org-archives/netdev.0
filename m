From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 10:58:09 +0200
Message-ID: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60239 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177Ab2FNI6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 04:58:30 -0400
Received: by wgbdr13 with SMTP id dr13so1656679wgb.1
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 01:58:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have bisected a regression which concerns TX throughput when using bonding.
I tested only with 10Gbps cards, as it appears when bandwidth need is
over 1Gbps on my machine.
I send UDP multicast packets over bonding and observe the tc result.

When KO :
$>tc -s -d qdisc show dev eth1
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1
1 1 1 1 1 1
 Sent 1106527591 bytes 273802 pkt (dropped 306419, overlimits 0 requeues 223)
 backlog 0b 0p requeues 223

Ok course, when OK, dropped is 0.
$>tc -s -d qdisc show dev eth1
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1
1 1 1 1 1 1
 Sent 1648662087 bytes 408009 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0


Here is the incriminated commit:

fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5 is the first bad commit
commit fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Fri Apr 16 12:18:22 2010 +0000

    net: Introduce skb_orphan_try()

    Transmitted skb might be attached to a socket and a destructor, for
    memory accounting purposes.

    Traditionally, this destructor is called at tx completion time, when skb
    is freed.

    When tx completion is performed by another cpu than the sender, this
    forces some cache lines to change ownership. XPS was an attempt to give
    tx completion to initial cpu.

    David idea is to call destructor right before giving skb to device (call
    to ndo_start_xmit()). Because device queues are usually small, orphaning
    skb before tx completion is not a big deal. Some drivers already do
    this, we could do it in upper level.

    There is one known exception to this early orphaning, called tx
    timestamping. It needs to keep a reference to socket until device can
    give a hardware or software timestamp.

    This patch adds a skb_orphan_try() helper, to centralize all exceptions
    to early orphaning in one spot, and use it in dev_hard_start_xmit().

    "tbench 16" results on a Nehalem machine (2 X5570  @ 2.93GHz)
    before: Throughput 4428.9 MB/sec 16 procs
    after: Throughput 4448.14 MB/sec 16 procs

    UDP should get even better results, its destructor being more complex,
    since SOCK_USE_WRITE_QUEUE is not set (four atomic ops instead of one)

    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

JM

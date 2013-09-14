From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next 0/2] bridge: fix NULL pointer deref of br_port_get_rcu
Date: Sat, 14 Sep 2013 22:42:26 +0800
Message-ID: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:60183 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab3INOoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 10:44:39 -0400
Received: by mail-pd0-f171.google.com with SMTP id g10so2388369pdj.30
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 07:44:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

I got an Oops on my box when br_handle_frame is called between these
2 lines of del_nbp:
	dev->priv_flags &= ~IFF_BRIDGE_PORT;
	/* --> br_handle_frame is called at this time */
	netdev_rx_handler_unregister(dev);

In br_handle_frame the return of br_port_get_rcu(dev) is dereferenced
without check but br_port_get_rcu(dev) returns NULL if:
	!(dev->priv_flags & IFF_BRIDGE_PORT)

Eric Dumazet pointed out the testing of IFF_BRIDGE_PORT is not necessary
here since we're in rcu_read_lock and we have synchronize_net() in
netdev_rx_handler_unregister. So removed the testing of
IFF_BRIDGE_PORT.

I tested the fix on my box with script doing "brctl addif" and "brctl
delif" repeatedly while a lot of broadcast frame present on the LAN.
I added msleep in del_nbp between setting of priv_flags and unregister
so it's easy to reproduce the oops without the fix.

I want to remove the NULL checks following call to br_port_get_rcu in
Br_netfilter and ebtables code. Could someone confirm that's OK?

The Oops(some lines omitted):
BUG: unable to handle kernel NULL pointer dereference at 0000000000000021
IP: [<ffffffff8150901d>] br_handle_frame+0xed/0x230
Oops: 0000 [#1] PREEMPT SMP
RIP: 0010:[<ffffffff8150901d>]  [<ffffffff8150901d>] br_handle_frame+0xed/0x230
RSP: 0018:ffff880030403c10  EFLAGS: 00010286
Stack:
 ffff88002c945700 ffffffff81508f30 0000000000000000 ffff88002d41e000
 ffff880030403c98 ffffffff81477acb ffffffff81477821 ffff880030403c68
 ffffffff81090e10 00ff88002d545c80 ffff88002c945700 ffffffff81aa50c0
Call Trace:
 <IRQ>
 [<ffffffff81508f30>] ? br_handle_frame_finish+0x300/0x300
 [<ffffffff81477acb>] __netif_receive_skb_core+0x39b/0x880

Hong Zhiguo (2):
  bridge: use br_port_get_rtnl within rtnl lock
  bridge: fix NULL pointer deref of br_port_get_rcu

 net/bridge/br_netlink.c | 4 ++--
 net/bridge/br_private.h | 7 ++-----
 2 files changed, 4 insertions(+), 7 deletions(-)

-- 
1.8.1.2

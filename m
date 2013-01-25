From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: loopback: fix a dst refcounting issue
Date: Fri, 25 Jan 2013 09:44:41 -0800
Message-ID: <1359135881.12374.3249.camel@edumazet-glaptop>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
	 <1358875607.3464.4020.camel@edumazet-glaptop>
	 <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>
	 <5100785D.8040101@candelatech.com>
	 <1358985688.12374.1247.camel@edumazet-glaptop>
	 <51007CA8.2050105@candelatech.com>
	 <1358987031.12374.1276.camel@edumazet-glaptop>
	 <51008294.2010201@candelatech.com>
	 <1358988358.12374.1303.camel@edumazet-glaptop>
	 <51008598.4000603@candelatech.com>
	 <1358989242.12374.1323.camel@edumazet-glaptop>
	 <51008900.2010803@candelatech.com>
	 <1358989843.12374.1334.camel@edumazet-glaptop>
	 <1358991906.12374.1356.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:57915 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab3AYRos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 12:44:48 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so273923dal.15
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 09:44:48 -0800 (PST)
In-Reply-To: <1358991906.12374.1356.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Ben Greear reported crashes in ip_rcv_finish() on a stress
test involving many macvlans.

We tracked the bug to a dst use after free. ip_rcv_finish()
was calling dst->input() and got garbage for dst->input value.

It appears the bug is in loopback driver, lacking
a skb_dst_force() before calling netif_rx().

As a result, a non refcounted dst, normally protected by a
RCU read_lock section, was escaping this section and could
be freed before the packet being processed.

  [<ffffffff813a3c4d>] loopback_xmit+0x64/0x83
  [<ffffffff81477364>] dev_hard_start_xmit+0x26c/0x35e
  [<ffffffff8147771a>] dev_queue_xmit+0x2c4/0x37c
  [<ffffffff81477456>] ? dev_hard_start_xmit+0x35e/0x35e
  [<ffffffff8148cfa6>] ? eth_header+0x28/0xb6
  [<ffffffff81480f09>] neigh_resolve_output+0x176/0x1a7
  [<ffffffff814ad835>] ip_finish_output2+0x297/0x30d
  [<ffffffff814ad6d5>] ? ip_finish_output2+0x137/0x30d
  [<ffffffff814ad90e>] ip_finish_output+0x63/0x68
  [<ffffffff814ae412>] ip_output+0x61/0x67
  [<ffffffff814ab904>] dst_output+0x17/0x1b
  [<ffffffff814adb6d>] ip_local_out+0x1e/0x23
  [<ffffffff814ae1c4>] ip_queue_xmit+0x315/0x353
  [<ffffffff814adeaf>] ? ip_send_unicast_reply+0x2cc/0x2cc
  [<ffffffff814c018f>] tcp_transmit_skb+0x7ca/0x80b
  [<ffffffff814c3571>] tcp_connect+0x53c/0x587
  [<ffffffff810c2f0c>] ? getnstimeofday+0x44/0x7d
  [<ffffffff810c2f56>] ? ktime_get_real+0x11/0x3e
  [<ffffffff814c6f9b>] tcp_v4_connect+0x3c2/0x431
  [<ffffffff814d6913>] __inet_stream_connect+0x84/0x287
  [<ffffffff814d6b38>] ? inet_stream_connect+0x22/0x49
  [<ffffffff8108d695>] ? _local_bh_enable_ip+0x84/0x9f
  [<ffffffff8108d6c8>] ? local_bh_enable+0xd/0x11
  [<ffffffff8146763c>] ? lock_sock_nested+0x6e/0x79
  [<ffffffff814d6b38>] ? inet_stream_connect+0x22/0x49
  [<ffffffff814d6b49>] inet_stream_connect+0x33/0x49
  [<ffffffff814632c6>] sys_connect+0x75/0x98

This bug was introduced in linux-2.6.35, in commit
7fee226ad2397b (net: add a noref bit on skb dst)

skb_dst_force() is enforced in dev_queue_xmit() for devices having a
qdisc. 

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/loopback.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 81f8f9e..fcbf680 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -77,6 +77,11 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 
 	skb_orphan(skb);
 
+	/* Before queueing this packet to netif_rx(),
+	 * make sure dst is refcounted.
+	 */
+	skb_dst_force(skb);
+
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */

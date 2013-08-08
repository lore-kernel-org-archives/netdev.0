From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] macvtap: fix two races
Date: Thu, 08 Aug 2013 08:06:14 -0700
Message-ID: <1375974374.4004.103.camel@edumazet-glaptop>
References: <20130807164319.20aa2333@thhw500>
	 <1375889211.4004.28.camel@edumazet-glaptop>
	 <20130808102551.6aa47852@thhw500>
	 <1375968072.4004.92.camel@edumazet-glaptop>
	 <20130808155634.239dbc2d@thhw500>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Thomas Huth <thuth@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47200 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965702Ab3HHPGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 11:06:17 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so3360742pbb.6
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 08:06:16 -0700 (PDT)
In-Reply-To: <20130808155634.239dbc2d@thhw500>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since commit ac4e4af1e59e1 ("macvtap: Consistently use rcu functions"),
Thomas gets two different warnings :

BUG: using smp_processor_id() in preemptible [00000000] code: vhost-45891/45892
caller is macvtap_do_read+0x45c/0x600 [macvtap]
CPU: 1 PID: 45892 Comm: vhost-45891 Not tainted 3.11.0-bisecttest #13
Call Trace:
([<00000000001126ee>] show_trace+0x126/0x144)
 [<00000000001127d2>] show_stack+0xc6/0xd4
 [<000000000068bcec>] dump_stack+0x74/0xd8
 [<0000000000481066>] debug_smp_processor_id+0xf6/0x114
 [<000003ff802e9a18>] macvtap_do_read+0x45c/0x600 [macvtap]
 [<000003ff802e9c1c>] macvtap_recvmsg+0x60/0x88 [macvtap]
 [<000003ff80318c5e>] handle_rx+0x5b2/0x800 [vhost_net]
 [<000003ff8028f77c>] vhost_worker+0x15c/0x1c4 [vhost]
 [<000000000015f3ac>] kthread+0xd8/0xe4
 [<00000000006934a6>] kernel_thread_starter+0x6/0xc
 [<00000000006934a0>] kernel_thread_starter+0x0/0xc

And

BUG: using smp_processor_id() in preemptible [00000000] code: vhost-45897/45898
caller is macvlan_start_xmit+0x10a/0x1b4 [macvlan]
CPU: 1 PID: 45898 Comm: vhost-45897 Not tainted 3.11.0-bisecttest #16
Call Trace:
([<00000000001126ee>] show_trace+0x126/0x144)
 [<00000000001127d2>] show_stack+0xc6/0xd4
 [<000000000068bdb8>] dump_stack+0x74/0xd4
 [<0000000000481132>] debug_smp_processor_id+0xf6/0x114
 [<000003ff802b72ca>] macvlan_start_xmit+0x10a/0x1b4 [macvlan]
 [<000003ff802ea69a>] macvtap_get_user+0x982/0xbc4 [macvtap]
 [<000003ff802ea92a>] macvtap_sendmsg+0x4e/0x60 [macvtap]
 [<000003ff8031947c>] handle_tx+0x494/0x5ec [vhost_net]
 [<000003ff8028f77c>] vhost_worker+0x15c/0x1c4 [vhost]
 [<000000000015f3ac>] kthread+0xd8/0xe4
 [<000000000069356e>] kernel_thread_starter+0x6/0xc
 [<0000000000693568>] kernel_thread_starter+0x0/0xc
2 locks held by vhost-45897/45898:
 #0:  (&vq->mutex){+.+.+.}, at: [<000003ff8031903c>] handle_tx+0x54/0x5ec [vhost_net]
 #1:  (rcu_read_lock){.+.+..}, at: [<000003ff802ea53c>] macvtap_get_user+0x824/0xbc4 [macvtap]


In the first case, macvtap_put_user() calls macvlan_count_rx()
in a preempt-able context, and this is not allowed.

In the second case, macvtap_get_user() calls
macvlan_start_xmit() with BH enabled, and this is not allowed.
 
Reported-by: Thomas Huth <thuth@linux.vnet.ibm.com>
Bisected-by: Thomas Huth <thuth@linux.vnet.ibm.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Thomas Huth <thuth@linux.vnet.ibm.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a98fb0e..b51db2a 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -818,10 +818,13 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	}
-	if (vlan)
+	if (vlan) {
+		local_bh_disable();
 		macvlan_start_xmit(skb, vlan->dev);
-	else
+		local_bh_enable();
+	} else {
 		kfree_skb(skb);
+	}
 	rcu_read_unlock();
 
 	return total_len;
@@ -912,8 +915,11 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 done:
 	rcu_read_lock();
 	vlan = rcu_dereference(q->vlan);
-	if (vlan)
+	if (vlan) {
+		preempt_disable();
 		macvlan_count_rx(vlan, copied - vnet_hdr_len, ret == 0, 0);
+		preempt_enable();
+	}
 	rcu_read_unlock();
 
 	return ret ? ret : copied;

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v3 4/5] ipvlan: use rcu_deference_bh() in ipvlan_queue_xmit()
Date: Tue, 14 Jul 2015 16:35:54 +0300
Message-ID: <20150714133554.22448.46602.stgit@buzz>
References: <20150714132941.22448.42175.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: linux-netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:59166 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752880AbbGNNf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 09:35:57 -0400
In-Reply-To: <20150714132941.22448.42175.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <xiyou.wangcong@gmail.com>

In tx path rcu_read_lock_bh() is held, so we need rcu_deference_bh().
This fixes the following warning:

 ===============================
 [ INFO: suspicious RCU usage. ]
 4.1.0-rc1+ #1007 Not tainted
 -------------------------------
 drivers/net/ipvlan/ipvlan.h:106 suspicious rcu_dereference_check() usage!

 other info that might help us debug this:

 rcu_scheduler_active = 1, debug_locks = 0
 1 lock held by dhclient/1076:
  #0:  (rcu_read_lock_bh){......}, at: [<ffffffff817e8d84>] rcu_lock_acquire+0x0/0x26

 stack backtrace:
 CPU: 2 PID: 1076 Comm: dhclient Not tainted 4.1.0-rc1+ #1007
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  0000000000000001 ffff8800d381bac8 ffffffff81a4154f 000000003c1a3c19
  ffff8800d4d0a690 ffff8800d381baf8 ffffffff810b849f ffff880117d41148
  ffff880117d40000 ffff880117d40068 0000000000000156 ffff8800d381bb18
 Call Trace:
  [<ffffffff81a4154f>] dump_stack+0x4c/0x65
  [<ffffffff810b849f>] lockdep_rcu_suspicious+0x107/0x110
  [<ffffffff8165a522>] ipvlan_port_get_rcu+0x47/0x4e
  [<ffffffff8165ad14>] ipvlan_queue_xmit+0x35/0x450
  [<ffffffff817ea45d>] ? rcu_read_unlock+0x3e/0x5f
  [<ffffffff810a20bf>] ? local_clock+0x19/0x22
  [<ffffffff810b4781>] ? __lock_is_held+0x39/0x52
  [<ffffffff8165b64c>] ipvlan_start_xmit+0x1b/0x44
  [<ffffffff817edf7f>] dev_hard_start_xmit+0x2ae/0x467
  [<ffffffff817ee642>] __dev_queue_xmit+0x50a/0x60c
  [<ffffffff817ee7a7>] dev_queue_xmit_sk+0x13/0x15
  [<ffffffff81997596>] dev_queue_xmit+0x10/0x12
  [<ffffffff8199b41c>] packet_sendmsg+0xb6b/0xbdf
  [<ffffffff810b5ea7>] ? mark_lock+0x2e/0x226
  [<ffffffff810a1fcc>] ? sched_clock_cpu+0x9e/0xb7
  [<ffffffff817d56f9>] sock_sendmsg_nosec+0x12/0x1d
  [<ffffffff817d7257>] sock_sendmsg+0x29/0x2e
  [<ffffffff817d72cc>] sock_write_iter+0x70/0x91
  [<ffffffff81199563>] __vfs_write+0x7e/0xa7
  [<ffffffff811996bc>] vfs_write+0x92/0xe8
  [<ffffffff811997d7>] SyS_write+0x47/0x7e
  [<ffffffff81a4d517>] system_call_fastpath+0x12/0x6f

Fixes: 2ad7bf363841 ("ipvlan: Initial check-in of the IPVLAN driver.")
Cc: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ipvlan/ipvlan.h      |    5 +++++
 drivers/net/ipvlan/ipvlan_core.c |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 40f9d7e4a0ea..9542b7bac61a 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -104,6 +104,11 @@ static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
 	return rcu_dereference(d->rx_handler_data);
 }
 
+static inline struct ipvl_port *ipvlan_port_get_rcu_bh(const struct net_device *d)
+{
+	return rcu_dereference_bh(d->rx_handler_data);
+}
+
 static inline struct ipvl_port *ipvlan_port_get_rtnl(const struct net_device *d)
 {
 	return rtnl_dereference(d->rx_handler_data);
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8f8628a0adba..207f62e8de9a 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -529,7 +529,7 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
-	struct ipvl_port *port = ipvlan_port_get_rcu(ipvlan->phy_dev);
+	struct ipvl_port *port = ipvlan_port_get_rcu_bh(ipvlan->phy_dev);
 
 	if (!port)
 		goto out;

From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next 2/4] macvtap: Consistently use rcu functions
Date: Tue, 25 Jun 2013 16:04:20 -0400
Message-ID: <1372190662-30815-3-git-send-email-vyasevic@redhat.com>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751619Ab3FYUEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 16:04:31 -0400
In-Reply-To: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently macvtap uses rcu_bh functions in its
user facing fuction macvtap_get_user() and macvtap_put_user().
However, its packet handlers use normal rcu as the rcu_read_lock()
is taken in netif_receive_skb().  We can safely discontinue
the usage or rcu with bh disabled.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index efbf2eb..d7856a8 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -754,8 +754,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 
 	skb_probe_transport_header(skb, ETH_HLEN);
 
-	rcu_read_lock_bh();
-	vlan = rcu_dereference_bh(q->vlan);
+	rcu_read_lock();
+	vlan = rcu_dereference(q->vlan);
 	/* copy skb_ubuf_info for callback when skb has no error */
 	if (zerocopy) {
 		skb_shinfo(skb)->destructor_arg = m->msg_control;
@@ -766,7 +766,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 		macvlan_start_xmit(skb, vlan->dev);
 	else
 		kfree_skb(skb);
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	return total_len;
 
@@ -774,11 +774,11 @@ err_kfree:
 	kfree_skb(skb);
 
 err:
-	rcu_read_lock_bh();
-	vlan = rcu_dereference_bh(q->vlan);
+	rcu_read_lock();
+	vlan = rcu_dereference(q->vlan);
 	if (vlan)
 		vlan->dev->stats.tx_dropped++;
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	return err;
 }
@@ -854,11 +854,11 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 	copied += len;
 
 done:
-	rcu_read_lock_bh();
-	vlan = rcu_dereference_bh(q->vlan);
+	rcu_read_lock();
+	vlan = rcu_dereference(q->vlan);
 	if (vlan)
 		macvlan_count_rx(vlan, copied - vnet_hdr_len, ret == 0, 0);
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	return ret ? ret : copied;
 }
-- 
1.8.1.4

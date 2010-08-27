From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next 2/2] macvlan:  Enable qdisc backoff logic.
Date: Fri, 27 Aug 2010 15:16:11 +0200
Message-ID: <201008271516.11295.arnd@arndb.de>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com> <201008261555.35250.arnd@arndb.de> <4C76A856.2040202@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:64433 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab0H0NQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 09:16:27 -0400
In-Reply-To: <4C76A856.2040202@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 26 August 2010, Ben Greear wrote:
> I think this will keep today's functionality.  Someone that knows and uses this
> code might can figure out how to properly do backpressure to calling code
> and re-queue the skb instead of just deleting it when the underlying device
> complains of being busy.

I think at the very least it needs to return -EAGAIN to the user, like this
(untested) fragment. I'm not sure if the poll() logic works correctly here,
will need to check that. In the worst case, the user would retransmit
immediately again.

Qemu calls poll() on the fd if it receives -EAGAIN, and macvtap waits for
the internal socket to become writable using 

        if (sock_writeable(&q->sk) ||
            (!test_and_set_bit(SOCK_ASYNC_NOSPACE, &q->sock.flags) &&
             sock_writeable(&q->sk)))
                mask |= POLLOUT | POLLWRNORM;

It seems that this code was never tested though, since we never returned
-EAGAIN before.

I'm also not sure how vhost handles -EAGAIN in the transmit path.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3b1c54a..37bde69 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -506,8 +506,13 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 
 	rcu_read_lock_bh();
 	vlan = rcu_dereference(q->vlan);
-	if (vlan)
-		macvlan_start_xmit(skb, vlan->dev);
+	if (vlan) {
+		err = macvlan_start_xmit(skb, vlan->dev);
+		if (err == NETDEV_TX_BUSY) {
+			kfree_skb(skb);
+			count = -EAGAIN;
+		}
+	}
 	else
 		kfree_skb(skb);
 	rcu_read_unlock_bh();

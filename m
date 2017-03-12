From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] tun: fix premature POLLOUT notification on tun devices
Date: Mon, 13 Mar 2017 00:00:26 +0100
Message-ID: <20170312230026.4632-1-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
        Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
        Jonas Lippuner <jonas@lippuner.ca>,
        aszlig <aszlig@redmoonstudios.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57342 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933224AbdCLXAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:00:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aszlig observed failing ssh tunnels (-w) during initialization since
commit cc9da6cc4f56e0 ("ipv6: addrconf: use stable address generator for
ARPHRD_NONE"). We already had reports that the mentioned commit breaks
Juniper VPN connections. I can't clearly say that the Juniper VPN client
has the same problem, but it is worth a try to hint to this patch.

Because of the early generation of link local addresses, the kernel now
can start asking for routers on the local subnet much earlier than usual.
Those router solicitation packets arrive inside the ssh channels and
should be transmitted to the tun fd before the configuration scripts
might have upped the interface and made it ready for transmission.

ssh polls on the interface and receives back a POLL_OUT. It tries to send
the earily router solicitation packet to the tun interface.  Unfortunately
it hasn't been up'ed yet by config scripts, thus failing with -EIO. ssh
doesn't retry again and considers the tun interface broken forever.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=121131
Fixes: cc9da6cc4f56 ("ipv6: addrconf: use stable address generator for ARPHRD_NONE")
Cc: Bjørn Mork <bjorn@mork.no>
Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Reported-by: Jonas Lippuner <jonas@lippuner.ca>
Cc: Jonas Lippuner <jonas@lippuner.ca>
Reported-by: aszlig <aszlig@redmoonstudios.org>
Cc: aszlig <aszlig@redmoonstudios.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/tun.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f58b7d850114b0..34cc3c590aa5c5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -822,7 +822,18 @@ static void tun_net_uninit(struct net_device *dev)
 /* Net device open. */
 static int tun_net_open(struct net_device *dev)
 {
+	struct tun_struct *tun = netdev_priv(dev);
+	int i;
+
 	netif_tx_start_all_queues(dev);
+
+	for (i = 0; i < tun->numqueues; i++) {
+		struct tun_file *tfile;
+
+		tfile = rtnl_dereference(tun->tfiles[i]);
+		tfile->socket.sk->sk_write_space(tfile->socket.sk);
+	}
+
 	return 0;
 }
 
@@ -1103,9 +1114,10 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
 	if (!skb_array_empty(&tfile->tx_array))
 		mask |= POLLIN | POLLRDNORM;
 
-	if (sock_writeable(sk) ||
-	    (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
-	     sock_writeable(sk)))
+	if (tun->dev->flags & IFF_UP &&
+	    (sock_writeable(sk) ||
+	     (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
+	      sock_writeable(sk))))
 		mask |= POLLOUT | POLLWRNORM;
 
 	if (tun->dev->reg_state != NETREG_REGISTERED)
-- 
2.9.3

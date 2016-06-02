From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/2] tun: Configure Rx queues to default to RPS
 enabled
Date: Wed, 01 Jun 2016 18:17:24 -0700
Message-ID: <20160602011724.9319.15659.stgit@localhost.localdomain>
References: <20160602010741.9319.56926.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36700 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbcFBBR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 21:17:26 -0400
Received: by mail-pf0-f174.google.com with SMTP id f144so24360557pfa.3
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 18:17:26 -0700 (PDT)
In-Reply-To: <20160602010741.9319.56926.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables tun/tap interfaces to use RPS by default.  The
motivation behind this is to address the fact that the interfaces are
currently using netif_rx_ni which in turn will queue packets on whatever
CPU the function is called on, and when combined with load balancing this
can result in packets being received out of order.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/tun.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e16487cc6a9a..51555daaa6e4 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -646,7 +646,6 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 	tfile->socket.sk->sk_shutdown &= ~RCV_SHUTDOWN;
 	rcu_assign_pointer(tfile->tun, tun);
 	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
-	tun->numqueues++;
 
 	if (tfile->detached)
 		tun_enable_queue(tfile);
@@ -655,6 +654,9 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 
 	tun_set_real_num_queues(tun);
 
+	netif_set_rps_cpus(tun->dev, cpu_online_mask, tun->numqueues);
+	tun->numqueues++;
+
 	/* device is allowed to go away first, so no need to hold extra
 	 * refcnt.
 	 */

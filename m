From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] net: do not process device backlog during unregistration
Date: Sat, 27 Jun 2015 19:02:51 +0300
Message-ID: <1435420971-19263-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47408 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751498AbbF0QDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Jun 2015 12:03:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 381c759d9916 ("ipv4: Avoid crashing in ip_error")
fixes a problem where processed packet comes from device
with destroyed inetdev (dev->ip_ptr). This is not expected
because inetdev_destroy is called in NETDEV_UNREGISTER
phase and packets should not be processed after
dev_close_many() and synchronize_net(). But backlog
processing is deactivated later after NETDEV_UNREGISTER_FINAL
phase which allows CPUs to initiate processing for new
packets during and after the NETDEV_UNREGISTER phase.

Fix it by moving flush_backlog after the device driver
is stopped and before the synchronize_net() call. This
allows dev->ip_ptr to be always valid during packet
processing.

Reported-by: Vittorio Gambaletta <linuxbugs@vittgam.net>
Fixes: 6e583ce5242f ("net: eliminate refcounting in backlog queue")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/core/dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Tested by reverting commit 381c759d9916 and using the
test commands provided by Eric Biederman:

http://marc.info/?l=linux-netdev&m=143239231905533&w=2

Problem does not occur every time. SMP may be needed
to reproduce.

diff --git a/net/core/dev.c b/net/core/dev.c
index aa82f9a..67132b3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6027,6 +6027,7 @@ static void rollback_registered_many(struct list_head *head)
 		unlist_netdevice(dev);
 
 		dev->reg_state = NETREG_UNREGISTERING;
+		on_each_cpu(flush_backlog, dev, 1);
 	}
 
 	synchronize_net();
@@ -6650,8 +6651,6 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
-
 		netdev_wait_allrefs(dev);
 
 		/* paranoia */
-- 
1.9.3

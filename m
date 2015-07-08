From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/2] net: pktgen: fix race between pktgen_thread_worker()
	and kthread_stop()
Date: Wed, 8 Jul 2015 21:42:11 +0200
Message-ID: <20150708194211.GA26552@redhat.com>
References: <20150708194154.GA26534@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Stancek <jstancek@redhat.com>,
	Marcelo Leitner <mleitner@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758792AbbGHTnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 15:43:45 -0400
Content-Disposition: inline
In-Reply-To: <20150708194154.GA26534@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pktgen_thread_worker() is obviously racy, kthread_stop() can come
between the kthread_should_stop() check and set_current_state().

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Reported-by: Jan Stancek <jstancek@redhat.com>
Reported-by: Marcelo Leitner <mleitner@redhat.com>
---
 net/core/pktgen.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 508155b..043ea18 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3490,8 +3490,10 @@ static int pktgen_thread_worker(void *arg)
 	pktgen_rem_thread(t);
 
 	/* Wait for kthread_stop */
-	while (!kthread_should_stop()) {
+	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
+		if (kthread_should_stop())
+			break;
 		schedule();
 	}
 	__set_current_state(TASK_RUNNING);
-- 
1.5.5.1

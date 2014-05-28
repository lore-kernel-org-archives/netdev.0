From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] af_iucv: correct cleanup if listen backlog is full
Date: Wed, 28 May 2014 10:22:29 +0200
Message-ID: <20140528082239.780317437@de.ibm.com>
References: <20140528082227.024995099@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Philipp Hachtmann <phacht@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:57640 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263AbaE1IWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 04:22:47 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 28 May 2014 09:22:45 +0100
Content-Disposition: inline; filename=606-af-iucv-fix-cleanup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

In case of transport HIPER a sock struct is allocated for an incoming
connect request. If the backlog queue is full this socket is not
needed, but is left in the list of af_iucv sockets. Final socket
release posts console message "Attempt to release alive iucv socket".
This patch makes sure the new created socket is cleaned up correctly
if the backlog queue is full.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reported-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 60f5c20..7a95fa4 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1943,11 +1943,10 @@ static int afiucv_hs_callback_syn(struct sock *sk, struct sk_buff *skb)
 	    sk_acceptq_is_full(sk) ||
 	    !nsk) {
 		/* error on server socket - connection refused */
-		if (nsk)
-			sk_free(nsk);
 		afiucv_swap_src_dest(skb);
 		trans_hdr->flags = AF_IUCV_FLAG_SYN | AF_IUCV_FLAG_FIN;
 		err = dev_queue_xmit(skb);
+		iucv_sock_kill(nsk);
 		bh_unlock_sock(sk);
 		goto out;
 	}

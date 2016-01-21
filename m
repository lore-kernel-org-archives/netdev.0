From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/3] sctp: hold transport before we access t->asoc in sctp proc
Date: Fri, 22 Jan 2016 01:49:08 +0800
Message-ID: <4357f1f3ad90ffec1481a265d8ca198d75e25d07.1453398443.git.lucien.xin@gmail.com>
References: <cover.1453398443.git.lucien.xin@gmail.com>
 <9f366422b6a8c6c0c939ccbf993548c1881a2c16.1453398443.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33796 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759914AbcAURtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 12:49:23 -0500
In-Reply-To: <9f366422b6a8c6c0c939ccbf993548c1881a2c16.1453398443.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1453398443.git.lucien.xin@gmail.com>
References: <cover.1453398443.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, before rhashtable, /proc assoc listing was done by
read-locking the entire hash entry and dumping all assocs at once, so we
were sure that the assoc wasn't freed because it wouldn't be possible to
remove it from the hash meanwhile.

Now we use rhashtable to list transports, and dump entries one by one.
That is, now we have to check if the assoc is still a good one, as the
transport we got may be being freed.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/proc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 684c5b3..c74a810 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -380,6 +380,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	}
 
 	transport = (struct sctp_transport *)v;
+	if (!sctp_transport_hold(transport))
+		return 0;
 	assoc = transport->asoc;
 	epb = &assoc->base;
 	sk = epb->sk;
@@ -412,6 +414,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		sk->sk_rcvbuf);
 	seq_printf(seq, "\n");
 
+	sctp_transport_put(transport);
+
 	return 0;
 }
 
@@ -489,6 +493,8 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 	}
 
 	tsp = (struct sctp_transport *)v;
+	if (!sctp_transport_hold(tsp))
+		return 0;
 	assoc = tsp->asoc;
 
 	list_for_each_entry_rcu(tsp, &assoc->peer.transport_addr_list,
@@ -544,6 +550,8 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "\n");
 	}
 
+	sctp_transport_put(tsp);
+
 	return 0;
 }
 
-- 
2.1.0

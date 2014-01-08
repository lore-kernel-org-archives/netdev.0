From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] unix: show socket peer if no addr is given in /proc/net/unix
Date: Wed,  8 Jan 2014 14:18:08 +0900
Message-ID: <1389158288-2855-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbaAHFSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 00:18:24 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s085IOZQ007482
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 8 Jan 2014 00:18:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Path field of /proc/net/unix is empty if an address is not given
to a socket. Typical way to create such socket is calling
socketpair. The empty fields make it difficult to understand the
communication between processes. e.g. lsof cannot resolve the role of
file descriptors well.

This patch fills the empty fields with unix_peer.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/unix/af_unix.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 800ca61..1700133 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2340,7 +2340,9 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 	else {
 		struct sock *s = v;
 		struct unix_sock *u = unix_sk(s);
+		struct sock *s_peer;
 		unix_state_lock(s);
+		s_peer = unix_peer(s);
 
 		seq_printf(seq, "%pK: %08X %08X %08X %04X %02X %5lu",
 			s,
@@ -2367,7 +2369,8 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 			}
 			for ( ; i < len; i++)
 				seq_putc(seq, u->addr->name->sun_path[i]);
-		}
+		} else if (s_peer)
+			seq_printf(seq, " #%pK", s_peer);
 		unix_state_unlock(s);
 		seq_putc(seq, '\n');
 	}
-- 
1.8.4.2

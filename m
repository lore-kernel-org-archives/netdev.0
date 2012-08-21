From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] af_netlink: force credentials passing [CVE-2012-3520]
Date: Tue, 21 Aug 2012 18:21:17 +0200
Message-ID: <1345566077.5158.530.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Petr Matousek <pmatouse@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60104 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217Ab2HUQVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 12:21:23 -0400
Received: by bkwj10 with SMTP id j10so2253226bkw.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 09:21:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Pablo Neira Ayuso discovered that avahi and 
potentially NetworkManager accept spoofed Netlink messages because of a 
kernel bug.  The kernel passes all-zero SCM_CREDENTIALS ancillary data 
to the receiver if the sender did not provide such data, instead of not 
including any such data at all or including the correct data from the 
peer (as it is the case with AF_UNIX).

This bug was introduced in commit 16e572626961
(af_unix: dont send SCM_CREDENTIALS by default)

This patch forces passing credentials for netlink, as
before the regression.

Another fix would be to not add SCM_CREDENTIALS in
netlink messages if not provided by the sender, but it
might break some programs.

With help from Florian Weimer & Petr Matousek

This issue is designated as CVE-2012-3520

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Petr Matousek <pmatouse@redhat.com>
Cc: Florian Weimer <fweimer@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/scm.h        |    4 +++-
 net/netlink/af_netlink.c |    2 +-
 net/unix/af_unix.c       |    4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 079d788..7dc0854 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -70,9 +70,11 @@ static __inline__ void scm_destroy(struct scm_cookie *scm)
 }
 
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
-			       struct scm_cookie *scm)
+			       struct scm_cookie *scm, bool forcecreds)
 {
 	memset(scm, 0, sizeof(*scm));
+	if (forcecreds)
+		scm_set_cred(scm, task_tgid(current), current_cred());
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <= 0)
 		return 0;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5463969..1445d73 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1362,7 +1362,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (NULL == siocb->scm)
 		siocb->scm = &scm;
 
-	err = scm_send(sock, msg, siocb->scm);
+	err = scm_send(sock, msg, siocb->scm, true);
 	if (err < 0)
 		return err;
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e4768c1..c5ee4ff 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1450,7 +1450,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
 	wait_for_unix_gc();
-	err = scm_send(sock, msg, siocb->scm);
+	err = scm_send(sock, msg, siocb->scm, false);
 	if (err < 0)
 		return err;
 
@@ -1619,7 +1619,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
 	wait_for_unix_gc();
-	err = scm_send(sock, msg, siocb->scm);
+	err = scm_send(sock, msg, siocb->scm, false);
 	if (err < 0)
 		return err;
 

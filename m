From: Salvatore Bonaccorso <carnil@debian.org>
Subject: Re: sctp: deny peeloff operation on asocs with threads sleeping on it
Date: Thu, 20 Apr 2017 14:32:57 +0200
Message-ID: <20170420123257.GA11798@lorien.valinor.li>
References: <20170420114405.mh7r5otmvpksacqd@lorien.valinor.li>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Cc: Alexander Popov <alex.popov@linux.com>,
        Ben Hutchings <ben@decadent.org.uk>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35460 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945325AbdDTMdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 08:33:10 -0400
Received: by mail-yw0-f196.google.com with SMTP id k13so5920423ywk.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 05:33:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170420114405.mh7r5otmvpksacqd@lorien.valinor.li>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi 

According to the documentation I should have sent this to
netdev@vger.kernel.org rather than stable@vger.kernel.org.

Rationale: Whilst 00eff2ebbd229758e90659907724c14dd5a18339 went to
stable, the dfcb9f4f99f1e9a49e43398a7bfbf56927544af1 commit is
missing.

Full quoting, my original misleaded mail:

On Thu, Apr 20, 2017 at 01:44:05PM +0200, Salvatore Bonaccorso wrote:
> Hi
> 
> Apparently the following commit
> 
> dfcb9f4f99f1e9a49e43398a7bfbf56927544af1 (sctp: deny peeloff operation
> on asocs with threads sleeping on it)
> 
> (was not CC'ed stable@vger.kernel.org, but was already applied in
> 3.2.87 and 3.16.42) is missing from 4.9:
> 
> 2dcab598484185dea7ec22219c76dcdd59e3cb90 was included in 4.9.11 via
> 00eff2ebbd229758e90659907724c14dd5a18339 . But
> dfcb9f4f99f1e9a49e43398a7bfbf56927544af1 is missing from 4.9.
> 
> This was assigned CVE-2017-6353.
> 
> Reference:
> https://marc.info/?l=linux-netdev&m=148785309416337&w=2
> http://www.openwall.com/lists/oss-security/2017/02/27/2
> 
> Regards,
> Salvatore

Regards,
Salvatore

--0OAP2g/MAC+5xKAE
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-sctp-deny-peeloff-operation-on-asocs-with-threads-sl.patch"

>From dfcb9f4f99f1e9a49e43398a7bfbf56927544af1 Mon Sep 17 00:00:00 2001
From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 23 Feb 2017 09:31:18 -0300
Subject: [PATCH] sctp: deny peeloff operation on asocs with threads sleeping
 on it

commit 2dcab5984841 ("sctp: avoid BUG_ON on sctp_wait_for_sndbuf")
attempted to avoid a BUG_ON call when the association being used for a
sendmsg() is blocked waiting for more sndbuf and another thread did a
peeloff operation on such asoc, moving it to another socket.

As Ben Hutchings noticed, then in such case it would return without
locking back the socket and would cause two unlocks in a row.

Further analysis also revealed that it could allow a double free if the
application managed to peeloff the asoc that is created during the
sendmsg call, because then sctp_sendmsg() would try to free the asoc
that was created only for that call.

This patch takes another approach. It will deny the peeloff operation
if there is a thread sleeping on the asoc, so this situation doesn't
exist anymore. This avoids the issues described above and also honors
the syscalls that are already being handled (it can be multiple sendmsg
calls).

Joint work with Xin Long.

Fixes: 2dcab5984841 ("sctp: avoid BUG_ON on sctp_wait_for_sndbuf")
Cc: Alexander Popov <alex.popov@linux.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/socket.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b532148..465a9c8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4862,6 +4862,12 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 	if (!asoc)
 		return -EINVAL;
 
+	/* If there is a thread waiting on more sndbuf space for
+	 * sending on this asoc, it cannot be peeled.
+	 */
+	if (waitqueue_active(&asoc->wait))
+		return -EBUSY;
+
 	/* An association cannot be branched off from an already peeled-off
 	 * socket, nor is this supported for tcp style sockets.
 	 */
@@ -7599,8 +7605,6 @@ static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
 		 */
 		release_sock(sk);
 		current_timeo = schedule_timeout(current_timeo);
-		if (sk != asoc->base.sk)
-			goto do_error;
 		lock_sock(sk);
 
 		*timeo_p = current_timeo;
-- 
2.1.4


--0OAP2g/MAC+5xKAE--

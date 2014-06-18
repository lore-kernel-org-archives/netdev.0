From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: check proc_dointvec result in proc_sctp_do_auth
Date: Wed, 18 Jun 2014 23:46:31 +0200
Message-ID: <1403127991-18114-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbaFRVqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 17:46:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When writing to the sysctl field net.sctp.auth_enable, it can well
be that the user buffer we handed over to proc_dointvec() via
proc_sctp_do_auth() handler contains something other than integers.

In that case, we would set an uninitialized 4-byte value from the
stack to net->sctp.auth_enable that can be leaked back when reading
the sysctl variable, and it can unintentionally turn auth_enable
on/off based on the stack content since auth_enable is interpreted
as a boolean.

Fix it up by making sure proc_dointvec() returned sucessfully.

Fixes: b14878ccb7fa ("net: sctp: cache auth_enable per endpoint")
Reported-by: Florian Westphal <fwestpha@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/sysctl.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index dcb1959..8a5b5c2 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -444,8 +444,7 @@ static int proc_sctp_do_auth(struct ctl_table *ctl, int write,
 		tbl.data = &net->sctp.auth_enable;
 
 	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
-
-	if (write) {
+	if (write && ret == 0) {
 		struct sock *sk = net->sctp.ctl_sock;
 
 		net->sctp.auth_enable = new_value;
-- 
1.7.11.7

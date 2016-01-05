From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] bridge: Only call /sbin/bridge-stp for the initial network namespace
Date: Tue,  5 Jan 2016 10:46:00 +0100
Message-ID: <1451987160-6273-1-git-send-email-hannes@stressinduktion.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:38713 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751510AbcAEJqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 04:46:07 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 84DBB209AB
	for <netdev@vger.kernel.org>; Tue,  5 Jan 2016 04:46:06 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[I stole this patch from Eric Biederman. He wrote:]

> There is no defined mechanism to pass network namespace information
> into /sbin/bridge-stp therefore don't even try to invoke it except
> for bridge devices in the initial network namespace.
>
> It is possible for unprivileged users to cause /sbin/bridge-stp to be
> invoked for any network device name which if /sbin/bridge-stp does not
> guard against unreasonable arguments or being invoked twice on the
> same network device could cause problems.

[Hannes: changed patch using netns_eq]

Cc: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/bridge/br_stp_if.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 905cedd37a0539..a31ac6ad76a223 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -143,7 +143,10 @@ static void br_stp_start(struct net_bridge *br)
 	char *envp[] = { NULL };
 	struct net_bridge_port *p;
 
-	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
+	if (net_eq(dev_net(br->dev), &init_net))
+		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
+	else
+		r = -ENOENT;
 
 	spin_lock_bh(&br->lock);
 
-- 
2.5.0

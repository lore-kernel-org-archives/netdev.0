From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] sctp: list pmtudisc initizlisation for ipv4 sctp socket
Date: Thu, 24 Jul 2008 19:46:17 +0400
Message-ID: <4888A3C9.3010203@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42385 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbYGXPoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 11:44:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure whether this was done deliberately, but the
sctp_v4_create_accept_sk doesn't set the newinet->pmtudisc
like it is done in both cases (ipv4 and v6) for tcp sockets
and for sctp over ipv6 socket.

This loss is painless, I suppose, since the whole socket is
zeroed by default and thus this field is automatically set
to IP_PMTUDISC_DONT.

Restore this setting logic for sctp over ipv4 socket.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a6e0818..b05c739 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -626,6 +626,11 @@ static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
 	newinet->mc_index = 0;
 	newinet->mc_list = NULL;
 
+	if (ipv4_config.no_pmtu_disc)
+		newinet->pmtudisc = IP_PMTUDISC_DONT;
+	else
+		newinet->pmtudisc = IP_PMTUDISC_WANT;
+
 	sk_refcnt_debug_inc(newsk);
 
 	if (newsk->sk_prot->init(newsk)) {

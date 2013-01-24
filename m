From: <xufengzhang.main@gmail.com>
Subject: [PATCH v2] sctp: set association state to established in dupcook_a handler
Date: Thu, 24 Jan 2013 10:44:34 +0800
Message-ID: <1358995474-28369-1-git-send-email-xufengzhang.main@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35816 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab3AXCmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 21:42:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xufeng Zhang <xufeng.zhang@windriver.com>

While sctp handling a duplicate COOKIE-ECHO and the action is
'Association restart', sctp_sf_do_dupcook_a() will processing
the unexpected COOKIE-ECHO for peer restart, but it does not set
the association state to SCTP_STATE_ESTABLISHED, so the association
could stuck in SCTP_STATE_SHUTDOWN_PENDING state forever.
This violates the sctp specification:
  RFC 4960 5.2.4. Handle a COOKIE ECHO when a TCB Exists
  Action
  A) In this case, the peer may have restarted. .....
     After this, the endpoint shall enter the ESTABLISHED state.

To resolve this problem, adding a SCTP_CMD_NEW_STATE cmd to the
command list before SCTP_CMD_REPLY cmd, this will set the restart
association to SCTP_STATE_ESTABLISHED state properly and also avoid
I-bit being set in the DATA chunk header when COOKIE_ACK is bundled
with DATA chunks.

Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
---
v2:
- Put the SCTP_CMD_NEW_STATE command before SCTP_CMD_REPLY and after SCTP_CMD_EVENT_ULP
  suggested by Vlad and Neil
- Improve the last paragraph of the commit header
 
 net/sctp/sm_statefuns.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 618ec7e..5131fcf 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1779,8 +1779,10 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
 
 	/* Update the content of current association. */
 	sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_ASSOC, SCTP_ASOC(new_asoc));
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
 	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
+	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
+			SCTP_STATE(SCTP_STATE_ESTABLISHED));
+	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
 	return SCTP_DISPOSITION_CONSUME;
 
 nomem_ev:
-- 
1.7.0.2

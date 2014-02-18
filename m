From: Xufeng Zhang <xufeng.zhang@windriver.com>
Subject: [PATCH RFC] sctp: Update HEARTBEAT timer immediately after user changed HB.interval
Date: Tue, 18 Feb 2014 13:56:50 +0800
Message-ID: <1392703010-6128-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xufeng.zhang@windriver.com>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52113 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbaBRFqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 00:46:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For an established association, if user has updated the HB.interval
parameter by setsockopt(), this new heartbeat interval will not
take effect until:
  - the expiry of the heartbeat timer and new hearbeat is sent.
  - DATA chunk has been sent and the transport resets the timer.
This could not meet the requirement of the user who need to
get HEARTBEAT sent at the specified time.

Thus, we need to update the heartbeat timer immediately after
user has changed HB.interval.

Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
---
 net/sctp/socket.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9e91d6e..699ae1e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2344,6 +2344,11 @@ static int sctp_apply_peer_addr_params(struct sctp_paddrparams *params,
 			if (trans) {
 				trans->hbinterval =
 				    msecs_to_jiffies(params->spp_hbinterval);
+
+				/* Update the heartbeat timer immediately. */
+				if (!mod_timer(&trans->hb_timer,
+					    sctp_transport_timeout(trans)))
+					sctp_transport_hold(trans);
 			} else if (asoc) {
 				asoc->hbinterval =
 				    msecs_to_jiffies(params->spp_hbinterval);
-- 
1.7.0.2

From: Xufeng Zhang <xufeng.zhang@windriver.com>
Subject: [PATCH v2] sctp: Fix sk_ack_backlog wrap-around problem
Date: Thu, 12 Jun 2014 10:53:36 +0800
Message-ID: <1402541616-15117-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consider the scenario:
For a TCP-style socket, while processing the COOKIE_ECHO chunk in
sctp_sf_do_5_1D_ce(), after it has passed a series of sanity check,
a new association would be created in sctp_unpack_cookie(), but afterwards,
some processing maybe failed, and sctp_association_free() will be called to
free the previously allocated association, in sctp_association_free(),
sk_ack_backlog value is decremented for this socket, since the initial
value for sk_ack_backlog is 0, after the decrement, it will be 65535,
a wrap-around problem happens, and if we want to establish new associations
afterward in the same socket, ABORT would be triggered since sctp deem the
accept queue as full.
Fix this issue by only decrementing sk_ack_backlog for associations in
the endpoint's list.

Fix-suggested-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
---
Change for v2:
  Drop the redundant test for temp suggested by Vlad Yasevich.

 net/sctp/associola.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 39579c3..0b99998 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -330,7 +330,7 @@ void sctp_association_free(struct sctp_association *asoc)
 	/* Only real associations count against the endpoint, so
 	 * don't bother for if this is a temporary association.
 	 */
-	if (!asoc->temp) {
+	if (!list_empty(&asoc->asocs)) {
 		list_del(&asoc->asocs);
 
 		/* Decrement the backlog value for a TCP-style listening
-- 
1.7.0.2

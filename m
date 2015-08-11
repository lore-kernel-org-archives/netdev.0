From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 5/6] dlm: replace BUG_ON with a less severe handling
Date: Tue, 11 Aug 2015 19:22:24 -0300
Message-ID: <37a757426f801e8df46a903f2603bb257721f996.1439330654.git.marcelo.leitner@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, tan.hu@zte.com.cn
To: cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932968AbbHKWWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 18:22:49 -0400
In-Reply-To: <cover.1439330654.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BUG_ON() is a severe action for this case, specially now that DLM with
SCTP will use 1 socket per association. Instead, we can just close the
socket on this error condition and return from the function.

Also move the check to an earlier stage as it won't change and thus we
can abort as soon as possible.

Although this issue was reported when still using SCTP with 1-to-many
API, this cleanup wouldn't be that simple back then because we couldn't
close the socket and making sure such event would cease would be hard.
And actually, previous code was closing the association, yet SCTP layer
is still raising the new data event. Probably a bug to be fixed in SCTP.

Reported-by: <tan.hu@zte.com.cn>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/dlm/lowcomms.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 856d750be96b64d06c48a1a4e2a68785e8dda048..4ea64e93e6b19ea24132606cffaca8bb502d18ab 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -542,6 +542,10 @@ static int receive_from_sock(struct connection *con)
 		ret = -EAGAIN;
 		goto out_close;
 	}
+	if (con->nodeid == 0) {
+		ret = -EINVAL;
+		goto out_close;
+	}
 
 	if (con->rx_page == NULL) {
 		/*
@@ -582,8 +586,6 @@ static int receive_from_sock(struct connection *con)
 	else if (ret == len)
 		call_again_soon = 1;
 
-	BUG_ON(con->nodeid == 0);
-
 	cbuf_add(&con->cb, ret);
 	ret = dlm_process_incoming_buffer(con->nodeid,
 					  page_address(con->rx_page),
-- 
2.4.3

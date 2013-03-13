From: Vlad Yasevich <vyasevich@gmail.com>
Subject: [PATCH] sctp: Use correct sideffect command in duplicate cookie handling
Date: Tue, 12 Mar 2013 21:53:23 -0400
Message-ID: <1363139603-14042-1-git-send-email-vyasevich@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:45747 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab3CMBxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 21:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When SCTP is done processing a duplicate cookie chunk, it tries
to delete a newly created association.  For that, it has to set
the right association for the side-effect processing to work.
However, when it uses the SCTP_CMD_NEW_ASOC command, that performs
more work then really needed (like hashing the associationa and
assigning it an id) and there is no point to do that only to
delete the association as a next step.  In fact, it also creates
an impossible condition where an association may be found by
the getsockopt() call, and that association is empty.  This
causes a crash in some sctp getsockopts.

The solution is rather simple.  We simply use SCTP_CMD_SET_ASOC
command that doesn't have all the overhead and does exactly
what we need.

Reported-by: Karl Heiss <kheiss@gmail.com>
Tested-by: Karl Heiss <kheiss@gmail.com>
CC: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
---
 net/sctp/sm_statefuns.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5131fcf..de1a013 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2082,7 +2082,7 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
 	}
 
 	/* Delete the tempory new association. */
-	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(new_asoc));
+	sctp_add_cmd_sf(commands, SCTP_CMD_SET_ASOC, SCTP_ASOC(new_asoc));
 	sctp_add_cmd_sf(commands, SCTP_CMD_DELETE_TCB, SCTP_NULL());
 
 	/* Restore association pointer to provide SCTP command interpeter
-- 
1.7.7.6

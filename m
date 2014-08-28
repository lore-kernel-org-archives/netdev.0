From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: fix ABI mismatch through sctp_assoc_to_state helper
Date: Thu, 28 Aug 2014 15:28:26 +0200
Message-ID: <1409232506-16598-1-git-send-email-dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbaH1N23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2014 09:28:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since SCTP day 1, that is, 19b55a2af145 ("Initial commit") from lksctp
tree, the official <netinet/sctp.h> header carries a copy of enum
sctp_sstat_state that looks like (compared to the current in-kernel
enumeration):

  User definition:                     Kernel definition:

  enum sctp_sstat_state {              typedef enum {
    SCTP_EMPTY             = 0,          <removed>
    SCTP_CLOSED            = 1,          SCTP_STATE_CLOSED            = 0,
    SCTP_COOKIE_WAIT       = 2,          SCTP_STATE_COOKIE_WAIT       = 1,
    SCTP_COOKIE_ECHOED     = 3,          SCTP_STATE_COOKIE_ECHOED     = 2,
    SCTP_ESTABLISHED       = 4,          SCTP_STATE_ESTABLISHED       = 3,
    SCTP_SHUTDOWN_PENDING  = 5,          SCTP_STATE_SHUTDOWN_PENDING  = 4,
    SCTP_SHUTDOWN_SENT     = 6,          SCTP_STATE_SHUTDOWN_SENT     = 5,
    SCTP_SHUTDOWN_RECEIVED = 7,          SCTP_STATE_SHUTDOWN_RECEIVED = 6,
    SCTP_SHUTDOWN_ACK_SENT = 8,          SCTP_STATE_SHUTDOWN_ACK_SENT = 7,
  };                                   } sctp_state_t;

This header was later on also placed into the uapi, so that user space
programs can compile without having <netinet/sctp.h>, but the shipped
with <linux/sctp.h> instead.

While RFC6458 under 8.2.1.Association Status (SCTP_STATUS) says that
sstat_state can range from SCTP_CLOSED to SCTP_SHUTDOWN_ACK_SENT, we
nevertheless have a what it appears to be dummy SCTP_EMPTY state from
the very early days.

While it seems to do just nothing, commit 0b8f9e25b0aa ("sctp: remove
completely unsed EMPTY state") did the right thing and removed this dead
code. That however, causes an off-by-one when the user asks the SCTP
stack via SCTP_STATUS API and checks for the current socket state thus
yielding possibly undefined behaviour in applications as they expect
the kernel to tell the right thing.

The enumeration had to be changed however as based on the current socket
state, we access a function pointer lookup-table through this. Therefore,
I think the best way to deal with this is just to add a helper function
sctp_assoc_to_state() to encapsulate the off-by-one quirk.

Reported-by: Tristan Su <sooqing@gmail.com>
Fixes: 0b8f9e25b0aa ("sctp: remove completely unsed EMPTY state")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/sctp.h | 13 +++++++++++++
 net/sctp/socket.c       |  2 +-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index f6e7397..f50dccf 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -320,6 +320,19 @@ static inline sctp_assoc_t sctp_assoc2id(const struct sctp_association *asoc)
 	return asoc ? asoc->assoc_id : 0;
 }
 
+static inline enum sctp_sstat_state
+sctp_assoc_to_state(const struct sctp_association *asoc)
+{
+	/* SCTP's uapi always had SCTP_EMPTY(=0) as a dummy state, but we
+	 * got rid of it in kernel space. Therefore SCTP_CLOSED et al
+	 * start at =1 in user space, but actually as =0 in kernel space.
+	 * Now that we can not break user space and SCTP_EMPTY is exposed
+	 * there, we need to fix it up with an ugly offset not to break
+	 * applications. :(
+	 */
+	return asoc->state + 1;
+}
+
 /* Look up the association by its id.  */
 struct sctp_association *sctp_id2assoc(struct sock *sk, sctp_assoc_t id);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index eb71d49..634a2ab 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4243,7 +4243,7 @@ static int sctp_getsockopt_sctp_status(struct sock *sk, int len,
 	transport = asoc->peer.primary_path;
 
 	status.sstat_assoc_id = sctp_assoc2id(asoc);
-	status.sstat_state = asoc->state;
+	status.sstat_state = sctp_assoc_to_state(asoc);
 	status.sstat_rwnd =  asoc->peer.rwnd;
 	status.sstat_unackdata = asoc->unack_data;
 
-- 
1.7.11.7

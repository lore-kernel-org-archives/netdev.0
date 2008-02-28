From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/4] [SCTP]: Incorrect length was used in SCTP_*_AUTH_CHUNKS socket option
Date: Thu, 28 Feb 2008 16:52:40 -0500
Message-ID: <1204235561-19993-4-git-send-email-vladislav.yasevich@hp.com>
References: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:13763 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955AbYB1VwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:52:19 -0500
In-Reply-To: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chunks are stored inside a parameter structure in the kernel
and when we copy them to the user, we need to account for
the parameter header.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 44797ad..848df21 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5070,6 +5070,7 @@ static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
 	struct sctp_authchunks val;
 	struct sctp_association *asoc;
 	struct sctp_chunks_param *ch;
+	u32    num_chunks;
 	char __user *to;
 
 	if (len <= sizeof(struct sctp_authchunks))
@@ -5086,10 +5087,11 @@ static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
 	ch = asoc->peer.peer_chunks;
 
 	/* See if the user provided enough room for all the data */
-	if (len < ntohs(ch->param_hdr.length))
+	num_chunks = ntohs(ch->param_hdr.length) - sizeof(sctp_paramhdr_t);
+	if (len < num_chunks)
 		return -EINVAL;
 
-	len = ntohs(ch->param_hdr.length);
+	len = num_chunks;
 	if (put_user(len, optlen))
 		return -EFAULT;
 	if (copy_to_user(to, ch->chunks, len))
@@ -5105,6 +5107,7 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 	struct sctp_authchunks val;
 	struct sctp_association *asoc;
 	struct sctp_chunks_param *ch;
+	u32    num_chunks;
 	char __user *to;
 
 	if (len <= sizeof(struct sctp_authchunks))
@@ -5123,10 +5126,11 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 	else
 		ch = sctp_sk(sk)->ep->auth_chunk_list;
 
-	if (len < ntohs(ch->param_hdr.length))
+	num_chunks = ntohs(ch->param_hdr.length) - sizeof(sctp_paramhdr_t);
+	if (len < num_chunks)
 		return -EINVAL;
 
-	len = ntohs(ch->param_hdr.length);
+	len = num_chunks;
 	if (put_user(len, optlen))
 		return -EFAULT;
 	if (copy_to_user(to, ch->chunks, len))
-- 
1.5.3.5


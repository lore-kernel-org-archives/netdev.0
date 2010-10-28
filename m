From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [Security] TIPC security issues
Date: Thu, 28 Oct 2010 15:51:07 -0400
Message-ID: <20101028195107.GA884@windriver.com>
References: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
 <20101027.102940.112580564.davem@davemloft.net>
 <AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>
 <20101027.105047.183059900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51310 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab0J1Tvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 15:51:53 -0400
Content-Disposition: inline
In-Reply-To: <20101027.105047.183059900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [Security] TIPC security issues] On 27/10/2010 (Wed 10:50) David Miller wrote:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 27 Oct 2010 10:37:46 -0700
> 
> > If you _really_ care deeply, then some packet-oriented protocol can
> > just have its own private packet size limit (which would be way less
> > than 2GB), and then just look at the total size and say "oh, the total
> > size is bigger than my limit, so I'll just error out". Then, the fact
> > that verify_iovec() may have truncated the message to 2GB-1 doesn't
> > matter at all.
> > 
> > (Practically speaking, I bet all packet-oriented protocols already
> > have a limit that is enforced by simply allocation patterns, so I
> > don't think it's actually a problem even now)
> 
> This is, as it turns out, effectively what the TIPC socket layer
> already does.
> 
> Most of the send calls that propagate down to this code adding up the
> iov_len lengths gets passed a maximum packet size.
> 

In keeping with this idea, perhaps this is a better solution for getting
an immediate fix to the tipc part of this issue than the previous
patches I'd sent?  I can see some immediate advantages to this:

   -it adds checks that arguably should have been there since day
    one, since it is always best to check for garbage input ASAP.

   -it is a much smaller change, and thus easier to review and have
    confidence in

   -by being smaller and clearer, it lends itself better for being
    directly cherry picked onto the -stable release(s).

We'll still need to clean up the mishmash of variable types being
used in the tipc internals, but at least we can then do that in
a development cycle, and we won't have to inflict those bigger
cleanup changesets back onto GregKH.

Paul.

----

>From 3fb200c1b27cf5cde668888ab85cffb1e9c6314f Mon Sep 17 00:00:00 2001
From: Allan Stephens <Allan.Stephens@windriver.com>
Date: Thu, 28 Oct 2010 07:58:24 -0400
Subject: [PATCH] tipc: Fix security hole exploitable by excessive send requests

Add checks to TIPC's socket send routines to promptly detect and
abort attempts to send more than 66,000 bytes in a single TIPC
message, or more than 2**31-1 bytes in a single TIPC byte stream
request.  This prevents excessively large size_t based inputs from
reaching internal tipc routines that currently use int values where
they risk being truncated or incorrectly wrapped.

The three checks are added to send_msg() send_packet() and
send_stream() -- all of which are entered via proto_ops .sendmsg, which
in turn already checked for msg_iovlen > UIO_MAXIOV [in net/socket.c],
so there is no need to repeat that specific test in these new checks.

Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc.h |    2 +-
 net/tipc/socket.c    |   10 ++++++++++
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index d10614b..1fd2889 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -101,7 +101,7 @@ static inline unsigned int tipc_node(__u32 addr)
  * Limiting values for messages
  */
 
-#define TIPC_MAX_USER_MSG_SIZE	66000
+#define TIPC_MAX_USER_MSG_SIZE	66000U
 
 /*
  * Message importance levels
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 33217fc..3562cf9 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -542,6 +542,8 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 	if (unlikely((m->msg_namelen < sizeof(*dest)) ||
 		     (dest->family != AF_TIPC)))
 		return -EINVAL;
+	if (total_len > TIPC_MAX_USER_MSG_SIZE)
+		return -EMSGSIZE;
 
 	if (iocb)
 		lock_sock(sk);
@@ -649,6 +651,9 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	if (unlikely(dest))
 		return send_msg(iocb, sock, m, total_len);
 
+	if (total_len > TIPC_MAX_USER_MSG_SIZE)
+		return -EMSGSIZE;
+
 	if (iocb)
 		lock_sock(sk);
 
@@ -733,6 +738,11 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
+	if (total_len > (unsigned)INT_MAX) {
+		res = -EMSGSIZE;
+		goto exit;
+	}
+
 	/*
 	 * Send each iovec entry using one or more messages
 	 *
-- 
1.7.3.1


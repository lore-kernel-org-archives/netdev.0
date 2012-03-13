From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Provide SYN packet for passive connections
Date: Mon, 12 Mar 2012 21:01:59 -0700
Message-ID: <1331611319.7787.37.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
	 <20120311.195542.1995263719633128071.davem@davemloft.net>
	 <CA+mtBx_LqwUpe5Df3VPw-L=h-WUjr=fxh86rgNuYnMacNikuOA@mail.gmail.com>
	 <20120311.211424.996831768685832926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:35600 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab2CMECD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 00:02:03 -0400
Received: by gghe5 with SMTP id e5so119265ggh.19
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 21:02:02 -0700 (PDT)
In-Reply-To: <20120311.211424.996831768685832926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-03-11 at 21:14 -0700, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 11 Mar 2012 21:08:38 -0700
> 
> > For inet_connection_sock I believe there are fields that would only be
> > used for a listeners(e.g. icsk_accept_queue), and fields that would
> > only be used for a real connection (e.g. icsk_retransmits).  Would it
> > be worth it to split these into a union?
> 
> Indeed, it might.

OK I took a look at this idea, and it seems safe right now.

[PATCH net-next] inet: embed icsk_accept_queue in an union

icsk_accept_queue is currently used only for LISTEN sockets. We could
share its space with fields used for other kind of inet sockets.

For active connections, this area is zeroed in socket setup, and for
passive ones, we clear the whole area in inet_csk_clone_lock() to make
sure we dont use content inherited from (listener) parent.

/* Deinitialize accept_queue to trap illegal accesses. */
memset(&newicsk->icsk_accept_queue, 0, sizeof(newicsk->icsk_accept_queue));

For 100% safety, we could do the same in inet_csk_listen_stop(), or we can
double check that fields added in this union later are only accessed by non
LISTEN sockets.

All these fields must have a null default value.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Suggested-by: Tom Herbert <therbert@google.com>
---
 include/net/inet_connection_sock.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index dbf9aab..d3ccaf9 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -86,7 +86,9 @@ struct inet_connection_sock_af_ops {
 struct inet_connection_sock {
 	/* inet_sock has to be the first member! */
 	struct inet_sock	  icsk_inet;
-	struct request_sock_queue icsk_accept_queue;
+	union {
+		struct request_sock_queue icsk_accept_queue;
+	};
 	struct inet_bind_bucket	  *icsk_bind_hash;
 	unsigned long		  icsk_timeout;
  	struct timer_list	  icsk_retransmit_timer;

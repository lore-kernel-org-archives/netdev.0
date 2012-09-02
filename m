From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: (ipt_log_packet, sb_add) 3.6.0-rc2 kernel panic - not syncing;
 Fatal exception in interrupt
Date: Mon, 03 Sep 2012 00:53:05 +0200
Message-ID: <1346626385.2563.44.camel@edumazet-glaptop>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
	 <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
	 <20120902132834.GB7456@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46628 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788Ab2IBWxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 18:53:12 -0400
Received: by wicr5 with SMTP id r5so3495278wic.1
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 15:53:10 -0700 (PDT)
In-Reply-To: <20120902132834.GB7456@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Sun, 2012-09-02 at 15:28 +0200, Florian Westphal wrote:
> Sami Farin <hvtaifwkbgefbaei@gmail.com> wrote:
> > I get this panic every 1-2 days.
> > Also with 7a611e69b26069a511d9d5251c6a28af6c521121 (commit before 3.6.0-rc4).
> 
> Could you please post iptables-save output?
> My guess is you're using NFLOG in INPUT?
> 
> If so, I bet its caused by the tcp early demux stuff.
> Does that crash go away with ip_early_demux sysctl off?
> 
> My guess is its assigning skb->sk with TIMEWAIT sockets, which
> would explain the crash.

Yes thats probably the reason.

First I thought changing demux to not do the lookup of TIMEWAIT slot in
__inet_lookup_established(), then it sounds not optimal to redo the full
lookup for ESTABLISHED sockets later in TCP stack.

So it seems we should fix xt_LOG instead

Thanks Florian !

[PATCH] xt_LOG: take care of timewait sockets

Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
full blown socket.

But with TCP early demux, we can have skb->sk pointing to a timewait
socket.

Diagnosed-by: Florian Westphal <fw@strlen.de>
Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/xt_LOG.c |   33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index ff5f75f..2a4f969 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -145,6 +145,19 @@ static int dump_tcp_header(struct sbuff *m, const struct sk_buff *skb,
 	return 0;
 }
 
+static void dump_sk_uid_gid(struct sbuff *m, struct sock *sk)
+{
+	if (!sk || sk->sk_state == TCP_TIME_WAIT)
+		return;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	if (sk->sk_socket && sk->sk_socket->file)
+		sb_add(m, "UID=%u GID=%u ",
+			sk->sk_socket->file->f_cred->fsuid,
+			sk->sk_socket->file->f_cred->fsgid);
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+
 /* One level of recursion won't kill us */
 static void dump_ipv4_packet(struct sbuff *m,
 			const struct nf_loginfo *info,
@@ -361,14 +374,8 @@ static void dump_ipv4_packet(struct sbuff *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & XT_LOG_UID) && !iphoff && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
-			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
-	}
+	if ((logflags & XT_LOG_UID) && !iphoff)
+		dump_sk_uid_gid(m, skb->sk);
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
 	if (!iphoff && skb->mark)
@@ -717,14 +724,8 @@ static void dump_ipv6_packet(struct sbuff *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & XT_LOG_UID) && recurse && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
-			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
-	}
+	if ((logflags & XT_LOG_UID) && recurse)
+		dump_sk_uid_gid(m, skb->sk);
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
 	if (!recurse && skb->mark)

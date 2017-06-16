From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next v2 01/15] bpf: BPF support for socket ops
Date: Fri, 16 Jun 2017 14:07:54 +0200
Message-ID: <5943CA1A.2060006@iogearbox.net>
References: <20170615200844.2752485-1-brakmo@fb.com> <20170615200844.2752485-2-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44834 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752752AbdFPMH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 08:07:57 -0400
In-Reply-To: <20170615200844.2752485-2-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2017 10:08 PM, Lawrence Brakmo wrote:
> Created a new BPF program type, BPF_PROG_TYPE_SOCKET_OPS, and a corresponding
> struct that allows BPF programs of this type to access some of the
> socket's fields (such as IP addresses, ports, etc.). Currently there is
> functionality to load one global BPF program of this type which can be
> called at appropriate times to set relevant connection parameters such
> as buffer sizes, SYN and SYN-ACK RTOs, etc., based on connection
> information such as IP addresses, port numbers, etc.
>
> Alghough there are already 3 mechanisms to set parameters (sysctls,
> route metrics and setsockopts), this new mechanism provides some
> disticnt advantages. Unlike sysctls, it can set parameters per
> connection. In contrast to route metrics, it can also use port numbers
> and information provided by a user level program. In addition, it could
> set parameters probabilistically for evaluation purposes (i.e. do
> something different on 10% of the flows and compare results with the
> other 90% of the flows). Also, in cases where IPv6 addresses contain
> geographic information, the rules to make changes based on the distance
> (or RTT) between the hosts are much easier than route metric rules and
> can be global. Finally, unlike setsockopt, it oes not require
> application changes and it can be updated easily at any time.
>
> I plan to add support for loading per cgroup socket ops BPF programs in
> the near future. One question is whether I should add this functionality
> into David Ahern's BPF_PROG_TYPE_CGROUP_SOCK or create a new cgroup bpf
> type. Whereas the current cgroup_sock type expects to be called only once
> during a connection's lifetime, the new socket_ops type could be called
> multipe times. For example, before sending SYN and SYN-ACKs to set an
> appropriate timeout, when the connection is established to set
> congestion control, etc. As a result it has "op" field to specify the
> type of operation requested.
>
> The purpose of this new program type is to simplify setting connection
> parameters, such as buffer sizes, TCP's SYN RTO, etc. For example, it is
> easy to use facebook's internal IPv6 addresses to determine if both hosts
> of a connection are in the same datacenter. Therefore, it is easy to
> write a BPF program to choose a small SYN RTO value when both hosts are
> in the same datacenter.
>
> This patch only contains the framework to support the new BPF program
> type, following patches add the functionality to set various connection
> parameters.
>
> This patch defines a new BPF program type: BPF_PROG_TYPE_SOCKET_OPS
> and a new bpf syscall command to load a new program of this type:
> BPF_PROG_LOAD_SOCKET_OPS.
>
> Two new corresponding structs (one for the kernel one for the user/BPF
> program):
>
> /* kernel version */
> struct bpf_socket_ops_kern {
>          struct sock *sk;
> 	__u32  is_req_sock:1;
>          __u32  op;
>          union {
>                  __u32 reply;
>                  __u32 replylong[4];
>          };
> };
>
> /* user version */
> struct bpf_socket_ops {
>          __u32 op;
>          union {
>                  __u32 reply;
>                  __u32 replylong[4];
>          };
>          __u32 family;
>          __u32 remote_ip4;
>          __u32 local_ip4;
>          __u32 remote_ip6[4];
>          __u32 local_ip6[4];
>          __u32 remote_port;
>          __u32 local_port;
> };

Above and ...

struct bpf_sock {
	__u32 bound_dev_if;
	__u32 family;
	__u32 type;
	__u32 protocol;
};

... would result in two BPF sock user versions. It's okayish, but
given struct bpf_sock is quite generic, couldn't we merge the members
from struct bpf_socket_ops into struct bpf_sock instead?

Idea would be that sock_filter_is_valid_access() for cgroups would
then check off < 0 || off + size > offsetofend(struct bpf_sock, protocol)
to disallow new members, and your socket_ops_is_valid_access() could
allow and xlate the full range. The family member is already duplicate
and the others could then be accessed from these kind of BPF progs as
well, plus we have a single user representation similar as with __sk_buff
that multiple types will use.

> Currently there are two types of ops. The first type expects the BPF
> program to return a value which is then used by the caller (or a
> negative value to indicate the operation is not supported). The second
> type expects state changes to be done by the BPF program, for example
> through a setsockopt BPF helper function, and they ignore the return
> value.
>
> The reply fields of the bpf_sockt_ops struct are there in case a bpf
> program needs to return a value larger than an integer.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
> ---
>   include/linux/bpf.h       |   6 ++
>   include/linux/bpf_types.h |   1 +
>   include/linux/filter.h    |  10 +++
>   include/net/tcp.h         |  27 ++++++++
>   include/uapi/linux/bpf.h  |  28 +++++++++
>   kernel/bpf/syscall.c      |   2 +
>   net/core/Makefile         |   3 +-
>   net/core/filter.c         | 157 ++++++++++++++++++++++++++++++++++++++++++++++
>   net/core/sock_bpfops.c    |  67 ++++++++++++++++++++
>   samples/bpf/bpf_load.c    |  13 +++-
>   10 files changed, 310 insertions(+), 4 deletions(-)
>   create mode 100644 net/core/sock_bpfops.c
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 1bcbf0a..e164f94 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -362,4 +362,10 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
>   void bpf_user_rnd_init_once(void);
>   u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
>
> +/* socket_ops related */
> +struct sock;

Is this needed? You're using it in struct bpf_socket_ops_kern in
filter.h, where we already have struct sock;

> +struct bpf_socket_ops_kern;
> +
> +int bpf_socket_ops_set_prog(int fd);
> +int bpf_socket_ops_call(struct bpf_socket_ops_kern *bpf_socket);
>   #endif /* _LINUX_BPF_H */
> diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
> index 03bf223..ca69d10 100644
> --- a/include/linux/bpf_types.h
> +++ b/include/linux/bpf_types.h
> @@ -10,6 +10,7 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCK, cg_sock_prog_ops)
>   BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_IN, lwt_inout_prog_ops)
>   BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_OUT, lwt_inout_prog_ops)
>   BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_XMIT, lwt_xmit_prog_ops)
> +BPF_PROG_TYPE(BPF_PROG_TYPE_SOCKET_OPS, socket_ops_prog_ops)
>   #endif
>   #ifdef CONFIG_BPF_EVENTS
>   BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe_prog_ops)
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 1fa26dc..102e881 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -898,4 +898,14 @@ static inline int bpf_tell_extensions(void)
>   	return SKF_AD_MAX;
>   }
>
> +struct bpf_socket_ops_kern {
> +	struct	sock *sk;
> +	u32	is_req_sock:1;
> +	u32	op;
> +	union {
> +		u32 reply;
> +		u32 replylong[4];
> +	};
> +};
> +
>   #endif /* __LINUX_FILTER_H__ */
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 3ab677d..9ad0d80 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -46,6 +46,9 @@
>   #include <linux/seq_file.h>
>   #include <linux/memcontrol.h>
>
> +#include <linux/bpf.h>
> +#include <linux/filter.h>
> +
>   extern struct inet_hashinfo tcp_hashinfo;
>
>   extern struct percpu_counter tcp_orphan_count;
> @@ -1991,4 +1994,28 @@ static inline void tcp_listendrop(const struct sock *sk)
>
>   enum hrtimer_restart tcp_pace_kick(struct hrtimer *timer);
>
> +/* Call BPF_SOCKET_OPS program that returns an int. If the return value
> + * is < 0, then the BPF op failed (for example if the loaded BPF
> + * program does not support the chosen operation or there is no BPF
> + * program loaded).
> + */
> +#ifdef CONFIG_BPF
> +static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
> +{
> +	struct bpf_socket_ops_kern socket_ops;
> +
> +	memset(&socket_ops, 0, sizeof(socket_ops));
> +	socket_ops.sk = sk;
> +	socket_ops.is_req_sock = is_req_sock ? 1 : 0;

Is is_req_sock actually used here in this patch (apart from setting it)?
Not seeing that BPF prog will access it, if it also shouldn't access it,
then bool type would be better.

> +	socket_ops.op = op;
> +
> +	return bpf_socket_ops_call(&socket_ops);
> +}
> +#else
> +static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
> +{
> +	return -1;
> +}
> +#endif
> +
>   #endif	/* _TCP_H */
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index f94b48b..1540336 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -87,6 +87,7 @@ enum bpf_cmd {
>   	BPF_PROG_GET_FD_BY_ID,
>   	BPF_MAP_GET_FD_BY_ID,
>   	BPF_OBJ_GET_INFO_BY_FD,
> +	BPF_PROG_LOAD_SOCKET_OPS,

Why is this as an extra cmd needed, not extending BPF_PROG_ATTACH
and BPF_PROG_DETACH that we already have?

>   };
>
>   enum bpf_map_type {
> @@ -120,6 +121,7 @@ enum bpf_prog_type {
>   	BPF_PROG_TYPE_LWT_IN,
>   	BPF_PROG_TYPE_LWT_OUT,
>   	BPF_PROG_TYPE_LWT_XMIT,
> +	BPF_PROG_TYPE_SOCKET_OPS,

(Nit: maybe BPF_PROG_TYPE_SOCK_OPS given we already have a *_SOCK type.)

>   };
>
>   enum bpf_attach_type {
> @@ -720,4 +722,30 @@ struct bpf_map_info {
>   	__u32 map_flags;
>   } __attribute__((aligned(8)));
>
> +/* User bpf_socket_ops struct to access socket values and specify request ops
> + * and their replies.
> + * New fields can only be added at the end of this structure
> + */
> +struct bpf_socket_ops {
> +	__u32 op;
> +	union {
> +		__u32 reply;
> +		__u32 replylong[4];
> +	};
> +	__u32 family;
> +	__u32 remote_ip4;
> +	__u32 local_ip4;
> +	__u32 remote_ip6[4];
> +	__u32 local_ip6[4];
> +	__u32 remote_port;
> +	__u32 local_port;
> +};
> +
> +/* List of known BPF socket_ops operators.
> + * New entries can only be added at the end
> + */
> +enum {
> +	BPF_SOCKET_OPS_VOID,
> +};
> +
>   #endif /* _UAPI__LINUX_BPF_H__ */
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 8942c82..5024b97 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -1458,6 +1458,8 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
>   		break;
>   	case BPF_OBJ_GET_INFO_BY_FD:
>   		err = bpf_obj_get_info_by_fd(&attr, uattr);
> +	case BPF_PROG_LOAD_SOCKET_OPS:
> +		err = bpf_socket_ops_set_prog(attr.bpf_fd);
>   		break;

(Comment above.)

>   	default:
>   		err = -EINVAL;
> diff --git a/net/core/Makefile b/net/core/Makefile
> index 79f9479..5d711c2 100644
> --- a/net/core/Makefile
> +++ b/net/core/Makefile
> @@ -9,7 +9,8 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
>
>   obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
>   			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
> -			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
> +			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o \
> +			sock_bpfops.o
>
>   obj-$(CONFIG_XFRM) += flow.o
>   obj-y += net-sysfs.o
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 60ed6f3..7466f55 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -3095,6 +3095,37 @@ void bpf_warn_invalid_xdp_action(u32 act)
>   }
>   EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
>
> +static bool __is_valid_socket_ops_access(int off, int size,
> +					 enum bpf_access_type type)

Nit: type unused here

> +{
> +	if (off < 0 || off >= sizeof(struct bpf_socket_ops))
> +		return false;
> +	/* The verifier guarantees that size > 0. */
> +	if (off % size != 0)
> +		return false;
> +	if (size != sizeof(__u32))
> +		return false;
> +
> +	return true;
> +}
> +
> +static bool socket_ops_is_valid_access(int off, int size,
> +				       enum bpf_access_type type,
> +				       enum bpf_reg_type *reg_type)
> +{
> +	if (type == BPF_WRITE) {
> +		switch (off) {
> +		case offsetof(struct bpf_socket_ops, op) ...
> +		     offsetof(struct bpf_socket_ops, replylong[3]):
> +			break;
> +		default:
> +			return false;
> +		}
> +	}
> +
> +	return __is_valid_socket_ops_access(off, size, type);
> +}
> +
>   static u32 bpf_convert_ctx_access(enum bpf_access_type type,
>   				  const struct bpf_insn *si,
>   				  struct bpf_insn *insn_buf,
> @@ -3364,6 +3395,126 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
>   	return insn - insn_buf;
>   }
>
> +static u32 socket_ops_convert_ctx_access(enum bpf_access_type type,
> +					 const struct bpf_insn *si,
> +					 struct bpf_insn *insn_buf,
> +					 struct bpf_prog *prog)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +	int off;
> +
> +	switch (si->off) {
> +	case offsetof(struct bpf_socket_ops, op) ...
> +	     offsetof(struct bpf_socket_ops, replylong[3]):

Could we also add a BUILD_BUG_ON() here asserting that kernel
representation has same FIELD_SIZEOF() as bpf_socket_ops.

> +		off = si->off;
> +		off -= offsetof(struct bpf_socket_ops, op);
> +		off += offsetof(struct bpf_socket_ops_kern, op);
> +		if (type == BPF_WRITE)
> +			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
> +					      off);
> +		else
> +			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
> +					      off);
> +		break;
> +
> +	case offsetof(struct bpf_socket_ops, family):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_family) != 2);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +					      struct bpf_socket_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_socket_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common, skc_family));
> +		break;
> +
> +	case offsetof(struct bpf_socket_ops, remote_ip4):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_daddr) != 4);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_socket_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_socket_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common, skc_daddr));
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +		break;
> +
> +	case offsetof(struct bpf_socket_ops, local_ip4):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_rcv_saddr) != 4);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +					      struct bpf_socket_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_socket_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common,
> +					       skc_rcv_saddr));
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +		break;
> +
> +	case offsetof(struct bpf_socket_ops, remote_ip6[0]) ...
> +		offsetof(struct bpf_socket_ops, remote_ip6[3]):

Nit: indent

> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
> +					  skc_v6_daddr.s6_addr32[0]) != 4);
> +
> +		off = si->off;
> +		off -= offsetof(struct bpf_socket_ops, remote_ip6[0]);
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_socket_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_socket_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common,
> +					       skc_v6_daddr.s6_addr32[0]) +
> +				      off);
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +		break;
> +
> +	case offsetof(struct bpf_socket_ops, local_ip6[0]) ...
> +		offsetof(struct bpf_socket_ops, local_ip6[3]):

Nit: indent

> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
> +					  skc_v6_rcv_saddr.s6_addr32[0]) != 4);
> +
> +		off = si->off;
> +		off -= offsetof(struct bpf_socket_ops, local_ip6[0]);
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_socket_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_socket_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common,
> +					       skc_v6_rcv_saddr.s6_addr32[0]) +
> +				      off);
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
> +		break;
> +
> +	case offsetof(struct bpf_socket_ops, remote_port):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_dport) != 2);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_socket_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_socket_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common, skc_dport));
> +		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 16);
> +		break;
> +
> +	case offsetof(struct bpf_socket_ops, local_port):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_num) != 2);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
> +						struct bpf_socket_ops_kern, sk),
> +				      si->dst_reg, si->src_reg,
> +				      offsetof(struct bpf_socket_ops_kern, sk));
> +		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
> +				      offsetof(struct sock_common, skc_num));
> +		break;
> +	}
> +	return insn - insn_buf;
> +}
> +
>   const struct bpf_verifier_ops sk_filter_prog_ops = {
>   	.get_func_proto		= sk_filter_func_proto,
>   	.is_valid_access	= sk_filter_is_valid_access,
> @@ -3413,6 +3564,12 @@ const struct bpf_verifier_ops cg_sock_prog_ops = {
>   	.convert_ctx_access	= sock_filter_convert_ctx_access,
>   };
>
> +const struct bpf_verifier_ops socket_ops_prog_ops = {
> +	.get_func_proto		= bpf_base_func_proto,
> +	.is_valid_access	= socket_ops_is_valid_access,
> +	.convert_ctx_access	= socket_ops_convert_ctx_access,
> +};
> +
>   int sk_detach_filter(struct sock *sk)
>   {
>   	int ret = -ENOENT;
> diff --git a/net/core/sock_bpfops.c b/net/core/sock_bpfops.c
> new file mode 100644
> index 0000000..8f8daa5
> --- /dev/null
> +++ b/net/core/sock_bpfops.c
> @@ -0,0 +1,67 @@
> +/*
> + * BPF support for sockets
> + *
> + * Copyright (c) 2016 Lawrence Brakmo <brakmo@fb.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + */
> +
> +#include <net/sock.h>
> +#include <linux/skbuff.h>
> +#include <linux/bpf.h>
> +#include <linux/filter.h>
> +#include <linux/errno.h>
> +#ifdef CONFIG_NET_NS
> +#include <net/net_namespace.h>
> +#include <linux/proc_ns.h>
> +#endif
> +
> +/* Global BPF program for sockets */
> +static struct bpf_prog *bpf_socket_ops_prog;
> +static DEFINE_RWLOCK(bpf_socket_ops_lock);
> +
> +int bpf_socket_ops_set_prog(int fd)
> +{
> +	int err = 0;
> +
> +	write_lock(&bpf_socket_ops_lock);
> +	if (bpf_socket_ops_prog) {
> +		bpf_prog_put(bpf_socket_ops_prog);
> +		bpf_socket_ops_prog = NULL;
> +	}
> +
> +	/* fd of zero is used as a signal to remove the current
> +	 * bpf_socket_ops_prog.
> +	 */
> +	if (fd == 0) {

Can we make the fd related semantics similar to dev_change_xdp_fd()?

> +		write_unlock(&bpf_socket_ops_lock);
> +		return 1;
> +	}
> +
> +	bpf_socket_ops_prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCKET_OPS);
> +	if (IS_ERR(bpf_socket_ops_prog)) {
> +		bpf_prog_put(bpf_socket_ops_prog);

This will crash the kernel, passing err value to bpf_prog_put().

> +		bpf_socket_ops_prog = NULL;
> +		err = 1;
> +	}
> +	write_unlock(&bpf_socket_ops_lock);

If all this gets a bit rearranged as in dev_change_xdp_fd(), we can
RCUify bpf_socket_ops_prog.

> +	return err;
> +}
> +
> +int bpf_socket_ops_call(struct bpf_socket_ops_kern *bpf_socket)
> +{
> +	int ret;
> +
> +	read_lock(&bpf_socket_ops_lock);
> +	if (bpf_socket_ops_prog) {
> +		rcu_read_lock();
> +		ret = (int)BPF_PROG_RUN(bpf_socket_ops_prog, bpf_socket);

Cast not needed.

> +		rcu_read_unlock();
> +	} else {
> +		ret = -1;
> +	}
> +	read_unlock(&bpf_socket_ops_lock);

See comment wrt RCU for bpf_socket_ops_prog, then read_lock()
can be dropped.

> +	return ret;
> +}

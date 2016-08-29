From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next RFC v2 8/9] samples/bpf: Add limit_connections,
 remap_bind checmate examples / tests
Date: Mon, 29 Aug 2016 15:30:43 -0700
Message-ID: <20160829223041.GA52252@ast-mbp.thefacebook.com>
References: <20160829114745.GA20912@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
        linux-security-module@vger.kernel.org, daniel@iogearbox.net,
        ast@fb.com, mic@digikod.net
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160829114745.GA20912@ircssh.c.rugged-nimbus-611.internal>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2016 at 04:47:46AM -0700, Sargun Dhillon wrote:
> 1) limit_connections
> This program performs connection limiting using a probablistic
> datastructure. It ensures that for a given 2-tuple, there will never be
> more than 10 connections. The parameters themselves are adjustable
> to allow for trading off memory usage vs. collision likelihood. The
> reason for not refcnting 2-tuples using atomic counters is the lack of
> a safe free mechanism.
> 
> In order to run this program, you may need to bump your ulimit -l.
> 
> 2) remap_bind
> This program rewrites binds from 6789 to 12345. It is meant to mimic
> the usage of DNAT.

these two are great examples of what lsm+bpf can be capable of.
Thanks!

> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> ---
>  samples/bpf/Makefile                          |  10 ++
>  samples/bpf/bpf_helpers.h                     |   2 +
>  samples/bpf/bpf_load.c                        |  11 +-
>  samples/bpf/checmate_limit_connections_kern.c | 146 ++++++++++++++++++++++++++
>  samples/bpf/checmate_limit_connections_user.c | 113 ++++++++++++++++++++
>  samples/bpf/checmate_remap_bind_kern.c        |  28 +++++
>  samples/bpf/checmate_remap_bind_user.c        |  82 +++++++++++++++
>  7 files changed, 389 insertions(+), 3 deletions(-)
>  create mode 100644 samples/bpf/checmate_limit_connections_kern.c
>  create mode 100644 samples/bpf/checmate_limit_connections_user.c
>  create mode 100644 samples/bpf/checmate_remap_bind_kern.c
>  create mode 100644 samples/bpf/checmate_remap_bind_user.c
> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index 5d2c178..ee5de8c 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -25,6 +25,8 @@ hostprogs-y += test_cgrp2_array_pin
>  hostprogs-y += xdp1
>  hostprogs-y += xdp2
>  hostprogs-y += test_current_task_under_cgroup
> +hostprogs-y += checmate_remap_bind
> +hostprogs-y += checmate_limit_connections
>  
>  test_verifier-objs := test_verifier.o libbpf.o
>  test_maps-objs := test_maps.o libbpf.o
> @@ -52,6 +54,10 @@ xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
>  xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
>  test_current_task_under_cgroup-objs := bpf_load.o libbpf.o cgroup_helpers.o \
>  				       test_current_task_under_cgroup_user.o
> +checmate_remap_bind-objs := bpf_load.o libbpf.o cgroup_helpers.o \
> +			    checmate_remap_bind_user.o
> +checmate_limit_connections-objs := bpf_load.o libbpf.o cgroup_helpers.o \
> +				   checmate_limit_connections_user.o
>  
>  # Tell kbuild to always build the programs
>  always := $(hostprogs-y)
> @@ -79,6 +85,8 @@ always += test_cgrp2_tc_kern.o
>  always += xdp1_kern.o
>  always += xdp2_kern.o
>  always += test_current_task_under_cgroup_kern.o
> +always += checmate_remap_bind_kern.o
> +always += checmate_limit_connections_kern.o
>  
>  HOSTCFLAGS += -I$(objtree)/usr/include
>  
> @@ -103,6 +111,8 @@ HOSTLOADLIBES_test_overhead += -lelf -lrt
>  HOSTLOADLIBES_xdp1 += -lelf
>  HOSTLOADLIBES_xdp2 += -lelf
>  HOSTLOADLIBES_test_current_task_under_cgroup += -lelf
> +HOSTLOADLIBES_checmate_remap_bind += -lelf
> +HOSTLOADLIBES_checmate_limit_connections += -lelf
>  
>  # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
>  #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
> diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
> index bbdf62a..da97ced 100644
> --- a/samples/bpf/bpf_helpers.h
> +++ b/samples/bpf/bpf_helpers.h
> @@ -55,6 +55,8 @@ static int (*bpf_skb_get_tunnel_opt)(void *ctx, void *md, int size) =
>  	(void *) BPF_FUNC_skb_get_tunnel_opt;
>  static int (*bpf_skb_set_tunnel_opt)(void *ctx, void *md, int size) =
>  	(void *) BPF_FUNC_skb_set_tunnel_opt;
> +static int (*bpf_probe_write_checmate)(void *ctx, void *dst, void *src, int len) =
> +	(void *) BPF_FUNC_probe_write_checmate;
>  
>  /* llvm builtin functions that eBPF C program may use to
>   * emit BPF_LD_ABS and BPF_LD_IND instructions
> diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
> index 0cfda23..e12460a 100644
> --- a/samples/bpf/bpf_load.c
> +++ b/samples/bpf/bpf_load.c
> @@ -51,6 +51,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
>  	bool is_kretprobe = strncmp(event, "kretprobe/", 10) == 0;
>  	bool is_tracepoint = strncmp(event, "tracepoint/", 11) == 0;
>  	bool is_xdp = strncmp(event, "xdp", 3) == 0;
> +	bool is_checmate = strncmp(event, "checmate", 8) == 0;
>  	enum bpf_prog_type prog_type;
>  	char buf[256];
>  	int fd, efd, err, id;
> @@ -69,6 +70,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
>  		prog_type = BPF_PROG_TYPE_TRACEPOINT;
>  	} else if (is_xdp) {
>  		prog_type = BPF_PROG_TYPE_XDP;
> +	} else if (is_checmate) {
> +		prog_type = BPF_PROG_TYPE_CHECMATE;
>  	} else {
>  		printf("Unknown event '%s'\n", event);
>  		return -1;
> @@ -82,7 +85,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
>  
>  	prog_fd[prog_cnt++] = fd;
>  
> -	if (is_xdp)
> +	if (is_xdp || is_checmate)
>  		return 0;
>  
>  	if (is_socket) {
> @@ -326,7 +329,8 @@ int load_bpf_file(char *path)
>  			    memcmp(shname_prog, "kretprobe/", 10) == 0 ||
>  			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
>  			    memcmp(shname_prog, "xdp", 3) == 0 ||
> -			    memcmp(shname_prog, "socket", 6) == 0)
> +			    memcmp(shname_prog, "socket", 6) == 0 ||
> +			    memcmp(shname_prog, "checmate", 8) == 0)
>  				load_and_attach(shname_prog, insns, data_prog->d_size);
>  		}
>  	}
> @@ -344,7 +348,8 @@ int load_bpf_file(char *path)
>  		    memcmp(shname, "kretprobe/", 10) == 0 ||
>  		    memcmp(shname, "tracepoint/", 11) == 0 ||
>  		    memcmp(shname, "xdp", 3) == 0 ||
> -		    memcmp(shname, "socket", 6) == 0)
> +		    memcmp(shname, "socket", 6) == 0 ||
> +		    memcmp(shname, "checmate", 8) == 0)
>  			load_and_attach(shname, data->d_buf, data->d_size);
>  	}
>  
> diff --git a/samples/bpf/checmate_limit_connections_kern.c b/samples/bpf/checmate_limit_connections_kern.c
> new file mode 100644
> index 0000000..d191dcb
> --- /dev/null
> +++ b/samples/bpf/checmate_limit_connections_kern.c
> @@ -0,0 +1,146 @@
> +/* Copyright (c) 2016 Sargun Dhillon <sargun@sargun.me>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program limits the usage of sockets connecting to a given ip:port.
> + * At the moment it doesn't take protocol (SOCK_STREAM vs. SOCK_DGRAM) into
> + * account, but doing so would just involve reading some more fields.
> + *
> + * Since proper refcnting would be fairly hard in eBPF, we do probablistic
> + * refcnting. This means you're probablistically limited to 10 connections.
> + * You may get fewer, but you'll never get more than 10.
> + *
> + * We hash the ip + port with fnv1a into a 22-bit space, and keep track of the
> + * connection count. We also keep track of the dstaddr of a given socket in
> + * another map as we already have to keep track of the sockets that qualified
> + * themselves for tracking (those connecting to AF_INET in this case). We
> + * could track less metadata, but this is an example.
> + */
> +
> +#include <uapi/linux/bpf.h>
> +#include <linux/socket.h>
> +#include <linux/in.h>
> +#include <linux/checmate.h>
> +#include "bpf_helpers.h"
> +#include <linux/version.h>
> +#include <linux/net.h>
> +
> +#define HASH_BITS	22 /* 2**22 * 4 = 16777216 (16mb) */
> +#define MASK		(((u32)1 << HASH_BITS) - 1)
> +#define FNV1_32_INIT	2166136261
> +#define FNV1_32_PRIME	16777619
> +#define CONN_LIMIT	10
> +
> +struct bpf_map_def SEC("maps") sk_to_hash_map = {
> +	.type			= BPF_MAP_TYPE_HASH,
> +	.key_size		= sizeof(struct sock *),
> +	.value_size		= sizeof(u32),
> +	/* This only allows 16384 socket connections */
> +	.max_entries		= 16384,
> +};
> +
> +struct bpf_map_def SEC("maps") addr_refcnt = {
> +	.type			= BPF_MAP_TYPE_ARRAY,
> +	.key_size		= sizeof(int),
> +	.value_size		= sizeof(u32),
> +	.max_entries		= 1 << HASH_BITS,
> +};
> +
> +static inline u32 fnv1a(struct sockaddr_in *addr)
> +{
> +	/*
> +	 * The reason to take this approach, rather than hash the whole
> +	 * structure is to avoid accidentally hashing the padding.
> +	 * The reasoning to start at byte 2 is to skip sin_family,
> +	 * and to stop at byte 8, because that's where sin_addr + sin_port end.
> +	 */
> +	u32 hash = FNV1_32_INIT;
> +	u8 *data = (u8 *)addr;
> +
> +	hash = hash ^ (data[2] & 0xff);
> +	hash = hash * FNV1_32_PRIME;
> +	hash = hash ^ (data[3] & 0xff);
> +	hash = hash * FNV1_32_PRIME;
> +	hash = hash ^ (data[4] & 0xff);
> +	hash = hash * FNV1_32_PRIME;
> +	hash = hash ^ (data[5] & 0xff);
> +	hash = hash * FNV1_32_PRIME;
> +	hash = hash ^ (data[6] & 0xff);
> +	hash = hash * FNV1_32_PRIME;
> +	hash = hash ^ (data[7] & 0xff);
> +	hash = hash * FNV1_32_PRIME;
> +	hash = (hash >> HASH_BITS) ^ (hash & MASK);
> +
> +	return hash;
> +}
> +
> +SEC("checmate/connect")
> +int prog_connect(struct checmate_ctx *ctx)
> +{
> +	struct sockaddr_in addr_in = {};
> +	struct sock *sk = 0;
> +	int rc = 0;
> +	u32 *refcnt;
> +	u32 hash;
> +
> +	rc = bpf_probe_read(&addr_in, sizeof(addr_in),
> +			    ctx->socket_connect.address);
> +	if (rc)
> +		return rc;
> +
> +	if (addr_in.sin_family != AF_INET)
> +		return 0;
> +
> +	rc = bpf_probe_read(&sk, sizeof(sk), &ctx->socket_connect.sock->sk);
> +	if (rc)
> +		return rc;
> +
> +	hash = fnv1a(&addr_in);
> +
> +	refcnt = bpf_map_lookup_elem(&addr_refcnt, &hash);
> +	if (!refcnt)
> +		return -EINVAL;
> +
> +	if (*refcnt >= CONN_LIMIT)
> +		return -EUSERS;
> +
> +	/* The only error we should get at this point is out of space */
> +	rc = bpf_map_update_elem(&sk_to_hash_map, &sk, &hash, BPF_ANY);
> +	if (rc)
> +		return rc;
> +
> +	__sync_fetch_and_add(refcnt, 1);
> +	return 0;
> +}
> +
> +SEC("checmate/sk_free")
> +int prog_sk_free(struct checmate_ctx *ctx)
> +{
> +	struct sock *sk = ctx->sk_free_security.sk;
> +	struct sockaddr_in *addr;
> +	u32 *refcnt, *hash;
> +	/*
> +	 * You cannot reuse map values as map keys, therefore we need to copy
> +	 * the hash to the stack.
> +	 */
> +	u32 hash_as_key;
> +
> +	hash = bpf_map_lookup_elem(&sk_to_hash_map, &sk);
> +	if (!hash)
> +		return 0;
> +
> +	memcpy(&hash_as_key, hash, sizeof(hash_as_key));
> +	refcnt = bpf_map_lookup_elem(&addr_refcnt, &hash_as_key);
> +	if (!refcnt)
> +		return -EINVAL;
> +
> +	__sync_fetch_and_add(refcnt, -1);
> +	bpf_map_delete_elem(&sk_to_hash_map, &sk);
> +
> +	return 0;
> +}
> +
> +char _license[] SEC("license") = "GPL";
> +u32 _version SEC("version") = LINUX_VERSION_CODE;
> diff --git a/samples/bpf/checmate_limit_connections_user.c b/samples/bpf/checmate_limit_connections_user.c
> new file mode 100644
> index 0000000..8834062
> --- /dev/null
> +++ b/samples/bpf/checmate_limit_connections_user.c
> @@ -0,0 +1,113 @@
> +/* Copyright (c) 2016 Sargun Dhillon <sargun@sargun.me>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
> +
> +#include <linux/bpf.h>
> +#include <stdio.h>
> +#include <errno.h>
> +#include <stdlib.h>
> +#include "bpf_load.h"
> +#include "libbpf.h"
> +#include <netinet/in.h>
> +#include <assert.h>
> +#include <fcntl.h>
> +#include <unistd.h>
> +#include <sys/socket.h>
> +#include <arpa/inet.h>
> +#include "cgroup_helpers.h"
> +
> +#define CONN_LIMIT		10
> +#define CGROUP_NAME		"limit_connections"
> +#define CONTROL_FILE_CONNECT	"limit_connections/checmate.socket_connect"
> +#define CONTROL_FILE_SK_FREE	"limit_connections/checmate.sk_free_security"
> +
> +int main(int ac, char **argv)
> +{
> +	int i, sock, connect_fd, sk_free_fd, rc = 0;
> +	struct sockaddr_in addr;
> +	int socks[CONN_LIMIT];
> +	char filename[256];
> +
> +	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
> +	if (load_bpf_file(filename)) {
> +		printf("%s", bpf_log_buf);
> +		return 1;
> +	}
> +	if (!(prog_fd[0] && prog_fd[1])) {
> +		printf("load_bpf_file: %s\n", strerror(errno));
> +		return 1;
> +	}
> +
> +	if (setup_cgroups())
> +		return 1;
> +
> +	if (add_controller("checmate"))
> +		return 1;
> +
> +	if (mkdirp(CGROUP_NAME))
> +		return 1;
> +
> +	if (join_cgroup(CGROUP_NAME)) {
> +		log_err("Joining target group");
> +		rc = 1;
> +		goto leave_cgroup_err;
> +	}
> +
> +	connect_fd = open(CONTROL_FILE_CONNECT, O_WRONLY);
> +	sk_free_fd = open(CONTROL_FILE_SK_FREE, O_WRONLY);
> +
> +	if (connect_fd < 0 || sk_free_fd < 0) {
> +		log_err("Unable to open checmate control file");
> +		rc = 1;
> +		goto leave_cgroup_err;
> +	}
> +
> +	if (reset_bpf_hook(connect_fd))
> +		goto leave_cgroup_err;
> +	if (reset_bpf_hook(sk_free_fd))
> +		goto leave_cgroup_err;
> +
> +	/* Install the programs */
> +	assert(dprintf(connect_fd, "%d\n", prog_fd[0]) > 0);
> +	assert(dprintf(sk_free_fd, "%d\n", prog_fd[1]) > 0);
> +
> +	addr.sin_family = AF_INET;
> +	addr.sin_port = htons(1234);
> +
> +	/* Assigned as "TEST-NET" for use in documentation and examples */
> +	addr.sin_addr.s_addr = inet_addr("192.0.2.0");
> +
> +	/* Create connections, and make sure they work */
> +	for (i = 0; i < CONN_LIMIT; i++) {
> +		socks[i] = socket(AF_INET, SOCK_DGRAM, 0);
> +		assert(!connect(socks[i], (struct sockaddr *)&addr,
> +				sizeof(addr)));
> +	}
> +
> +	sock = socket(AF_INET, SOCK_DGRAM, 0);
> +	/* This last connection should fail, but succeed later */
> +	assert(connect(sock, (struct sockaddr *)&addr, sizeof(addr)));
> +
> +	/* Test is socket freeing works correctly */
> +	for (i = 0; i < CONN_LIMIT; i++)
> +		close(socks[i]);
> +
> +	/* Sockets are freed asynchronously, so we need to wait a moment */
> +	usleep(100000);
> +
> +	/* Retry the connection with the same sk -- should succeed */
> +	assert(!connect(sock, (struct sockaddr *)&addr, sizeof(addr)));
> +
> +	reset_bpf_hook(connect_fd);
> +	reset_bpf_hook(sk_free_fd);
> +	close(connect_fd);
> +	close(sk_free_fd);
> +
> +leave_cgroup_err:
> +	join_cgroup(".");
> +	rmdir(CGROUP_NAME);
> +	return rc;
> +}
> diff --git a/samples/bpf/checmate_remap_bind_kern.c b/samples/bpf/checmate_remap_bind_kern.c
> new file mode 100644
> index 0000000..9456e40
> --- /dev/null
> +++ b/samples/bpf/checmate_remap_bind_kern.c
> @@ -0,0 +1,28 @@
> +#include <linux/version.h>
> +#include <uapi/linux/bpf.h>
> +#include <linux/socket.h>
> +#include <linux/in.h>
> +#include <linux/checmate.h>
> +#include "bpf_helpers.h"
> +
> +SEC("checmate/prog1")
> +int prog1(struct checmate_ctx *ctx)
> +{
> +	struct sockaddr address = {};
> +	struct sockaddr_in *in_addr = (struct sockaddr_in *) &address;
> +
> +	bpf_probe_read(&address, sizeof(struct sockaddr_in),
> +		       ctx->socket_bind.address);
> +
> +	if (address.sa_family == AF_INET &&
> +	    be16_to_cpu(in_addr->sin_port) == 6789) {
> +		in_addr->sin_port = cpu_to_be16(12345);
> +		bpf_probe_write_checmate(ctx, ctx->socket_bind.address,
> +					 in_addr, sizeof(*in_addr));
> +	}
> +
> +	return 0;
> +}
> +
> +char _license[] SEC("license") = "GPL";
> +u32 _version SEC("version") = LINUX_VERSION_CODE;
> diff --git a/samples/bpf/checmate_remap_bind_user.c b/samples/bpf/checmate_remap_bind_user.c
> new file mode 100644
> index 0000000..a53b20b
> --- /dev/null
> +++ b/samples/bpf/checmate_remap_bind_user.c
> @@ -0,0 +1,82 @@
> +#include <linux/bpf.h>
> +#include <stdio.h>
> +#include <errno.h>
> +#include <stdlib.h>
> +#include "bpf_load.h"
> +#include "libbpf.h"
> +#include <netinet/in.h>
> +#include <assert.h>
> +#include <fcntl.h>
> +#include <unistd.h>
> +#include "cgroup_helpers.h"
> +
> +#define CGROUP_NAME	"remap_bind_user"
> +#define CONTROL_FILE	"remap_bind_user/checmate.socket_bind"
> +
> +int main(int ac, char **argv)
> +{
> +	struct sockaddr_in addr = {};
> +	socklen_t len = sizeof(addr);
> +	int sock, fd, rc = 0;
> +	char filename[256];
> +
> +	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
> +	if (load_bpf_file(filename)) {
> +		printf("%s", bpf_log_buf);
> +		return 1;
> +	}
> +	if (!prog_fd[0]) {
> +		printf("load_bpf_file: %s\n", strerror(errno));
> +		return 1;
> +	}
> +
> +	if (setup_cgroups())
> +		return 1;
> +
> +	if (add_controller("checmate"))
> +		return 1;
> +
> +	if (mkdirp(CGROUP_NAME))
> +		return 1;
> +
> +	if (join_cgroup(CGROUP_NAME)) {
> +		log_err("Joining target group");
> +		rc = 1;
> +		goto leave_cgroup_err;
> +	}
> +
> +	fd = open(CONTROL_FILE, O_WRONLY);
> +
> +	if (fd < 0) {
> +		log_err("Unable to open checmate control file");
> +		rc = 1;
> +		goto leave_cgroup_err;
> +	}
> +
> +	if (reset_bpf_hook(fd))
> +		goto leave_cgroup_err;
> +
> +	/* Install program */
> +	assert(dprintf(fd, "%d\n", prog_fd[0]) > 0);
> +
> +	sock = socket(AF_INET, SOCK_DGRAM, 0);
> +	if (sock < 0) {
> +		log_err("Creating socket");
> +		rc = 1;
> +		goto cleanup_hook_err;
> +	}
> +
> +	addr.sin_family = AF_INET;
> +	addr.sin_port = htons(6789);
> +	assert(bind(sock, (const struct sockaddr *)&addr, sizeof(addr)) == 0);
> +	assert(getsockname(sock, (struct sockaddr *)&addr, &len) == 0);
> +	assert(addr.sin_port == htons(12345));
> +
> +cleanup_hook_err:
> +	reset_bpf_hook(fd);
> +	close(fd);
> +leave_cgroup_err:
> +	join_cgroup(".");
> +	rmdir(CGROUP_NAME);
> +	return rc;
> +}
> -- 
> 2.7.4
> 

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/3] tools lib bpf: Sync with samples/bpf/libbpf
Date: Wed, 02 Nov 2016 03:52:54 +0100
Message-ID: <58195506.8040205@iogearbox.net>
References: <20161031183917.9938-1-joe@ovn.org> <20161031183917.9938-3-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, ast@fb.com
To: Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58831 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbcKBCw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 22:52:59 -0400
In-Reply-To: <20161031183917.9938-3-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2016 07:39 PM, Joe Stringer wrote:
> Extend the tools/ version of libbpf to include all of the functionality
> provided in the samples/bpf version.
>
> Signed-off-by: Joe Stringer <joe@ovn.org>
> ---
>   tools/lib/bpf/bpf.c    | 139 +++++++++++++++++++++++++++------
>   tools/lib/bpf/bpf.h    | 208 +++++++++++++++++++++++++++++++++++++++++++++++--
>   tools/lib/bpf/libbpf.c |   3 +-
>   3 files changed, 317 insertions(+), 33 deletions(-)
>
[...]
> +int open_raw_sock(const char *name)
> +{
> +	struct sockaddr_ll sll;
> +	int sock;
> +
> +	sock = socket(PF_PACKET, SOCK_RAW | SOCK_NONBLOCK | SOCK_CLOEXEC,
> +		      htons(ETH_P_ALL));
> +	if (sock < 0) {
> +		printf("cannot create raw socket\n");
> +		return -1;
> +	}
> +
> +	memset(&sll, 0, sizeof(sll));
> +	sll.sll_family = AF_PACKET;
> +	sll.sll_ifindex = if_nametoindex(name);
> +	sll.sll_protocol = htons(ETH_P_ALL);
> +	if (bind(sock, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
> +		printf("bind to %s: %s\n", name, strerror(errno));
> +		close(sock);
> +		return -1;
> +	}
> +
> +	return sock;
> +}
> +
> +int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
> +		    int group_fd, unsigned long flags)
> +{
> +	return syscall(__NR_perf_event_open, attr, pid, cpu,
> +		       group_fd, flags);
>   }

I'm actually wondering, above bits are not really libbpf related. Maybe
these should go elsewhere into some other misc header file just for the
samples to use?

> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
> index e8ba54087497..227edb23c022 100644
> --- a/tools/lib/bpf/bpf.h
> +++ b/tools/lib/bpf/bpf.h
> @@ -23,16 +23,208 @@
>
>   #include <linux/bpf.h>
>
> +struct bpf_insn;
> +

Isn't that already defined in the above uapi bpf.h anyway?

>   int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
> -		   int max_entries);
> +		   int max_entries, int map_flags);
> +int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
> +int bpf_lookup_elem(int fd, void *key, void *value);
> +int bpf_delete_elem(int fd, void *key);
> +int bpf_get_next_key(int fd, void *key, void *next_key);
> +
> +int bpf_load_program(enum bpf_prog_type prog_type,
> +		     const struct bpf_insn *insns, int insn_len,
> +		     const char *license, int kern_version,
> +		     char *log_buf, size_t log_buf_sz);
> +
> +int bpf_obj_pin(int fd, const char *pathname);
> +int bpf_obj_get(const char *pathname);

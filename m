From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Wed, 10 Sep 2014 11:21:01 +0200
Message-ID: <541017FD.1030308@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbaIJJVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 05:21:38 -0400
In-Reply-To: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2014 07:09 AM, Alexei Starovoitov wrote:
....
> BPF(2)                     Linux Programmer's Manual                    BPF(2)
...
>         union bpf_attr {
>             struct { /* anonymous struct used by BPF_MAP_CREATE command */
>                 enum bpf_map_type map_type;
>                 __u32             key_size;    /* size of key in bytes */
>                 __u32             value_size;  /* size of value in bytes */
>                 __u32             max_entries; /* max number of entries in a map */
>             };
>
>             struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
>                 int map_fd;
>                 void *key;
>                 union {
>                     void *value;
>                     void *next_key;
>                 };

When you pass in these structs with pointers in it to other user space
buffers, how do you handle this with mixed 32/64 bit user/kernel space?

As an example, for the current way to load BPF although we export ...

struct sock_fprog {
	unsigned short len;
	struct sock_filter __user *filter;
};

... through uapi, we still need to handle this via compat_sock_fprog
to take care of different pointer sizes via compat_uptr_t :

#ifdef CONFIG_COMPAT
struct compat_sock_fprog {
	u16 len;
	compat_uptr_t filter;
};
#endif

Perhaps I'm missing something, but I think, that would currently break in
your syscall handler, no?

>             };
>
>             struct { /* anonymous struct used by BPF_PROG_LOAD command */
>                 enum bpf_prog_type    prog_type;
>                 __u32                 insn_cnt;
>                 const struct bpf_insn *insns;
>                 const char            *license;
>                 __u32                 log_level; /* verbosity level of eBPF verifier */
>                 __u32                 log_size;  /* size of user buffer */
>                 void                  *log_buf;  /* user supplied buffer */
>             };
>         };

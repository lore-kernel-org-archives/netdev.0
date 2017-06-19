From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next v2 01/15] bpf: BPF support for socket ops
Date: Mon, 19 Jun 2017 20:52:49 +0200
Message-ID: <59481D81.8080505@iogearbox.net>
References: <20170615200844.2752485-1-brakmo@fb.com> <20170615200844.2752485-2-brakmo@fb.com> <5943CA1A.2060006@iogearbox.net> <EFA12996-9C47-444F-9E09-B87F673DCCB0@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <Kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56060 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753019AbdFSSwy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:52:54 -0400
In-Reply-To: <EFA12996-9C47-444F-9E09-B87F673DCCB0@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2017 11:48 PM, Lawrence Brakmo wrote:
> On 6/16/17, 5:07 AM, "Daniel Borkmann" <daniel@iogearbox.net> wrote:
>
>      On 06/15/2017 10:08 PM, Lawrence Brakmo wrote:
>      > Two new corresponding structs (one for the kernel one for the user/BPF
>      > program):
>      >
>      > /* kernel version */
>      > struct bpf_socket_ops_kern {
>      >          struct sock *sk;
>      > 	__u32  is_req_sock:1;
>      >          __u32  op;
>      >          union {
>      >                  __u32 reply;
>      >                  __u32 replylong[4];
>      >          };
>      > };
>      >
>      > /* user version */
>      > struct bpf_socket_ops {
>      >          __u32 op;
>      >          union {
>      >                  __u32 reply;
>      >                  __u32 replylong[4];
>      >          };
>      >          __u32 family;
>      >          __u32 remote_ip4;
>      >          __u32 local_ip4;
>      >          __u32 remote_ip6[4];
>      >          __u32 local_ip6[4];
>      >          __u32 remote_port;
>      >          __u32 local_port;
>      > };
>
>      Above and ...
>
>      struct bpf_sock {
>      	__u32 bound_dev_if;
>      	__u32 family;
>      	__u32 type;
>      	__u32 protocol;
>      };
>
>      ... would result in two BPF sock user versions. It's okayish, but
>      given struct bpf_sock is quite generic, couldn't we merge the members
>      from struct bpf_socket_ops into struct bpf_sock instead?
>
>      Idea would be that sock_filter_is_valid_access() for cgroups would
>      then check off < 0 || off + size > offsetofend(struct bpf_sock, protocol)
>      to disallow new members, and your socket_ops_is_valid_access() could
>      allow and xlate the full range. The family member is already duplicate
>      and the others could then be accessed from these kind of BPF progs as
>      well, plus we have a single user representation similar as with __sk_buff
>      that multiple types will use.
>
> I am concerned that it could make usage more confusing. One type of
> sock program (cgroup) could only use a subset of the fields while the
> other type (socket_ops) could use all (or a different subset). Then what
> happens if there is a need to add a new field to cgroup type sock program?
> In addition, in the near future I will have a patch to attach socket_ops
> programs to cgroups.
> I rather leave it as it is.

Okay, I'm fine with that as well. For the __sk_buff, we also have the
case that some members are not available for all program types like
tc_classid, so it's similar there. But if indeed the majority of members
cannot be supported for the most parts (?) then having different structs
seems okay, probably easier to use, but we should try hard to not ending
up with 10 different uapi socket structs that apply to program types
working on sockets in one way or another.

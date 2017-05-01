From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: more bpf samples build breakage...
Date: Mon, 01 May 2017 22:38:58 +0200
Message-ID: <59079CE2.6010305@iogearbox.net>
References: <20170501.153005.983887567095122966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52495 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdEAUjC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 16:39:02 -0400
In-Reply-To: <20170501.153005.983887567095122966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2017 09:30 PM, David Miller wrote:
>
> Inlcuding bpf_util.h into test_pkt_access.c et al. broke the build even
> more so than it already is on sparc.
>
> The problem is we end up including all the stdio.h bits and eventually
> hit things like:
>
> In file included from /usr/include/stdio.h:933:
> /usr/include/bits/stdio-ldbl.h:28:20: error: cannot apply asm label to function after its first use
> __LDBL_REDIR_DECL (vfprintf)
> ~~~~~~~~~~~~~~~~~~~^~~~~~~~~
> /usr/include/sys/cdefs.h:373:26: note: expanded from macro '__LDBL_REDIR_DECL'
>    extern __typeof (name) name __asm (__ASMNAME ("__nldbl_" #name));
>
> So please let's put CLANG compiled helpers into header files
> specifically meant to be included by CLANG compiled BPF programs
> rather than the host build environment.

Argh, sorry for that and thanks for the quick fix. When I tested
this on x86_64, I didn't hit a compilation issue.

BPF selftests:

[root@apoc bpf]# make > /dev/null
Warning: tools/include/uapi/linux/bpf.h differs from kernel
[root@apoc bpf]# ./test_progs
test_pkt_access:PASS:ipv4 401 nsec
test_pkt_access:PASS:ipv6 271 nsec
test_xdp:PASS:ipv4 4617 nsec
test_xdp:PASS:ipv6 2979 nsec
test_l4lb:PASS:ipv4 921 nsec
test_l4lb:PASS:ipv6 717 nsec
Summary: 6 PASSED, 0 FAILED
[root@apoc bpf]#

BPF samples:

[root@apoc bpf]# make > /dev/null
In file included from /root/cilium/net-next/samples/bpf/cookie_uid_helper_example.c:54:0:
/root/cilium/net-next/samples/bpf/cookie_uid_helper_example.c: In function ‘prog_load’:
/root/cilium/net-next/samples/bpf/cookie_uid_helper_example.c:119:5: warning: overflow in implicit constant conversion [-Woverflow]
      -32 + offsetof(struct stats, uid)),
      ^
/root/cilium/net-next/samples/bpf/libbpf.h:135:12: note: in definition of macro ‘BPF_STX_MEM’
    .off   = OFF,     \
             ^
/root/cilium/net-next/samples/bpf/cookie_uid_helper_example.c:121:5: warning: overflow in implicit constant conversion [-Woverflow]
      -32 + offsetof(struct stats, packets), 1),
      ^
/root/cilium/net-next/samples/bpf/libbpf.h:155:12: note: in definition of macro ‘BPF_ST_MEM’
    .off   = OFF,     \
             ^
/root/cilium/net-next/samples/bpf/cookie_uid_helper_example.c:129:5: warning: overflow in implicit constant conversion [-Woverflow]
      -32 + offsetof(struct stats, bytes)),
      ^
/root/cilium/net-next/samples/bpf/libbpf.h:135:12: note: in definition of macro ‘BPF_STX_MEM’
    .off   = OFF,     \
             ^
[root@apoc bpf]#

Above warning is from 51570a5ab2b7 ("A Sample of using socket
cookie and uid for traffic monitoring"). I can see to send a
fix for it.

Thanks,
Daniel

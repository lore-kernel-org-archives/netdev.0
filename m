From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix panic in SO_GET_FILTER with native ebpf
 programs
Date: Mon, 05 Oct 2015 06:44:36 -0700 (PDT)
Message-ID: <20151005.064436.1724241104415987226.davem@davemloft.net>
References: <98ab6d68ec6db39bfa3b1655d228692457861d60.1443779830.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbJEN25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:28:57 -0400
In-Reply-To: <98ab6d68ec6db39bfa3b1655d228692457861d60.1443779830.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  2 Oct 2015 12:06:03 +0200

> When sockets have a native eBPF program attached through
> setsockopt(sk, SOL_SOCKET, SO_ATTACH_BPF, ...), and then try to
> dump these over getsockopt(sk, SOL_SOCKET, SO_GET_FILTER, ...),
> the following panic appears:
> 
>   [49904.178642] BUG: unable to handle kernel NULL pointer dereference at (null)
>   [49904.178762] IP: [<ffffffff81610fd9>] sk_get_filter+0x39/0x90
>   [49904.182000] PGD 86fc9067 PUD 531a1067 PMD 0
>   [49904.185196] Oops: 0000 [#1] SMP
>   [...]
>   [49904.224677] Call Trace:
>   [49904.226090]  [<ffffffff815e3d49>] sock_getsockopt+0x319/0x740
>   [49904.227535]  [<ffffffff812f59e3>] ? sock_has_perm+0x63/0x70
>   [49904.228953]  [<ffffffff815e2fc8>] ? release_sock+0x108/0x150
>   [49904.230380]  [<ffffffff812f5a43>] ? selinux_socket_getsockopt+0x23/0x30
>   [49904.231788]  [<ffffffff815dff36>] SyS_getsockopt+0xa6/0xc0
>   [49904.233267]  [<ffffffff8171b9ae>] entry_SYSCALL_64_fastpath+0x12/0x71
> 
> The underlying issue is the very same as in commit b382c0865600
> ("sock, diag: fix panic in sock_diag_put_filterinfo"), that is,
> native eBPF programs don't store an original program since this
> is only needed in cBPF ones.
> 
> However, sk_get_filter() wasn't updated to test for this at the
> time when eBPF could be attached. Just throw an error to the user
> to indicate that eBPF cannot be dumped over this interface.
> That way, it can also be known that a program _is_ attached (as
> opposed to just return 0), and a different (future) method needs
> to be consulted for a dump.
> 
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable.

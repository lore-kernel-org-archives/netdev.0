From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, array: fix heap out-of-bounds access when
 updating elements
Date: Tue, 01 Dec 2015 21:57:36 -0500 (EST)
Message-ID: <20151201.215736.672943879522319005.davem@davemloft.net>
References: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dvyukov@google.com, kcc@google.com,
	glider@google.com, edumazet@google.com, sasha.levin@oracle.com,
	syzkaller@googlegroups.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbbLBC5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 21:57:39 -0500
In-Reply-To: <674d6a1d4ff0e7728e535dc2d8fe1c5bea1e50b0.1448883657.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 30 Nov 2015 13:02:55 +0100

> During own review but also reported by Dmitry's syzkaller [1] it has been
> noticed that we trigger a heap out-of-bounds access on eBPF array maps
> when updating elements. This happens with each map whose map->value_size
> (specified during map creation time) is not multiple of 8 bytes.
> 
> In array_map_alloc(), elem_size is round_up(attr->value_size, 8) and
> used to align array map slots for faster access. However, in function
> array_map_update_elem(), we update the element as ...
> 
> memcpy(array->value + array->elem_size * index, value, array->elem_size);
> 
> ... where we access 'value' out-of-bounds, since it was allocated from
> map_update_elem() from syscall side as kmalloc(map->value_size, GFP_USER)
> and later on copied through copy_from_user(value, uvalue, map->value_size).
> Thus, up to 7 bytes, we can access out-of-bounds.
> 
> Same could happen from within an eBPF program, where in worst case we
> access beyond an eBPF program's designated stack.
> 
> Since 1be7f75d1668 ("bpf: enable non-root eBPF programs") didn't hit an
> official release yet, it only affects priviledged users.
> 
> In case of array_map_lookup_elem(), the verifier prevents eBPF programs
> from accessing beyond map->value_size through check_map_access(). Also
> from syscall side map_lookup_elem() only copies map->value_size back to
> user, so nothing could leak.
> 
>   [1] http://github.com/google/syzkaller
> 
> Fixes: 28fbcfa08d8e ("bpf: add array type of eBPF maps")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.

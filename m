From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: fix allocation warnings in bpf maps and integer
 overflow
Date: Mon, 30 Nov 2015 15:30:34 -0800
Message-ID: <20151130233033.GA67392@ast-mbp.thefacebook.com>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com>
 <20151130005934.GA95228@ast-mbp.thefacebook.com>
 <565C549C.5080408@iogearbox.net>
 <565C5E7B.2080602@iogearbox.net>
 <20151130181310.GA30762@ast-mbp.thefacebook.com>
 <565CCACE.8020406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35793 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbK3Xai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 18:30:38 -0500
Content-Disposition: inline
In-Reply-To: <565CCACE.8020406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 11:16:46PM +0100, Daniel Borkmann wrote:
> 
> So, when creating a sufficiently large map where map->key_size + map->value_size
> would be > MAX_BPF_STACK (but map->key_size still <= MAX_BPF_STACK), we can only
> read the map from an eBPF program, but not update it. In such cases, updates could
> only happen from user space application.

yes and no.
If both key_size + value_size > MAX_BPF_STACK, the program cannot technically
call bpf_map_update_elem() helper, but the user space can still populate large map
elements and the program can update it, since it can have a pointer via
bpf_map_lookup_elem(). So depends on definition of 'update'.

btw, the large-ish key support is actually needed too, since on tracing side
we need to be able to do map[kernel_stack_and_user_stack]++ and key is multipage long.
On userspace side it will be consumed by flamegraphs.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix hashmap extra_elems logic
Date: Wed, 22 Mar 2017 14:12:56 -0700 (PDT)
Message-ID: <20170322.141256.255577722554467671.davem@davemloft.net>
References: <1490148304-1459018-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, kafai@fb.com, davej@codemonkey.org.uk,
        netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdCVVND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:13:03 -0400
In-Reply-To: <1490148304-1459018-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 21 Mar 2017 19:05:04 -0700

> In both kmalloc and prealloc mode the bpf_map_update_elem() is using
> per-cpu extra_elems to do atomic update when the map is full.
> There are two issues with it. The logic can be misused, since it allows
> max_entries+num_cpus elements to be present in the map. And alloc_extra_elems()
> at map creation time can fail percpu alloc for large map values with a warn:
> WARNING: CPU: 3 PID: 2752 at ../mm/percpu.c:892 pcpu_alloc+0x119/0xa60
> illegal size (32824) or align (8) for percpu allocation
> 
> The fixes for both of these issues are different for kmalloc and prealloc modes.
> For prealloc mode allocate extra num_possible_cpus elements and store
> their pointers into extra_elems array instead of actual elements.
> Hence we can use these hidden(spare) elements not only when the map is full
> but during bpf_map_update_elem() that replaces existing element too.
> That also improves performance, since pcpu_freelist_pop/push is avoided.
> Unfortunately this approach cannot be used for kmalloc mode which needs
> to kfree elements after rcu grace period. Therefore switch it back to normal
> kmalloc even when full and old element exists like it was prior to
> commit 6c9059817432 ("bpf: pre-allocate hash map elements").
> 
> Add tests to check for over max_entries and large map values.
> 
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Martin KaFai Lau <kafai@fb.com>

Applied and queued up for -stable, thanks.

From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH] net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
Date: Mon, 29 Aug 2016 17:59:26 +0300
Message-ID: <c03157a0-b7d0-bde7-0fe9-4f3b19a68d08@mellanox.com>
References: <20160826203808.23664-1-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        "Or Gerlitz" <gerlitz.or@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: Brenden Blanco <bblanco@plumgrid.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0043.outbound.protection.outlook.com ([104.47.2.43]:21728
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756203AbcH3CfW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 22:35:22 -0400
In-Reply-To: <20160826203808.23664-1-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brenden,

The solution direction should be XDP specific that does not hurt the 
regular flow.

On 26/08/2016 11:38 PM, Brenden Blanco wrote:
> Depending on the preempt mode, the bpf_prog stored in xdp_prog may be
> freed despite the use of call_rcu inside bpf_prog_put. The situation is
> possible when running in PREEMPT_RCU=y mode, for instance, since the rcu
> callback for destroying the bpf prog can run even during the bh handling
> in the mlx4 rx path.
>
> Several options were considered before this patch was settled on:
>
> Add a napi_synchronize loop in mlx4_xdp_set, which would occur after all
> of the rings are updated with the new program.
> This approach has the disadvantage that as the number of rings
> increases, the speed of udpate will slow down significantly due to
> napi_synchronize's msleep(1).
I prefer this option as it doesn't hurt the data path. A delay in a 
control command can be tolerated.
> Add a new rcu_head in bpf_prog_aux, to be used by a new bpf_prog_put_bh.
> The action of the bpf_prog_put_bh would be to then call bpf_prog_put
> later. Those drivers that consume a bpf prog in a bh context (like mlx4)
> would then use the bpf_prog_put_bh instead when the ring is up. This has
> the problem of complexity, in maintaining proper refcnts and rcu lists,
> and would likely be harder to review. In addition, this approach to
> freeing must be exclusive with other frees of the bpf prog, for instance
> a _bh prog must not be referenced from a prog array that is consumed by
> a non-_bh prog.
>
> The placement of rcu_read_lock in this patch is functionally the same as
> putting an rcu_read_lock in napi_poll. Actually doing so could be a
> potentially controversial change, but would bring the implementation in
> line with sk_busy_loop (though of course the nature of those two paths
> is substantially different), and would also avoid future copy/paste
> problems with future supporters of XDP. Still, this patch does not take
> that opinionated option.
So you decided to add a lock for all non-XDP flows, which are 99% of the 
cases.
We should avoid this.
>
> Testing was done with kernels in either PREEMPT_RCU=y or
> CONFIG_PREEMPT_VOLUNTARY=y+PREEMPT_RCU=n modes, with neither exhibiting
> any drawback. With PREEMPT_RCU=n, the extra call to rcu_read_lock did
> not show up in the perf report whatsoever, and with PREEMPT_RCU=y the
> overhead of rcu_read_lock (according to perf) was the same before/after.
> In the rx path, rcu_read_lock is eventually called for every packet
> from netif_receive_skb_internal, so the napi poll call's rcu_read_lock
> is easily amortized.
For now, I don't agree with this fix.
Let me think about the options you suggested.
I also need to do my perf tests.

Regards,
Tariq

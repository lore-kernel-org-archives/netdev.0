From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 1/3] mm, percpu: add support for __GFP_NOWARN flag
Date: Tue, 17 Oct 2017 08:53:50 -0700
Message-ID: <20171017155349.k5cfpirons56w2ox@ast-mbp.dhcp.thefacebook.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
 <beeeab23cda20c0b0ee3e4ccb30b91518de6c075.1508251210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tj@kernel.org, ast@kernel.org,
        john.fastabend@gmail.com, mark.rutland@arm.com, richard@nod.at,
        sp3485@columbia.edu, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <beeeab23cda20c0b0ee3e4ccb30b91518de6c075.1508251210.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 04:55:52PM +0200, Daniel Borkmann wrote:
> Add an option for pcpu_alloc() to support __GFP_NOWARN flag.
> Currently, we always throw a warning when size or alignment
> is unsupported (and also dump stack on failed allocation
> requests). The warning itself is harmless since we return
> NULL anyway for any failed request, which callers are
> required to handle anyway. However, it becomes harmful when
> panic_on_warn is set.
> 
> The rationale for the WARN() in pcpu_alloc() is that it can
> be tracked when larger than supported allocation requests are
> made such that allocations limits can be tweaked if warranted.
> This makes sense for in-kernel users, however, there are users
> of pcpu allocator where allocation size is derived from user
> space requests, e.g. when creating BPF maps. In these cases,
> the requests should fail gracefully without throwing a splat.
> 
> The current work-around was to check allocation size against
> the upper limit of PCPU_MIN_UNIT_SIZE from call-sites for
> bailing out prior to a call to pcpu_alloc() in order to
> avoid throwing the WARN(). This is bad in multiple ways since
> PCPU_MIN_UNIT_SIZE is an implementation detail, and having
> the checks on call-sites only complicates the code for no
> good reason. Thus, lets fix it generically by supporting the
> __GFP_NOWARN flag that users can then use with calling the
> __alloc_percpu_gfp() helper instead.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Mark Rutland <mark.rutland@arm.com>

The approach looks great to me. We've been doing this dance around
allocator warning for long time. It's really not a job of bpf code
to guess into valid parameters of pcpu alloc.
Adding support for __GFP_NOWARN and using it in bpf is much cleaner
fix that avoids layering violations.

Acked-by: Alexei Starovoitov <ast@kernel.org>

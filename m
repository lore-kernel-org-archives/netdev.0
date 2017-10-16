From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: devmap: Check attr->max_entries more carefully
Date: Mon, 16 Oct 2017 20:52:13 +0200
Message-ID: <59E4FFDD.7010402@iogearbox.net>
References: <20171015220020.8157-1-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@kernel.org, sp3485@columbia.edu,
        tj@kernel.org, mark.rutland@arm.com, john.fastabend@gmail.com
To: Richard Weinberger <richard@nod.at>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171015220020.8157-1-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ +Tejun, Mark, John ]

On 10/16/2017 12:00 AM, Richard Weinberger wrote:
> max_entries is user controlled and used as input for __alloc_percpu().
> This function expects that the allocation size is a power of two and
> less than PCPU_MIN_UNIT_SIZE.
> Otherwise a WARN() is triggered.
>
> Fixes: 11393cc9b9be ("xdp: Add batching support to redirect map")
> Reported-by: Shankara Pailoor <sp3485@columbia.edu>
> Reported-by: syzkaller <syzkaller@googlegroups.com>
> Signed-off-by: Richard Weinberger <richard@nod.at>

Thanks for the patch, Richard. There was a prior discussion here [1] on
the same issue, I thought this would have been resolved by now, but looks
like it's still open and there was never a follow-up, at least I don't see
it in the percpu tree if I didn't miss anything.

I would suggest, we do the following below and pass __GFP_NOWARN from BPF
side to the per-cpu allocs. This is kind of a generic 'issue' and we shouldn't
add more code which bails out anyway just to work around the WARN(). Lets
handle it properly instead.

If Tejun is fine with the one below, I could cook and official patch and
cleanup the remaining call-sites from BPF which have similar pattern.

   [1] https://patchwork.kernel.org/patch/9975851/

Thanks,
Daniel

  mm/percpu.c | 5 +++--
  1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 59d44d6..5d9414e 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1357,7 +1357,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,

  	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE ||
  		     !is_power_of_2(align))) {
-		WARN(true, "illegal size (%zu) or align (%zu) for percpu allocation\n",
+		WARN(!(gfp & __GFP_NOWARN),
+		     "illegal size (%zu) or align (%zu) for percpu allocation\n",
  		     size, align);
  		return NULL;
  	}
@@ -1478,7 +1479,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
  fail:
  	trace_percpu_alloc_percpu_fail(reserved, is_atomic, size, align);

-	if (!is_atomic && warn_limit) {
+	if (!is_atomic && warn_limit && !(gfp & __GFP_NOWARN)) {
  		pr_warn("allocation failed, size=%zu align=%zu atomic=%d, %s\n",
  			size, align, is_atomic, err);
  		dump_stack();
-- 
1.9.3

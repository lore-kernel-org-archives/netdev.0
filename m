From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 5/5] MIPS: Add support for eBPF JIT.
Date: Thu, 25 May 2017 19:23:02 -0700
Message-ID: <20170526022300.c4gtxhqt3tyiukz2@ast-mbp>
References: <20170526003826.10834-1-david.daney@cavium.com>
 <20170526003826.10834-6-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, Markos Chandras <markos.chandras@imgtec.com>
To: David Daney <david.daney@cavium.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20170526003826.10834-6-david.daney@cavium.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Thu, May 25, 2017 at 05:38:26PM -0700, David Daney wrote:
> Since the eBPF machine has 64-bit registers, we only support this in
> 64-bit kernels.  As of the writing of this commit log test-bpf is showing:
> 
>   test_bpf: Summary: 316 PASSED, 0 FAILED, [308/308 JIT'ed]
> 
> All current test cases are successfully compiled.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>  arch/mips/Kconfig       |    1 +
>  arch/mips/net/bpf_jit.c | 1627 ++++++++++++++++++++++++++++++++++++++++++++++-
>  arch/mips/net/bpf_jit.h |    7 +
>  3 files changed, 1633 insertions(+), 2 deletions(-)

Great stuff. I wonder what is the performance difference
interpreter vs JIT

> + * eBPF stack frame will be something like:
> + *
> + *  Entry $sp ------>   +--------------------------------+
> + *                      |   $ra  (optional)              |
> + *                      +--------------------------------+
> + *                      |   $s0  (optional)              |
> + *                      +--------------------------------+
> + *                      |   $s1  (optional)              |
> + *                      +--------------------------------+
> + *                      |   $s2  (optional)              |
> + *                      +--------------------------------+
> + *                      |   $s3  (optional)              |
> + *                      +--------------------------------+
> + *                      |   tmp-storage  (if $ra saved)  |
> + * $sp + tmp_offset --> +--------------------------------+ <--BPF_REG_10
> + *                      |   BPF_REG_10 relative storage  |
> + *                      |    MAX_BPF_STACK (optional)    |
> + *                      |      .                         |
> + *                      |      .                         |
> + *                      |      .                         |
> + *     $sp -------->    +--------------------------------+
> + *
> + * If BPF_REG_10 is never referenced, then the MAX_BPF_STACK sized
> + * area is not allocated.
> + */

It's especially great to see that you've put the tmp storage
above program stack and made the stack allocation optional.
At the moment I'm working on reducing bpf program stack size,
so that JIT and interpreter can use only the stack they need.
Looking at this JIT code only minimal changes will be needed.

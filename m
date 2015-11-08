From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] arm64: bpf: fix JIT stack setup
Date: Sat, 7 Nov 2015 18:27:27 -0800
Message-ID: <20151108022726.GB39441@ast-mbp.thefacebook.com>
References: <1446874577-14539-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com, zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446874577-14539-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 06, 2015 at 09:36:17PM -0800, Yang Shi wrote:
> ARM64 JIT used FP (x29) as eBPF fp register, but FP is subjected to
> change during function call so it may cause the BPF prog stack base address
> change too. Whenever, it pointed to the bottom of BPF prog stack instead of
> the top.
> 
> So, when copying data via bpf_probe_read, it will be copied to (SP - offset),
> then it may overwrite the saved FP/LR.
> 
> Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
> saved register, so it will keep intact during function call.
> It is initialized in BPF prog prologue when BPF prog is started to run
> everytime. When BPF prog exits, it could be just tossed.
> 
> Other than this the BPf prog stack base need to be setup before function
> call stack.
> 
> So, the BPF stack layout looks like:
> 
>                                  high
>          original A64_SP =>   0:+-----+ BPF prologue
>                                 |     | FP/LR and callee saved registers
>          BPF fp register => +64:+-----+
>                                 |     |
>                                 | ... | BPF prog stack
>                                 |     |
>                                 |     |
>          current A64_SP =>      +-----+
>                                 |     |
>                                 | ... | Function call stack
>                                 |     |
>                                 +-----+
>                                   low
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> CC: Xi Wang <xi.wang@gmail.com>

Thanks for tracking it down.
That looks like fundamental bug in arm64 jit. I'm surprised function calls worked at all.
Zi please review.

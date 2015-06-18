From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: fix a bug in verification logic when SUB
 operation taken on FRAME_PTR
Date: Thu, 18 Jun 2015 09:00:19 -0700
Message-ID: <20150618160018.GA13470@Alexeis-MBP.westell.com>
References: <1434615176-96706-1-git-send-email-wangnan0@huawei.com>
 <1434616305-97746-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lizefan@huawei.com, pi3orama@163.com
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1434616305-97746-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 18, 2015 at 08:31:45AM +0000, Wang Nan wrote:
> Original code has a problem, cause following code failed to pass verifier:
> 
>  r1 <- r10
>  r1 -= 8
>  r2 = 8
>  r3 = unsafe pointer
>  call BPF_FUNC_probe_read  <-- R1 type=inv expected=fp
> 
> However, by replacing 'r1 -= 8' to 'r1 += -8' the above program can be
> loaded successfully.
> 
> This is because the verifier allows only BPF_ADD instruction on a
> FRAME_PTR reigster to forge PTR_TO_STACK register, but makes BPF_SUB
> on FRAME_PTR reigster to get a UNKNOWN_VALUE register.
> 
> This patch fix it by adding BPF_SUB in stack_relative checking.

It's not a bug. It's catching ADD only by design.
If we let it recognize SUB then one might argue we should let it
recognize multiply, shifts and all other arithmetic on pointers.
verifier will be getting bigger and bigger. Where do we stop?
llvm only emits canonical ADD. If you've seen llvm doing SUB,
let's fix it there.
So what piece generated this 'r1 -= 8' ?

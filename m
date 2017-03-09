From: David Miller <davem@davemloft.net>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging
 request at 0000a7cf
Date: Thu, 09 Mar 2017 10:08:30 -0800 (PST)
Message-ID: <20170309.100830.994695882061843653.davem@davemloft.net>
References: <58C157E6.1010909@iogearbox.net>
        <alpine.DEB.2.20.1703091547460.3521@nanos>
        <58C19607.6000605@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, keescook@chromium.org, labbott@redhat.com,
        torvalds@linux-foundation.org, mingo@kernel.org, hpa@zytor.com,
        fengguang.wu@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, lkp@01.org, ast@fb.com,
        x86@kernel.org
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58C19607.6000605@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 09 Mar 2017 18:51:03 +0100

> I added some debugging around __native_flush_tlb_global_irq_disabled()
> and if I understand it correctly, the idea of cr4 is that we need to
> toggle X86_CR4_PGE in order to trigger a TLB flush.
> 
> What I see is that original cr4 is 0x610. The cpu_tlbstate.cr4 is
> consistent to native_read_cr4() and since cr4 is != 0, it tells me
> based on the comment in native_read_cr4() that cr4 seems to be
> supported. Thus, meaning we end up with writing ...
> 
>   native_write_cr4(0x610);
>   native_write_cr4(0x610);
> 
> ... twice, and this just doesn't trigger the desired TLB flush. I
> changed the code into the following ...
> 
>         cr4 = this_cpu_read(cpu_tlbstate.cr4);
>         /* clear PGE */
> -       native_write_cr4(cr4 & ~X86_CR4_PGE);
> +       native_write_cr4(cr4 ^ X86_CR4_PGE);
>         /* write old PGE again and flush TLBs */
>         native_write_cr4(cr4);
> 
> ... and the test cases seem to be working for me now with "-cpu
> kvm64",
> so that seems to trigger the TLB we were missing.

Great detective work Daniel.

From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Page allocator order-0 optimizations merged
Date: Mon, 27 Mar 2017 07:15:18 -0700
Message-ID: <20170327141518.GB27285@bombadil.infradead.org>
References: <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
 <20170322234004.kffsce4owewgpqnm@techsingularity.net>
 <20170323144347.1e6f29de@redhat.com>
 <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
 <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
 <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
 <2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
 <20170327105514.1ed5b1ba@redhat.com>
 <20170327143947.4c237e54@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Pankaj Gupta <pagupta@redhat.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170327143947.4c237e54@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2017 at 02:39:47PM +0200, Jesper Dangaard Brouer wrote:
>  
> +static __always_inline int in_irq_or_nmi(void)
> +{
> +	return in_irq() || in_nmi();
> +// XXX: hoping compiler will optimize this (todo verify) into:
> +// #define in_irq_or_nmi()	(preempt_count() & (HARDIRQ_MASK | NMI_MASK))
> +
> +	/* compiler was smart enough to only read __preempt_count once
> +	 * but added two branches
> +asm code:
> + │       mov    __preempt_count,%eax
> + │       test   $0xf0000,%eax    // HARDIRQ_MASK: 0x000f0000
> + │    ┌──jne    2a
> + │    │  test   $0x100000,%eax   // NMI_MASK:     0x00100000
> + │    │↓ je     3f
> + │ 2a:└─→mov    %rbx,%rdi
> +
> +	 */
> +}

To be fair, you told the compiler to do that with your use of fancy-pants ||
instead of optimisable |.  Try this instead:

static __always_inline int in_irq_or_nmi(void)
{
	return in_irq() | in_nmi();
}

0000000000001770 <test_fn>:
    1770:       65 8b 05 00 00 00 00    mov    %gs:0x0(%rip),%eax        # 1777 <test_fn+0x7>
                        1773: R_X86_64_PC32     __preempt_count-0x4
#define in_nmi()                (preempt_count() & NMI_MASK)
#define in_task()               (!(preempt_count() & \
                                   (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
static __always_inline int in_irq_or_nmi(void)
{
        return in_irq() | in_nmi();
    1777:       25 00 00 1f 00          and    $0x1f0000,%eax
}
    177c:       c3                      retq   
    177d:       0f 1f 00                nopl   (%rax)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] radix-tree: must check __radix_tree_preload() return value
Date: Tue, 5 Sep 2017 11:07:37 -0700
Message-ID: <CA+55aFwNK39yB_wbwKSkk4VfLSxALzeZHT6dShpT1zZdpmeq1Q@mail.gmail.com>
References: <1504634367.15310.59.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Wilcox <willy@infradead.org>,
        Matthew Wilcox <mawilcox@microsoft.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504634367.15310.59.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 5, 2017 at 10:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> @@ -2104,7 +2104,10 @@ EXPORT_SYMBOL(radix_tree_tagged);
>   */
>  void idr_preload(gfp_t gfp_mask)
>  {
> -       __radix_tree_preload(gfp_mask, IDR_PRELOAD_SIZE);
> +       int ret = __radix_tree_preload(gfp_mask, IDR_PRELOAD_SIZE);
> +
> +       if (ret)
> +               preempt_disable();
>  }
>  EXPORT_SYMBOL(idr_preload);

Is there a reason for the "ret" variable that is entirely mis-named,
since it's never actually used as a return value?

(Sure. it's the return value of a function, but that is entirely
useless and pointless information, and adds no value. We should name
variables by the data they contain or how they are used, not by "it
was the return value of a function").

In other words, why isn't this just

        if (__radix_tree_preload(..))
                preempt_disable();

which is shorter and clearer and not confusing?

> @@ -2118,13 +2121,14 @@ EXPORT_SYMBOL(idr_preload);
>   */
>  int ida_pre_get(struct ida *ida, gfp_t gfp)
>  {
> -       __radix_tree_preload(gfp, IDA_PRELOAD_SIZE);
> +       int ret = __radix_tree_preload(gfp, IDA_PRELOAD_SIZE);
>         /*
>          * The IDA API has no preload_end() equivalent.  Instead,
>          * ida_get_new() can return -EAGAIN, prompting the caller
>          * to return to the ida_pre_get() step.
>          */
> -       preempt_enable();
> +       if (!ret)
> +               preempt_enable();

Same issue, but this time strengthened by an additional "why doesn't
this just use that idr_preload function then?" question..

               Linus

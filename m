From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables
	performance
Date: Fri, 23 Sep 2005 11:04:38 -0700
Message-ID: <1127498679.10664.85.camel@localhost>
References: <43308324.70403@cosmosbay.com> <200509221454.22923.ak@suse.de>
	 <20050922125849.GA27413@infradead.org> <200509221505.05395.ak@suse.de>
	 <Pine.LNX.4.62.0509220835310.16793@schroedinger.engr.sgi.com>
	 <4332D2D9.7090802@cosmosbay.com>
	 <20050923171120.GO731@sunbeam.de.gnumonks.org>
	 <Pine.LNX.4.62.0509231043270.22308@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Harald Welte <laforge@netfilter.org>, Andi Kleen <ak@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750948AbVIWSFJ@vger.kernel.org>
To: Christoph Lameter <clameter@engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509231043270.22308@schroedinger.engr.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2005-09-23 at 10:44 -0700, Christoph Lameter wrote:
>         for (i = 0; i < area->nr_pages; i++) {
> -               area->pages[i] = alloc_page(gfp_mask);
> +               if (node < 0)
> +                       area->pages[i] = alloc_page(gfp_mask);
> +               else
> +                       area->pages[i] = alloc_pages_node(node, gfp_mask, 0);
>                 if (unlikely(!area->pages[i])) {
>                         /* Successfully allocated i pages, free them in __vunmap() */
>                         area->nr_pages = i;
...
>  void *vmalloc_exec(unsigned long size)
>  {
> -       return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC);
> +       return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC, -1);
>  }

Instead of hard-coding all of those -1's for the node to specify a
default allocation, and changing all of those callers, why not:

void *__vmalloc_node(unsigned long size, unsigned int __nocast gfp_mask,
pgprot_t prot, int node)
{
	... existing vmalloc code here
}

void *__vmalloc(unsigned long size, unsigned int __nocast gfp_mask,
pgprot_t prot)
{
	__vmalloc_node(size, gfp_mask, prot, -1);
}

A named macro is probably better than -1, but if it is only used in one
place, it is hard to complain.

-- Dave

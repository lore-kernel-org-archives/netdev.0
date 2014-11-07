From: Zoltan Kiss <zoltan.kiss@linaro.org>
Subject: Re: [Xen-devel] BUG in xennet_make_frags with paged skb data
Date: Fri, 07 Nov 2014 09:25:39 +0000
Message-ID: <545C9013.1090406@linaro.org>
References: <20141106214940.GD44162@ubuntu-hedt>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141106214940.GD44162@ubuntu-hedt>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

AFAIK in this scenario your skb frag is wrong. The page pointer should 
point to the original compound page (not a member of it), and offset 
should be set accordingly.
For example, if your compound page is 16K (4 page), then the page 
pointer should point to the first page, and if the data starts at the 
3rd page, then offset should be >8K

Zoli

On 06/11/14 21:49, Seth Forshee wrote:
> We've had several reports of hitting the following BUG_ON in
> xennet_make_frags with 3.2 and 3.13 kernels (I'm currently awaiting
> results of testing with 3.17):
>
>          /* Grant backend access to each skb fragment page. */
>          for (i = 0; i < frags; i++) {
>                  skb_frag_t *frag = skb_shinfo(skb)->frags + i;
>                  struct page *page = skb_frag_page(frag);
>
>                  len = skb_frag_size(frag);
>                  offset = frag->page_offset;
>
>                  /* Data must not cross a page boundary. */
>                  BUG_ON(len + offset > PAGE_SIZE<<compound_order(page));
>
> When this happens the page in question is a "middle" page in a compound
> page (i.e. it's a tail page but not the last tail page), and the data is
> fully contained within the compound page. The data does however cross
> the hardware page boundary, and since compound_order evaluates to 0 for
> tail pages the check fails.
>
> In going over this I've been unable to determine whether the BUG_ON in
> xennet_make_frags is incorrect or the paged skb data is wrong. I can't
> find that it's documented anywhere, and the networking code itself is a
> bit ambiguous when it comes to compound pages. On the one hand
> __skb_fill_page_desc specifically handles adding tail pages as paged
> data, but on the other hand skb_copy_bits kmaps frag->page.p which could
> fail with data that extends into another page.
>
> Can anyone explain what the rules are here? My best guess based on
> skb_copy_bits is that paged data should never cross the hardware page
> boundary, but I'm not really sure how all of this works out when dealing
> with compound pages.
>
> Thanks,
> Seth
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>

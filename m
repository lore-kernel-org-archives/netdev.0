From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc6-mm1
Date: Tue, 8 Jan 2008 16:27:39 -0800
Message-ID: <20080108162739.f2f577ce.akpm@linux-foundation.org>
References: <64bb37e0801061203l503f29f0hd922a1347f8169ac@mail.gmail.com>
	<20080107151639P.fujita.tomonori@lab.ntt.co.jp>
	<20080108155948.GC26114@elte.hu>
	<20080109085753O.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, fujita.tomonori@lab.ntt.co.jp,
	just.for.lkml@googlemail.com, tomof@acm.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42767 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751943AbYAIA3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 19:29:11 -0500
In-Reply-To: <20080109085753O.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Jan 2008 08:57:53 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> Andrew, can you replace
> 
> iommu-sg-add-iommu-helper-functions-for-the-free-area-management.patch
> 
> with the updated patch:
> 
> http://ozlabs.org/pipermail/linuxppc-dev/2007-December/048997.html
> 
> For your convenience I've attached the updated patch too.

<generates the incremental>


> --- a/lib/iommu-helper.c~a
> +++ a/lib/iommu-helper.c
> @@ -8,15 +8,20 @@
>  static unsigned long find_next_zero_area(unsigned long *map,
>  					 unsigned long size,
>  					 unsigned long start,
> -					 unsigned int nr)
> +					 unsigned int nr,
> +					 unsigned long align_mask)
>  {
>  	unsigned long index, end, i;
>  again:
>  	index = find_next_zero_bit(map, size, start);
> +
> +	/* Align allocation */
> +	index = (index + align_mask) & ~align_mask;

The ALIGN() macro is the approved way of doing this.

(I don't think ALIGN adds much value really, especially given that you've
commented what's going on, but I guess it does make reviewing and reading a
little easier).


>  	end = index + nr;
> -	if (end > size)
> +	if (end >= size)
>  		return -1;
> -	for (i = index + 1; i < end; i++) {
> +	for (i = index; i < end; i++) {
>  		if (test_bit(i, map)) {
>  			start = i+1;
>  			goto again;
> @@ -50,9 +55,8 @@ unsigned long iommu_area_alloc(unsigned 
>  {
>  	unsigned long index;
>  again:
> -	index = find_next_zero_area(map, size, start, nr);
> +	index = find_next_zero_area(map, size, start, nr, align_mask);
>  	if (index != -1) {
> -		index = (index + align_mask) & ~align_mask;
>  		if (is_span_boundary(index, nr, shift, boundary_size)) {
>  			/* we could do more effectively */
>  			start = index + 1;
> _
> 
> 

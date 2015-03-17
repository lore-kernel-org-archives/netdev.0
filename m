From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc class: Don't fail if there is no default
 names file
Date: Tue, 17 Mar 2015 15:32:39 +0100
Message-ID: <55083B07.2000307@iogearbox.net>
References: <1426599666-8968-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50732 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbbCQOcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 10:32:41 -0400
In-Reply-To: <1426599666-8968-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2015 02:41 PM, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
>
> Added the following changes in one patch:
>
> 1) Split db_names_init into alloc & load funcs
>
> 2) Added checks for out of memory with new alloc helpers
>
> 3) Ignore if there is no default class names file
>
> 3) Changed default class names path cls_names -> tc_cls
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
...
> diff --git a/lib/utils.c b/lib/utils.c
> index 9cda268..d119a69 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -904,3 +904,29 @@ char *int_to_str(int val, char *buf)
>   	sprintf(buf, "%d", val);
>   	return buf;
>   }
> +
> +void *xmalloc(size_t size)
> +{
> +	void *ptr = malloc(size);
> +	if (!ptr)
> +		fprintf(stderr, "xmalloc: Out of memory\n");
> +
> +	return ptr;
> +}
> +
> +void xfree(void *ptr)
> +{
> +	if (!ptr)
> +		fprintf(stderr, "xfree: ptr is NULL\n");
> +	else
> +		free(ptr);
> +}
> +
> +char *xstrdup(char *str)
> +{
> +	char *ptr = strdup(str);
> +	if (!ptr)
> +		fprintf(stderr, "xstrdup: Out of memory\n");
> +
> +	return ptr;
> +}

When you add xmalloc and friends, the expectation is rather
different then what you've implemented : i.e. xmalloc dies
in case the allocation fails, so that xmalloc() et al users
don't have to care about the NULL check.

Simple example:

void *xmalloc(size_t size)
{
	void *ptr;

	ptr = malloc(size);
	if (unlikely(ptr == NULL))
		panic("xmalloc: out of memory (allocating %zu bytes)\n",
		      size);

	return ptr;
}

For a more elaborate example, you can also have a look at git,
e.g. wrapper.c +84, but a simpler form is sufficient here.

I think there are two possible ways forward: either use normal
malloc() and check for NULL, or you could add in a different set
xmalloc() et al, and convert also other users from iproute2 that
don't have an error recovery, iow do abort() or the like.

Other than that, would be good if you split up this patch into
a set.

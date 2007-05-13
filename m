From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: compile breakage due to [SK_BUFF]: Convert skb->end to sk_buff_data_t
Date: Sun, 13 May 2007 21:29:41 +0300
Message-ID: <20070513182941.GC4343@rhun.haifa.ibm.com>
References: <200704271703.l3RH3i2F021726@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:52864 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757559AbXEMS3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2007 14:29:47 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l4DITkak057812
	for <netdev@vger.kernel.org>; Sun, 13 May 2007 18:29:46 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4DITkU42429168
	for <netdev@vger.kernel.org>; Sun, 13 May 2007 19:29:46 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4DHSNbr006829
	for <netdev@vger.kernel.org>; Sun, 13 May 2007 18:28:23 +0100
Content-Disposition: inline
In-Reply-To: <200704271703.l3RH3i2F021726@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2007 at 05:03:44PM +0000, Linux Kernel Mailing List wrote:

> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=4305b541357ddbd205aa145dc378926b7cb12283
> Commit:     4305b541357ddbd205aa145dc378926b7cb12283
> Parent:     27a884dc3cb63b93c2b3b643f5b31eed5f8a4d26
> Author:     Arnaldo Carvalho de Melo <acme@redhat.com>
> AuthorDate: Thu Apr 19 20:43:29 2007 -0700
> Committer:  David S. Miller <davem@sunset.davemloft.net>
> CommitDate: Wed Apr 25 22:26:29 2007 -0700
> 
>     [SK_BUFF]: Convert skb->end to sk_buff_data_t
>     
>     Now to convert the last one, skb->data, that will allow many simplifications
>     and removal of some of the offset helpers.
>     
>     Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

This patch and the previous one breaks the compilation on one of my
machines. Specifically, this bit:

> @@ -632,12 +644,13 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  	/* Copy only real data... and, alas, header. This should be
>  	 * optimized for the cases when header is void. */
>  	memcpy(data + nhead, skb->head,
> -		skb->tail
> -#ifndef NET_SKBUFF_DATA_USES_OFFSET
> -		- skb->head
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +		skb->tail);
> +#else
> +		skb->tail - skb->head);
>  #endif
> -		);
> -	memcpy(data + size, skb->end, sizeof(struct skb_shared_info));
> +	memcpy(data + size, skb_end_pointer(skb),
> +	       sizeof(struct skb_shared_info));
>  
>  	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
>  		get_page(skb_shinfo(skb)->frags[i].page);

Causes this compile error:

/home/muli/kernel/trident/trident.git/net/core/skbuff.c:648:1: directives may not be used inside a macro argument
/home/muli/kernel/trident/trident.git/net/core/skbuff.c:647:39: unterminated argument list invoking macro "memcpy"
/home/muli/kernel/trident/trident.git/net/core/skbuff.c: In function `pskb_expand_head':
/home/muli/kernel/trident/trident.git/net/core/skbuff.c:651: `memcpy' undeclared (first use in this function)
/home/muli/kernel/trident/trident.git/net/core/skbuff.c:651: (Each undeclared identifier is reported only once
/home/muli/kernel/trident/trident.git/net/core/skbuff.c:651: for each function it appears in.)
/home/muli/kernel/trident/trident.git/net/core/skbuff.c:651: syntax error before "skb"

muli@rhun:~/kernel/trident/trident.git$ gcc -v
Reading specs from /usr/lib/gcc-lib/i386-redhat-linux/3.2.3/specs
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --enable-shared --enable-threads=posix --disable-checking --with-system-zlib --enable-__cxa_atexit --host=i386-redhat-linux
Thread model: posix
gcc version 3.2.3 20030502 (Red Hat Linux 3.2.3-53)

It happens because memcpy ends up being a macro, and this gcc dislikes
having a preprocessor directive inside a macro argument. I don't know
if if it's valid in general, but Documentation/Changes does say we
still support gcc 3.2...

Cheers,
Muli


From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH RFC 1/6] skbuff: support per-page destructors in
 copy_ubufs
Date: Thu, 10 May 2012 18:46:17 +0100
Message-ID: <1336671977.14220.26.camel@zakaz.uk.xensource.com>
References: <cover.1336397823.git.mst@redhat.com>
	 <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:50582 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760484Ab2EJRqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 13:46:35 -0400
In-Reply-To: <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 14:54 +0100, Michael S. Tsirkin wrote:

>  	/* skb frags point to kernel buffers */
>  	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
> +		skb_frag_t *f = &skb_shinfo(skb)->frags[i];

This needs to be ....->frags[i - 1]

otherwise you put every new frag one too high and don't do anything to
frag 0, which leaves the old destructor pointer in place and leads to a
double free.

I think skb_frag_set_destructor and skb_copy_frag_destructor need to
clear and propagate respectively (or maybe just clear in both cases) the
destructor_arg field since it is otherwise not initialised when we set
SKBTX_DEV_ZEROCOPY and that can trigger wrong behaviour in this
function.

Ian.

> +		if (unlikely((!uarg && !f->page.destructor)))
> +			continue;
>  		__skb_fill_page_desc(skb, i-1, head, 0,
>  				     skb_shinfo(skb)->frags[i - 1].size);
>  		head = (struct page *)head->private;

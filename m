From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/2][INET] Fix potential kfree on vmalloc-ed area of
 request_sock_queue
Date: Wed, 14 Nov 2007 20:42:38 +0100
Message-ID: <20071114204238.68662cbf.dada1@cosmosbay.com>
References: <473B399D.2040004@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39028 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753258AbXKNTmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 14:42:45 -0500
In-Reply-To: <473B399D.2040004@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007 21:08:29 +0300
Pavel Emelyanov <xemul@openvz.org> wrote:

> The request_sock_queue's listen_opt is either vmalloc-ed or
> kmalloc-ed depending on the number of table entries. Thus it 
> is expected to be handled properly on free, which is done in 
> the reqsk_queue_destroy().
> 
> However the error path in inet_csk_listen_start() calls 
> the lite version of reqsk_queue_destroy, called 
> __reqsk_queue_destroy, which calls the kfree unconditionally. 
> 
> Fix this and move the __reqsk_queue_destroy into a .c file as 
> it looks too big to be inline.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 

> +void __reqsk_queue_destroy(struct request_sock_queue *queue)
> +{
> +	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);

WARNING : lopt can be NULL here (or else the locking in reqsk_queue_yank_listen_sk() would be useless ?)

kfree(NULL) was ok, not NULL->nr_table_entries :)

> +	size_t lopt_size = sizeof(struct listen_sock) +
> +		lopt->nr_table_entries * sizeof(struct request_sock *);
> +
> +	if (lopt_size > PAGE_SIZE)
> +		vfree(lopt);
> +	else
> +		kfree(lopt);
> +}

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][INET] Fix potential kfree on vmalloc-ed area of
 request_sock_queue
Date: Wed, 14 Nov 2007 16:09:05 -0800 (PST)
Message-ID: <20071114.160905.94404396.davem@davemloft.net>
References: <473B399D.2040004@openvz.org>
	<20071114204238.68662cbf.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752697AbXKOAJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 19:09:06 -0500
In-Reply-To: <20071114204238.68662cbf.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 14 Nov 2007 20:42:38 +0100

> On Wed, 14 Nov 2007 21:08:29 +0300
> Pavel Emelyanov <xemul@openvz.org> wrote:
> 
> > The request_sock_queue's listen_opt is either vmalloc-ed or
> > kmalloc-ed depending on the number of table entries. Thus it 
> > is expected to be handled properly on free, which is done in 
> > the reqsk_queue_destroy().
> > 
> > However the error path in inet_csk_listen_start() calls 
> > the lite version of reqsk_queue_destroy, called 
> > __reqsk_queue_destroy, which calls the kfree unconditionally. 
> > 
> > Fix this and move the __reqsk_queue_destroy into a .c file as 
> > it looks too big to be inline.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > 
> > ---
> > 
> 
> > +void __reqsk_queue_destroy(struct request_sock_queue *queue)
> > +{
> > +	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
> 
> WARNING : lopt can be NULL here (or else the locking in reqsk_queue_yank_listen_sk() would be useless ?)
> 
> kfree(NULL) was ok, not NULL->nr_table_entries :)

I think for the error recovery case he is trying to fix all of this
locking is unnecessary and we know lopt is not NULL.

Pavel can you rework your fix a bit to deal with this?

Thanks a lot.

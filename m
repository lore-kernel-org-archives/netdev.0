From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: avoid list_del_init if it's freeing the
 memory right away
Date: Wed, 8 Feb 2017 17:57:47 -0200
Message-ID: <20170208195747.GE3414@localhost.localdomain>
References: <e1b3b9b24f39ee82a3131a39a0413231ba54bc7c.1486494022.git.marcelo.leitner@gmail.com>
 <20170207.142121.1027174926882132252.davem@davemloft.net>
 <20170207194508.GD3414@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        vyasevich@gmail.com, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43970 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751025AbdBHT6T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 14:58:19 -0500
Content-Disposition: inline
In-Reply-To: <20170207194508.GD3414@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 05:45:09PM -0200, Marcelo Ricardo Leitner wrote:
> On Tue, Feb 07, 2017 at 02:21:21PM -0500, David Miller wrote:
> > From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > Date: Tue,  7 Feb 2017 17:03:21 -0200
> > 
> > > There is no reason to use list_del_init() in these places as we are
> > > going to free/destroy the memory in a few lines below.
> > > 
> > > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > > ---
> > >  net/sctp/associola.c     | 14 ++++----------
> > >  net/sctp/auth.c          |  8 ++------
> > >  net/sctp/chunk.c         |  4 ++--
> > >  net/sctp/outqueue.c      | 14 +++++++-------
> > >  net/sctp/sm_make_chunk.c |  3 +--
> > >  5 files changed, 16 insertions(+), 27 deletions(-)
> > > 
> > > diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> > > index e50dc6d7543fd6acfa7442f3a9ee575203c7718d..7eb9dacfa53a438b20a34319cf01c6c9a591f0c3 100644
> > > --- a/net/sctp/associola.c
> > > +++ b/net/sctp/associola.c
> > > @@ -1638,25 +1638,19 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
> > >  static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc)
> > >  {
> > >  	struct sctp_chunk *asconf;
> > > -	struct sctp_chunk *tmp;
> > >  
> > > -	list_for_each_entry_safe(asconf, tmp, &asoc->addip_chunk_list, list) {
> > > -		list_del_init(&asconf->list);
> > > +	list_for_each_entry(asconf, &asoc->addip_chunk_list, list)
> > >  		sctp_chunk_free(asconf);
> > > -	}
> > >  }
> > 
> > This leave freed memory on the asoc->addip_chunk_list, in fact why aren't you seeing
> 
> This should be alright, because here we are purging the entire list and
> the asoc will also be free right after.
> 
> > the BUG_ON() in sctp_chunk_destroy() get triggered?  If you elide the list_del() here
> > then the "list_empty(&chunk->list)" check there will not be true.
> > 
> 
> Good question. I have to double check this, but you're probably right.

Now I managed to trigger the BUG_ON, as you anticipated.

> 
> > I don't think this transformation here is legal at all.

Yeah it's not. It would be relying on freed memory to find the next
elements. Uff, sorry.

Thanks,
Marcelo

From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH net-next v2 1/4] cxgb4/iw_cxgb4/cxgb4i: remove duplicate
 definitions
Date: Wed, 15 Apr 2015 10:12:34 -0600
Message-ID: <20150415161234.GB4653@obsidianresearch.com>
References: <cover.1428930614.git.varun@chelsio.com>
 <6358f849b5a1a3727879f4f2f5c855e3a5b95ab4.1428930614.git.varun@chelsio.com>
 <20150413163808.GA17521@obsidianresearch.com>
 <20150415130425.GA5317@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org, davem@davemloft.net,
	JBottomley@parallels.com, roland@purestorage.com,
	leedom@chelsio.com, anish@chelsio.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com, kxie@chelsio.com,
	praveenm@chelsio.com, kumaras@chelsio.com
To: Varun Prakash <varun@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150415130425.GA5317@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 06:34:27PM +0530, Varun Prakash wrote:
> On Mon, Apr 13, 2015 at 10:38:08AM -0600, Jason Gunthorpe wrote:
> > On Mon, Apr 13, 2015 at 07:34:23PM +0530, Varun Prakash wrote:
> > > define struct ulptx_idata in common header file t4_msg.h
> > > to remove duplicate definitions.
> > 
> > The Infiniband side of this patch looks OK.
> > 
> > Reviewed-By: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> > 
> > Just some random thoughts on the other patches:
> >  - Try and use 'if (IS_ENABLED(CONFIG_XX))' over #ifdef 
> >    to improve compile test coverage. This would drop a fair number
> >    of ifdefs.
> 
> FCoE specific structures and functions are defined only if 
> CONFIG_CHELSIO_T4_FCOE is enabled.

I saw a number of places that could be switched, you should look
through.

> #ifdef CONFIG_CHELSIO_T4_FCOE
> void cxgb_fcoe_init_ddp(struct adapter *adap)
> {
> 	...
> }
> #endif
> 
> If CONFIG_CHELSIO_T4_FCOE is disabled then following code will
> result in build error "implicit declaration of function cxgb_fcoe_init_ddp"
>
> if (IS_ENABLED(CONFIG_CHELSIO_T4_FCOE))
> 	cxgb_fcoe_init_ddp(adap);

Commonly the ifdef would be moved to the function header and a static
inline cxgb_fcoe_init_ddp(..) {} declared for the ifndef case. For the
case of static function calls, just drop the ifdefing entirely. The
compiler will silently drop unused static functions. Think carefully
about ifdefing out structure members - I don't think saving a few bytes of
heap in a driver like cxgb4 is worthwhile.

I also just noticed that

drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c

Is wrapped in a whole file #ifdef CONFIG_CHELSIO_T4_FCOE - please use
the makefile instead for this.

Jason

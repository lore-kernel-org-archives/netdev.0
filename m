From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/36] scsi,rcu: convert call_rcu(fc_rport_free_rcu) to
 kfree_rcu()
Date: Tue, 22 Mar 2011 23:50:14 -0700
Message-ID: <20110323065014.GU2322@linux.vnet.ibm.com>
References: <4D82D071.5020703@cn.fujitsu.com>
 <4D82D3FF.2080303@cn.fujitsu.com>
 <4D82D45A.30102@cn.fujitsu.com>
 <1300814913.19083.427.camel@fritz>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>,
	Jens Axboe <axboe@kernel.dk>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tejun Heo <tj@kernel.org>, Jarek Poplawski <jarkao2@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Love <robert.w.love@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51810 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab1CWGud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 02:50:33 -0400
Content-Disposition: inline
In-Reply-To: <1300814913.19083.427.camel@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 10:28:33AM -0700, Robert Love wrote:
> On Thu, 2011-03-17 at 20:41 -0700, Lai Jiangshan wrote:
> > 
> > The rcu callback fc_rport_free_rcu() just calls a kfree(),
> > so we use kfree_rcu() instead of the call_rcu(fc_rport_free_rcu).
> > 
> > Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> > ---
> >  drivers/scsi/libfc/fc_rport.c |   14 +-------------
> >  1 files changed, 1 insertions(+), 13 deletions(-)
> > 
> > diff --git a/drivers/scsi/libfc/fc_rport.c b/drivers/scsi/libfc/fc_rport.c
> > index a7175ad..29abab0 100644
> > --- a/drivers/scsi/libfc/fc_rport.c
> > +++ b/drivers/scsi/libfc/fc_rport.c
> > @@ -151,18 +151,6 @@ static struct fc_rport_priv *fc_rport_create(struct fc_lport *lport,
> >  }
> >  
> >  /**
> > - * fc_rport_free_rcu() - Free a remote port
> > - * @rcu: The rcu_head structure inside the remote port
> > - */
> > -static void fc_rport_free_rcu(struct rcu_head *rcu)
> > -{
> > -	struct fc_rport_priv *rdata;
> > -
> > -	rdata = container_of(rcu, struct fc_rport_priv, rcu);
> > -	kfree(rdata);
> > -}
> > -
> > -/**
> >   * fc_rport_destroy() - Free a remote port after last reference is released
> >   * @kref: The remote port's kref
> >   */
> > @@ -171,7 +159,7 @@ static void fc_rport_destroy(struct kref *kref)
> >  	struct fc_rport_priv *rdata;
> >  
> >  	rdata = container_of(kref, struct fc_rport_priv, kref);
> > -	call_rcu(&rdata->rcu, fc_rport_free_rcu);
> > +	kfree_rcu(rdata, rcu);
> 
> I think this last line should be:
> 
> kfree_rcu(rdata, &rdata->rcu);

Hello, Robert,

I believe that it is correct as is.  The kfree_rcu() definition is as
follows:

#define kfree_rcu(ptr, rcu_head)					\
	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))

Then __kfree_rcu() encodes the offset into the rcu_head so that it can
be handled properly at the end of the grace period.

							Thanx, Paul

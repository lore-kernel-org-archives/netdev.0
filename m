From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 04/23 v3] mlx4_core: add slave resource allocation
Date: Tue, 09 Feb 2010 17:32:28 +0000
Message-ID: <1265736748.2126.123.camel@achroite.uk.solarflarecom.com>
References: <49BFC313.1030901@mellanox.co.il>
	 <4B6AEDCC.8020503@mellanox.co.il>
	 <1265726692.2126.80.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59426 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755124Ab0BIRcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 12:32:32 -0500
In-Reply-To: <1265726692.2126.80.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-09 at 14:44 +0000, Ben Hutchings wrote:
> On Thu, 2010-02-04 at 17:54 +0200, Yevgeny Petrilin wrote:
> > All QPs/CQs/SRQs/MPTs/MTTs are allocated from shared pools, which are owned by
> > the master. In addition, all backing ICM memory for these objects is managed by
> > the master.
> > To allow slaves to allocate resources, ICM allocation is separated from the rest
> > of the object state, which is held at the slave.
> > Slaves can then reserve resource ranges and allocate ICM over the comm channel.
> > 
> > Signed-off-by: Liran Liss <liranl@mellanox.co.il>
> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> > ---
> >  drivers/net/mlx4/cmd.c   |  110 +++++++++++++++++++++++++++++++++
> >  drivers/net/mlx4/cq.c    |   91 +++++++++++++++++++++-------
> >  drivers/net/mlx4/mlx4.h  |   27 ++++++++
> >  drivers/net/mlx4/mr.c    |  125 ++++++++++++++++++++++++++++++++++----
> >  drivers/net/mlx4/qp.c    |  151 +++++++++++++++++++++++++++++++++-------------
> >  drivers/net/mlx4/srq.c   |   88 ++++++++++++++++++++-------
> >  include/linux/mlx4/cmd.h |    2 +
> >  7 files changed, 496 insertions(+), 98 deletions(-)
> > 
> > diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
> > index 9e85330..533ce77 100644
> > --- a/drivers/net/mlx4/cmd.c
> > +++ b/drivers/net/mlx4/cmd.c
> > @@ -417,6 +417,100 @@ static int mlx4_ACCESS_MEM(struct mlx4_dev *dev, u64 master_addr,
> >  					   MLX4_CMD_TIME_CLASS_A);
> >  }
> >  
> > +static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
> > +						       struct mlx4_cmd_mailbox *inbox,
> > +						       struct mlx4_cmd_mailbox *outbox)
> > +{
> > +	u32 param1 = *((u32 *) &vhcr->in_param);
> > +	u32 param2 = *(((u32 *) &vhcr->in_param) + 1);
[...]

I failed to spot this in the first pass.  Really, this is ridiculous.
If you are going to make a habit of passing around pairs of 32-bit
values, declare in_param as a union.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


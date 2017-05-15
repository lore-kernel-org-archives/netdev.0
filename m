From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4] net/mlx4_core: Use min3 to select number of MSI-X
 vectors
Date: Mon, 15 May 2017 10:53:24 +0300
Message-ID: <20170515075324.GA3523@yuval-lap>
References: <1494569451-2567-1-git-send-email-yuval.shaia@oracle.com>
 <20170514190133.GC28994@yuval-lap>
 <20170515044304.GV3616@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170515044304.GV3616-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2017 at 07:43:04AM +0300, Leon Romanovsky wrote:
> On Sun, May 14, 2017 at 10:01:34PM +0300, Yuval Shaia wrote:
> > On Fri, May 12, 2017 at 09:10:51AM +0300, Yuval Shaia wrote:
> > > Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > > ---
> > > v0 -> v1:
> > > 	* s/"min_t("/"min_t(int"
> > > v1 -> v2:
> > > 	* Use min3 instead of min_t twice
> > > v2 -> v3:
> > > 	* Change commit log header message to reflect the changes made in
> > > 	  v2
> > > v3 -> v4:
> > > 	* Cast return value from num_online_cpus to int to avoid
> > > 	  compilation errors from "sparse"
> >
> > Hi Leon,
> > Got your r-b for v3, can you please review v4?
> 
> What was the sparse error?
> 
> num_online_cpus() is declared as "unsigned int", so you don't need to do casting.
> 
> ➜  linux-rdma git:(master) git grep num_online_cpus include/
> include/linux/cpumask.h:#define num_online_cpus()       cpumask_weight(cpu_online_mask)
> include/linux/cpumask.h:#define num_online_cpus()       1U
> 
> ➜  linux-rdma git:(master) git grep cpumask_weight include/
> include/linux/cpumask.h:static inline unsigned int cpumask_weight(const struct cpumask *srcp)

But num_eqs and reserved_eqs are ints so assuming the error is that i
asked min3 to compare unsigned int with int.

This casting cannot do harm because anyway the result is stored in int
variable.

> 
> Thanks
> 
> >
> > Thanks,
> >
> > > ---
> > >  drivers/net/ethernet/mellanox/mlx4/main.c | 10 ++++------
> > >  1 file changed, 4 insertions(+), 6 deletions(-)
> > >
> > > diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> > > index 7032054..83aab1e 100644
> > > --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> > > +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> > > @@ -2862,12 +2862,10 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
> > >  	int port = 0;
> > >
> > >  	if (msi_x) {
> > > -		int nreq = dev->caps.num_ports * num_online_cpus() + 1;
> > > -
> > > -		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
> > > -			     nreq);
> > > -		if (nreq > MAX_MSIX)
> > > -			nreq = MAX_MSIX;
> > > +		int nreq = min3(dev->caps.num_ports *
> > > +				(int)num_online_cpus() + 1,
> > > +				dev->caps.num_eqs - dev->caps.reserved_eqs,
> > > +				MAX_MSIX);
> > >
> > >  		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
> > >  		if (!entries)
> > > --
> > > 2.7.4
> > >
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> > > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

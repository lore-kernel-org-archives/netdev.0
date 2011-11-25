From: Thomas Osterried <thomas@osterried.de>
Subject: Re: [PATCH 3/4] NET: NETROM: Cleanup argument SIOCADDRT ioctl argument checking.
Date: Fri, 25 Nov 2011 14:26:25 +0100
Message-ID: <201111251426.26469.thomas@osterried.de>
References: <cover.1322214950.git.ralf@linux-mips.org> <4ECF7A76.3090305@bfs.de> <4ECF8629.7000301@bfs.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org,
	Kernel Janitors List <kernel-janitors@vger.kernel.org>
To: wharms@bfs.de
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4ECF8629.7000301@bfs.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Am Freitag, den 25. November 2011 um 13:12:25 Uhr, schrieb walter harms <wharms@bfs.de> in <4ECF8629.7000301@bfs.de>:
> hi,
> according to LXR there are several places where the check is >AX25_MAX_DIGIS instead of >=.
> 
> any takers ?


nr_route.ndigis is used at 
  nr_call_to_digi(&digi, nr_route.ndigis, nr_route.digipeaters),

Image nr_route.ndigis is 0.

static ax25_digi *nr_call_to_digi(ax25_digi *digi, int ndigis,
        ax25_address *digipeaters)
{
        int i;

        if (ndigis == 0)
                return NULL;

           ################ here we leave

        for (i = 0; i < ndigis; i++) {
                digi->calls[i]    = digipeaters[i];
                digi->repeated[i] = 0;
        }

        digi->ndigi      = ndigis;
        digi->lastrepeat = -1;

        return digi;
}


Image ndigi is 8 (AX25_MAX_DIGIS), as large as nr_route.digipeaters (because it's digipeaters[AX25_MAX_DIGIS]).

we fill the array from i = 0 to i < ndigis (=7) -> 8 times == sizeof(digipeaters)

-> everything is fine with that.

vy 73,
	- Thomas  dl9sau

> 
> re,
>  wh
> 
> 
> Am 25.11.2011 12:22, schrieb walter harms:
> > 
> > 
> > Am 25.11.2011 10:09, schrieb Ralf Baechle:
> >> nr_route.ndigis is unsigned int so the nr_route.ndigis < 0 expression is
> >> never true and can be dropped.  Doing the nr_ax25_dev_get call later
> >> allows the nr_route.ndigis test to bail out without having to dev_put.
> >>
> >> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> >> Cc: Thomas Osterried <thomas@osterried.de>
> >> ---
> >>  net/netrom/nr_route.c |    6 ++----
> >>  1 files changed, 2 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
> >> index 8d7716c..2cf3301 100644
> >> --- a/net/netrom/nr_route.c
> >> +++ b/net/netrom/nr_route.c
> >> @@ -670,12 +670,10 @@ int nr_rt_ioctl(unsigned int cmd, void __user *arg)
> >>  	case SIOCADDRT:
> >>  		if (copy_from_user(&nr_route, arg, sizeof(struct nr_route_struct)))
> >>  			return -EFAULT;
> >> -		if ((dev = nr_ax25_dev_get(nr_route.device)) == NULL)
> >> +		if (nr_route.ndigis > AX25_MAX_DIGIS)
> >>  			return -EINVAL;
> >> -		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS) {
> >> -			dev_put(dev);
> >> +		if ((dev = nr_ax25_dev_get(nr_route.device)) == NULL)
> >>  			return -EINVAL;
> >> -		}
> >>  		switch (nr_route.type) {
> >>  		case NETROM_NODE:
> >>  			if (strnlen(nr_route.mnemonic, 7) == 7) {
> > 
> > I realy do not know if that matters but some use AX25_MAX_DIGIS as array
> > and therefore it should be >=AX25_MAX_DIGIS.
> > 
> > struct rose_route_struct {
> >          rose_address    address;
> >         unsigned short  mask;
> >         ax25_address    neighbour;
> >         char            device[16];
> >          unsigned char   ndigis;
> >          ax25_address    digipeaters[AX25_MAX_DIGIS];
> >   };
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-hams" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 

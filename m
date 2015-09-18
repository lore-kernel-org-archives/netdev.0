From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Fri, 18 Sep 2015 16:06:07 -0700
Message-ID: <20150918160607.574425f5e3b1f0afe29b7448@linux-foundation.org>
References: <20150916092447.GA945@swordfish>
	<CAOMZO5CTgq_Sd81=XWEHv5oe1WyVpaydNzUXz_EbY2BWR6xF7g@mail.gmail.com>
	<55F984EF.4040503@cumulusnetworks.com>
	<20150917085850.GA7953@ulmo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Fabio Estevam <festevam@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	richard.alpe@ericsson.com
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150917085850.GA7953@ulmo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Sep 2015 10:58:52 +0200 Thierry Reding <thierry.reding@gmail.com> wrote:

> On Wed, Sep 16, 2015 at 09:04:15AM -0600, David Ahern wrote:
> > On 9/16/15 9:00 AM, Fabio Estevam wrote:
> > >On Wed, Sep 16, 2015 at 6:24 AM, Sergey Senozhatsky
> > ><sergey.senozhatsky.work@gmail.com> wrote:
> > >
> > >>added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8
> > >>
> > >>     net: Add FIB table id to rtable
> > >>
> > >>     Add the FIB table id to rtable to make the information available for
> > >>     IPv4 as it is for IPv6.
> > >
> > >I see the same issue here when booting a mx25 ARM processor via NFS.
> > >
> > >defconfig is arch/arm/configs/imx_v4_v5_defconfig.
> > >
> > 
> > I am still not able to reproduce. While I work on a full Cumulus image for
> > other test cases here's a patch to try; eagle eye Nikolay noted a potential
> > use without init in the maze of goto's.
> > 
> > Thanks,
> > David
> 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index da427a4a33fe..80f7c5b7b832 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1712,6 +1712,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> >  		goto martian_source;
> >  
> >  	res.fi = NULL;
> > +	res.table = NULL;
> >  	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
> >  		goto brd_input;
> >  
> > @@ -1834,6 +1835,7 @@ out:	return err;
> >  	RT_CACHE_STAT_INC(in_no_route);
> >  	res.type = RTN_UNREACHABLE;
> >  	res.fi = NULL;
> > +	res.table = NULL;
> >  	goto local_input;
> >  
> >  	/*
> 
> I was seeing the same oops as Fabio (except that the faulting address
> was 0xb instead of 0x7) and after applying this patch I no longer see
> it:
> 
> Tested-by: Thierry Reding <treding@nvidia.com>

I've been hitting this as well.  An oops on boot in
ip_route_input_slow(), here:

	#ifdef CONFIG_IP_ROUTE_CLASSID
		rth->dst.tclassid = itag;
	#endif
		rth->rt_is_input = 1;
		if (res.table)
-->>			rth->rt_table_id = res.table->tb_id;
	
		RT_CACHE_STAT_INC(in_slow_tot);
	

I did this, which made it go away:

--- a/net/ipv4/route.c~a
+++ a/net/ipv4/route.c
@@ -1692,6 +1692,8 @@ static int ip_route_input_slow(struct sk
 	struct net    *net = dev_net(dev);
 	bool do_cache;
 
+	res.table = 0;
+
 	/* IP on this device is disabled. */
 
 	if (!in_dev)
_

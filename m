From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Mon, 01 Sep 2014 21:22:28 +0200
Message-ID: <1409599348.21965.6.camel@localhost>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	 <CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	 <20140829195339.GA9780@kria> <1409363489.2980.17.camel@localhost>
	 <20140830105821.GB18155@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <20140830105821.GB18155@kria>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sa, 2014-08-30 at 12:58 +0200, Sabrina Dubroca wrote:
> 2014-08-30, 03:51:29 +0200, Hannes Frederic Sowa wrote:
> > Hi Sabrina,
> > 
> > [...]
> > 
> > Sorry, just had time to look at this.
> > 
> > The reason is not to have list corruption but that the calls down to
> > ndo_set_rx_mode expect rtnl to be locked by the drivers. Filter lists
> > are locked by addr_list_lock and that's why I think we never saw any
> > problems with that, but drivers expect rtnl locked for those calls.
> > 
> > But this problem also affects multicast join, so patch seems incomplete
> > to me (and for that matter ssm multicast join, too).
> > 
> > Also rtnl_lock and rcu_read_lock compose in that order, so we don't need
> > to change dev_get_by_flags, but as this is the only user it sure is
> > possible. RCU locked version is just easier composeable, so I wouldn't
> > touch that if needed in future, just also take rcu lock as before.
> > 
> > So just adding rtnl_lock add appropriate places seems to be ok to me,
> > but still need to review parts of the ssm code.
> > 
> > Also we should move ASSERT_RTNL checks from addrconf_join_solict to
> > ipv6_dev_mc_inc/dec.
> > 
> > Thanks,
> > Hannes
> 
> Thanks for explaining.
> 
> I had a look at what you suggested.
> 
> 
> So, for anycast, on top of the previous patch, we'd have:
> 
> ---
> diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
> index 210183244689..61dd3046b804 100644
> --- a/net/ipv6/anycast.c
> +++ b/net/ipv6/anycast.c
>  static void aca_put(struct ifacaddr6 *ac)
> @@ -233,6 +235,8 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
>  	struct rt6_info *rt;
>  	int err;
>  
> +	ASSERT_RTNL();
> +
>  	idev = in6_dev_get(dev);
>  
>  	if (idev == NULL)
> @@ -302,6 +306,8 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr)
>  {
>  	struct ifacaddr6 *aca, *prev_aca;
>  
> +	ASSERT_RTNL();
> +
>  	write_lock_bh(&idev->lock);
>  	prev_aca = NULL;
>  	for (aca = idev->ac_list; aca; aca = aca->aca_next) {
> @@ -336,6 +342,8 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
>  {
>  	struct inet6_dev *idev = __in6_dev_get(dev);
>  
> +	ASSERT_RTNL();
> +
>  	if (idev == NULL)
>  		return -ENODEV;
>  	return __ipv6_dev_ac_dec(idev, addr);

ASSERT_RTNL() still performs a runtime check. While those are not really
fast paths, I still think it is better to keep them to a minimum and
place them only at places where we know all code which needs to be
guarded passes by:

I would suggest to move ASSERT_RTNL to ipv6_dev_mc_inc and
__ipv6_dev_mc_dec and even remove the checks from addrconf_join_solict
and addrconf_leave_solict. Does that cover all code paths and makes
sense?

> ---
> 
> 
> And for multicast:
>  - locking order in the patch below: rtnl -> rcu -> ipv6_sk_mc_lock
>  - ipv6_sock_mc_join: maybe move all the _unlock()'s together at the end of the function
>  - do we need to modify rcu_dereference_protected in ipv6_sock_mc_drop/ipv6_sock_mc_close
>  - I had a look at the other codepaths that call ipv6_dev_mc_inc/dec
>    - ipv6_mc_destroy_dev, dev_forward_change, ipv6_add_dev,
>      addrconf_join_solict -- all take rtnl or already have an
>      ASSERT_RTNL()
>    - pndisc_destructor, called from pneigh_ifdown/pneigh_delete
>    - pndisc_constructor, called from pneigh_lookup -- pneigh_lookup
>      has ASSERT_RTNL(), but pneigh_lookup is called from ip6_forward and
>      ndisc_recv_na
>    - (hope I didn't miss any callers)
> 
> As far as I could see, apart maybe from pndisc_constructor, it seems
> okay, but I'd like to hear your comments.

The rest of the patch looks good.

Can you or Cong post a final patch with the adapted ac_join/drop
changes?

Thanks,
Hannes

From: Nikolay Borisov <kernel@kyup.com>
Subject: Re: [PATCH] net: igmp: use IS_ENABLED(CONFIG_IP_MULTICAST) instead of
 ifdef
Date: Tue, 16 Feb 2016 18:10:52 +0200
Message-ID: <56C34A0C.9040207@kyup.com>
References: <1455638393-3269483-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455638393-3269483-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 02/16/2016 05:59 PM, Arnd Bergmann wrote:
> A recent change to use correct network namespace in net/ipv4/igmp.c
> caused a couple of harmless build warnings when CONFIG_MULTICAST is
> disabled:
> 
> net/ipv4/igmp.c: In function 'igmp_group_added':
> net/ipv4/igmp.c:1227:14: error: unused variable 'net' [-Werror=unused-variable]
> net/ipv4/igmp.c: In function 'ip_mc_inc_group':
> net/ipv4/igmp.c:1319:14: error: unused variable 'net' [-Werror=unused-variable]
> net/ipv4/igmp.c: In function 'ip_mc_init_dev':
> net/ipv4/igmp.c:1646:14: error: unused variable 'net' [-Werror=unused-variable]
> net/ipv4/igmp.c: In function 'ip_mc_up':
> net/ipv4/igmp.c:1665:14: error: unused variable 'net' [-Werror=unused-variable]
> 
> This reworks the entire file to change each instance if '#ifdef
> CONFIG_IP_MULTICAST' to 'if (IS_ENABLED(CONFIG_IP_MULTICAST)', which
> should avoid these problems forever, and makes the whole file more
> readable.
> 
> Build-tested only.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 87a8a2ae65b7 ("igmp: Namespaceify igmp_llm_reports sysctl knob")

Overall it looks OK, just 2 minor points I could spot. See below.

[...]
> +		sf_markstate(pmc);
> +
>  	if (!delta) {
>  		err = -EINVAL;
>  		if (!pmc->sfcount[sfmode])
> @@ -1821,17 +1807,15 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
>  		if (!err && rv < 0)
>  			err = rv;
>  	}
> -	if (pmc->sfmode == MCAST_EXCLUDE &&
> +	if (IS_ENABLED(CONFIG_IP_MULTICAST) &&
> +	    pmc->sfmode == MCAST_EXCLUDE &&
>  	    pmc->sfcount[MCAST_EXCLUDE] == 0 &&
>  	    pmc->sfcount[MCAST_INCLUDE]) {
> -#ifdef CONFIG_IP_MULTICAST
>  		struct ip_sf_list *psf;
>  		struct net *net = dev_net(in_dev->dev);
> -#endif
>  
>  		/* filter mode change */
>  		pmc->sfmode = MCAST_INCLUDE;

The above line was always executed, whereas now it wouldn't execute
unless IS_ENABLED passes.

> -#ifdef CONFIG_IP_MULTICAST
>  		pmc->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
>  		in_dev->mr_ifc_count = pmc->crcount;
>  		for (psf = pmc->sources; psf; psf = psf->sf_next)
> @@ -1839,7 +1823,6 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
>  		igmp_ifc_event(pmc->interface);
>  	} else if (sf_setstate(pmc) || changerec) {
>  		igmp_ifc_event(pmc->interface);
> -#endif
>  	}
....
>  /*
>   * Add multicast source filter list to the interface list
> @@ -1977,9 +1961,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
>  	spin_lock_bh(&pmc->lock);
>  	rcu_read_unlock();
>  
> -#ifdef CONFIG_IP_MULTICAST
>  	sf_markstate(pmc);
> -#endif

This would be executed unconditionally, which is contrary to the
original intention. Dunno if it makes a difference though.


>  	isexclude = pmc->sfmode == MCAST_EXCLUDE;
>  	if (!delta)
>  		pmc->sfcount[sfmode]++;
> @@ -1997,28 +1979,26 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
>  		for (j = 0; j < i; j++)
>  			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
>  	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
> -#ifdef CONFIG_IP_MULTICAST
>  		struct ip_sf_list *psf;
>  		struct net *net = dev_net(pmc->interface->dev);
>  		in_dev = pmc->interface;
> -#endif
>  
>  		/* filter mode change */
>  		if (pmc->sfcount[MCAST_EXCLUDE])
>  			pmc->sfmode = MCAST_EXCLUDE;
>  		else if (pmc->sfcount[MCAST_INCLUDE])
>  			pmc->sfmode = MCAST_INCLUDE;
> -#ifdef CONFIG_IP_MULTICAST
>  		/* else no filters; keep old mode for reports */
> -
> -		pmc->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
> -		in_dev->mr_ifc_count = pmc->crcount;
> -		for (psf = pmc->sources; psf; psf = psf->sf_next)
> -			psf->sf_crcount = 0;
> -		igmp_ifc_event(in_dev);
> -	} else if (sf_setstate(pmc)) {
> +		if (IS_ENABLED(CONFIG_IP_MULTICAST)) {
> +			pmc->crcount = in_dev->mr_qrv ?:
> +				       net->ipv4.sysctl_igmp_qrv;
> +			in_dev->mr_ifc_count = pmc->crcount;
> +			for (psf = pmc->sources; psf; psf = psf->sf_next)
> +				psf->sf_crcount = 0;
> +			igmp_ifc_event(in_dev);
> +		}
> +	} else if (IS_ENABLED(CONFIG_IP_MULTICAST) && sf_setstate(pmc)) {
>  		igmp_ifc_event(in_dev);
> -#endif
>  	}
>  	spin_unlock_bh(&pmc->lock);
>  	return err;
> @@ -2711,13 +2691,10 @@ static int igmp_mc_seq_show(struct seq_file *seq, void *v)
>  		char   *querier;
>  		long delta;
>  
> -#ifdef CONFIG_IP_MULTICAST
> -		querier = IGMP_V1_SEEN(state->in_dev) ? "V1" :
> +		querier = !IS_ENABLED(CONFIG_IP_MULTICAST) ? "NONE" :
> +			  IGMP_V1_SEEN(state->in_dev) ? "V1" :
>  			  IGMP_V2_SEEN(state->in_dev) ? "V2" :
>  			  "V3";
> -#else
> -		querier = "NONE";
> -#endif
>  
>  		if (rcu_access_pointer(state->in_dev->mc_list) == im) {
>  			seq_printf(seq, "%d\t%-10s: %5d %7s\n",
> 

Reviewed-by: Nikolay Borisov <kernel@kyup.com>

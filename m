From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] net: sched: convert qdisc linked list to
 hashtable
Date: Fri, 08 Jul 2016 10:50:38 +0200
Message-ID: <1467967838.17638.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	  <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	  <20160414151813.GE3715@orbyte.nwl.cc>
	  <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
	  <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
	  <5710E1C1.2090209@mojatatu.com>
	 <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
	 <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>
	 <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-07-07 at 22:36 +0200, Jiri Kosina wrote:
> From: Jiri Kosina <jkosina@suse.cz>
> 
> Convert the per-device linked list into a hashtable. The primary 
> motivation for this change is that currently, we're not tracking all the 
> qdiscs in hierarchy (e.g. excluding default qdiscs), as the lookup 
> performed over the linked list by qdisc_match_from_root() is rather 
> expensive.
> 
> The ultimate goal is to get rid of hidden qdiscs completely, which will 
> bring much more determinism in user experience.
> 
> As we're adding hashtable.h include into generic netdevice.h, we have to make
> sure HASH_SIZE macro is now non-conflicting with local definitions.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---


> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index fdc9de2..0f70ecc 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -62,11 +62,11 @@ module_param(log_ecn_error, bool, 0644);
>  MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
>  
>  #define HASH_SIZE_SHIFT  5
> -#define HASH_SIZE (1 << HASH_SIZE_SHIFT)
> +#define __HASH_SIZE (1 << HASH_SIZE_SHIFT)

__ prefix is mostly used for functions having some kind of
shells/helpers.

I would rather use IP6_GRE_HASH_SIZE or something which has lower
chances of being used elsewhere.

Or maybe you could use new HASH_SIZE(name), providing proper 'name'

@@ -732,6 +730,8 @@ static void attach_default_qdiscs(struct net_device *dev)
>  			qdisc->ops->attach(qdisc);
>  		}
>  	}
> +	if (dev->qdisc)
> +		qdisc_hash_add(dev->qdisc);
>  }
>  

I do not understand this addition, could you comment on it ?

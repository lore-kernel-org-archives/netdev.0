From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Fri, 27 May 2005 11:56:51 -0400
Message-ID: <1117209411.6383.104.camel@localhost.localdomain>
References: <20050526185306.GW15391@postel.suug.ch>
	 <20050526185526.GZ15391@postel.suug.ch>
	 <1117192464.6688.3.camel@localhost.localdomain>
	 <20050527121503.GN15391@postel.suug.ch>
	 <1117201853.6383.29.camel@localhost.localdomain>
	 <20050527141023.GP15391@postel.suug.ch>
	 <1117205822.6383.68.camel@localhost.localdomain>
	 <20050527151608.GZ15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527151608.GZ15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 17:16 +0200, Thomas Graf wrote:
> * jamal <1117205822.6383.68.camel@localhost.localdomain> 2005-05-27 10:57
> > The thresholds etc are there - just not netlink accessible. Example, the
> > default values for V4 are settable or queriable via:
> > 
> > /proc/sys/net/ipv4/neigh/default/gc_thresh3
> > /proc/sys/net/ipv4/neigh/default/gc_thresh2
> > /proc/sys/net/ipv4/neigh/default/gc_thresh1
> > /proc/sys/net/ipv4/neigh/default/gc_interval
> 
> Sorry but this is just one big hack:

It maybe in the user space representation, but not in the kernel 
abstraction which is what i was refering to.
In other words look at struct in_device;

> a) they do not belong there, the first implication a user does when
>    he sees default/, dev1/, dev2/, devN is that default/ covers
>    the same set of parameters as devX/. Therefore he expects all
>    parameters in default/ to be also in devX/.
> 

The deafult can be overriden by devX. So they dont need to sync.
But this is a separate topic

> b)	struct neigh_parms	parms;
> 	/* HACK. gc_* shoul follow parms without a gap! */
> 	int			gc_interval;
> 	int			gc_thresh1;
> 	int			gc_thresh2;
> 	int			gc_thresh3;
> 
> ...
> 
> 	if (dev) {
> 		dev_name_source = dev->name;
> 		t->neigh_dev[0].ctl_name = dev->ifindex;
> 		t->neigh_vars[12].procname = NULL; <- gc_interval
> 		t->neigh_vars[13].procname = NULL; <- gc_thresh1
> 		t->neigh_vars[14].procname = NULL; <- gc_thresh2
> 		t->neigh_vars[15].procname = NULL; <- gc_thresh3
> 	} else {
>  		dev_name_source = t->neigh_dev[0].procname;
> 		t->neigh_vars[12].data = (int *)(p + 1);
> 		t->neigh_vars[13].data = (int *)(p + 1) + 1;
> 		t->neigh_vars[14].data = (int *)(p + 1) + 2;
> 		t->neigh_vars[15].data = (int *)(p + 1) + 3;
> 	}
> 
>   I will not push along these hacks into my code ;->
> 

I am afraid you are looking at this from the wrong angle (user space),
Thomas ;-> 
The abstraction in the kernel is proper.

To redraw that model again with the exact structure names:

netdevice ->
  L2 config stuff
  config stuff
  more config stuff
  ..
  ..
  netdevice protocol config:
   -> v4 specific (struct in_device)
   ----> IPV4 addresses (ifa_list), ARP params(arp_parms),etc
   -> v6 specific (struct inet6_dev)
   ----> IPV6 addresses(addr_list), ndisc params (nd_parms), etc
 
There are a few more items but i am leaving them out for brevity.
I hope it makes more sense now.

> Some more notes on the devconfig idea: I'm not sure if you are still
> implying devconfig as devinet but if so: although we only have neighbour
> tables on devinets so far there might be neighbour table on other
> interfaces for whatever reason. 

in_devxxx types; sorry, I created the confusion by mentioning devconf in
the sweep.

> A protocol might allocate a neighbour
> parameter set on any netdevice which makes me think that the netlink
> neighbour code should be open for this as well. It depends on how we
> do the devconfig thing, so what I suggest it so leave this as-is for
> the moment and make a decision once we know more about how the devconfig
> thing will look like. Reasonable?

Take a look at what i said above and see if it makes sense. 
Note, I am not objecting to the patch like i said - I think some of
those items are must put in that patch. Whatever simplifies life for
you. I am not exactly a purist but at times i like getting it right from
the beggining.

cheers,
jamal

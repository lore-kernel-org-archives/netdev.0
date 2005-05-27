From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Fri, 27 May 2005 17:16:08 +0200
Message-ID: <20050527151608.GZ15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch> <20050526185526.GZ15391@postel.suug.ch> <1117192464.6688.3.camel@localhost.localdomain> <20050527121503.GN15391@postel.suug.ch> <1117201853.6383.29.camel@localhost.localdomain> <20050527141023.GP15391@postel.suug.ch> <1117205822.6383.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117205822.6383.68.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117205822.6383.68.camel@localhost.localdomain> 2005-05-27 10:57
> The thresholds etc are there - just not netlink accessible. Example, the
> default values for V4 are settable or queriable via:
> 
> /proc/sys/net/ipv4/neigh/default/gc_thresh3
> /proc/sys/net/ipv4/neigh/default/gc_thresh2
> /proc/sys/net/ipv4/neigh/default/gc_thresh1
> /proc/sys/net/ipv4/neigh/default/gc_interval

Sorry but this is just one big hack:

a) they do not belong there, the first implication a user does when
   he sees default/, dev1/, dev2/, devN is that default/ covers
   the same set of parameters as devX/. Therefore he expects all
   parameters in default/ to be also in devX/.

b)	struct neigh_parms	parms;
	/* HACK. gc_* shoul follow parms without a gap! */
	int			gc_interval;
	int			gc_thresh1;
	int			gc_thresh2;
	int			gc_thresh3;

...

	if (dev) {
		dev_name_source = dev->name;
		t->neigh_dev[0].ctl_name = dev->ifindex;
		t->neigh_vars[12].procname = NULL; <- gc_interval
		t->neigh_vars[13].procname = NULL; <- gc_thresh1
		t->neigh_vars[14].procname = NULL; <- gc_thresh2
		t->neigh_vars[15].procname = NULL; <- gc_thresh3
	} else {
 		dev_name_source = t->neigh_dev[0].procname;
		t->neigh_vars[12].data = (int *)(p + 1);
		t->neigh_vars[13].data = (int *)(p + 1) + 1;
		t->neigh_vars[14].data = (int *)(p + 1) + 2;
		t->neigh_vars[15].data = (int *)(p + 1) + 3;
	}

  I will not push along these hacks into my code ;->

Some more notes on the devconfig idea: I'm not sure if you are still
implying devconfig as devinet but if so: although we only have neighbour
tables on devinets so far there might be neighbour table on other
interfaces for whatever reason. A protocol might allocate a neighbour
parameter set on any netdevice which makes me think that the netlink
neighbour code should be open for this as well. It depends on how we
do the devconfig thing, so what I suggest it so leave this as-is for
the moment and make a decision once we know more about how the devconfig
thing will look like. Reasonable?

> I apologize i didnt comment on the patch earlier - sometimes when i am
> away from the list for sometime i skip threads which may require me to
> spend time looking at them to make any useful comments. This maybe the
> reason i didnt respond. To catchup i normally read emails addressed to
> me first then go over the list in a LIFO mode and stop once i get
> engaged in a discussion.

I should have CCed you, my fault.

From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/4] Initialize and fill IPv6 route age
Date: Tue, 24 Jul 2007 08:26:46 +0100
Message-ID: <20070724082646.4cbd1ede@oldman>
References: <20070723101318.c773f600.varunc@linux.vnet.ibm.com>
	<20070723123429.15715972@oldman.hamilton.local>
	<46A57E29.9040404@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47343 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752788AbXGXH1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 03:27:55 -0400
In-Reply-To: <46A57E29.9040404@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jul 2007 09:50:57 +0530
Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:

> Stephen Hemminger wrote:
> > On Mon, 23 Jul 2007 10:13:18 +0530
> > Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:
> >
> >   
> >> The age field of the ipv6 route structures are initilized with the current timeval at the time of route       creation. When the route dump is called the route age value stored in the structure is subtracted from the     present timeval and the difference is passed on as the route age.
> >>
> >> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
> >> ---
> >>  include/net/ip6_fib.h   |    1 +
> >>  include/net/ip6_route.h |    3 +++
> >>  net/ipv6/addrconf.c     |    5 +++++
> >>  net/ipv6/route.c        |   23 +++++++++++++++++++----
> >>  4 files changed, 28 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> >> index c48ea87..e30a1cf 100644
> >> --- a/include/net/ip6_fib.h
> >> +++ b/include/net/ip6_fib.h
> >> @@ -98,6 +98,7 @@ struct rt6_info
> >>  	
> >>  	u32				rt6i_flags;
> >>  	u32				rt6i_metric;
> >> +	time_t				rt6i_age;
> >>  	atomic_t			rt6i_ref;
> >>  	struct fib6_table		*rt6i_table;
> >>  
> >> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> >> index 5456fdd..fc9716c 100644
> >> --- a/include/net/ip6_route.h
> >> +++ b/include/net/ip6_route.h
> >> @@ -36,6 +36,9 @@ struct route_info {
> >>  #define RT6_LOOKUP_F_REACHABLE	0x2
> >>  #define RT6_LOOKUP_F_HAS_SADDR	0x4
> >>  
> >> +#define RT6_SET_ROUTE_INFO 0x0
> >> +#define RT6_GET_ROUTE_INFO 0x1
> >> +
> >>  extern struct rt6_info	ip6_null_entry;
> >>  
> >>  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
> >> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> >> index 5a5f8bd..715c766 100644
> >> --- a/net/ipv6/addrconf.c
> >> +++ b/net/ipv6/addrconf.c
> >> @@ -4187,6 +4187,7 @@ EXPORT_SYMBOL(unregister_inet6addr_notif
> >>  
> >>  int __init addrconf_init(void)
> >>  {
> >> +	struct timeval tv;
> >>  	int err = 0;
> >>  
> >>  	/* The addrconf netdev notifier requires that loopback_dev
> >> @@ -4214,10 +4215,14 @@ int __init addrconf_init(void)
> >>  	if (err)
> >>  		return err;
> >>  
> >> +	do_gettimeofday(&tv);
> >>     
> >
> > Better to use ktime_t or timespec in new code.
> >   
> You are saying not to use timeval as its going to be removed sometime in
> future? If not, may i know why should we use timespec or ktime?
> I need only seconds granularity so i was wondering if that matters.
> 

Timeval isn't going away, but ktime is easier for basic maths.
If all you need is seconds resolution,  just use jiffies. Gettimeofday
(and ktime_get) both require expensive hardware accesses on
some platforms.

For the specific case IPV6 route ageing, this isn't a big deal it is just
that people tend to copy code. 

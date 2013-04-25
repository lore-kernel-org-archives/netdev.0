From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: getting VF link info seems to be broken in 3.9-rc8
Date: Thu, 25 Apr 2013 13:45:13 -0700
Message-ID: <20130425134513.12720d31@nehalam.linuxnetplumber.net>
References: <517975F0.60003@intel.com>
	<20130425.152431.1753713368050789406.davem@davemloft.net>
	<51799008.60507@intel.com>
	<20130425.162510.310560314302575352.davem@davemloft.net>
	<517993B6.8040105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	shemminger@vyatta.com, ronye@mellanox.com, ogerlitz@mellanox.com,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <517993B6.8040105@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 25 Apr 2013 13:36:06 -0700
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> On 04/25/2013 01:25 PM, David Miller wrote:
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > Date: Thu, 25 Apr 2013 13:20:24 -0700
> >
> >> On 04/25/2013 12:24 PM, David Miller wrote:
> >>> From: Alexander Duyck <alexander.h.duyck@intel.com>
> >>> Date: Thu, 25 Apr 2013 11:29:04 -0700
> >>>
> >>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> >>> index b65441d..23854b5 100644
> >>> --- a/net/core/rtnetlink.c
> >>> +++ b/net/core/rtnetlink.c
> >>> @@ -1072,7 +1072,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
> >>>  	rcu_read_lock();
> >>>  	cb->seq = net->dev_base_seq;
> >>>  
> >>> -	if (nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
> >>> +	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
> >>>  			ifla_policy) >= 0) {
> >>>  
> >>>  		if (tb[IFLA_EXT_MASK])
> >>> @@ -1922,7 +1922,7 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
> >>>  	u32 ext_filter_mask = 0;
> >>>  	u16 min_ifinfo_dump_size = 0;
> >>>  
> >>> -	if (nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
> >>> +	if (nlmsg_parse(nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
> >>>  			ifla_policy) >= 0) {
> >>>  		if (tb[IFLA_EXT_MASK])
> >>>  			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
> >> I thought that as well.  I tried reverting it and the issue is still there.
> >>
> >> However, I do think this may be part of the issue since I added a printk
> >> to dump nlmsg_attrlen before going into the nlmsg_parse and with
> >> ifinfomsg the attrlen is -12, with rtgenmsg it is 0.
> > I wonder if we are seeing two ways tools are making these calls, some are
> > passing rtgenmsg and some are passing ifinfomsg.  The latter, I am mostly
> > convinced, is what we must see here from properly written applications.
> >
> > That would be really unfortunate, but seeing a nlmsg_attrlen() of -12 would
> > seem to confirm that a rtgenmsg was used.
> >
> > I guess you're using iproute2?
> 
> Yes.  All I am doing is ip link show and previously this would display
> VF info as well as PF.  Now the VF info is not there.
> 
> From what I can tell the problem call is rtnl_wilddump_req_filter since
> it is only passing a rtgenmsg and asking us to dump the link with the
> RTEXT_FILTER_VF filter mask.

It looks like a bug in the initial code for filter. in this case, it calls:
  ip_list_flush_or_save
     rtnl_wilddump_req_filter
       which sends 'struct rtgenmsg' 

This was probably a mistake in the original flags addition, not sure if we can
fix it now that ABI is set. Probably have to revert the kernel change.


commit bd886ebb1ffd84301caa2341b671df9a9e2db4c9
Author: Rose, Gregory V <gregory.v.rose@intel.com>
Date:   Tue Feb 21 10:43:09 2012 +0000

    iproute2: Add netlink attribute to filter dump requests
    
    Add a new netlink attribute type to the dump request to allow
    filtering of the information returned for the respective matching
    interfaces.  At this time the only filter defined is to request
    virtual function (VF) device info for interfaces that attached VFs.
    
    It will also be possible to extend the request with other yet to be
    defined netlink attributes in the future.
    
    Signed-off-by: Greg Rose <gregory.v.rose@intel.com>




------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_apr
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

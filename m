From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v1 1/7] net: add generic PF_BRIDGE:RTM_ FDB
 hooks
Date: Wed, 11 Apr 2012 17:05:50 +0100
Message-ID: <1334160350.2552.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
	  <20120409220017.3288.13746.stgit@jf-dev1-dcblab>
	 <1334114599.7150.361.camel@deadeye> <4F85991A.5030808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <roprabhu@cisco.com>, <mst@redhat.com>,
	<stephen.hemminger@vyatta.com>, <davem@davemloft.net>,
	<hadi@cyberus.ca>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gregory.v.rose@intel.com>,
	<krkumar2@in.ibm.com>, <sri@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9303 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756764Ab2DKQF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 12:05:56 -0400
In-Reply-To: <4F85991A.5030808@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-11 at 07:45 -0700, John Fastabend wrote:
> On 4/10/2012 8:23 PM, Ben Hutchings wrote:
> > On Mon, 2012-04-09 at 15:00 -0700, John Fastabend wrote:
> > [...]
> >> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> >> index 1f77540..05822e5 100644
> >> --- a/include/linux/netdevice.h
> >> +++ b/include/linux/netdevice.h
> > [...]
> >> @@ -905,6 +906,19 @@ struct netdev_fcoe_hbainfo {
> >>   *	feature set might be less than what was returned by ndo_fix_features()).
> >>   *	Must return >0 or -errno if it changed dev->features itself.
> >>   *
> >> + * int (*ndo_fdb_add)(struct ndmsg *ndm, struct net_device *dev,
> >> + *		      unsigned char *addr, u16 flags)
> >> + *	Adds an FDB entry to dev for addr. The ndmsg contains flags to indicate
> >> + *	if the dev->master FDB should be updated or the devices internal FDB.
> > 
> > I don't think the second sentence is helpful, as rtnl_fdb_add() will
> > take care of those flags.
> > 
> >> + * int (*ndo_fdb_del)(struct ndmsg *ndm, struct net_device *dev,
> >> + *		      unsigned char *addr)
> >> + *	Deletes the FDB entry from dev coresponding to addr. The ndmsg
> >> + *	contains flags to indicate if the dev->master FDB should be
> >> + *	updated or the devices internal FDB.
> > 
> > Similarly here.
> 
> agreed neither seem particularly helpful I'll remove them.
> 
> > 
> >> + * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
> >> + *		       struct net_device *dev, int idx)
> >> + *	Used to add FDB entries to dump requests. Implementers should add
> >> + *	entries to skb and update idx with the number of entries.
> >>   */
> > [...
> >> --- a/net/core/rtnetlink.c
> >> +++ b/net/core/rtnetlink.c
> > [...]
> >> +static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
> >> +{
> > [...]
> >> +	err = -EOPNOTSUPP;
> > 
> > So if NTF_MASTER and NTF_SELF are both set, we can quietly fall back to
> > just setting one FDB?  Not sure that's really desirable though 
> > 
> 
> It makes it easier to keep an embedded agent and the sw bridge in
> sync if setting both flags adds the entry to both the SW bridge and
> embedded bridge.

Yes, I agree with that.

[...]
> > Wonder what we should do on error here if we've already successfully
> > called ndo_fdb_add on the master?  Should we try to roll back the first
> > addition?
> > 
> 
> The problem with rolling back is the table is likely already updated and
> traffic may already be being forwarded. So I think in this case the user
> will have to query the device to learn what failed. It seems like the
> simplest way to handle this. I think it is unwanted to have traffic being
> forwarded one way for a short period of time then rolled back.
> 
> The other idea I just had is we could clear the NTF_ bit in ndm_flags after
> the successful add, del command. I believe the nlmsg gets sent back to the
> user on error I would need to check on this.
[...]

That sounds like a good way of doing it, assuming there's no
compatibility issue.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

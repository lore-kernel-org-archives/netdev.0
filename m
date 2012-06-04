From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v1 2/3] net: add VEPA, VEB bridge mode
Date: Mon, 04 Jun 2012 09:38:04 -0700
Message-ID: <4FCCE46C.7080809@intel.com>
References: <20120530030531.7443.72024.stgit@jf-dev1-dcblab> <20120530030705.7443.22155.stgit@jf-dev1-dcblab> <OF0D72A103.6F322B98-ON65257A13.00500E50-65257A13.005272D6@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	eilong@broadcom.com, eric.w.multanen@intel.com,
	gregory.v.rose@intel.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, mst@redhat.com,
	netdev@vger.kernel.org, shemminger@vyatta.com, sri@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13299 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297Ab2FDQiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 12:38:25 -0400
In-Reply-To: <OF0D72A103.6F322B98-ON65257A13.00500E50-65257A13.005272D6@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/2012 7:59 AM, Krishna Kumar2 wrote:
> John Fastabend <john.r.fastabend@intel.com> wrote on 05/30/2012 08:37:06
> AM:
> 
> Some comments below:
> 
>> +static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
>> +{
>> ...
>> +		 if (!flags && master && master->netdev_ops->
> ndo_bridge_getlink)
>> +		 		 err = master->netdev_ops->ndo_bridge_getlink(skb,
> 0, 0, dev);
>> +		 else if (dev->netdev_ops->ndo_bridge_getlink)
>> +		 		 err = dev->netdev_ops->ndo_bridge_getlink(skb, 0,
> 0, dev);
> 
> I think you should do something like:
> 
>         if ((flags == BRIDGE_FLAGS_MASTER) && ...)
>                 ...
> 
> Also you could use BRIDGE_FLAGS_MASTER=1, SELF=2, and use
> "if (flags & BRIDGE_FLAGS_MASTER)" for consistency?

OK this is likely a good thing otherwise user space is a
bit tedious when managing FDB and bridge modes. We do still
need the !flags case to support existing applications though,
(we must maintain existing semantics)

if (!flags || (flags & BRIDGE_FLAGS_MASTER) && ...)
	...
else (flags & BRIDGE_FLAGS_SELF)
	...

> 
> 
> +		 if (!err)
> +		 		 err = rtnl_bridge_notify(dev, flags);
> 
> It is possible to return a reporting error even though
> the operation succeeded. Maybe something that could be
> done here to indicate that the operation succeeded, or
> is that a TODO?
> 

The problem is if rtnl_bridge_notify fails due to memory
constraints or otherwise. In this case the set has already
completed successfully as you note so we should not return
any error. This should fix it if I understand your concern
correctly.

	if (!err)
		rtnl_bridge_notify(dev, flags);
	return err;



>>  static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr
> *nlh,
>>                  void *arg)
>>  {
> ..
>> +   if (!flags && dev->master &&
>> +       dev->master->netdev_ops->ndo_bridge_setlink)
>> +      err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
>> +   else if ((flags & BRIDGE_FLAGS_SELF) &&
>> +         dev->netdev_ops->ndo_bridge_setlink)
> 
> Same usage of MASTER here.

Agreed. Thanks.

> 
> Thanks,
> - KK
> 

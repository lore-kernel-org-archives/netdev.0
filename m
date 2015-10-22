From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v4 1/2] mpls: multipath route support
Date: Thu, 22 Oct 2015 14:48:55 +0100
Message-ID: <5628E947.60707@brocade.com>
References: <1445217645-42885-2-git-send-email-roopa@cumulusnetworks.com> <5628B94A.5010903@brocade.com> <5628E594.4070900@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<ebiederm@xmission.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:18990 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756185AbbJVNtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:49:09 -0400
In-Reply-To: <5628E594.4070900@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/15 14:33, roopa wrote:
> On 10/22/15, 3:24 AM, Robert Shearman wrote:
>> On 19/10/15 02:20, Roopa Prabhu wrote:
>>>        return dev;
>>>    }
>>>
>>> +static int mpls_nh_assign_dev(struct net *net, struct mpls_nh *nh, int oif)
>>> +{
>>> +    struct net_device *dev = NULL;
>>> +    int err = -ENODEV;
>>> +
>>> +    dev = find_outdev(net, nh, oif);
>>> +    if (IS_ERR(dev)) {
>>> +        err = PTR_ERR(dev);
>>> +        dev = NULL;
>>> +        goto errout;
>>> +    }
>>> +
>>> +    /* Ensure this is a supported device */
>>> +    err = -EINVAL;
>>> +    if (!mpls_dev_get(dev))
>>> +        goto errout;
>>> +
>>> +    /* For now just support ethernet devices */
>>> +    if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
>>> +        goto errout;
>>> +
>>> +    RCU_INIT_POINTER(nh->nh_dev, dev);
>>> +    dev_put(dev);
>>
>> If it's safe to not keep a reference to dev (i.e. because the device cannot go away while a netlink message is being processed), then why not just change find_outdev to use __dev_get_by_index?
> yes, rtnl is held here. dev_get_by_index was used by the original code. So i did not feel the need to change that.
> I can see the need to get away with the dev_hold instead of doing a dev_hold with dev_get_by_index, rcu assign and put because of rtnl. But, it seems cleaner to use it the way it is today, given the other cases where the dev is already held during lookup when oif is not specified.
>
>> If the dev can go away during this, then we could end up adding an mpls route that points to a freed interface, because until we've added the route to the label table mpls_ifdown won't find it.
> dev should not go away because we have rtnl held at this point. no ?
> If there is a problem i can think about moving the dev_put's for nexthop devs after mpls_route_update

Yes, either do that or change find_outdev to avoid holding a reference 
to the dev (which given that it's safe is my preference). The way it is 
here is slightly confusing as it raises the question in the reader's 
mind about whether a reference to dev is required or not.

Thanks,
Rob

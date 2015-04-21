From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 07/11] IB/cm: Add network namespace support
Date: Tue, 21 Apr 2015 14:59:55 +0300
Message-ID: <55363BBB.1020407@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
 <1429520622-10303-8-git-send-email-haggaie@mellanox.com>
 <20150420170659.GD7676@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150420170659.GD7676-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20/04/2015 20:06, Jason Gunthorpe wrote:
> On Mon, Apr 20, 2015 at 12:03:38PM +0300, Haggai Eran wrote:
>> From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>
>> Add namespace support to the IB-CM layer.
> 
>> - Each CM-ID now has a network namespace it is associated with, assigned at
>>   creation. This namespace is used as needed during subsequent action on the
>>   CM-ID or related objects.
> 
> There is really something weird about this layering. At the CM layer
> there should be no concept of an IP address, it only deals with GIDs.

Using the GID alone is not enough to distinguish between namespaces,
because you can have multiple IPoIB interfaces, all using the GID (and
possibly the same P_Key), and each belonging to a different namespace.

> So how can a CM object have a network namespace associated with it?

The listener rbtree's key is currently the service ID, for instance. Now
with namespaces, you can have multiple listeners listening on the same
service ID, so we need to use (service ID, namespace) as the key.

> 
>>  {
>>  	av->port = port;
>>  	av->pkey_index = wc->pkey_index;
>>  	ib_init_ah_from_wc(port->cm_dev->ib_device, port->port_num, wc,
>> -			   grh, &av->ah_attr, &init_net);
>> +			   grh, &av->ah_attr, net);
> 
> There is something deeply wrong with adding network namespace
> arguments to verbs.
> 
> For rocee the gid index clearly specifies the network namespace
> to use, so much of this should go away and have rocee get the
> namespace from the gid index.
> 
> Ie in ib_init_ah_from_wc we have the ib_wc which contains the sgid
> index.

I don't see it there. The code seem to fetch the GID from the GRH.
Because the IP address in the source GID can be the same for different
namespaces, this is not enough to pick the right namespace.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

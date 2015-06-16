From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH 02/11] IB/ipoib: Return IPoIB devices matching connection
 parameters
Date: Tue, 16 Jun 2015 09:36:35 +0300
Message-ID: <557FC3F3.8030902@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-3-git-send-email-haggaie@mellanox.com>
 <20150615172210.GB14982@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0054.outbound.protection.outlook.com ([157.56.112.54]:4032
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751798AbbFPGgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 02:36:37 -0400
In-Reply-To: <20150615172210.GB14982@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/2015 20:22, Jason Gunthorpe wrote:
> On Mon, Jun 15, 2015 at 11:47:07AM +0300, Haggai Eran wrote:
> 
>> +/* Called with an RCU read lock taken */
> 
> Add _rcu to the name? That is the standard convention.

Sure, I'll change that.

> 
>> +/* returns an IPoIB netdev on top a given ipoib device matching a pkey_index
>> + * and address, if one exists. */
>> +static struct net_device *ipoib_match_gid_pkey_addr(struct ipoib_dev_priv *priv,
>> +						    const union ib_gid *gid,
>> +						    u16 pkey_index,
>> +						    const struct sockaddr *addr)
>> +{
>> +	struct ipoib_dev_priv *child_priv;
>> +	struct net_device *net_dev = NULL;
>> +
>> +	if (priv->pkey_index == pkey_index &&
>> +	    (!gid || !memcmp(gid, &priv->local_gid, sizeof(*gid)))) {
>> +		net_dev = ipoib_get_net_dev_match_addr(addr, priv->dev);
>> +		if (net_dev)
>> +			return net_dev;
> 
> As I said already, this should not even look at the sockaddr unless
> there are multiple possible hits on the other parameters,
What is the goal here? The only difference omitting the IP check will
make is when sending a request to a matching GID but with the wrong IP.
Is it important that we pass these requests here so that they will be
dropped at the rdma_cm module?

Also, note that ipoib_get_net_dev_match_addr can return a different
net_dev from the one ipoib created. When using bonding, it will find the
IP address on the bonding device, and return the bonding net_dev instead.

> and there
> should be a comment explaining the sockaddr is only a hack to make up
> for having an incomplete LLADDR.

Sure, I'll add a comment.

> 
> That way people not using same guid children do not get incorrect
> functionality..
> 
>> +static struct net_device *ipoib_get_net_dev_by_params(
>> +		struct ib_device *dev, u8 port, u16 pkey,
>> +		const union ib_gid *gid, const struct sockaddr *addr)
> 
> [..]
> 
>> +	ret = ib_find_cached_pkey(dev, port, pkey, &pkey_index);
>> +	if (ret)
>> +		return NULL;
>> +
>> +	if (!rdma_protocol_ib(dev, port))
>> +		return NULL;
> 
> This if should be first I'd think.

Okay.

> 
> 
>> +	dev_list = ib_get_client_data(dev, &ipoib_client);
>> +	if (!dev_list)
>> +		return NULL;
> 
> Is the locking OK here? This access protected by lists_rwsem -
> but for instance ib_unregister_device holds only the device_mutex when
> calling client->remove, which kfree's dev_list. Looks wrong to me.

I think you're right. Perhaps we can switch the client data to NULL in
ib_unregister_device under the lists_rwsem. Then the
ipoib_get_net_dev_by_params call will know to skip it. The remove()
callback will need to be augmented with the client data as a parameter,
because it won't be able to retrieve it using ib_get_client_data anymore.

Haggai

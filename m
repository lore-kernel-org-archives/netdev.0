From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC 6/8] macvtap: allow TUNSETIFF to create multiqueue
 device
Date: Fri, 24 May 2013 13:36:50 +0800
Message-ID: <519EFC72.1010405@redhat.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com> <1369278753-2533-7-git-send-email-jasowang@redhat.com> <20130523114556.GC17993@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130523114556.GC17993@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2013 07:45 PM, Michael S. Tsirkin wrote:
> On Thu, May 23, 2013 at 11:12:31AM +0800, Jason Wang wrote:
>> Though the queue were in fact created by open(), we still need to add this check
>> to be compatible with tuntap which can let mgmt software use a single API to
>> manage queues. This patch only validates the device name and moves the TUNSETIFF
>> to a helper.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/macvtap.c |   50 ++++++++++++++++++++++++++++++++++++++----------
>>  1 files changed, 39 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 5fd341c..e3f9344 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -867,6 +867,7 @@ out:
>>  	return ret;
>>  }
>>  
>> +
> Please don't add empty lines like this :).

Sure.
>
>>  static struct macvlan_dev *macvtap_get_vlan(struct macvtap_queue *q)
>>  {
>>  	struct macvlan_dev *vlan;
>> @@ -884,6 +885,43 @@ static void macvtap_put_vlan(struct macvlan_dev *vlan)
>>  	dev_put(vlan->dev);
>>  }
>>  
>> +static int macvtap_set_iff(struct file *file, struct ifreq __user *ifr_u)
>> +{
>> +	struct macvtap_queue *q = file->private_data;
>> +	struct net *net = current->nsproxy->net_ns;
>> +	struct inode *inode = file_inode(file);
>> +	struct net_device *dev, *dev2;
>> +	struct ifreq ifr;
>> +
>> +	if (copy_from_user(&ifr, ifr_u, sizeof(struct ifreq)))
>> +		return -EFAULT;
>> +
>> +	if (ifr.ifr_flags & IFF_MULTI_QUEUE) {
> So why do we validate the name?
> Pls add a comment.

Ok. The validation is to prevent the userspace create the queues on the
wrong device. Not sure whether or not this is needed for single queue case.
>
>> +		dev = __dev_get_by_name(net, ifr.ifr_name);
>> +		if (!dev)
>> +			return -EINVAL;
>> +
>> +		dev2 = dev_get_by_macvtap_minor(iminor(inode));
>> +		if (!dev2)
>> +			return -EINVAL;
>> +
>> +		if (dev != dev2) {
>> +			dev_put(dev2);
>> +			return -EINVAL;
>> +		}
>> +
>> +		dev_put(dev2);
>> +	}
>> +
>> +	if ((ifr.ifr_flags & ~(IFF_VNET_HDR | IFF_MULTI_QUEUE)) !=
>> +	    (IFF_NO_PI | IFF_TAP))
>> +		return -EINVAL;
>> +	else
>> +		q->flags = ifr.ifr_flags;
>> +
>> +	return 0;
>> +}
>> +
>>  /*
>>   * provide compatibility with generic tun/tap interface
>>   */
>> @@ -902,17 +940,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>>  
>>  	switch (cmd) {
>>  	case TUNSETIFF:
>> -		/* ignore the name, just look at flags */
>> -		if (get_user(u, &ifr->ifr_flags))
>> -			return -EFAULT;
>> -
>> -		ret = 0;
>> -		if ((u & ~IFF_VNET_HDR) != (IFF_NO_PI | IFF_TAP))
>> -			ret = -EINVAL;
>> -		else
>> -			q->flags = u;
>> -
>> -		return ret;
>> +		return macvtap_set_iff(file, ifr);
>>  
>>  	case TUNGETIFF:
>>  		vlan = macvtap_get_vlan(q);
>> -- 
>> 1.7.1

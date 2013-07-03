From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: rtnl_lock deadlock on 3.10
Date: Wed, 3 Jul 2013 20:26:11 +0300
Message-ID: <51D45EB3.7030404@mellanox.com>
References: <20130701145456.GA7756@sbohrermbp13-local.rgmadvisors.com> <20130702082818.GA26178@order.stressinduktion.org> <kqul4h$ib8$1@ger.gmane.org> <20130703051152.GA12615@order.stressinduktion.org> <20130703053307.GB12615@order.stressinduktion.org> <20130703172239.GA3439@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<sbohrer-EgGFQ3RFNTIP7C3xziwOQw@public.gmane.org>
To: Shawn Bohrer <shawn.bohrer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130703172239.GA3439-/vebjAlq/uFE7V8Yqttd03bhEEblAqRIDbRjUBewulXQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/07/2013 20:22, Shawn Bohrer wrote:
> On Wed, Jul 03, 2013 at 07:33:07AM +0200, Hannes Frederic Sowa wrote:
>> On Wed, Jul 03, 2013 at 07:11:52AM +0200, Hannes Frederic Sowa wrote:
>>> On Tue, Jul 02, 2013 at 01:38:26PM +0000, Cong Wang wrote:
>>>> On Tue, 02 Jul 2013 at 08:28 GMT, Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org> wrote:
>>>>> On Mon, Jul 01, 2013 at 09:54:56AM -0500, Shawn Bohrer wrote:
>>>>>> I've managed to hit a deadlock at boot a couple times while testing
>>>>>> the 3.10 rc kernels.  It seems to always happen when my network
>>>>>> devices are initializing.  This morning I updated to v3.10 and made a
>>>>>> few config tweaks and so far I've hit it 4 out of 5 reboots.  It looks
>>>>>> like most processes are getting stuck on rtnl_lock.  Below is a boot
>>>>>> log with the soft lockup prints.  Please let know if there is any
>>>>>> other information I can provide:
>>>>> Could you try a build with CONFIG_LOCKDEP enabled?
>>>>>
>>>> The problem is clear: ib_register_device() is called with rtnl_lock,
>>>> but itself needs device_mutex, however, ib_register_client() first
>>>> acquires device_mutex, then indirectly calls register_netdev() which
>>>> takes rtnl_lock. Deadlock!
>>>>
>>>> One possible fix is always taking rtnl_lock before taking
>>>> device_mutex, something like below:
>>>>
>>>> diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
>>>> index 18c1ece..890870b 100644
>>>> --- a/drivers/infiniband/core/device.c
>>>> +++ b/drivers/infiniband/core/device.c
>>>> @@ -381,6 +381,7 @@ int ib_register_client(struct ib_client *client)
>>>>   {
>>>>   	struct ib_device *device;
>>>>   
>>>> +	rtnl_lock();
>>>>   	mutex_lock(&device_mutex);
>>>>   
>>>>   	list_add_tail(&client->list, &client_list);
>>>> @@ -389,6 +390,7 @@ int ib_register_client(struct ib_client *client)
>>>>   			client->add(device);
>>>>   
>>>>   	mutex_unlock(&device_mutex);
>>>> +	rtnl_unlock();
>>>>   
>>>>   	return 0;
>>>>   }
>>>> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
>>>> index b6e049a..5a7a048 100644
>>>> --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
>>>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
>>>> @@ -1609,7 +1609,7 @@ static struct net_device *ipoib_add_port(const char *format,
>>>>   		goto event_failed;
>>>>   	}
>>>>   
>>>> -	result = register_netdev(priv->dev);
>>>> +	result = register_netdevice(priv->dev);
>>>>   	if (result) {
>>>>   		printk(KERN_WARNING "%s: couldn't register ipoib port %d; error %d\n",
>>>>   		       hca->name, port, result);
>>> Looks good to me. Shawn, could you test this patch?
>> ib_unregister_device/ib_unregister_client would need the same change,
>> too. I have not checked the other ->add() and ->remove() functions. Also
>> cc'ed linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland Dreier.
> Cong's patch is missing the #include <linux/rtnetlink.h> but otherwise
> I've had 34 successful reboots with no deadlocks which is a good sign.
> It sounds like there are more paths that need to be audited and a
> proper patch submitted.  I can do more testing later if needed.
>
> Thanks,
> Shawn
>

Guys, I was a bit busy today looking into that, but I don't think we 
want the IB core layer  (core/device.c) to
use rtnl locking which is something that belongs to the network stack.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

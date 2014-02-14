From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net,v3] hyperv: Fix the carrier status setting
Date: Fri, 14 Feb 2014 10:19:11 +0800
Message-ID: <52FD7D1F.2030102@redhat.com>
References: <1392252867-21146-1-git-send-email-haiyangz@microsoft.com>
 <52FC4147.7060803@redhat.com>
 <900caa9031c345a6a21604ca7bb02174@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <900caa9031c345a6a21604ca7bb02174@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On 02/13/2014 11:04 PM, Haiyang Zhang wrote:
>
>> -----Original Message-----
>> From: Jason Wang [mailto:jasowang@redhat.com]
>> Sent: Wednesday, February 12, 2014 10:52 PM
>> To: Haiyang Zhang; davem@davemloft.net; netdev@vger.kernel.org
>> Cc: KY Srinivasan; olaf@aepfle.de; linux-kernel@vger.kernel.org; driverdev-
>> devel@linuxdriverproject.org
>> Subject: Re: [PATCH net,v3] hyperv: Fix the carrier status setting
>>
>> On 02/13/2014 08:54 AM, Haiyang Zhang wrote:
>>> Without this patch, the "cat /sys/class/net/ethN/operstate" shows
>>> "unknown", and "ethtool ethN" shows "Link detected: yes", when VM
>>> boots up with or without vNIC connected.
>>>
>>> This patch fixed the problem.
>>>
>>> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
>>> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
>>> ---
>>>  drivers/net/hyperv/netvsc_drv.c |   53
>> ++++++++++++++++++++++++++++-----------
>>>  1 files changed, 38 insertions(+), 15 deletions(-)
>>>
>>> diff --git a/drivers/net/hyperv/netvsc_drv.c
>>> b/drivers/net/hyperv/netvsc_drv.c index 7756118..7141a19 100644
>>> --- a/drivers/net/hyperv/netvsc_drv.c
>>> +++ b/drivers/net/hyperv/netvsc_drv.c
>>> @@ -88,8 +88,12 @@ static int netvsc_open(struct net_device *net)  {
>>>  	struct net_device_context *net_device_ctx = netdev_priv(net);
>>>  	struct hv_device *device_obj = net_device_ctx->device_ctx;
>>> +	struct netvsc_device *nvdev;
>>> +	struct rndis_device *rdev;
>>>  	int ret = 0;
>>>
>>> +	netif_carrier_off(net);
>>> +
>>>  	/* Open up the device */
>>>  	ret = rndis_filter_open(device_obj);
>>>  	if (ret != 0) {
>>> @@ -99,6 +103,11 @@ static int netvsc_open(struct net_device *net)
>>>
>>>  	netif_start_queue(net);
>>>
>>> +	nvdev = hv_get_drvdata(device_obj);
>>> +	rdev = nvdev->extension;
>>> +	if (!rdev->link_state)
>>> +		netif_carrier_on(net);
>>> +
>> Maybe you can just schedule the work here and then you can drop the
>> rtnl_lock in netvsc_link_change() ?
> The rtnl_lock will still be necessary in the netvsc_link_change(), because 
> we want to prevent it getting wrong rdev pointer when netvsc_change_mtu
> is removing/adding rndis device.

Ok.
>>> +
>>> +	if (notify)
>>> +		netdev_notify_peers(net);
>>>  }
>>>
>> Looks like this forces arp_notify here. Is it expected?
> Yes, this is expected. It's required after live migration.
>
> Thanks,
> - Haiyang

Yes, this does not change the current behaviour. (arp_notify is
meaningless for netvsc).

Acked-by: Jason Wang <jasowang@redhat.com>

The patch is also needed for stable.

Thanks
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [RFC PATCH 09/11] IB/Verbs: Use management helper has_ipoib()
 and, cap_ipoib() for ipoib-check
Date: Fri, 27 Mar 2015 17:15:42 +0100
Message-ID: <5515822E.2020207@profitbricks.com>
References: <551579CA.4030901@profitbricks.com> <55157BC6.70400@profitbricks.com> <20150327160616.GA28412@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Alex Estrin <alex.estrin@int
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150327160616.GA28412-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/27/2015 05:06 PM, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 04:48:22PM +0100, Michael Wang wrote:
>
>> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
>> index 3341754..fcd7558 100644
>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
>> @@ -1655,7 +1655,7 @@ static void ipoib_add_one(struct ib_device *device)
>>      struct ipoib_dev_priv *priv;
>>      int s, e, p;
>>  
>> -    if (!rdma_transport_is_ib(device))
>> +    if (!has_ipoib(device))
>>          return;
> This is a good example of a test that doesn't really make sense, IPoIB
> is certainly a port specific attribute.
According to my understanding, seems like the logical is:

    if 'device have no port need ipoib initialization'
            return
>
>>      dev_list = kmalloc(sizeof *dev_list, GFP_KERNEL);
>> @@ -1673,7 +1673,7 @@ static void ipoib_add_one(struct ib_device *device)
>>      }
>>  
>>      for (p = s; p <= e; ++p) {
>> -        if (!rdma_port_ll_is_ib(device, p))
>> +        if (!cap_ipoib(device, p))
>>              continue;
> And down here we test every port.
>
> The routine should just test every port and do nothing if no ports
> need IPoIB.
And here since there are some initial work to do, it iterate all the
port to find out which one need to be initialized.

>
>>          dev = ipoib_add_port("ib%d", device, p);
>>          if (!IS_ERR(dev)) {
>> @@ -1690,7 +1690,7 @@ static void ipoib_remove_one(struct ib_device *device)
>>      struct ipoib_dev_priv *priv, *tmp;
>>      struct list_head *dev_list;
>>  
>> -    if (!rdma_transport_is_ib(device))
>> +    if (!has_ipoib(device))
>>          return;
> This test should be made redundant by having ib_get_client_data return
> null if ipoib_add_one didn't do anything. Maybe that already happens?
Here if we have done nothing when add a device, then nothing
need to be cleanup when remove it.

I'm not sure if it's a good idea, but seems like the idea is use twice
check on different level to save some cycles?

Regards,
Michael Wang
>
> Jason

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

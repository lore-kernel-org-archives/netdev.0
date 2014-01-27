From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] net: hyperv: initialize link status correctly
Date: Mon, 27 Jan 2014 18:37:14 +0800
Message-ID: <52E636DA.4030406@redhat.com>
References: <1390807854-4469-1-git-send-email-jasowang@redhat.com>		
 <20140127.003559.2290408024387922847.davem@davemloft.net>		
 <52E629A8.5010302@redhat.com>	
 <1390818121.2735.130.camel@deadeye.wl.decadent.org.uk>	
 <52E634DA.3040200@redhat.com>
 <1390818638.2735.136.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
 David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1390818638.2735.136.camel@deadeye.wl.decadent.org.uk>
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

On 01/27/2014 06:30 PM, Ben Hutchings wrote:
> On Mon, 2014-01-27 at 18:28 +0800, Jason Wang wrote:
>> On 01/27/2014 06:22 PM, Ben Hutchings wrote:
>>> On Mon, 2014-01-27 at 17:40 +0800, Jason Wang wrote:
>>>> On 01/27/2014 04:35 PM, David Miller wrote:
>>>>> From: Jason Wang <jasowang@redhat.com>
>>>>> Date: Mon, 27 Jan 2014 15:30:54 +0800
>>>>>
>>>>>> Call netif_carrier_on() after register_device(). Otherwise it won't work since
>>>>>> the device was still in NETREG_UNINITIALIZED state.
>>>>>>
>>>>>> Fixes a68f9614614749727286f675d15f1e09d13cb54a
>>>>>> (hyperv: Fix race between probe and open calls)
>>>>>>
>>>>>> Cc: Haiyang Zhang <haiyangz@microsoft.com>
>>>>>> Cc: K. Y. Srinivasan <kys@microsoft.com>
>>>>>> Reported-by: Di Nie <dnie@redhat.com>
>>>>>> Tested-by: Di Nie <dnie@redhat.com>
>>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>>> A device up can occur at the moment you call register_netdevice(),
>>>>> therefore that up call can see the carrier as down and fail or
>>>>> similar.  So you really cannot resolve the carrier to be on in this
>>>>> way.
>>>> True, we need a workqueue to synchronize them.
>>> Whatever for?  All you need to do is:
>>>
>>> 	rtnl_lock();
>>> 	register_netdevice();
>>> 	netif_carrier_on();
>>> 	rtnl_unlock();
>>>
>>> It would be nice if we could make the current code work with a change in
>>> the core, though.
>>>
>>> Ben.
>>>
>> Looks like the link status interrupt may happen during this (after
>> netvsc_device_add() was called by rndis_filter_device_add()) without any
>> synchronization. This may lead a wrong link status here.
> Now I'm confused - if there's a link status interrupt, why are you
> setting the carrier on initially?
>
> Ben.
>

I realize that setting carrier on initially was a bug after David's
comment. So I think we need a workqueue.

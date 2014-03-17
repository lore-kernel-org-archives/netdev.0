From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: ensure pm_runtime cannot suspend the device during
 init
Date: Tue, 18 Mar 2014 02:09:29 +0300
Message-ID: <532780A9.3030005@cogentembedded.com>
References: <1395056275-5005-1-git-send-email-ben.dooks@codethink.co.uk> <2780951.47jzSPgHnH@avalon> <53277782.6070804@cogentembedded.com> <2182534.rxjU11HcCL@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben.dooks@codethink.co.uk>, linux-sh@vger.kernel.org,
	netdev@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2182534.rxjU11HcCL@avalon>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/18/2014 12:34 AM, Laurent Pinchart wrote:

>>>> The pm_rumtime work queue is causing the device to be suspended during
>>>> initialisation, thus the initialisation may not be able to access
>>>> registers properly. As the code is called from a work queue, it is
>>>> possible that this is not seen from certain configurations/builds due to
>>>> the asynchronos nature of the code.

>>>> Use pm_runtime_get_sync() and pm_runtime_put_sync() to ensure that the
>>>> pm system does not suspend it during the probe() call and remove the
>>>> now unnecessary pm_runtime_resume() call.

>>>> This fixes the external abort that can cause /sbin/init or other such
>>>> init processed to die.

>>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>>>> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
>>>> ---

>>>>    drivers/net/ethernet/renesas/sh_eth.c | 3 ++-
>>>>    1 file changed, 2 insertions(+), 1 deletion(-)

>>>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>>>> b/drivers/net/ethernet/renesas/sh_eth.c index 4f76b5e..f1cfd64 100644
>>>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>>>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>>>> @@ -2869,7 +2869,7 @@ static int sh_eth_drv_probe(struct platform_device
>>>> *pdev) spin_lock_init(&mdp->lock);
>>>>
>>>>    	mdp->pdev = pdev;
>>>>    	pm_runtime_enable(&pdev->dev);
>>>>
>>>> -	pm_runtime_resume(&pdev->dev);
>>>> +	pm_runtime_get_sync(&pdev->dev);

>>> Now that we've found out that the problem is caused by registering the
>>> network device before registering the mdio bus, shouldn't the proper
>>> solution be to register the network device last in the probe function ?

>> Unfortunately, it's not easy to do, as sh_mdio_init() uses net_device::dev.
>> Probably could get rid of that use by partly reverting my managed device API
>> patch since the only user seems to be devm_kzalloc() in that function, at
>> least I hope so... still looking into this.

> What about using pdev->dev instead ?

    Well, that seems possible too.

>> BTW, quite many drivers have the same problem, doing different things after
>> register_netdev() call, many of them probing MDIO as well.

> Great, that means more opportunities to fix bugs :-D

    For somebody else, maybe. My manager tells me not to spend time even on 
the 'sh_eth' driver... sigh.

WBR, Sergei


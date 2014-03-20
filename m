From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Thu, 20 Mar 2014 22:09:11 +0300
Message-ID: <532B3CD7.5050005@cogentembedded.com>
References: <1395336877-12402-1-git-send-email-ben.dooks@codethink.co.uk> <3894339.LtO9XLDneL@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, davem@davemloft.net
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:52100 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755574AbaCTSJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 14:09:17 -0400
Received: by mail-la0-f47.google.com with SMTP id y1so889159lam.6
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 11:09:15 -0700 (PDT)
In-Reply-To: <3894339.LtO9XLDneL@avalon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/20/2014 09:01 PM, Laurent Pinchart wrote:

>> The pm_rumtime work queue is causing the device to be suspended during
>> initialisation, thus the initialisation may not be able to access registers
>> properly. As the code is called from a work queue, it is possible that this
>> is not seen from certain configurations/builds due to the asynchronos
>> nature of the code.

>> Another issue has also been found where the network device registration
>> calls back into the driver thus causing further pm_runtime calls that
>> also caused issues with the MDIO bus code.

>> Use pm_runtime_get_sync() and pm_runtime_put() to ensure that the
>> pm system does not suspend it during the probe() call and remove the
>> now unnecessary pm_runtime_resume() call.

>> This fixes the external abort that can cause /sbin/init or other such
>> init processed to die.

>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

>> ---
>> Cc: sergei.shtylyov@cogentembedded.com
>> Cc: laurent.pinchart+renesas@ideasonboard.com
>> cc: netdev@vger.kernel.org

>> Note, Laurent this should probably be applied before your
>> current series as it may require changes to the exit sequence.

> Would you like me to include the patch in that series when I'll send a pull
> request ?

>> Fixes from v1:
>> 	- use pm_runtime_put() over pm_runtime_put_sync() as
>> 	  we do not need to guaranteed the device has powered
>>            off after probe.

>> Fixed from v2:
>> 	- call pm_runtime_put() in error path
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c | 7 +++++--
>>   1 file changed, 5 insertions(+), 2 deletions(-)

>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c index 4f76b5e..610da51 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
>> @@ -2976,6 +2978,7 @@ out_release:
>>   	if (ndev)
>>   		free_netdev(ndev);
>>
>> +	pm_runtime_put(&pdev->dev);

> Do we also need a pm_runtime_disable() here ?

    I've looked at other drivers and it looks like we do.

>>   out:
>>   	return ret;
>>   }

WBR, Sergei

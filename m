From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: Fix EPHY reset in power up
Date: Sat, 24 Sep 2016 05:55:35 +0900
Message-ID: <73230229-A16D-4692-8D34-ED45C29842F6@gmail.com>
References: <20160923132004.5734-1-jaedon.shin@gmail.com>
 <20160923140609.GA22965@lunn.ch>
 <5A71930B-ED19-4690-942D-779F1454C77A@gmail.com>
 <f68f0b8c-df49-1326-c05f-ddd7f95e4209@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.1 \(3243\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33669 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760834AbcIWUzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 16:55:39 -0400
Received: by mail-pf0-f176.google.com with SMTP id 21so45414072pfy.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 13:55:39 -0700 (PDT)
In-Reply-To: <f68f0b8c-df49-1326-c05f-ddd7f95e4209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

> On 24 Sep 2016, at 1:54 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
> On 09/23/2016 08:04 AM, Jaedon Shin wrote:
>> Hi Andrew,
>> 
>> On 23 Sep 2016, at 11:06 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>>> 
>>> On Fri, Sep 23, 2016 at 10:20:04PM +0900, Jaedon Shin wrote:
>>>> The bcmgenet_mii_reset() is always not running in power up sequence
>>>> after 'commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from
>>>> struct net_device")'. This'll show extremely high latency and duplicate
>>>> packets while interface down and up repeatedly.
>>>> 
>>>> For now, adds again a private phydev for mii reset when runs power up to
>>>> open interface.
>>> 
>>> Hi Jaedon
>>> 
>>> How does this fix the issue? It sounds like you are papering over the
>>> crack, not truly fixing it.
>>> 
>>>      Andrew
>> 
>> Yes, It feel like a workaround, but I think it must need v4.8 stable
>> version. If we find better way that fixes internal PHY to initialize
>> after re-open interface, this patch will be dropped.
> 
> I can observe the faulting behavior with 4.8-rc7 that the link below
> fixed initially:
> 
> # ping fainelli-linux
> PING fainelli-linux (10.112.156.244): 56 data bytes
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.352 ms
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.472 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.496 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.517 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.536 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=1.557 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=752.448 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=1.291 ms
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=1.421 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=1.444 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=1.464 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=1.483 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=1.505 ms (DUP!)
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=24.964 ms (DUP!)
> 
> If we revert this patch, we indeed get the normal and expected behavior
> back:
> 
> # ping fainelli-linux
> PING fainelli-linux (10.112.156.244): 56 data bytes
> 64 bytes from 10.112.156.244: seq=0 ttl=61 time=0.417 ms
> 64 bytes from 10.112.156.244: seq=1 ttl=61 time=0.415 ms
> 64 bytes from 10.112.156.244: seq=2 ttl=61 time=0.424 ms
> 
> Actually, the key thing is this:
> 
> - without Philippe's patch we call twice bcmgenet_mii_reset, and that is
> intended:
> 	- first time from bcmgenet_power_up() to make sure the PHY is
> initialized *before* we get to initialize the UniMAC, this is critical
> 	- second time from bcmgenet_mii_probe(), through the normal phy_init_hw()
> 
> - with Philippe's patch, we only get to call bcmgenet_mii_reset once, in
> bcmgenet_mii_probe() because the first time in bcmgenet_power_up(),
> dev->phydev is NULL, because of a prior call to phy_disconnect() in
> bcmgenet_close(), unfortunately, there has been MAC activity, so the PHY
> gets in a bad state
> 
> Jaedon, feel free to use the explanation above, and send a plain revert
> of commit 62469c76007e11428e2ee3c6de90cbe74b588d44.
> 

Will send revert patch.

Thanks,
Jaedon

> Thanks!
> 
> Thanks!
> -- 
> Florian

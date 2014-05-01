From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net phy: Check for aneg completion before setting state
 to PHY_RUNNING
Date: Wed, 30 Apr 2014 19:11:08 -0700
Message-ID: <CAGVrzcaVEWTm+wJa-G4O8ZTXGLA2WjCj2sfJAzfmKa+AhGrpoQ@mail.gmail.com>
References: <53587C7F.2000808@gmail.com> <CAGVrzcbrm3KO_=NSJz=KOAcPWvVUMm5kPM7nryJBag6BotKgoQ@mail.gmail.com>
 <CAHPKR9Ltie2shuJqdSKbQcVSKwMt-Q8XTfAJRn6gXxVs5fHRwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:60401 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaEACLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 22:11:48 -0400
Received: by mail-qc0-f180.google.com with SMTP id i17so2093344qcy.39
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 19:11:48 -0700 (PDT)
In-Reply-To: <CAHPKR9Ltie2shuJqdSKbQcVSKwMt-Q8XTfAJRn6gXxVs5fHRwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-24 22:53 GMT-07:00 Balakumaran Kannan <kumaran.4353@gmail.com>:
> On Fri, Apr 25, 2014 at 12:23 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> 2014-04-23 19:52 GMT-07:00 Balakumaran Kannan <kumaran.4353@gmail.com>:
>>> phy_state_machine should check whether auto-negotiatin is completed
>>> before changing phydev->state from PHY_NOLINK to PHY_RUNNING. If
>>> auto-negotiation is not completed phydev->state should be set to
>>> PHY_AN.
>>
>> I need some time to review this. Just out of curiosity, is this fixing
>> a bug you have encountered or was this found by state machine
>> inspection?
>
> Actually I encountered a problem that Linux-3.4 sends Neighbor Solicitation (NS)
> before hardware completes auto-negotiation. The driver being used for
> my hardware
> is smsc911x.
>
> While investigation on this, I came to know that state of phydev
> follows this sequence
> PHY_READY --> PHY_UP (in phy_start)
> PHY_UP --> PHY_AN (in phy_start_aneg called by phy_state_machine)
> PHY_AN --> PHY_NOLINK (in phy_state_machine. Link is down)
> PHY_NOLINK --> PHY_RUNNING (in phy_state_machine. Link becomes ready)
>
> So I felt that the sequence of PHY_AN --> PHY_RUNNING while link is up and
> PHY_NOLINK --> PHY_RUNNING are different. In the earlier case aneg completion
> is taken into account but not in later.

I see, we should indeed go back to PHY_AN

>
> But this patch doesn't fix my problem. I made the smsc driver's open function to
> poll on phy_aneg_done until auto-negotiation completes.
>
> Here I have a doubt.
>  * Linux network initialization and phy_state_machine runs in separate threads.
>  * And driver doesn't bother about state of phydev.
> Is it correct?

That is correct, once your driver calls phy_start(), the PHY state
machine executes in the background within the context of a separate
workqueue.

> Doesn't driver need to confirm phydev is ready(PHY_RUNNING) before
> returning to kernel?

phy_start() really starts the PHY state machine, but does not block
until the PHY is in the PHY_RUNNING state, which is something that
might never happen if e.g: the cable is disconnected.

What really tells the network stack whether the link is ready, is when
the PHY state machine calls netif_carrier_on().
-- 
Florian

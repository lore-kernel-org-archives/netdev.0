From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH] net phy: Check for aneg completion before setting state
 to PHY_RUNNING
Date: Fri, 25 Apr 2014 11:23:03 +0530
Message-ID: <CAHPKR9Ltie2shuJqdSKbQcVSKwMt-Q8XTfAJRn6gXxVs5fHRwA@mail.gmail.com>
References: <53587C7F.2000808@gmail.com>
	<CAGVrzcbrm3KO_=NSJz=KOAcPWvVUMm5kPM7nryJBag6BotKgoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:43956 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaDYFxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 01:53:04 -0400
Received: by mail-wi0-f177.google.com with SMTP id cc10so2122924wib.16
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 22:53:03 -0700 (PDT)
In-Reply-To: <CAGVrzcbrm3KO_=NSJz=KOAcPWvVUMm5kPM7nryJBag6BotKgoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 12:23 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-04-23 19:52 GMT-07:00 Balakumaran Kannan <kumaran.4353@gmail.com>:
>> phy_state_machine should check whether auto-negotiatin is completed
>> before changing phydev->state from PHY_NOLINK to PHY_RUNNING. If
>> auto-negotiation is not completed phydev->state should be set to
>> PHY_AN.
>
> I need some time to review this. Just out of curiosity, is this fixing
> a bug you have encountered or was this found by state machine
> inspection?

Actually I encountered a problem that Linux-3.4 sends Neighbor Solicitation (NS)
before hardware completes auto-negotiation. The driver being used for
my hardware
is smsc911x.

While investigation on this, I came to know that state of phydev
follows this sequence
PHY_READY --> PHY_UP (in phy_start)
PHY_UP --> PHY_AN (in phy_start_aneg called by phy_state_machine)
PHY_AN --> PHY_NOLINK (in phy_state_machine. Link is down)
PHY_NOLINK --> PHY_RUNNING (in phy_state_machine. Link becomes ready)

So I felt that the sequence of PHY_AN --> PHY_RUNNING while link is up and
PHY_NOLINK --> PHY_RUNNING are different. In the earlier case aneg completion
is taken into account but not in later.

But this patch doesn't fix my problem. I made the smsc driver's open function to
poll on phy_aneg_done until auto-negotiation completes.

Here I have a doubt.
 * Linux network initialization and phy_state_machine runs in separate threads.
 * And driver doesn't bother about state of phydev.
Is it correct?
Doesn't driver need to confirm phydev is ready(PHY_RUNNING) before
returning to kernel?

Regards,
K.Balakumaran

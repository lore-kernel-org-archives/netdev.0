From: Bhadram Varka <vbhadram@nvidia.com>
Subject: RE: netdev carrier changes is one even after ethernet link up.
Date: Mon, 4 Sep 2017 05:07:40 +0000
Message-ID: <67a9f7aa73f348558b2b3f097d2c040f@bgmail102.nvidia.com>
References: <974898714b3e4e59b933983ded977ce2@bgmail102.nvidia.com>
 <25c3b4ca-02d7-e217-fe27-ca3b7d2cbf07@gmail.com>
 <cd860399cf9148d193a08636a6d82a68@DRBGMAIL102.nvidia.com>
 <a7bf6cf0-c534-95f9-47f6-ee56a95fe961@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:18085 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdIDFIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 01:08:13 -0400
In-Reply-To: <a7bf6cf0-c534-95f9-47f6-ee56a95fe961@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Saturday, September 02, 2017 7:25 AM
> To: Bhadram Varka <vbhadram@nvidia.com>; andrew@lunn.ch
> Cc: linux-netdev <netdev@vger.kernel.org>
> Subject: Re: netdev carrier changes is one even after ethernet link up.
> 
> On 08/31/2017 10:49 PM, Bhadram Varka wrote:
> > Thanks for responding. Now responding inline
> >
> >> -----Original Message-----
> >> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> >> Sent: Friday, September 01, 2017 5:53 AM
> >> To: Bhadram Varka <vbhadram@nvidia.com>; andrew@lunn.ch
> >> Cc: linux-netdev <netdev@vger.kernel.org>
> >> Subject: Re: netdev carrier changes is one even after ethernet link up.
> >>
> >> On 08/30/2017 10:53 PM, Bhadram Varka wrote:
> >>> Hi,
> >>>
> >>>
> >>>
> >>> I have observed that carrier_changes is one even in case of the
> >>> ethernet link is up.
> >>>
> >>>
> >>>
> >>> After investigating the code below is my observation -
> >>>
> >>>
> >>>
> >>> ethernet_driver_probe()
> >>>
> >>> +--->phy_connect()
> >>>
> >>> |     +--->phy_attach_direct()
> >>>
> >>> |           +---> netif_carrier_off()    : which increments
> >>> carrier_changes to one.
> >>>
> >>> +--->register_netdevice() : will the carrier_changes becomes zero here ?
> >>>
> >>> +--->netif_carrier_off(): not increment the carrier_changes since
> >>> __LINK_STATE_NOCARRIER already set.
> >>>
> >>>
> >>>
> >>> From ethernet driver open will start the PHY and trigger the
> >>> phy_state_machine.
> >>>
> >>> Phy_state_machine workqueue calling netif_carrier_on() once the link
> >>> is
> >> UP.
> >>>
> >>> netif_carrier_on() increments the carrier_changes by one.
> >>
> >> If the call trace is correct, then there is at least two problems here:
> >>
> >> - phy_connect() does start the PHY machine which means that as soon
> >> as it detects a link state of any kind (up or down) it can call
> >> netif_carrier_off() respectively netif_carrier_on()
> >>
> >> - as soon as you call register_netdevice() notifiers run and other
> >> parts of the kernel or user-space programs can see an inconsistent
> >> link state
> >>
> >> I would suggest doing the following sequence instead:
> >>
> >> netif_carrier_off()
> >> register_netdevice()
> >> phy_connect()
> >>
> >> Which should result in a consistent link state and carrier value.
> >>
> > Yes, It will address the issue.
> >
> > If we did the phy_conect in ndo_open it will make the carrier changes as
> two. But if we did in probe function then it's not working.
> >
> > In ethernet driver probe - (below sequence is not working)
> > phy_connect()
> > register_netdevice()
> > netif_carrier_off()
> >
> > working sequence:
> > In probe():
> > register_netdevice()
> > ndo_open:
> >            phy_connect()
> >
> > After reverting - https://lkml.org/lkml/2016/1/9/173 this works if we do
> phy_connect in probe as well.
> 
> But as mentioned before you should not be doing the PHY probe in your
> driver's probe function for different reasons:
> 
> - the probe function's responsibility is to initialize the driver and the HW to a
> state where they both have everything needed but it should be in quiesced
> state. There is no guarantee that your network device may ever be used
> after probe unless something calls ndo_open(), you should therefore keep
> all resources to a minimum: memory allocated, HW powered down etc.
> 
> - there is a race condition between the PHY state machine started in
> phy_connect(), and when register_netdevice() is called and notifiers running
> which can lead to an inconsistent state for the carrier
> 
Agreed. But I could see lot of drivers performing the phy_connect() in driver_probe() function itself. 
Also observed that these drivers are performing netif_carrier_off() after register_netdevice().

My point is that we do we need to do netif_carrier_off() in phy_connect since we already doing the same after register_netdevice() ?

Thanks!
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

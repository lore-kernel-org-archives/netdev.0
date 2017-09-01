From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: netdev carrier changes is one even after ethernet link up.
Date: Thu, 31 Aug 2017 17:23:00 -0700
Message-ID: <25c3b4ca-02d7-e217-fe27-ca3b7d2cbf07@gmail.com>
References: <974898714b3e4e59b933983ded977ce2@bgmail102.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Bhadram Varka <vbhadram@nvidia.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:33850 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdIAAXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 20:23:07 -0400
Received: by mail-wr0-f182.google.com with SMTP id z91so2824867wrc.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 17:23:06 -0700 (PDT)
In-Reply-To: <974898714b3e4e59b933983ded977ce2@bgmail102.nvidia.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2017 10:53 PM, Bhadram Varka wrote:
> Hi,
> 
>  
> 
> I have observed that carrier_changes is one even in case of the ethernet
> link is up.
> 
>  
> 
> After investigating the code below is my observation –
> 
>  
> 
> ethernet_driver_probe()
> 
> +--->phy_connect()
> 
> |     +--->phy_attach_direct()
> 
> |           +---> netif_carrier_off()    : which increments
> carrier_changes to one.
> 
> +--->register_netdevice() : will the carrier_changes becomes zero here ?
> 
> +--->netif_carrier_off(): not increment the carrier_changes since
> __LINK_STATE_NOCARRIER already set.
> 
>  
> 
> From ethernet driver open will start the PHY and trigger the
> phy_state_machine.
> 
> Phy_state_machine workqueue calling netif_carrier_on() once the link is UP.
> 
> netif_carrier_on() increments the carrier_changes by one.

If the call trace is correct, then there is at least two problems here:

- phy_connect() does start the PHY machine which means that as soon as
it detects a link state of any kind (up or down) it can call
netif_carrier_off() respectively netif_carrier_on()

- as soon as you call register_netdevice() notifiers run and other parts
of the kernel or user-space programs can see an inconsistent link state

I would suggest doing the following sequence instead:

netif_carrier_off()
register_netdevice()
phy_connect()

Which should result in a consistent link state and carrier value.

> 
>  
> 
> After link is UP if we check the carrier_changes sysfs node - it will be
> one only.
> 
>  
> 
> $ cat /sys/class/net/eth0/carrier_changes
> 
> 1
> 
>  
> 
> After reverting the change - https://lkml.org/lkml/2016/1/9/173 (net:
> phy: turn carrier off on phy attach) then I could see the carrier
> changes incremented to 2 after Link UP.
> 
> $ cat /sys/class/net/eth0/carrier_changes
> 
> 2
> 
>  
> 
> Thanks,
> 
> Bhadram.
> 
> ------------------------------------------------------------------------
> This email message is for the sole use of the intended recipient(s) and
> may contain confidential information.  Any unauthorized review, use,
> disclosure or distribution is prohibited.  If you are not the intended
> recipient, please contact the sender by reply email and destroy all
> copies of the original message.
> ------------------------------------------------------------------------


-- 
Florian

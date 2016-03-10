From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Micrel Phy - Is there a way to configure the Phy not to do 802.3x
 flow control?
Date: Thu, 10 Mar 2016 17:51:09 -0500
Message-ID: <56E1FA5D.9090003@ti.com>
References: <56D8B83E.7000303@ti.com> <56D8D3D7.6070900@gmail.com>
 <56E1A55F.3090906@ti.com> <56E1B75F.9070100@gmail.com>
 <56E1CD4D.20405@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <johan@kernel.org>,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:36517 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089AbcCJWvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 17:51:09 -0500
In-Reply-To: <56E1CD4D.20405@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2016 02:38 PM, Murali Karicheri wrote:
> On 03/10/2016 01:05 PM, Florian Fainelli wrote:
>> On 10/03/16 08:48, Murali Karicheri wrote:
>>> On 03/03/2016 07:16 PM, Florian Fainelli wrote:
>>>> On 03/03/16 14:18, Murali Karicheri wrote:
>>>>> Hi,
>>>>>
>>>>> We are using Micrel Phy in one of our board and wondering if we can force the
>>>>> Phy to disable flow control at start. I have a 1G ethernet switch connected
>>>>> to Phy and the phy always enable flow control. I would like to configure the
>>>>> phy not to flow control. Is that possible and if yes, what should I do in the
>>>>> my Ethernet driver to tell the Phy not to enable flow control?
>>>>
>>>> The PHY is not doing flow control per-se, your pseudo Ethernet MAC in
>>>> the switch is doing, along with the link partner advertising support for
>>>> it. You would want to make sure that your PHY device interface (provided
>>>> that you are using the PHY library) is not starting with Pause
>>>> advertised, but it could be supported.
>>>
>>> Understood that Phy is just advertise FC. The Micrel phy for 9031 advertise
>>> by default FC supported. After negotiation, I see that Phylib provide the 
>>> link status with parameter pause = 1, asym_pause = 1. How do I tell the Phy not
>>> to advertise?
>>>
>>> I call following sequence in the Ethernet driver.
>>>
>>> of_phy_connect(x,y,hndlr,a,z);
>>
>> Here you should be able to change phydev->advertising and
>> phydev->supported to mask the ADVERTISED_Pause | ADVERTISED_AsymPause
>> bits and have phy_start() restart with that which should disable pause
>> and asym_pause as seen by your adjust_link handler.
>>
> Ok. Good point. I will try this. Thanks for your suggestion.
> 

I made following changes. The phylib still report flow control enabled to
the driver. Some bug in the phylib/phydev?

+
+               printk("slave->phy->supported %x, slave->phy->advertising %x\n",
+                       slave->phy->supported, slave->phy->advertising);
+               slave->phy->supported &=
+                               ~(SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+               slave->phy->advertising = slave->phy->supported;
+               printk("slave->phy->supported %x, slave->phy->advertising %x\n",
+                       slave->phy->supported, slave->phy->advertising);
                phy_start(slave->phy);
+               printk("slave->phy->supported %x, slave->phy->advertising %x\n",
+                       slave->phy->supported, slave->phy->advertising);
                phy_read_status(slave->phy);


[   10.757001] slave->phy->supported 22ff, slave->phy->advertising 22ff
[   10.763354] slave->phy->supported 2ff, slave->phy->advertising 2ff
[   10.769552] slave->phy->supported 2ff, slave->phy->advertising 2ff
[   10.776045] netcp-1.0 2620110.netcp eth0: Link is Down
udhcpc (v1.23.1) started
Sending discover...
Sending discover...
[   14.757280] netcp-1.0 2620110.netcp eth0: Link is Up - 1Gbps/Full - flow control rx/tx
Sending discover...
Sending select for 158.218.103.170...
Lease of 158.218.103.170 obtained, lease time 28800
/etc/udhcpc.d/50default: Adding DNS 192.0.2.2
/etc/udhcpc.d/50default: Adding DNS 192.0.2.3


> Murali
>>> phy_start()
>>>
>>> Now in hndlr() I have pause = 1, asym_pause = 1, in phy_device ptr. How can 
>>> I tell the phy not to advertise initially?
> 
> 


-- 
Murali Karicheri
Linux Kernel, Keystone

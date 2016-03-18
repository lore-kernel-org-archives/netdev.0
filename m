From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Micrel Phy - Is there a way to configure the Phy not to do 802.3x
 flow control?
Date: Thu, 17 Mar 2016 17:10:10 -0700
Message-ID: <56EB4762.109@gmail.com>
References: <56D8B83E.7000303@ti.com> <56D8D3D7.6070900@gmail.com>
 <56E1A55F.3090906@ti.com> <56E1B75F.9070100@gmail.com>
 <56E1CD4D.20405@ti.com> <56E30EE5.4050904@ti.com>
 <56E321DE.9030408@gmail.com> <56E976DE.9040000@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Murali Karicheri <m-karicheri2@ti.com>, johan@kernel.org,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>, Andrew Lunn <andrew@lunn.ch>,
	opendmb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35227 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967113AbcCRALu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 20:11:50 -0400
Received: by mail-pf0-f181.google.com with SMTP id n5so141704447pfn.2
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 17:11:50 -0700 (PDT)
In-Reply-To: <56E976DE.9040000@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 16, 2016 8:08:14 AM PDT, Murali Karicheri
>> What it means before your patch is that flow control is reported to
>the
>> PHY device if the link partner advertises that, with your patch
>applied,
>> it is reported only if the link partner and yourself advertise flow
>control.
>> 
>> You seem to be willing to have phydev->pause and phydev->asym_pause
>> reflect the resolved pause capability, as opposed to the link
>partner's
>> pause capability, which I am not convinced is correct here, because
>we
>> need to take into account the user-configured pause configuration as
>> well. Your adjust_link function should be the one deciding whether
>pause
>> frame advertising and enabling is appropriate based on: locally
>> configured pause settings (enabled, disabled, autoneg) and the link
>> partner's pause capability.
>> 
>> I do agree that the two fields are confusing and poorly documented,
>and
>> we should probably be consolidating the pause frame behavior in
>PHYLIB
>> as opposed to letting drivers deal with like e.g: gianfar,
>bcm63xx_enet,
>> tg3 etc.
>> 
>>>  
>>> Could you explain, why the common maximum capability is not reported
>to the
>>> driver as per standard?? Or Am I understood it wrong?
>> 
>> I do not understand the question, what is "maximum capability" in
>that
>> context and what standard are you refering to?
>> 
>I assume the Phylib is responsible for deciding what is the flow
>control pause and asym pause status to the driver through adjust_link.

Not exclusively, the Ethernet MAC driver is responsible for getting the
full picture: whether pause frames need to be advertised, enabled
locally and supported by the link partner. PHYLIB helps with the later
since the former may come from ethtool:: get_pauseparam and need to
program MAC specific registers within the adjust_link callback.

>When driver starts the phy, it also tells its capabilities (for example
>it can reset some of the capabilities available in the Phy driver. In
>this
>particular case, Pause is a feature supported by Micrel phy. I have
>reset
>this feature in my driver by resetting this feature bit in the
>phy_device
>as suggested earlier in this discussion). So phylib has all knowledge
>available to disable flow control in this scenario even if LP is
>capable
>of flow control. Wondering why every driver has to take this decision
>again to enable or disable flow control instead of telling the driver
>what to do. 

PHYLIB still misses the MAC driver decisions like whether pause frames
are to be enabled by default through autoneg or manually enforced via an
user, which is why it reports what the link partner's pause capability
so as to get your driver to be able to make the right decisions here.


>
>Looks like Marvel driver (reproduced below) does this logic. I think
>the
>802.3x flow control states, but I don't have access to the standard
>documentation.
>However I find the documentation at 
>http://www.studioreti.it/slide/08_SwFlowContr_E_A.pdf.
>
>Page 17 states the behavior based on Local device & Link partner's 
>capabilities. Probably adjust_link() should tell the outcome in pause
>and asym_pause so that driver can enable/disable fc. Also user's action
>to be taken into account as well so that fc can be disabled if desired.
>
>Code from drivers/net/phy/marvel.c


Well, thanks for poing that piece of code, that seems to be duplicating
a bit of what genphy_read_status() is already doing.

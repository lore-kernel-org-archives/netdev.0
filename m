From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/8] net: dsa: mv88e6xxx: do not increment bus refcount
Date: Fri, 10 Jun 2016 15:59:22 -0400
Message-ID: <87k2hwq0h1.fsf@ketchup.mtl.sfl>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com> <20160609004456.5441-5-vivien.didelot@savoirfairelinux.com> <20160609023641.GJ2227@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:60159 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbcFJT71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 15:59:27 -0400
In-Reply-To: <20160609023641.GJ2227@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Andrew Lunn <andrew@lunn.ch> writes:

> On Wed, Jun 08, 2016 at 08:44:52PM -0400, Vivien Didelot wrote:
>> The MDIO device probe and remove functions are respectively incrementing
>> and decrementing the bus refcount themselves. Since these bus level
>> actions are out of the device scope, remove them.
>
> I agree with the patch. But have you checked the mdio layer is doing
> the right thing? If not, we should fix that first.

So I added some printing after incrementing/decrementing the refcount in
get_device/put_device to track &ps->bus->dev, which name is "0.1".

Regardless having this patch or not, the refcount of the 0.1 mii_bus
device is 5 before loading the mv88e6xxx module on vf610-zii-dev-rev-b.

Below is a portion of dmesg:

    [    8.921647] get_device: 400d1000.etherne refcount: 4
    [    8.926225] get_device: 0.1 refcount: 2
    [    8.929561] get_device: mdio-mux refcount: 5
    [    8.934076] get_device: 0.1 refcount: 3
    [    8.937446] get_device: 0.1 refcount: 4
    [    8.940792] put_device: 0.1 refcount: 3
    [    8.944181] libphy: mdio_mux: probed
    [    8.947885] mdio_bus 0.1:00: mdio_device_register
    [    8.952649] get_device: 0.1:00 refcount: 2
    [    8.956283] get_device: 0.1 refcount: 4
    [    8.959838] get_device: 0.1:00 refcount: 3
    [    8.963991] get_device: 0.1:00 refcount: 4
    [    8.967598] put_device: 0.1:00 refcount: 3
    [    8.971298] get_device: 0.2 refcount: 2
    [    8.974687] get_device: mdio-mux refcount: 7

So it seems like of_ is managing the bus refcount on events such as a
new child node (0.1:00).

Thanks,

        Vivien

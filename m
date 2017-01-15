From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to
 device_find_class()
Date: Sun, 15 Jan 2017 09:27:22 -0800
Message-ID: <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:33953 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdAOR1Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 12:27:25 -0500
In-Reply-To: <20170115110628.GF26374@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/15/2017 03:06 AM, Greg KH wrote:
> On Sat, Jan 14, 2017 at 01:47:09PM -0800, Florian Fainelli wrote:
>> Now that the base device driver code provides an identical
>> implementation of dev_find_class() utilize device_find_class() instead
>> of our own version of it.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  net/dsa/dsa.c | 22 ++--------------------
>>  1 file changed, 2 insertions(+), 20 deletions(-)
>>
>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>> index 2306d1b87c83..77fa4c4f5828 100644
>> --- a/net/dsa/dsa.c
>> +++ b/net/dsa/dsa.c
>> @@ -455,29 +455,11 @@ EXPORT_SYMBOL_GPL(dsa_switch_resume);
>>  #endif
>>  
>>  /* platform driver init and cleanup *****************************************/
>> -static int dev_is_class(struct device *dev, void *class)
>> -{
>> -	if (dev->class != NULL && !strcmp(dev->class->name, class))
>> -		return 1;
>> -
>> -	return 0;
>> -}
>> -
>> -static struct device *dev_find_class(struct device *parent, char *class)
>> -{
>> -	if (dev_is_class(parent, class)) {
>> -		get_device(parent);
>> -		return parent;
>> -	}
>> -
>> -	return device_find_child(parent, class, dev_is_class);
>> -}
>> -
>>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
>>  {
>>  	struct device *d;
>>  
>> -	d = dev_find_class(dev, "mdio_bus");
>> +	d = device_find_class(dev, "mdio_bus");
>>  	if (d != NULL) {
>>  		struct mii_bus *bus;
> 
> You want a peer of your device on a specific class?  What is this for?

It's not a peer of our device, it's a separate device reference from the
one looked up in the "net" class. In the classic, and now deprecated DSA
device driver model, a "dsa" platform device would represent one or more
Ethernet switches, connected via a MDIO bus (this reference above), and
one Ethernet device (the CPU/host/management interface). This was
completely violating the Linux device driver model and imposed
limitations on what bus would be used, and we did not have proper struct
device references (therefore no adequate hierarchy either).

Thanks to the work of Andrew, we now have proper MDIO, SPI, GPIO, I2C,
PCI, platform and drivers that allow us to register with DSA as a
specialized kind of device (so we are now finally using the right Linux
Device Driver model). What we still need though, in order to our switch
to the networking stack is a reference to the master/host network device
since we mangle packets in and out of it.

> 
>> @@ -495,7 +477,7 @@ static struct net_device *dev_to_net_device(struct device *dev)
>>  {
>>  	struct device *d;
>>  
>> -	d = dev_find_class(dev, "net");
>> +	d = device_find_class(dev, "net");
>>  	if (d != NULL) {
>>  		struct net_device *nd;
> 
> Again, huh?  What is the device heirachy here that is so odd that this
> type of function is needed?

An Ethernet switch managed by DSA needs to have one ore more references
to a host/CPU/management network interface, this is what this struct
device reference is here for.

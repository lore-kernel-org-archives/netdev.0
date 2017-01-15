From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to device_find_class()
Date: Sun, 15 Jan 2017 09:52:16 -0800
Message-ID: <a9ea1f45-b9a5-d840-68e0-9bf9bc7a6598@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
 <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
 <20170115173949.GA19268@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Russell King <linux@armlinux.org.uk>, open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM SUB-ARCHITECTURES" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170115173949.GA19268@kroah.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 01/15/2017 09:39 AM, Greg KH wrote:
> On Sun, Jan 15, 2017 at 09:27:22AM -0800, Florian Fainelli wrote:
>>
>>
>> On 01/15/2017 03:06 AM, Greg KH wrote:
>>> On Sat, Jan 14, 2017 at 01:47:09PM -0800, Florian Fainelli wrote:
>>>> Now that the base device driver code provides an identical
>>>> implementation of dev_find_class() utilize device_find_class() instead
>>>> of our own version of it.
>>>>
>>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>>> ---
>>>>  net/dsa/dsa.c | 22 ++--------------------
>>>>  1 file changed, 2 insertions(+), 20 deletions(-)
>>>>
>>>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>>>> index 2306d1b87c83..77fa4c4f5828 100644
>>>> --- a/net/dsa/dsa.c
>>>> +++ b/net/dsa/dsa.c
>>>> @@ -455,29 +455,11 @@ EXPORT_SYMBOL_GPL(dsa_switch_resume);
>>>>  #endif
>>>>  
>>>>  /* platform driver init and cleanup *****************************************/
>>>> -static int dev_is_class(struct device *dev, void *class)
>>>> -{
>>>> -	if (dev->class != NULL && !strcmp(dev->class->name, class))
>>>> -		return 1;
>>>> -
>>>> -	return 0;
>>>> -}
>>>> -
>>>> -static struct device *dev_find_class(struct device *parent, char *class)
>>>> -{
>>>> -	if (dev_is_class(parent, class)) {
>>>> -		get_device(parent);
>>>> -		return parent;
>>>> -	}
>>>> -
>>>> -	return device_find_child(parent, class, dev_is_class);
>>>> -}
>>>> -
>>>>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
>>>>  {
>>>>  	struct device *d;
>>>>  
>>>> -	d = dev_find_class(dev, "mdio_bus");
>>>> +	d = device_find_class(dev, "mdio_bus");
>>>>  	if (d != NULL) {
>>>>  		struct mii_bus *bus;
>>>
>>> You want a peer of your device on a specific class?  What is this for?
>>
>> It's not a peer of our device, it's a separate device reference from the
>> one looked up in the "net" class. In the classic, and now deprecated DSA
>> device driver model, a "dsa" platform device would represent one or more
>> Ethernet switches, connected via a MDIO bus (this reference above), and
>> one Ethernet device (the CPU/host/management interface). This was
>> completely violating the Linux device driver model and imposed
>> limitations on what bus would be used, and we did not have proper struct
>> device references (therefore no adequate hierarchy either).
>>
>> Thanks to the work of Andrew, we now have proper MDIO, SPI, GPIO, I2C,
>> PCI, platform and drivers that allow us to register with DSA as a
>> specialized kind of device (so we are now finally using the right Linux
>> Device Driver model). What we still need though, in order to our switch
>> to the networking stack is a reference to the master/host network device
>> since we mangle packets in and out of it.
> 
> Ok, but where in the tree are you trying to find this other device?  Are
> you just going to randomly find any device that happens to be of the
> specific class type?  That seems really fragile and broken :(

The search is not really random, since the platform data for the DSA
switch we want to register gives us a reference to a device registered
via any bus type, and we know (by contract it has to) that it has to
provide a network device of some kind, we do a specific search in the
"net" class for that purpose. I agree this is not great.

> 
> You should NEVER have to walk the device tree to find stuff.  Why can't
> you have a pointer to the device you need to talk to some other way?

We do, I think the existing code just tries to be extra careful here and
make sure that the device reference we got is actually part of the "net"
class, indicating that the reference passed is indeed pointing to a
network device, and not a random device.

> 
> What exactly is the relationship between these devices (a ascii-art tree
> or sysfs tree output might be nice) so I can try to understand what is
> going on here.

OK, let me try and let's take the case of only one Ethernet switch in
the system for all simplicity:

- switch device drivers get probed by any kind of bus allocate and
register a dsa_switch with dsa_register_switch()

- this switch device has platform data (struct dsa_chip_data) that
describes its port layout (number of ports mostly) and has one struct
device references to which Ethernet network interface these ports connect to

- a dsa_switch_tree is created, this struct dsa_switch is attached to
the dsa_switch_tree at position 0 in the tree, we invoke a bunch of
switch driver operations

- we conclude with attaching this dsa_switch_tree to the network device
we looked up and assigning the tree to the dsa_ptr member

Documentation/networking/dsa/dsa.txt has some ascii art drawing that
sort of capture what is going on.
-- 
Florian

From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Sun, 22 Feb 2015 22:19:38 -0800
Message-ID: <54EAC67A.3040906@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com> <54EA8E7C.90401@roeck-us.net> <20150223031447.GA19267@lunn.ch> <54EAA767.6060105@roeck-us.net> <20150223042220.GA20063@lunn.ch> <54EAAEBC.6080609@roeck-us.net> <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:59498 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbBWGUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 01:20:15 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPmNJ-004FwJ-EY
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 06:20:13 +0000
In-Reply-To: <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2015 08:43 PM, Florian Fainelli wrote:
> 2015-02-22 20:38 GMT-08:00 Guenter Roeck <linux@roeck-us.net>:
>> On 02/22/2015 08:22 PM, Andrew Lunn wrote:
>>>
>>> On Sun, Feb 22, 2015 at 08:07:03PM -0800, Guenter Roeck wrote:
>>>>
>>>> On 02/22/2015 07:14 PM, Andrew Lunn wrote:
>>>>>
>>>>> On Sun, Feb 22, 2015 at 06:20:44PM -0800, Guenter Roeck wrote:
>>>>>>
>>>>>> On 02/17/2015 11:26 AM, Florian Fainelli wrote:
>>>>>>>
>>>>>>> In order to support bridging offloads in DSA switch drivers, select
>>>>>>> NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
>>>>>>> NDOs that we are required to implement.
>>>>>>>
>>>>>>> To facilitate the integratation at the DSA driver level, we implement
>>>>>>> 3
>>>>>>> types of operations:
>>>>>>>
>>>>>>
>>>>>> Hi Florian,
>>>>>>
>>>>>>>
>>>>>>> +/* Return a bitmask of all ports being currently bridged. Note that
>>>>>>> on
>>>>>>> + * leave, the mask will still return the bitmask of ports currently
>>>>>>> bridged,
>>>>>>> + * prior to port removal, and this is exactly what we want.
>>>>>>> + */
>>>>>>> +static u32 dsa_slave_br_port_mask(struct dsa_switch *ds)
>>>>>>> +{
>>>>>>> +       unsigned int port;
>>>>>>> +       u32 mask = 0;
>>>>>>> +
>>>>>>> +       for (port = 0; port < DSA_MAX_PORTS; port++) {
>>>>>>> +               if (!((1 << port) & ds->phys_port_mask))
>>>>>>> +                       continue;
>>>>>>> +
>>>>>>> +               if (ds->ports[port]->priv_flags & IFF_BRIDGE_PORT)
>>>>>>> +                       mask |= 1 << port;
>>>>>>
>>>>>>
>>>>>> Problem is that the function can be called through
>>>>>> dsa_slave_netdevice_event
>>>>>> before the slave devices are fully initialized.
>>>>>>
>>>>>> After adding
>>>>>>
>>>>>> +               if (!ds->ports[port]) {
>>>>>> +                       netdev_err(bridge,
>>>>>> +                                  "No ports data for port %d,
>>>>>> mask=0x%x\n",
>>>>>> +                                  port, ds->phys_port_mask);
>>>>>> +                       continue;
>>>>>> +               }
>>>>>>
>>>>>> and with some more debug messages added to dsa_switch_setup(), I see
>>>>>> the following.
>>>>>>
>>>>>> [   14.187290] e1000e 0000:00:19.0 em1: [0]: Creating slave device for
>>>>>> port 1(port1)
>>>>>> [   14.272605] e1000e 0000:00:19.0 em1: [0]: Creating slave device for
>>>>>> port 2(port2)
>>>>>> [   14.353118] e1000e 0000:00:19.0 em1: [0]: Creating slave device for
>>>>>> port 3(port3)
>>>>>> [   14.472002] br0: No ports data for port 3, mask=0x1e
>>>>>> [   14.472053] br0: No ports data for port 4, mask=0x1e
>>>>>> [   14.472753] e1000e 0000:00:19.0 em1: [0]: Creating slave device for
>>>>>> port 4(host2esb)
>>>>>>
>>>>>> This happens if I add the bridge configuration to
>>>>>> /etc/network/interfaces instead
>>>>>> of creating the bridge manually. Apparently dsa_switch_setup() is not
>>>>>> yet complete
>>>>>> when dsa_slave_netdevice_event is executed to handle a state change on
>>>>>> one of its
>>>>>> newly created slave interfaces.
>>>>>>
>>>>>> The relevant information from /etc/network/interfaces is:
>>>>>>
>>>>>> auto br0
>>>>>>
>>>>>> iface port1 inet manual
>>>>>> iface port2 inet manual
>>>>>>
>>>>>> iface br0 inet dhcp
>>>>>>          bridge_ports port1 port2
>>>>>
>>>>>
>>>>> Hi Guenter
>>>>>
>>>>> Does this actually matter? The ports which don't exists yet are not
>>>>> being added to the bridge. The mask will come out correct. What
>>>>> happens when port4 is made a member of the bridge? I expect it
>>>>> works. It is the creation of the interface which triggers hotplug to
>>>>> read interfaces and add the interface to the port.
>>>>>
>>>>
>>>>          if (!ds->ports[port])
>>>>                  continue;
>>>>
>>>> might be an option. However, I am not sure that what you say is correct,
>>>> at least not strictly speaking. dsa_slave_create() returns the created
>>>> slave device, which is added to ds->ports[port] in dsa_switch_setup().
>>>> Since there is no protection in dsa_switch_setup(), there is no guarantee
>>>> that the callback doesn't happen prior to the initialization of
>>>> ds->ports[port]. So the above would leave a race condition, where the
>>>> port being added to the bridge _is_ one for which ds->ports[port] is
>>>> not yet initialized.
>>>
>>>
>>> Yes, you are correct, there is a race here.
>>>
>>>
>>>> Protecting the entire slave creation loop in dsa_switch_setup()
>>>> and using register_netdevice() in dsa_slave_create() solves the problem
>>>> as far as I can see, I just don't know if it is an acceptable solution.
>>>
>>>
>>> Or:
>>>
>>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>>> index 2173402d87e0..1aa120d6d0e4 100644
>>> --- a/net/dsa/dsa.c
>>> +++ b/net/dsa/dsa.c
>>> @@ -325,8 +325,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int
>>> index,
>>>                                      index, i, pd->port_names[i]);
>>>                           continue;
>>>                   }
>>> -
>>> -               ds->ports[i] = slave_dev;
>>>           }
>>>
>>>    #ifdef CONFIG_NET_DSA_HWMON
>>> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>>> index f23deadf42a0..d6004072a957 100644
>>> --- a/net/dsa/slave.c
>>> +++ b/net/dsa/slave.c
>>> @@ -669,12 +669,14 @@ dsa_slave_create(struct dsa_switch *ds, struct
>>> device *parent,
>>>                   free_netdev(slave_dev);
>>>                   return NULL;
>>>           }
>>> +       ds->ports[port] = slave_dev;
>>>
>>>           ret = register_netdev(slave_dev);
>>>           if (ret) {
>>>                   netdev_err(master, "error %d registering interface %s\n",
>>>                              ret, slave_dev->name);
>>>                   phy_disconnect(p->phy);
>>> +               ds->ports[port] = NULL;
>>>                   free_netdev(slave_dev);
>>>                   return NULL;
>>>           }
>>>
>>> Not tested. But the point being, ensure everything is setup before
>>> calling register_netdev().
>>>
>>
>> That should work. I'll give it a try.
>
Looks like it works, with a couple of additional changes.
dsa_slave_create doesn't need to return slave_dev anymore,
and I still need to check if ds->ports[port] is NULL in
dsa_slave_br_port_mask.

> BTW, before I re-submit this patch series, do you think we should
> introduce a fdb_flush() callback that switch drivers are required to
> implement, and invoke it from net/dsa/slave.c upon port join/leave?
>

It also needs to be called for state changes. Right now I call it from
the driver code. I don't really have a strong opinion either way.

One caveat: state updates may be called with soft interrupts disabled,
meaning I can only schedule a state change but not directly execute it.
You don't see that in the sf2 code since you don't use mdio to talk
with the switch. This should probably be documented somewhere.

Guenter

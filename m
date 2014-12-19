From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port
 configuration
Date: Fri, 19 Dec 2014 09:25:36 +0100
Message-ID: <20141219082536.GD1848@nanopsycho.orion>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD9E53@IRSMSX108.ger.corp.intel.com>
 <5492EFC3.8030102@cumulusnetworks.com>
 <C4896FB061E7DE4AAC93031BDCA044B104ADA16F@IRSMSX108.ger.corp.intel.com>
 <549313B8.6050102@cumulusnetworks.com>
 <C4896FB061E7DE4AAC93031BDCA044B104ADA310@IRSMSX108.ger.corp.intel.com>
 <54931969.7040209@cumulusnetworks.com>
 <5493293A.2000802@intel.com>
 <54935E28.8050602@cumulusnetworks.com>
 <549362A5.3000808@intel.com>
 <549367CC.2080307@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Varlese, Marco" <marco.varlese@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <549367CC.2080307@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Dec 19, 2014 at 12:48:28AM CET, roopa@cumulusnetworks.com wrote:
>On 12/18/14, 3:26 PM, Samudrala, Sridhar wrote:
>>
>>On 12/18/2014 3:07 PM, Roopa Prabhu wrote:
>>>On 12/18/14, 11:21 AM, John Fastabend wrote:
>>>>On 12/18/2014 10:14 AM, Roopa Prabhu wrote:
>>>>>On 12/18/14, 10:02 AM, Varlese, Marco wrote:
>>>>>>Removed unnecessary content for ease of reading...
>>>>>>
>>>>>>>>>>>>+/* Switch Port Attributes section */
>>>>>>>>>>>>+
>>>>>>>>>>>>+enum {
>>>>>>>>>>>>+    IFLA_ATTR_UNSPEC,
>>>>>>>>>>>>+    IFLA_ATTR_LEARNING,
>>>>>>>>>>>Any reason you want learning here ?. This is covered as part  of
>>>>>>>>>>>the bridge setlink attributes.
>>>>>>>>>>>
>>>>>>>>>>Yes, because the user may _not_ want to go through a bridge
>>>>>>>>>>interface
>>>>>>>>>necessarily.
>>>>>>>>>But, the bridge setlink/getlink interface was changed to
>>>>>>>>>accommodate
>>>>>>>'self'
>>>>>>>>>for exactly such cases.
>>>>>>>>>I kind of understand your case for the other attributes (these are
>>>>>>>>>per port settings that switch asics provide).
>>>>>>>>>
>>>>>>>>>However, i don't understand the reason to pull in bridge
>>>>>>>>>attributes here.
>>>>>>>>>
>>>>>>>>Maybe, I am missing something so you might help. The learning
>>>>>>>>attribute -
>>>>>>>in my case - it is like all other attributes: a port attribute
>>>>>>>(as you said, port
>>>>>>>settings that the switch provides per port).
>>>>>>>>So, what I was saying is "why the user shall go through a
>>>>>>>>bridge to configure
>>>>>>>the learning attribute"? From my perspective, it is as any other
>>>>>>>attribute and
>>>>>>>as such configurable on the port.
>>>>>>>
>>>>>>>Thinking about this some more, i don't see why any of these
>>>>>>>attributes
>>>>>>>(except loopback. I dont understand the loopback attribute) cant
>>>>>>>be part of
>>>>>>>the birdge port attributes.
>>>>>>>
>>>>>>>With this we will end up adding l2 attributes in two places: the
>>>>>>>general link
>>>>>>>attributes and bridge attributes.
>>>>>>>
>>>>>>>And since we have gone down the path of using
>>>>>>>ndo_bridge_setlink/getlink
>>>>>>>with 'self'....we should stick to that for all l2 attributes.
>>>>>>>
>>>>>>>The idea of overloading ndo_bridge_set/getlink, was to have the
>>>>>>>same set of
>>>>>>>attributes but support both cases where the user wants to go
>>>>>>>through the
>>>>>>>bridge driver or directly to the switch port driver. So, you are
>>>>>>>not really going
>>>>>>>through the bridge driver if you use 'self' and
>>>>>>>ndo_bridge_setlink/getlink.
>>>>>>>
>>>>>>Roopa, one of the comments I got from Thomas Graf on my v1 patch
>>>>>>was that your patch and mine were supplementary ("I think Roopa's
>>>>>>patches are supplementary. Not all switchdev users will be backed
>>>>>>with a Linux Bridge. I therefore welcome your patches very
>>>>>>much")... I also understood by others that the patch made sense for
>>>>>>the same reason. I simply do not understand why these attributes
>>>>>>(and maybe others in the future) could not be configured directly
>>>>>>on a standard port but have to go through a bridge.
>>>>>>
>>>>>ok, i am very confused in that case. The whole moving of bridge
>>>>>attributes from the bridge driver to rtnetlink.c was to make the
>>>>>bridge attributes accessible to any driver who wants to set l2/bridge
>>>>>attributes on their switch ports. So, its unclear to me why we are
>>>>>doing this parallel thing again. This move to rtnetlink.c was done
>>>>>during the recent rocker support. so, maybe scott/jiri can elaborate
>>>>>more.
>>>>
>>>>Not sure if this will add to the confusion or help. But you do not
>>>>need to have the bridge.ko loaded or netdev's attached to a bridge
>>>>to use the setlink/getlink ndo ops and netlink messages.
>>>>
>>>>This was intentionally done. Its already used with NIC devices to
>>>>configure embedded bridge settings such as VEB/VEPA.
>>>
>>>that helps my case, thanks.
>>
>>So the user interface to set/get the per-port attributes will be via
>>'bridge', not 'ip'
>>
>>    bridge link set dev sw0p1 port_attr bcast_flooding 1 self
>>    bridge link get dev sw0p1 port_attr bcast_flooding self
>
>yes, l2 attributes.
>>
>>We also need an interface to set per-switch attributes. Can this work?
>>    bridge link set dev sw0 sw_attr bcast_flooding 1 master
>>where sw0 is a bridge representing the hardware switch.

How can a bridge represent the hardware switch? What if you have 2 bridge
on ports of the same hardware switch. Or what if you have a bridge with
couple of ports from one hardware switch and couple of ports from second
hardware switch. Or else, you can have a misxture of switch ports and
other devices (taps for example). Bridge->hardware switch does not map
1:1.

If you want to set any per switch attributes, just use one of the ports
as a "gateway". port->hardware switch mapping is strict, so you should
be okay doing that. There are no ndos for this purpose at the moment,
but they can be easily added.

>
>Not today. We discussed this @ LPC, and one way to do this would be to have a
>device
>representing the switch asic. This is in the works.
>

Yep, I still do not find a need to introduce some new device class. I
think it would be just confusing. Example.

br0 --- sw0p0
    --- sw0p1
    --- sw0p2

br1 --- sw0p3
    --- sw0p4
    --- sw0p5

and in paralel, without any connection you would have some mysterious
device "sw0" which would do something, not clear why.

Btw this device would not be netdev, so it could not be used for
anything netdevs can be currently used for.

Yes, I still might be missing something, for sure. Nobody told me what yet.

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Tue, 25 Mar 2014 22:37:03 -0700
Message-ID: <5332677F.2090404@cumulusnetworks.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us> <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48768 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaCZFqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 01:46:11 -0400
In-Reply-To: <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/25/14, 1:11 PM, Florian Fainelli wrote:
> 2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
>> On Tue, Mar 25, 2014 at 06:00:09PM +0000, Thomas Graf wrote:
>>> On 03/25/14 at 01:39pm, Neil Horman wrote:
>>>> No, but it would be really nice if these smaller devices could take advantage of
>>>> this infrastructure.  Looking at it, I don't see why thats not possible.  The
>>>> big trick (as we've discussed in the past), is using a net_device structure to
>>>> take advantage of all the features that net_devices offer while not enabling the
>>>> device specific features that some hardware doesn't allow.
>>>>
>>>> For instance the broadcom chips that live in many wireless routers would be well
>>>> served by the model jiri has here as far as Media level interface control is
>>>> concerned (i.e. ifup/down/speed/duplex/etc), but its a bit lacking in that
>>>> net_devices are assumed to support L3 protocol configuration (i.e. they can have
>>>> ip addresses assigned to them), which you can't IIRC do on these chips.
>>> How about a new device flag indicating pure L2 mode? Any L3 address
>>> configuration would fail with EAFNOSUPP.
>>>
>> Yeah, we've discussed that before, and it seems like a good idea, though I'm not
>> sure that its flexible enough.  It clearly prevents L3 operations on devices
>> that can only do L2, which is great, but that may not be sufficient for some
>> devices.  For example, what if you wanted to use ebtables on an L2 port where
>> the hardware can't mirror the actions of a given table rule?  Do we need to
>> expand out those capabilities?
>>
>>>> Would it be worth considering a private interface model?  That is to say:
>>>>
>>>> 1) Ports on a switch chip are accessed using net_device structures, but
>>>> registered to a private list contained within the switch device, rather than to
>>>> the net namespaces device list.
>>>> 2) Access to the switch ports via user space is done through the master switch
>>>> interface with additional netlink attributes specifying the port on the switch
>>>> to access (or not to access the master switch device directly)
>>>> Such a model I think might fit well with Jiri's code here and provide greater
>>>> flexibility for a wider range of devices.  It would of course require
>>>> augmentation for user space, but the changes would be additive, so I think they
>>>> would be reasonable.  This would also allow the switch device to have a hook in
>>>> the control path to block or allow features that the hardware may or may not
>>>> support while still being able to use the existing net_device infrastructure to
>>>> support these operations as they are normally carried out.
>>> I believe this would defeat the main advantage of reusing net_device
>>> model which is compatibility with the well established standard toolset.
>>>
>>> In an ideal world, we represent what is possible using the existing
>>> net_device model.
>>>
>> Maybe I'm not being clear. I'm not suggesting that we abandon the use of a
>> net_device to do any of this work, only that we add a layer of indirection to
>> get to it.  By Augmenting the existing network device stack to allow
>> registration of net_devices to arbitrary lists, rather than to a fixes
>> per-net-namespace global device list, we can operate net_devices that are only
>> visible within the scope of a given switch fabric.  User space still works the
>> same way, it just requires the specification of additional information when
>> speaking to ports on a switch device that may not be directly accessible via the
>> cpu.  For example, if a systems has a directly connected nic (em1), and a switch
>> fabric with a master bridge port (sw1), and 10 external ports (sw1pX), we could
>> access them all from user space via ip link show.  for example:
>>
>> 1) ip link show:
>> em1
>> sw1
>>
>> 2) ip link show sw1
>> sw1
>>
>> 3) ip link show -p sw1
>> sw1p0
>> sw1p1
>> sw1p2...
> I was scratching my head about why we might want to expose sw1 as a
> separate net_device, but I think this is a good model as it allows for
> a "seamless" switch awareness to be constructed, and allows for
> controlling the CPU/management port(s) of a given Ethernet switch
> separately, which is valuable. It also makes it possible to expose the
> multiple CPU/management ports of a given switch when that exists, and
> finally, there might be special firmware running on the Ethernet
> switch, and that specific 'sw1' net_device could be the one to use to
> talk to this via sockets, ioctls, whatever.
>
>
Sorry about getting on this thread late and possibly in the middle.
Agree on the idea of keeping the ports linked to the master switch dev 
(or the 'conduit' to the switch chip) via private list instead of the 
master-slave relationship proposed earlier.
By private i mean the netdev->priv linkage to the master switch dev and 
not really keeping the ports from being exposed to the user.

We think its better to keep the switch ports exposed as any other netdev 
on linux.
  This approach will make the switch ports look exactly like a nic port 
and all tools will continue to work seamlessly. The switch port 
operations could internally be forwarded to the switch netdev (sw1 in 
the above case).

example:
$ip link set dev sw1p0 up
$ethtool -S sw1p0


whether sw1 is needed as a separate netdev existing on the system is 
debatable.
Most cases the switch port driver (API) can talk to the switch chip 
driver without a switch netdev in between.
But there are cases where a switch netdev might become necessary for 
switch chip specific operations (which probably has been discussed on 
this thread). An example could be a global acl rule that applies to all 
switch ports. One can argue that this can be applied on individual 
switch ports and the switch driver can take care of consolidating or 
optimally programming the acl rule in the switch chip.

Thanks,
Roopa

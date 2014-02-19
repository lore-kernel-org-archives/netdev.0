From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to opt out
 from becoming the root bridge
Date: Wed, 19 Feb 2014 14:35:43 +0000
Message-ID: <5304C13F.3030802@citrix.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>	<20140216105754.63738163@nehalam.linuxnetplumber.net>	<CAB=NE6WwbOXNLO_Mn42i7y62pEsmDOWd35B621eiJk4iaE3Hfg@mail.gmail.com> <1392803559.23084.99.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	<xen-devel@lists.xenproject.org>
To: Ian Campbell <Ian.Campbell@citrix.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392803559.23084.99.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/02/14 09:52, Ian Campbell wrote:
> On Tue, 2014-02-18 at 13:02 -0800, Luis R. Rodriguez wrote:
>> On Sun, Feb 16, 2014 at 10:57 AM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>> On Fri, 14 Feb 2014 18:59:37 -0800
>>> "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
>>>
>>>> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>>>>
>>>> It doesn't make sense for some interfaces to become a root bridge
>>>> at any point in time. One example is virtual backend interfaces
>>>> which rely on other entities on the bridge for actual physical
>>>> connectivity. They only provide virtual access.
>>>>
>>>> Device drivers that know they should never become part of the
>>>> root bridge have been using a trick of setting their MAC address
>>>> to a high broadcast MAC address such as FE:FF:FF:FF:FF:FF. Instead
>>>> of using these hacks lets the interfaces annotate its intent and
>>>> generalizes a solution for multiple drivers, while letting the
>>>> drivers use a random MAC address or one prefixed with a proper OUI.
>>>> This sort of hack is used by both qemu and xen for their backend
>>>> interfaces.
>>>>
>>>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>>>> Cc: bridge@lists.linux-foundation.org
>>>> Cc: netdev@vger.kernel.org
>>>> Cc: linux-kernel@vger.kernel.org
>>>> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
>>>
>>> This is already supported in a more standard way via the root
>>> block flag.
>>
>> Great! For documentation purposes the root_block flag is a sysfs
>> attribute, added via 3.8 through commit 1007dd1a. The respective
>> interface flag is IFLA_BRPORT_PROTECT and can be set via the iproute2
>> bridge utility or through sysfs:
>>
>> mcgrof@garbanzo ~/linux (git::master)$ find /sys/ -name root_block
>> /sys/devices/pci0000:00/0000:00:04.0/0000:02:00.0/net/eth0/brport/root_block
>> /sys/devices/vif-3-0/net/vif3.0/brport/root_block
>> /sys/devices/virtual/net/vif3.0-emu/brport/root_block
>>
>> mcgrof@garbanzo ~/devel/iproute2 (git::master)$ cat
>> /sys/devices/vif-3-0/net/vif3.0/brport/root_block
>> 0
>> mcgrof@garbanzo ~/devel/iproute2 (git::master)$ sudo bridge link set
>> dev vif3.0 root_block on
>> mcgrof@garbanzo ~/devel/iproute2 (git::master)$ cat
>> /sys/devices/vif-3-0/net/vif3.0/brport/root_block
>> 1
>>
>> So if we'd want to avoid using the MAC address hack alternative to
>> skip a root port userspace would need to be updated to simply set this
>> attribute after adding the device to the bridge. Based on Zoltan's
>> feedback there seems to be use cases to not enable this always for all
>> xen-netback interfaces though as such we can just punt this to
>> userspace for the topologies that require this.
>>
>> The original motivation for this series was to avoid the IPv6
>> duplicate address incurred by the MAC address hack for avoiding the
>> root bridge. Given that Zoltan also noted a use case whereby IPv4 and
>> IPv6 addresses can be assigned to the backend interfaces we should be
>> able to avoid the duplicate address situation for IPv6 by using a
>> proper random MAC address *once* userspace has been updated also to
>> use IFLA_BRPORT_PROTECT. New userspace can't and won't need to set
>> this flag for older kernels (older than 3.8) as root_block is not
>> implemented on those kernels and the MAC address hack would still be
>> used there. This strategy however does put a requirement on new
>> kernels to use new userspace as otherwise the MAC address workaround
>> would not be in place and root_block would not take effect.
>
> Can't we arrange things in the Xen hotplug scripts such that if the
> root_block stuff isn't available/doesn't work we fallback to the
> existing fe:ff:ff:ff:ff usage?
>
> That would avoid concerns about forward/backwards compat I think. It
> wouldn't solve the issue you are targeting on old systems, but it also
> doesn't regress them any further.

I agree, I think this problem could be better handled from userspace: if 
it can set root_block then change the default MAC to a random one, if it 
can't, then stay with the default one. Or if someone doesn't care about 
STP but DAD is still important, userspace can have a force_random_mac 
option somewhere to change to a random MAC regardless of root_block 
presence.

Zoli

From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 1/4] bridge: enable interfaces to opt out from becoming
 the root bridge
Date: Tue, 18 Feb 2014 13:02:29 -0800
Message-ID: <CAB=NE6WwbOXNLO_Mn42i7y62pEsmDOWd35B621eiJk4iaE3Hfg@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
 <1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com> <20140216105754.63738163@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140216105754.63738163@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 16, 2014 at 10:57 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 14 Feb 2014 18:59:37 -0800
> "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
>
>> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>>
>> It doesn't make sense for some interfaces to become a root bridge
>> at any point in time. One example is virtual backend interfaces
>> which rely on other entities on the bridge for actual physical
>> connectivity. They only provide virtual access.
>>
>> Device drivers that know they should never become part of the
>> root bridge have been using a trick of setting their MAC address
>> to a high broadcast MAC address such as FE:FF:FF:FF:FF:FF. Instead
>> of using these hacks lets the interfaces annotate its intent and
>> generalizes a solution for multiple drivers, while letting the
>> drivers use a random MAC address or one prefixed with a proper OUI.
>> This sort of hack is used by both qemu and xen for their backend
>> interfaces.
>>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Cc: bridge@lists.linux-foundation.org
>> Cc: netdev@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
>
> This is already supported in a more standard way via the root
> block flag.

Great! For documentation purposes the root_block flag is a sysfs
attribute, added via 3.8 through commit 1007dd1a. The respective
interface flag is IFLA_BRPORT_PROTECT and can be set via the iproute2
bridge utility or through sysfs:

mcgrof@garbanzo ~/linux (git::master)$ find /sys/ -name root_block
/sys/devices/pci0000:00/0000:00:04.0/0000:02:00.0/net/eth0/brport/root_block
/sys/devices/vif-3-0/net/vif3.0/brport/root_block
/sys/devices/virtual/net/vif3.0-emu/brport/root_block

mcgrof@garbanzo ~/devel/iproute2 (git::master)$ cat
/sys/devices/vif-3-0/net/vif3.0/brport/root_block
0
mcgrof@garbanzo ~/devel/iproute2 (git::master)$ sudo bridge link set
dev vif3.0 root_block on
mcgrof@garbanzo ~/devel/iproute2 (git::master)$ cat
/sys/devices/vif-3-0/net/vif3.0/brport/root_block
1

So if we'd want to avoid using the MAC address hack alternative to
skip a root port userspace would need to be updated to simply set this
attribute after adding the device to the bridge. Based on Zoltan's
feedback there seems to be use cases to not enable this always for all
xen-netback interfaces though as such we can just punt this to
userspace for the topologies that require this.

The original motivation for this series was to avoid the IPv6
duplicate address incurred by the MAC address hack for avoiding the
root bridge. Given that Zoltan also noted a use case whereby IPv4 and
IPv6 addresses can be assigned to the backend interfaces we should be
able to avoid the duplicate address situation for IPv6 by using a
proper random MAC address *once* userspace has been updated also to
use IFLA_BRPORT_PROTECT. New userspace can't and won't need to set
this flag for older kernels (older than 3.8) as root_block is not
implemented on those kernels and the MAC address hack would still be
used there. This strategy however does put a requirement on new
kernels to use new userspace as otherwise the MAC address workaround
would not be in place and root_block would not take effect.

  Luis

From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Wed, 14 Oct 2015 09:14:46 +0300
Message-ID: <20151014061446.GA29908@colbert.mtl.com>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
 <1444651299-2813-1-git-send-email-razor@blackwall.org>
 <20151012173625.GA17983@ketchup.lan>
 <20151013083111.GA1432@colbert.mtl.com>
 <20151013143225.GA9636@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Nikolay Aleksandrov <razor@blackwall.org>,
	<netdev@vger.kernel.org>, <sfeldma@gmail.com>, <jiri@resnulli.us>,
	<davem@davemloft.net>,
	"Nikolay Aleksandrov" <nikolay@cumulusnetworks.com>,
	<eladr@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0062.outbound.protection.outlook.com ([157.55.234.62]:26684
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750759AbbJNGO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 02:14:56 -0400
Content-Disposition: inline
In-Reply-To: <20151013143225.GA9636@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 13, 2015 at 05:32:26PM IDT, vivien.didelot@savoirfairelinux.com wrote:
>On Oct. Tuesday 13 (42) 11:31 AM, Ido Schimmel wrote:
>> Mon, Oct 12, 2015 at 08:36:25PM IDT, vivien.didelot@savoirfairelinux.com wrote:
>> >Hi guys,
>> >
>> >On Oct. Monday 12 (42) 02:01 PM, Nikolay Aleksandrov wrote:
>> >> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> >> 
>> >> We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
>> >> 
>> >> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> >> ---
>> >>  net/switchdev/switchdev.c | 3 +++
>> >>  1 file changed, 3 insertions(+)
>> >> 
>> >> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> >> index 6e4a4f9ad927..256c596de896 100644
>> >> --- a/net/switchdev/switchdev.c
>> >> +++ b/net/switchdev/switchdev.c
>> >> @@ -720,6 +720,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
>> >>  			if (vlan.vid_begin)
>> >>  				return -EINVAL;
>> >>  			vlan.vid_begin = vinfo->vid;
>> >> +			/* don't allow range of pvids */
>> >> +			if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
>> >> +				return -EINVAL;
>> >>  		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
>> >>  			if (!vlan.vid_begin)
>> >>  				return -EINVAL;
>> >> -- 
>> >> 2.4.3
>> >> 
>> >
>> >Yes the patch looks good, but it is a minor check though. I hope the
>> >subject of this thread is making sense.
>> >
>> >VLAN ranges seem to have been included for an UX purpose (so commands
>> >look like Cisco IOS). We don't want to change any existing interface, so
>> >we pushed that down to drivers, with the only valid reason that, maybe
>> >one day, an hardware can be capable of programming a range on a per-port
>> >basis.
>> Hi,
>> 
>> That's actually what we are doing in mlxsw. We can do up to 256 entries in
>> one go. We've yet to submit this part.
>
>Perfect Ido, thanks for pointing this out! I'm OK with the range then. 
>
>So there is now a very last question in my head for this, which is more
>a matter of kernel design. Should the user be aware of such underlying
>support? In other words, would it make sense to do this in a driver:
>
>    foo_port_vlan_add(struct net_device *dev,
>                      struct switchdev_obj_port_vlan *vlan)
>    {
>        if (vlan->vid_begin != vlan->vid_end)
>            return -ENOTSUPP; /* or something more relevant for user */
>
>        return foo_port_single_vlan_add(dev, vlan->vid_begin);
>    }
>
>So drivers keep being simple, and we can easily propagate the fact that
>one-or-all VLAN is not supportable, vs. the VLAN feature itself is not
>implemented and must be done in software.
I think that if you want to keep it simple, then Scott's advice from the
previous thread is the most appropriate one. I believe the hardware you
are using is simply not meant to support multiple 802.1Q bridges.

Trying to go around this will simply result in weird behavior (such as
not supporting VLAN ranges), which is only sacrificed to support
something a user doesn't even require (given the fact he's aware the
hardware is meant to support only one 802.1Q bridge).

What do you think?
>
>I'm not sure how transparent the hardware must be to the user.
>
>(the problem of one VLAN unsupported in a range is still something we
>need to address).
>
>> 
>> >
>> >So what happens is that we'll add some code to fix and check non-sense
>> >(e.g. range + PVID) in switchdev, bridge, and I'm sure we are missing
>> >other spots.
>> >
>> >Sorry for being insistent, but this still doesn't look right to me.
>> >
>> >It seems like we are bloating bridge, switchdev and drivers for the only
>> >reason to maintain a kernel support for something like:
>> >
>> >    # for i in $(seq 100 4000); do bridge vlan add vid $i dev swp0; done
>
>Thanks,
>-v

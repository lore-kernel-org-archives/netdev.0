From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Tue, 13 Oct 2015 10:32:26 -0400
Message-ID: <20151013143225.GA9636@ketchup.mtl.sfl>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
 <1444651299-2813-1-git-send-email-razor@blackwall.org>
 <20151012173625.GA17983@ketchup.lan>
 <20151013083111.GA1432@colbert.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org,
	sfeldma@gmail.com, jiri@resnulli.us, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	eladr@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52036 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbbJMOca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 10:32:30 -0400
Content-Disposition: inline
In-Reply-To: <20151013083111.GA1432@colbert.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Tuesday 13 (42) 11:31 AM, Ido Schimmel wrote:
> Mon, Oct 12, 2015 at 08:36:25PM IDT, vivien.didelot@savoirfairelinux.com wrote:
> >Hi guys,
> >
> >On Oct. Monday 12 (42) 02:01 PM, Nikolay Aleksandrov wrote:
> >> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> >> 
> >> We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
> >> 
> >> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> >> ---
> >>  net/switchdev/switchdev.c | 3 +++
> >>  1 file changed, 3 insertions(+)
> >> 
> >> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> >> index 6e4a4f9ad927..256c596de896 100644
> >> --- a/net/switchdev/switchdev.c
> >> +++ b/net/switchdev/switchdev.c
> >> @@ -720,6 +720,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
> >>  			if (vlan.vid_begin)
> >>  				return -EINVAL;
> >>  			vlan.vid_begin = vinfo->vid;
> >> +			/* don't allow range of pvids */
> >> +			if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
> >> +				return -EINVAL;
> >>  		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
> >>  			if (!vlan.vid_begin)
> >>  				return -EINVAL;
> >> -- 
> >> 2.4.3
> >> 
> >
> >Yes the patch looks good, but it is a minor check though. I hope the
> >subject of this thread is making sense.
> >
> >VLAN ranges seem to have been included for an UX purpose (so commands
> >look like Cisco IOS). We don't want to change any existing interface, so
> >we pushed that down to drivers, with the only valid reason that, maybe
> >one day, an hardware can be capable of programming a range on a per-port
> >basis.
> Hi,
> 
> That's actually what we are doing in mlxsw. We can do up to 256 entries in
> one go. We've yet to submit this part.

Perfect Ido, thanks for pointing this out! I'm OK with the range then. 

So there is now a very last question in my head for this, which is more
a matter of kernel design. Should the user be aware of such underlying
support? In other words, would it make sense to do this in a driver:

    foo_port_vlan_add(struct net_device *dev,
                      struct switchdev_obj_port_vlan *vlan)
    {
        if (vlan->vid_begin != vlan->vid_end)
            return -ENOTSUPP; /* or something more relevant for user */

        return foo_port_single_vlan_add(dev, vlan->vid_begin);
    }

So drivers keep being simple, and we can easily propagate the fact that
one-or-all VLAN is not supportable, vs. the VLAN feature itself is not
implemented and must be done in software.

I'm not sure how transparent the hardware must be to the user.

(the problem of one VLAN unsupported in a range is still something we
need to address).

> 
> >
> >So what happens is that we'll add some code to fix and check non-sense
> >(e.g. range + PVID) in switchdev, bridge, and I'm sure we are missing
> >other spots.
> >
> >Sorry for being insistent, but this still doesn't look right to me.
> >
> >It seems like we are bloating bridge, switchdev and drivers for the only
> >reason to maintain a kernel support for something like:
> >
> >    # for i in $(seq 100 4000); do bridge vlan add vid $i dev swp0; done

Thanks,
-v

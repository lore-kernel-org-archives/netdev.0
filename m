From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Wed, 14 Oct 2015 10:14:24 -0700
Message-ID: <CAE4R7bDFMgWnvS03OU+SE3QAeC-TSVYZ7=oLV9q-v6DbYmm_Tg@mail.gmail.com>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
 <1444651299-2813-1-git-send-email-razor@blackwall.org> <20151012173625.GA17983@ketchup.lan>
 <20151013083111.GA1432@colbert.mtl.com> <20151013143225.GA9636@ketchup.mtl.sfl>
 <20151014061446.GA29908@colbert.mtl.com> <20151014152515.GA6681@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ido Schimmel <idosch@mellanox.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Elad Raz <eladr@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:33198 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbbJNROo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:14:44 -0400
Received: by oiar126 with SMTP id r126so31599515oia.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:14:44 -0700 (PDT)
In-Reply-To: <20151014152515.GA6681@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 8:25 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> On Oct. Wednesday 14 (42) 09:14 AM, Ido Schimmel wrote:
>> Tue, Oct 13, 2015 at 05:32:26PM IDT, vivien.didelot@savoirfairelinux.com wrote:
>> >On Oct. Tuesday 13 (42) 11:31 AM, Ido Schimmel wrote:
>> >> Mon, Oct 12, 2015 at 08:36:25PM IDT, vivien.didelot@savoirfairelinux.com wrote:
>> >> >Hi guys,
>> >> >
>> >> >On Oct. Monday 12 (42) 02:01 PM, Nikolay Aleksandrov wrote:
>> >> >> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> >> >>
>> >> >> We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
>> >> >>
>> >> >> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> >> >> ---
>> >> >>  net/switchdev/switchdev.c | 3 +++
>> >> >>  1 file changed, 3 insertions(+)
>> >> >>
>> >> >> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> >> >> index 6e4a4f9ad927..256c596de896 100644
>> >> >> --- a/net/switchdev/switchdev.c
>> >> >> +++ b/net/switchdev/switchdev.c
>> >> >> @@ -720,6 +720,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
>> >> >>                         if (vlan.vid_begin)
>> >> >>                                 return -EINVAL;
>> >> >>                         vlan.vid_begin = vinfo->vid;
>> >> >> +                       /* don't allow range of pvids */
>> >> >> +                       if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
>> >> >> +                               return -EINVAL;
>> >> >>                 } else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
>> >> >>                         if (!vlan.vid_begin)
>> >> >>                                 return -EINVAL;
>> >> >> --
>> >> >> 2.4.3
>> >> >>
>> >> >
>> >> >Yes the patch looks good, but it is a minor check though. I hope the
>> >> >subject of this thread is making sense.
>> >> >
>> >> >VLAN ranges seem to have been included for an UX purpose (so commands
>> >> >look like Cisco IOS). We don't want to change any existing interface, so
>> >> >we pushed that down to drivers, with the only valid reason that, maybe
>> >> >one day, an hardware can be capable of programming a range on a per-port
>> >> >basis.
>> >> Hi,
>> >>
>> >> That's actually what we are doing in mlxsw. We can do up to 256 entries in
>> >> one go. We've yet to submit this part.
>> >
>> >Perfect Ido, thanks for pointing this out! I'm OK with the range then.
>> >
>> >So there is now a very last question in my head for this, which is more
>> >a matter of kernel design. Should the user be aware of such underlying
>> >support? In other words, would it make sense to do this in a driver:
>> >
>> >    foo_port_vlan_add(struct net_device *dev,
>> >                      struct switchdev_obj_port_vlan *vlan)
>> >    {
>> >        if (vlan->vid_begin != vlan->vid_end)
>> >            return -ENOTSUPP; /* or something more relevant for user */
>> >
>> >        return foo_port_single_vlan_add(dev, vlan->vid_begin);
>> >    }
>> >
>> >So drivers keep being simple, and we can easily propagate the fact that
>> >one-or-all VLAN is not supportable, vs. the VLAN feature itself is not
>> >implemented and must be done in software.
>> I think that if you want to keep it simple, then Scott's advice from the
>> previous thread is the most appropriate one. I believe the hardware you
>> are using is simply not meant to support multiple 802.1Q bridges.
>
> You mean allowing only one Linux bridge over an hardware switch?
>
> It would for sure simplify how, as developers and users, we represent a
> physical switch. But I am not sure how to achieve that and I don't have
> strong opinions on this TBH.

Hi Vivien, I think it's possible to keep switch ports on just one
bridge if we do a little bit of work on the NETDEV_CHANGEUPPER
notifier.  This will give you the driver-level control you want.  Do
you have time to investigate?  The idea is:

1) In your driver's handler for NETDEV_CHANGEUPPER, if switch port is
being added to a second bridge,then return NOTIFY_BAD.  Your driver
needs to track the bridge count.

2) In __netdev_upper_dev_link(), check the return code from the
call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, ...) call, and if
NOTIFY_BAD, abort the linking operation (goto rollback_xxx).

-scott

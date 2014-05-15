From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: bonding directly changes underlying device address
Date: Wed, 14 May 2014 18:38:45 -0700
Message-ID: <5046.1400117925@localhost.localdomain>
References: <5371FCD0.7050502@mellanox.com> <20140513115527.GC2910@minipsycho.orion> <20030.1399998641@localhost.localdomain> <CAJZOPZ+pOBw4M-ZFF2qsqNgGJcKcRRdhWFf4dy1FQ8Ngr-ZqRA@mail.gmail.com> <20140514080114.GA30960@mikrodark.usersys.redhat.com>
Cc: Or Gerlitz <or.gerlitz@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36319 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaEOBiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 21:38:52 -0400
In-reply-to: <20140514080114.GA30960@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@gmail.com> wrote:

>On Tue, May 13, 2014 at 08:38:01PM +0300, Or Gerlitz wrote:
>>On Tue, May 13, 2014 at 7:30 PM, Jay Vosburgh
>><jay.vosburgh@canonical.com> wrote:
>>>>Tue, May 13, 2014 at 01:06:56PM CEST, ogerlitz@mellanox.com wrote:
>>
>>[...]
>>
>>>>>I suspect this can lead to funny (or actually sad) bugs in networking
>>>>>drivers, can we avoid that?
>>
>>>         Changing this would also remove support for the tlb mode from
>>> any device that cannot change their MAC while open.  I don't know how
>>> many devices that is (it's probably a small number nowadays), but if
>>> it's not zero then an assessment on losing that support has to be made.
>>
>>Focusing on the last part of your reply, are you OK with a patch that
>>branches on whether that device supports ndo_set_mac_address and if
>>this is the case we will call dev_set_mac_address, else do the current
>>practice of setting dev_addr directly?
>
>I'd actually just drop support for non-ndo_set_mac_address NICs, as it'll
>unify the RLB and TLB logic, and anyways dev_set_mac_address() is used in
>SIOCSIFHWADDR and rtnl ops, and thus, if the NIC doesn't support it, it
>can't change its mac address at all, and using it in *LB modes makes little
>sense.

	It's not that the device drivers lack ndo_set_mac_address, it's
that the MAC can only be changed while the device is down.  The hardware
is programmed with the MAC only when the device transitions from down to
up.

	I looked, and a large number (~140) of device drivers use
eth_mac_addr as the ndo_set_mac_address function and do not set
IFF_LIVE_ADDR_CHANGE in priv_flags.  All eth_mac_addr does is copy the
MAC address into dev->dev_addr after checking that the device isn't up.
The actual programming of the hardware happens in the device's ndo_open
function.  These are the devices that the odd balance-tlb dev_addr MAC
address handling is meant for.

	Now, just skimming the list of those drivers, it looks like the
vast majority are old 10/100 only chipsets.  Probably a good chunk of
them cannot actually be used today due to a lack of hardware.  A few are
funky things that nobody is likely to run bonding on (ibmveth, for
example).  A few, though, are gigabit chipsets and appear to have
relatively recent work being done on them.  I suppose it's possible that
there are users on 10/100 chipsets as well.

>Other way of doing this would be to just move the dev_addr to the slave
>struct, instead of using the net_device's dev_addr, cause in tlb we don't
>usually need to set the NIC mac address (except when there's mac filtering,
>I guess), but only need to set the packet's source mac. This way we'll omit
>quite costy mac address setting (as, on some NICs, it resets the whole NIC
>and takes seconds), still maintain compatibility with older NICs and won't
>mess with NICs ->dev_addr.

	By this you mean to, basically, stash the MAC in the struct
slave somewhere instead of in dev->dev_addr, and then in bond_tlb_xmit
change the Ethernet destination?  Without having actually tried it, I
can't think of a reason why this wouldn't work.  That's really all
that's happening now, except the stash is dev_addr, and the Ethernet
destination is set for us by dev_hard_header.  So, in principle, I don't
see any problems with this.

>Anyway, I'll let Jay decide.

	Well, my general thought here is that, yes, this is icky, and
it's even been behind a bug not too long ago, when some device went down
then up and programmed the dev_addr into its hardware and ended up with
a duplicate MAC address on the network.  So, I'm not automatically
against changing this to make it "better."

	On the other hand, I do not feel that I have a good grasp as to
how many users are out there that rely on this property of balance-tlb
(that the device need be able to not change its MAC while open).
Therefore, I'm not in favor of a change that would break that support.

	So, I'd say "No" to conversion to dev_set_mac_address() and
"show me the code" to the "stash it in the slave" plan.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com

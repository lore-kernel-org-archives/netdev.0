From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Tue, 7 Jun 2011 18:25:23 -0700
Message-ID: <BANLkTikmNXK=i1HhtGtb1+81rGqGgBQ8mA@mail.gmail.com>
References: <20110603200738.GA24804@midget.suse.cz> <20110605.142823.1727360496050285755.davem@davemloft.net>
 <20110607161808.GA5018@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, pedro.netdev@dondevamos.com
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:51614 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932732Ab1FHBZo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 21:25:44 -0400
Received: by vxi39 with SMTP id 39so20340vxi.19
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 18:25:43 -0700 (PDT)
In-Reply-To: <20110607161808.GA5018@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 7, 2011 at 9:18 AM, Jiri Bohac <jbohac@suse.cz> wrote:
> Hi David,
>
> On Sun, Jun 05, 2011 at 02:28:23PM -0700, David Miller wrote:
>> From: Jiri Bohac <jbohac@suse.cz>
>> Date: Fri, 3 Jun 2011 22:07:38 +0200
>>
>> > Commit ad1afb00 registers a VLAN with vid =3D=3D 0 for every devic=
e to handle
>> > 802.1p frames. =C2=A0This is currently done on every NETDEV_UP eve=
nt and the special
>> > vlan is never unregistered. =C2=A0This may have strange effects on=
 drivers
>> > implementning ndo_vlan_rx_add_vid(). E.g. bonding will allocate a =
linked-list
>> > element each time, causing a memory leak.
>> >
>> > Only register the special VLAN once on NETDEV_REGISTER.
>> >
>> > Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>>
>> I recognize the problem, but this solution isn't all that good.
>>
>> I am pretty sure that the hardware device driver methods that
>> implement ndo_vlan_rx_add_vid() assume that the device is up.
>> Because most drivers completely reset the chip when the
>> interface is brought up and this will likely clear out the
>> VLAN ID tables in the chip.
>
> Really? In that case, we have a much bigger problem: the vlan
> code allows registering a new vlan on an interface that is down.
> And it only registers the VID with ndo_vlan_rx_add_vid() in
> register_vlan_dev() during the registration of the new vlan
> interface -- it never re-registers the VIDs on a NETDEV_UP.

No, it's not true.  All drivers store the registered vlan filters in
some way so that they can restore them when the device is reset.  This
is currently done in one of two ways: storing a bitmap or iterating
over the devices currently registered in a group.

The vlan code is moving away from directly accessing groups and no new
drivers do this.  In fact, once all drivers are converted over groups
will not even be registered on devices.  This is because otherwise
there is quite a bit of vlan code in each driver, which leads to
inconsistent behavior and bugs.

Really, all a driver needs to know is whether it should add a given
vlan to its table, not what the upper layers plan to do with it.  So
when ndo_vlan_rx_add_vid() is called it should add it to its CAM table
and store it if it is needed to restore behavior after a reset, just
as is done with all other configuration state.

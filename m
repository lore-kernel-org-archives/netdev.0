From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: by default accept untagged packets
Date: Wed, 27 May 2015 00:34:57 -0700
Message-ID: <CAE4R7bAnR3ZprJaS_Ukm6L6AM-q4Zcm2Pwny9073pp_moCBfCA@mail.gmail.com>
References: <1432601703-26774-1-git-send-email-simon.horman@netronome.com>
	<CAE4R7bAEQDE0QCnfVet29BZ574vVFqBoXv_EbyhYXYvBqo_xEA@mail.gmail.com>
	<CAE4R7bBYK0zJbb_q0BUowh_jrrCMapVq8xouD5bv56hPXYGsWQ@mail.gmail.com>
	<20150527010703.GA24249@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:34231 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbbE0He6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 03:34:58 -0400
Received: by qcbhb1 with SMTP id hb1so574770qcb.1
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 00:34:57 -0700 (PDT)
In-Reply-To: <20150527010703.GA24249@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 6:07 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi Scott,
>
> On Tue, May 26, 2015 at 02:04:00AM -0700, Scott Feldman wrote:
>> On Tue, May 26, 2015 at 12:28 AM, Scott Feldman <sfeldma@gmail.com> wrote:
>> > On Mon, May 25, 2015 at 5:55 PM, Simon Horman
>> > <simon.horman@netronome.com> wrote:
>> >> This will occur anyway if the 8021q module is loaded as it will
>> >> call rocker_port_vlan_rx_add_vid for vlan 0. This code is here
>> >> to handle the case where the 8021q module is not loaded.
>> >>
>> >> This patch also handles the case where the 8021q is unloaded
>> >> removing all VLANs from all ports.
>> >>
>> >> This change should not affect bridging, although the rules are
>> >> harmlessly installed anyway. This is in keeping with the behaviour
>> >> for VLANs when the 8021q modules is loaded.
>> >>
>> >> To aid implementation of the above provide a helper
>> >> and use it to replace some existing code.
>> >>
>> >> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>>
>> [cut]
>>
>> >
>> > Hi Simon,
>> >
>> > Thanks for looking into this one.  I looked at your patch and the code
>> > and I think we can streamline it a little bit more.  For the
>> > no-8021q-module case we use rocker_port_vlan_add() and
>> > rocker_port_vlan_del() to add/del bridge vlans.  We should be able to
>> > move those functions up in the file so they can be called from
>> > rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid(),
>> > passing trans=SWITCHDEV_TRANS_NONE, but only if vid != 0.  Next, like
>> > in your patch, we need to call rocker_port_vlan_add() in
>> > rocker_port_open(), passing in vid=0 for untagged.  And in
>> > rocker_port_stop(), call rocker_port_vlan_del(), again passing in
>> > vid=0.
>> >
>> > To summarize:
>> >
>> > Call rocker_port_vlan_add() from:
>> >
>> > 1) rocker_port_open with vid=0
>> > 2) rocker_port_vlans_add()                             // bridge vlan
>> > 3) rocker_port_vlan_rx_add_vid() if vid != 0       // 8021q vlan
>> >
>> > Call rocker_port_vlan_del() from:
>> >
>> > 1) rocker_port_stop with vid=0
>> > 2) rocker_port_vlans_del()                              // bridge vlan
>> > 3) rocker_port_vlan_rx_kill_vid() if vid != 0        // 8021q vlan
>> >
>> > Does this look right?
>
> It seems like it ought to work, I can try implementing the above
> idea if you think it is worthwhile.
>
> Can I clarify  that its ok to ignore vid != 0 in
> rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid()?
>
> If so I think that leads to an easy simplification of
> my proposed change to rocker_port_vlan_rx_kill_vid():
> the logic to restore vlan 0 if no vlans are present can be dropped.
>
> Of course your suggestion goes further than that.
>
>> Hmmmm...things get simpler if we removed support for 8021q module in
>> rocker driver by removing NETIF_F_HW_VLAN_CTAG_FILTER.  That gets rid
>> of rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid().
>> Leaving us with the bridge VLAN interface to add/del/show vlans on the
>> port.  I'm wondering if we can also avoid setting up untagged traffic
>> on the port during port open by requiring a explicit command on the
>> port from the user:
>>
>> bridge vlan add vid 0 dev DEV master self        // enable untagged
>> traffic on port
>
> I have some questions about that approach:
>
> * Does that behaviour differ from other devices
>   (that don't set NETIF_F_HW_VLAN_CTAG_FILTER)?
>   It seems like it may be an extra unnecessary step to me.

The answer is which drivers use bridge_setlink/bridge_dellink for
VLANs, which is none outside of switchdev drivers.

There are some drivers that use bridge_setlink (benet, i40e, ixgbe)
for setting hw_mode, but ignore the IFLA_BRIDGE_VLAN_INFO attr.

> * Does that behaviour change the current behaviour supported by rocker?
>   If so it seems unwise to change it.

I did some experiments, and with rocker there currently are two ways
to enable a port for rx untagged traffic:

1) Load the 8021q driver, which in turn will add vid=0 on interface
supporting NETIF_F_HW_VLAN_CTAG_FILTER, when interface opens.

2) Without 8021q driver loaded, by manually adding vid=0 to interface using:

       bridge vlan add vid=0 dev DEV self

> * Does the scheme described above work when rocker ports are not bridged?
>   This is the scenario I am interested in at this time.

Yes, confusingly, since the user command is "bridge vlan".  But the
command works for bridged or un-bridged ports.  In either case, by
targeting "self", the port driver's bridge_setlink/bridge_getlink are
called.  For switchdev port drivers, that means a call into
switchdev_port_bridge_setlink/switchdev_port_bridge_dellink.

In rocker, as an experiment, I removed NETIF_F_HW_VLAN_CTAG_FILTER
(and associated ndo ops), and was able to run/pass all my tests.  For
the tests with unbridged ports, I had to run "bridge vlan add vid=0
dev DEV self" before passing traffic.  The advantages of using
bridge_setlink/bridge_dellink for VLANs over 8021q module are:

1) single API to implement in port driver
2) can handle VLAN ranges efficiently (thanks Roopa!)
3) switchdev already handles stacked driver case (and transaction model)
4) includes support for PVID on bridge
5) includes support for egress untagged property on port
6) user space command included with iproute2 pkg

I see no disadvantages over using 8021q module.

One thing that's missing or incomplete is support for bridge_getlink
for VLANs.  Currently switchdev defaults to ndo_dflt_bridge_getlink()
which doesn't return any IFLA_BRIDGE_VLAN_INFO attrs.  And the "bridge
vlan show" command might need some help in displaying that info, it it
was available.  Cc:ing Ronen as he's been looking into bridge_getlink
for switchdev.

So I think since yesterday I'm becoming even more biased against 8021q
for switchdev.  For rocker, I think we need to figure out if the
driver does an automatic vid=0 install, say on ndo_open, and then a
removal on ndo_stop.  That would simplify the logic in
rocker_port_bridge_join()/leave().  Doing the automatic add makes the
device more like a NIC where passing untagged traffic is the baseline
default.

-scott

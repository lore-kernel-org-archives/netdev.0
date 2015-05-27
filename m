From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next] rocker: by default accept untagged packets
Date: Wed, 27 May 2015 10:07:05 +0900
Message-ID: <20150527010703.GA24249@vergenet.net>
References: <1432601703-26774-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bAEQDE0QCnfVet29BZ574vVFqBoXv_EbyhYXYvBqo_xEA@mail.gmail.com>
 <CAE4R7bBYK0zJbb_q0BUowh_jrrCMapVq8xouD5bv56hPXYGsWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35646 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbbE0BHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 21:07:11 -0400
Received: by pacwv17 with SMTP id wv17so105335949pac.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 18:07:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBYK0zJbb_q0BUowh_jrrCMapVq8xouD5bv56hPXYGsWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

On Tue, May 26, 2015 at 02:04:00AM -0700, Scott Feldman wrote:
> On Tue, May 26, 2015 at 12:28 AM, Scott Feldman <sfeldma@gmail.com> wrote:
> > On Mon, May 25, 2015 at 5:55 PM, Simon Horman
> > <simon.horman@netronome.com> wrote:
> >> This will occur anyway if the 8021q module is loaded as it will
> >> call rocker_port_vlan_rx_add_vid for vlan 0. This code is here
> >> to handle the case where the 8021q module is not loaded.
> >>
> >> This patch also handles the case where the 8021q is unloaded
> >> removing all VLANs from all ports.
> >>
> >> This change should not affect bridging, although the rules are
> >> harmlessly installed anyway. This is in keeping with the behaviour
> >> for VLANs when the 8021q modules is loaded.
> >>
> >> To aid implementation of the above provide a helper
> >> and use it to replace some existing code.
> >>
> >> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> [cut]
> 
> >
> > Hi Simon,
> >
> > Thanks for looking into this one.  I looked at your patch and the code
> > and I think we can streamline it a little bit more.  For the
> > no-8021q-module case we use rocker_port_vlan_add() and
> > rocker_port_vlan_del() to add/del bridge vlans.  We should be able to
> > move those functions up in the file so they can be called from
> > rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid(),
> > passing trans=SWITCHDEV_TRANS_NONE, but only if vid != 0.  Next, like
> > in your patch, we need to call rocker_port_vlan_add() in
> > rocker_port_open(), passing in vid=0 for untagged.  And in
> > rocker_port_stop(), call rocker_port_vlan_del(), again passing in
> > vid=0.
> >
> > To summarize:
> >
> > Call rocker_port_vlan_add() from:
> >
> > 1) rocker_port_open with vid=0
> > 2) rocker_port_vlans_add()                             // bridge vlan
> > 3) rocker_port_vlan_rx_add_vid() if vid != 0       // 8021q vlan
> >
> > Call rocker_port_vlan_del() from:
> >
> > 1) rocker_port_stop with vid=0
> > 2) rocker_port_vlans_del()                              // bridge vlan
> > 3) rocker_port_vlan_rx_kill_vid() if vid != 0        // 8021q vlan
> >
> > Does this look right?

It seems like it ought to work, I can try implementing the above
idea if you think it is worthwhile.

Can I clarify  that its ok to ignore vid != 0 in
rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid()?

If so I think that leads to an easy simplification of
my proposed change to rocker_port_vlan_rx_kill_vid():
the logic to restore vlan 0 if no vlans are present can be dropped.

Of course your suggestion goes further than that.

> Hmmmm...things get simpler if we removed support for 8021q module in
> rocker driver by removing NETIF_F_HW_VLAN_CTAG_FILTER.  That gets rid
> of rocker_port_vlan_rx_add_vid() and rocker_port_vlan_rx_kill_vid().
> Leaving us with the bridge VLAN interface to add/del/show vlans on the
> port.  I'm wondering if we can also avoid setting up untagged traffic
> on the port during port open by requiring a explicit command on the
> port from the user:
> 
> bridge vlan add vid 0 dev DEV master self        // enable untagged
> traffic on port

I have some questions about that approach:

* Does that behaviour differ from other devices
  (that don't set NETIF_F_HW_VLAN_CTAG_FILTER)?
  It seems like it may be an extra unnecessary step to me.
* Does that behaviour change the current behaviour supported by rocker?
  If so it seems unwise to change it.
* Does the scheme described above work when rocker ports are not bridged?
  This is the scenario I am interested in at this time.

> 
> Do you have a requirement for 8021q module?  I'm leaning towards a
> clean break from 8021q and using just the built-in bridge VLAN
> support.  I'm curious if others have an opinion about 8021q module
> used with switchdev devices.

I do not have a requirement on the 8021q module at this time.

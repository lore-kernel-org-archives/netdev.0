From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next] rocker: by default accept untagged packets
Date: Wed, 27 May 2015 16:42:40 +0900
Message-ID: <20150527074238.GA14409@vergenet.net>
References: <1432601703-26774-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bAEQDE0QCnfVet29BZ574vVFqBoXv_EbyhYXYvBqo_xEA@mail.gmail.com>
 <CAE4R7bBYK0zJbb_q0BUowh_jrrCMapVq8xouD5bv56hPXYGsWQ@mail.gmail.com>
 <20150527010703.GA24249@vergenet.net>
 <CAE4R7bAnR3ZprJaS_Ukm6L6AM-q4Zcm2Pwny9073pp_moCBfCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34594 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbbE0Hmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 03:42:46 -0400
Received: by pdbki1 with SMTP id ki1so3352818pdb.1
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 00:42:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAnR3ZprJaS_Ukm6L6AM-q4Zcm2Pwny9073pp_moCBfCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

On Wed, May 27, 2015 at 12:34:57AM -0700, Scott Feldman wrote:
> On Tue, May 26, 2015 at 6:07 PM, Simon Horman
> <simon.horman@netronome.com> wrote:

[snip]

> > I have some questions about that approach:
> >
> > * Does that behaviour differ from other devices
> >   (that don't set NETIF_F_HW_VLAN_CTAG_FILTER)?
> >   It seems like it may be an extra unnecessary step to me.
> 
> The answer is which drivers use bridge_setlink/bridge_dellink for
> VLANs, which is none outside of switchdev drivers.
> 
> There are some drivers that use bridge_setlink (benet, i40e, ixgbe)
> for setting hw_mode, but ignore the IFLA_BRIDGE_VLAN_INFO attr.
> 
> > * Does that behaviour change the current behaviour supported by rocker?
> >   If so it seems unwise to change it.
> 
> I did some experiments, and with rocker there currently are two ways
> to enable a port for rx untagged traffic:
> 
> 1) Load the 8021q driver, which in turn will add vid=0 on interface
> supporting NETIF_F_HW_VLAN_CTAG_FILTER, when interface opens.
> 
> 2) Without 8021q driver loaded, by manually adding vid=0 to interface using:
> 
>        bridge vlan add vid=0 dev DEV self
> 
> > * Does the scheme described above work when rocker ports are not bridged?
> >   This is the scenario I am interested in at this time.
> 
> Yes, confusingly, since the user command is "bridge vlan".  But the
> command works for bridged or un-bridged ports.  In either case, by
> targeting "self", the port driver's bridge_setlink/bridge_getlink are
> called.  For switchdev port drivers, that means a call into
> switchdev_port_bridge_setlink/switchdev_port_bridge_dellink.

That is indeed confusing.

> In rocker, as an experiment, I removed NETIF_F_HW_VLAN_CTAG_FILTER
> (and associated ndo ops), and was able to run/pass all my tests.  For
> the tests with unbridged ports, I had to run "bridge vlan add vid=0
> dev DEV self" before passing traffic.  The advantages of using
> bridge_setlink/bridge_dellink for VLANs over 8021q module are:
> 
> 1) single API to implement in port driver
> 2) can handle VLAN ranges efficiently (thanks Roopa!)
> 3) switchdev already handles stacked driver case (and transaction model)
> 4) includes support for PVID on bridge
> 5) includes support for egress untagged property on port
> 6) user space command included with iproute2 pkg
> 
> I see no disadvantages over using 8021q module.
> 
> One thing that's missing or incomplete is support for bridge_getlink
> for VLANs.  Currently switchdev defaults to ndo_dflt_bridge_getlink()
> which doesn't return any IFLA_BRIDGE_VLAN_INFO attrs.  And the "bridge
> vlan show" command might need some help in displaying that info, it it
> was available.  Cc:ing Ronen as he's been looking into bridge_getlink
> for switchdev.
> 
> So I think since yesterday I'm becoming even more biased against 8021q
> for switchdev.  For rocker, I think we need to figure out if the
> driver does an automatic vid=0 install, say on ndo_open, and then a
> removal on ndo_stop.  That would simplify the logic in
> rocker_port_bridge_join()/leave().  Doing the automatic add makes the
> device more like a NIC where passing untagged traffic is the baseline
> default.

My feeling at this time is that it would be nice to to the automatic add
to make rocker feel more like a NIC. That is the behaviour that I for
one would expect without other knowledge of the situation.

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH V2 00/12] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 21:37:16 +0200
Message-ID: <20121219213716.778d6449.shmulik.ladkani@gmail.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
	<20121219101006.7086faef@pixies.home.jungo.com>
	<50D1CB76.50202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:64561 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab2LSTqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 14:46:24 -0500
Received: by mail-wg0-f43.google.com with SMTP id e12so1156225wge.22
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 11:46:23 -0800 (PST)
In-Reply-To: <50D1CB76.50202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Wed, 19 Dec 2012 09:13:10 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> > Why the "untagged vlan" is per-bridge global?
> It's not.  There is a per port untagged pointer where you can designate 
> which VLAN is untagged/native on a port.

Ok (misinterpreted the text in the cover letter).

> > 802.1q switches usually allow conifguring per-vlan, per-port
> > tagged/untagged egress policy: each vid has its port membership map and
> > an accompanying port egress-policy map.
> > This gives great flexibility defining all sorts of configurations.
> 
> Right, and that's what's provided here.
>   * Each VLAN has port membership map (net_bridge_vlan.portgroup).
>   * Each port has a list of vlans configured as well 
> (net_port_vlan.vlan_list).
>   * Each port also has a single vlan that can be untagged 
> (net_bridge_port.untagged).
>   * The bridge also has a single untagged vlan (net_bridge.untagged)
> 
> The limitation (in switches as well) is that only a single VLAN
> may be untagged on any 1 port. 

Switches usually allow you to configure each port's egress policy per
vlan, and allow you to configure multiple vlans to _egress_ untagged
on a port.

> If you have more then 1, you don't know
> which VLAN the untagged traffic belongs to.

The port's PVID uniquely determines VID to associate with the frame
during _ingress_ on that port - in the case frame arrived untagged.

This is unrelated to whether a frame having a specific VID would _egress_
tagged or untagged on that port.

> > Personally, I'd prefer a fully flexible vlan bridge allowing all sorts
> > of configurations (as available in 802.1q switches).
> >
> > What's the reason limiting such configurations?
> 
> So, what do you see that's missing?

I suspect some configurations wouldn't be possible at current design,
please let me know what do you think.

Take for example such a configuration:

 +---+---+
 |   |   |
p1  p2   p3

A bridge with 3 ports: p1 p2 p3.
(the bridge interface itself is irrelevant for this discussion)
	
This setup expects all traffic at those ports to be untagged.

I'd like p1 to be bridged to p2, but not to p3.

I'd like p3 to be bridged to p2, but not to p1.

Set the following:

p1 - PVID is 1
    member of VLANs 1(egress untagged), 2(egress untagged)

p3 - PVID is 3
    member of VLANs 3(egress untagged), 2(egress untagged)

p2 - PVID is 2
    member of VLANs 1,2,3 (all egress untagged)

Or putting it differently:

VLAN 1 ports membership: p1, p2
       egress policy:    U   U

VLAN 2 ports membership: p1, p2, p3
       egress policy:    U   U   U

VLAN 3 ports membership:     p2, p3
       egress policy:        U   U

Now, untagged traffic arriving at p1 will be assigned its PVID, which
is 1, an thus forced to egress via p2 (the only other member of VLAN 1).
Upon egress on p2, it will egress untagged.

(similarly for ingress in p3, only egress at p2 is possible, again
 untagged).

If untagged traffic arrives at p2, it will be assigned its PVID, which
is 2, and thus it may egress on either p1 or p3 (they are both members
of VLAN 2).
Actual port of egress is according to FDB match.
Again egress would be untagged.

This setup might sound exotic, but similar patterns may be used in
reality.
Although the example is synthetic and simplistic, still it demonstrates
the vast flexibility allowed by a 802.1q bridge.

The bridge constructs needed for supporting such setups are:
- per port: PVID
- per VLAN: port membership map
- per VLAN: port egress policy map

I agree, tools other than a vlan bridge may implement such setups, but
using the vlan bridge would be preferred, mainly due to the simplicity.

Regards,
Shmulik

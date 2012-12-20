From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 03/13] bridge: Validate that vlan is
 permitted on ingress
Date: Thu, 20 Dec 2012 18:24:02 +0200
Message-ID: <20121220182402.6143fcb1@pixies.home.jungo.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
	<1355939304-21804-4-git-send-email-vyasevic@redhat.com>
	<20121220160713.30cdfc05@pixies.home.jungo.com>
	<50D331A8.3080206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:64081 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063Ab2LTQYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 11:24:08 -0500
Received: by mail-wg0-f49.google.com with SMTP id 15so1558643wgd.4
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 08:24:07 -0800 (PST)
In-Reply-To: <50D331A8.3080206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2012 10:41:28 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> >> +static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
> >> +{
> >> +	struct net_port_vlan *pve;
> >> +	u16 vid;
> >> +
> >> +	/* If there are no vlan in the permitted list, all packets are
> >> +	 * permitted.
> >> +	 */
> >> +	if (list_empty(&p->vlan_list))
> >> +		return true;
> >
> > I assumed the default policy would be Drop in such case, otherwise
> > leaking between vlan domains is possible.
> > Or maybe, ingress policy when port isn't a member of ingress VID should
> > be configurable (drop/allow).
> 
> We have have to default to allow since we want to retain original bridge 
> functionality if there is no configuration.

Ok; so having the port not a member of ANY vlan is a "port vlan
disabled" configuration knob, and as such, it is a member of ANY vlan,
meaning that:

(1) every "non-vlan port" is connected to any other "non-vlan port"
(2) frame ingress on a "non-vlan" port may egress on a "vlan enabled"
  port, depending on the ingress VID and the port-membership map of the
  egress port
  (and thus, PVID should be defined even to "non-vlan" ports, for the
  case where untagged frame is received on the non-vlan port)
(3) frame ingress on a "vlan-enabled" port would always egress on
  "non-vlan" ports

Seems ok.
However this is an additional nuance that might not be expected by the
user configuring the bridge; maybe this needs some clarification.

> >> +	vid = br_get_vlan(skb);
> >> +	pve = nbp_vlan_find(p, vid);
> >
> > Why search by iterating through NBP's vlan_list?
> > You know the VID (hence may fetch the net_bridge_vlan from the hash), so
> > why don't you directly consult the net_bridge_vlan's port_bitmap?
> 
> It's an alternative...  I am betting that this port isn't in too many 
> vlans and that searching the list might be faster.

I assumed the opposite: finding the hash bucket is just a bitwise mask,
and number of items in a bucket would rarely be grater than 1.
I expect such code to be shorter, but this needs to be verified.

Regards,
Shmulik

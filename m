From: Simon Horman <simon.horman@netronome.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 17:38:01 +0900
Message-ID: <20150226083758.GA15139@vergenet.net>
References: <20150226074214.GF2074@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, jpettit@nicira.com,
	joestringer@nicira.com, john.r.fastabend@intel.com,
	jhs@mojatatu.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44445 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbBZIiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 03:38:18 -0500
Received: by pdbnh10 with SMTP id nh10so11392834pdb.11
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 00:38:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150226074214.GF2074@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Thu, Feb 26, 2015 at 08:42:14AM +0100, Jiri Pirko wrote:
> Hello everyone.
> 
> I would like to discuss big next step for switch offloading. Probably
> the most complicated one we have so far. That is to be able to offload flows.
> Leaving nftables aside for a moment, I see 2 big usecases:
> - TC filters and actions offload.
> - OVS key match and actions offload.
> 
> I think it might sense to ignore OVS for now. The reason is ongoing efford
> to replace OVS kernel datapath with TC subsystem. After that, OVS offload
> will not longer be needed and we'll get it for free with TC offload
> implementation. So we can focus on TC now.
> 
> Here is my list of actions to achieve some results in near future:
> 1) finish cls_openflow classifier and iproute part of it
> 2) extend switchdev API for TC cls and acts offloading (using John's flow api?)
> 3) use rocker to provide offload for cls_openflow and couple of selected actions
> 4) improve cls_openflow performance (hashtables etc)
> 5) improve TC subsystem performance in both slow and fast path
>     -RTNL mutex and qdisc lock removal/reduction, lockless stats update.
> 6) implement "named sockets" (working name) and implement TC support for that
>     -ingress qdisc attach, act_mirred target
> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
> 8) implement TC act_mpls
> 9) suggest to switch OVS userspace from OVS genl to TC API
> 
> This is my personal action list, but you are *very welcome* to step in to help.
> Point 2) haunts me at night....
> I believe that John is already working on 2) and part of 3).
> 
> What do you think?

>From my point of view the question of replacing the kernel datapath with TC
is orthogonal to the question of flow offloads. This is because I believe
there is some consensus around the idea that, at least in the case of Open
vSwitch, the decision to offload flows should made in user-space where
flows are already managed. And in that case datapath will not be
transparently offloading of flows.  And thus flow offload may be performed
independently of the kernel datapath, weather that be via flow manipulation
portions of John's Flow API, TC, or some other means.

Regardless of the above, I have three question relating to the scheme you
outline above:

1. Open vSwitch flows are independent of a device. My recollection
   is that while they typically match in the in_port (ingress port)
   this is not a requirement. Conversely my understanding is that
   TC classifiers attach to a netdev. I'm wondering how this
   difference can be reconciled.

   I asked this question at your presentation at Netdev 0.1 and Jamal
   indicated a possibility was to attach to the bridge netdev. But unless I
   misunderstand things that would actually have the effect of a flow
   matching in_port=host.

   Of course things could be changed around to give the behaviour that
   Jamal described. Or perhaps it is already the case. But then
   how would one match on in_port=host?

2. In a similar vein, does the named sockets approach allow for the scheme
   that Open vSwitch supports of matching on in_port=tunnel_port.

3. As mentioned above my understanding is that there is some consensus that
   there should be a mechanism to allow decisions about which flows are
   offloaded to be managed by user-space.

   It seems to me that could be achieved within the context of what
   you describe above using a flag or similar denoting weather a flow
   should be added to hardware or software. Or perhaps two flags allowing
   for a flow to be added to both hardware and software. Am I on the
   right track here?

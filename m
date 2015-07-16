From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [RFC net-next 22/22] openvswitch: Use regular GRE net_device
 instead of vport
Date: Thu, 16 Jul 2015 14:36:19 -0700
Message-ID: <CALnjE+omzvWop3T2bD_Yp9gW3XN-9NbeEnCmh615iNqJH2dvog@mail.gmail.com>
References: <cover.1436537414.git.tgraf@suug.ch>
	<74f200a9e634a9fefd6de85265f54b8a6697ab72.1436537414.git.tgraf@suug.ch>
	<20150716085915.GA11294@penelope.isobedori.kobe.vergenet.net>
	<20150716145246.GC22603@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>, rshearma@brocade.com,
	ebiederm <ebiederm@xmission.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, tom@herbertland.com,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	marcelo.leitner@gmail.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Justin Pettit <jpettit@nicira.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35470 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755768AbbGPVgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 17:36:20 -0400
Received: by igcqs7 with SMTP id qs7so24243469igc.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 14:36:20 -0700 (PDT)
In-Reply-To: <20150716145246.GC22603@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 7:52 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/16/15 at 05:59pm, Simon Horman wrote:
>> On Fri, Jul 10, 2015 at 04:19:24PM +0200, Thomas Graf wrote:
>> >  static void ipgre_tap_setup(struct net_device *dev)
>> >  {
>> >     ether_setup(dev);
>> > -   dev->netdev_ops         = &gre_tap_netdev_ops;
>> >     dev->priv_flags         |= IFF_LIVE_ADDR_CHANGE;
>> >     ip_tunnel_setup(dev, gre_tap_net_id);
>> > +
>> > +   if (!strcmp(dev->name, GRE_TAP_FB_NAME))
>> > +           dev->netdev_ops         = &gre_fb_netdev_ops;
>> > +   else
>> > +           dev->netdev_ops         = &gre_tap_netdev_ops;
>> >  }
>> >
>> >  static int ipgre_newlink(struct net *src_net, struct net_device *dev,
>>
>> [snip]
>>
>> Is there a side-effect of the above that if a user creates a gretap device
>> whose name is "gretap0" then the device will use gre_fb_netdev_ops instead
>> of gre_tap_netdev_ops. If so, does that imply a change in behaviour for
>> gretap devices created with that name?
>
Reason for checking the name is to switch to different xmit function
for flow based and non flow based devices. I did it to avoid checking
tunnel-info on every xmit. But vxlan does the check on xmit. So I will
change it so that there is no need to define another ops structure.
This way we can share same gre-tap-ops for flow based and non flow
based devices.

> I'm inclined to change this and use an in-kernel API as well to
> create the net_device just like VXLAN does in patch 21.
>
> Pravin, what do you think?

About the vxlan APIs we also need to direct netlink interface for
userspace to configure vxlan device. This will allow us to remove
vxlan compat code from ovs vport-netdev.c in future.

From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 20 May 2016 18:12:05 +0900
Message-ID: <20160520091202.GC17561@vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <20160517163250.7ead555e@griffin>
 <20160520052858.GA15505@vergenet.net>
 <20160520100028.0065a2ef@griffin>
 <20160520081120.GA17561@vergenet.net>
 <20160520081611.GB17561@vergenet.net>
 <20160520103939.723f2a42@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33327 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932150AbcETJMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 05:12:15 -0400
Received: by mail-pa0-f49.google.com with SMTP id xk12so37975343pac.0
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 02:12:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160520103939.723f2a42@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 20, 2016 at 10:39:39AM +0200, Jiri Benc wrote:
> On Fri, 20 May 2016 17:16:13 +0900, Simon Horman wrote:
> > My understanding is that currently OvS handles access ports using a
> > push_vlan action.
> 
> When needed (i.e. when the packet goes to a non-access port), yes.
> 
> > And that this patch set in conjunction with its
> > user-space counterpart should ensure that a push_eth action occurs first.
> > This is the context of my remarks above.
> 
> Okay, works for me principally. If it's later found insufficient,
> relaxing push_vlan and pop_vlan to work also for L3 frames is still
> easily possible without breaking compatibility.

Right. I'm all for allowing extension later if the need arises.

> Out of curiosity (and without looking at the user space patchset), what
> will the pushed Ethernet header contain? E.g., consider the following
> scenario: two GRE ports, both set as access ports with the same tag,
> and a mirror port mirroring everything. Now an IP packet without inner
> Ethernet header is received on one of the GRE interfaces.
> 
> Will the packet be output to the second GRE port? Will it be sent out
> without the inner Ethernet header? Are custom rules necessary, or will
> NORMAL take care of this? What will be sent to the mirror port?

Let me take a stab at answering that without running any tests.

1. push_eth adds an Ethernet header with all-zero addresses and
   the Ethernet type as determined from skb->protocol which is in
   turn determined by the tunnel header (we have discussed that
   bit before).

   In principle it is pushed when needed. And this happens automatically
   as controlled by user-space.

   It is possible to modify the Ethernet addresses using a custom rule.
   (I need to exercise that more often.)

2. For the GRE part of the scenario above it is important to know that with
   the accompanying user-space patch set OvS user-space the user-space
   representation of a vport (from now on simply vport) may be "layer3" or
   not.

   This allows OvS user-space to determine if an Ethernet header should be
   present or not on receive. And if it needs to be present or not on
   transmit. This allows it to automatically use pop_eth and push_eth to
   control the presence of an Ethernet header so its there when it needs to
   be and not when it doesn't.

   So if a GRE vport is "layer3" then no Ethernet header should be
   present on transmit, regardless of where the packet came from. And
   conversely if the GRE vport is not "layer3" then an Ethernet header
   should be present.

3. With regards to the mirroring part of your connection, I need to check
   on that and possibly its broken. But my thinking is that a mirroring
   vport would regarded in the same way as any other vport in this respect
   and the presence of the "layer3" flag would control whether an Ethernet
   header is present or not.

   It may be the case that its not possible to use a tunnel vport as a
   mirroring vport. And as all other vports currently do not support
   "layer3" then currently an Ethernet header would always be present
   on output to a mirror.

From: Cong Wang <amwang@redhat.com>
Subject: A question on the design of OVS GRE tunnel
Date: Mon, 08 Jul 2013 17:51:05 +0800
Message-ID: <1373277065.8227.26.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@nicira.com>, Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462Ab3GHJvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jul 2013 05:51:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jesse, Pravin

I have a question on the design of OVS GRE tunnel. Why OVS GRE tunnel
doesn't register a netdev? I understand it is enough for GRE to function
without registering a netdev, just a GRE vport is sufficient and
probably even simpler.

However, I noticed there is some problem with such design:

I saw very bad performance with the _default_ setup with OVS GRE. After
digging it a little bit, clearly the cause is that OVS GRE tunnel adds
an outer IP header and a GRE header for every packet that passed to it,
which could result in a packet whose length is larger than the MTU of
the uplink, therefore after the packet goes through OVS, it has to be
fragmented by IP before going to the wire.

Of course we can workaround this problem by:

1) lower down the MTU of the first net device to reserve some room for
GRE header

2) pass vnet_hdr=on to KVM guests so that packets going out there are
still GSO packets even on hosts (I never try this, just analysis it by
reading code)

Do we have to live with this? Can we solve this problem at OVS layer? So
that no matter how large the packets are we can avoid IP fragmentation?
One solution in my mind is registering a netdev for OVS GRE tunnel too,
so that we could probably reuse GRO cells, thus packets can be merged
before OVS processing them, and it will be segmented again before going
to the wire. But I could easily miss something here. ;)

What do you think? Any better idea to fix this?

Thanks!

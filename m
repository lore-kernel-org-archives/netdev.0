From: Jesse Gross <jesse@nicira.com>
Subject: Open vSwitch Design
Date: Thu, 24 Nov 2011 12:10:42 -0800
Message-ID: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Chris Wright <chrisw@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Justin Pettit <jpettit@nicira.com>, jhs@mojatatu.com
To: netdev <netdev@vger.kernel.org>, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64119 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab1KXULE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 15:11:04 -0500
Received: by ghrr1 with SMTP id r1so2848258ghr.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 12:11:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I realized that since Open vSwitch is so userspace-centric some of the
design considerations might not be apparent from the kernel code
alone.  I did a poor job of explaining the larger picture which has
lead to some misconceptions, so I thought it would be helpful if I
gave a short overview.

One of the driving goals was to push as much logic as possible to
userspace, so the kernel portion is less than 6000 lines and has four
components:

 * Switching infrastructure:  As the name implies, Open vSwitch is
intended to be a network switch, focused on
virtualization/OpenFlow/software defined networking.  This means that
what we are modeling is not actually a collection of flows but a
switch which contains a group of related ports, a software virtual
device, etc.  The switch model is used in a variety of places, such as
to measure traffic that actually flows through it in order to
implement monitoring and sampling protocols.

 * Flow lookup:  Although used to implement OpenFlow, the kernel flow
table does not actually directly contain OpenFlow flows.  This is
because OpenFlow tables can contain wildcards, multiple pipeline
stages, etc. and we did not want to push that complexity into the
kernel fast path (nor tie it to a specific version of OpenFlow).
Instead an exact match flow table is populated on-demand from
userspace based on the more complex rules stored there.  Although it
might seem limiting, this design has allowed significant new
functionality to be added without modifications to the kernel or
performance impact.

 * Packet execution:  Once a flow is matched it can be output,
enqueued to a particular qdisc, etc.  Some of these operations are
specific to Open vSwitch, such as sampling, whereas others we leverage
existing infrastructure (including tc for QoS) by simply marking the
packet for further processing.

 * Userspace interfaces:  One of the difficulties of having a
specialized, exact match flow lookup engine is maintaining
compatibility across differing kernel/userspace versions.  This
compatibility shows up heavily in the userspace interfaces and is
achieved by passing the kernel's version of the flow along with packet
information.  This allows userspace to install appropriate flows even
if its interpretation of a packet differs from the kernel's without
version checks or maintaining multiple implementations of the flow
extraction code in the kernel.

It's obviously possible to put this code anywhere, whether it is an
independent module, in the bridge, or tc.  Regardless, however, it's
largely new code that is geared towards this particular model so it
seems better not to add to the complexity of existing components if at
all possible.

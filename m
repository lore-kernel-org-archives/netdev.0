From: Cong Wang <amwang@redhat.com>
Subject: Re: A question on the design of OVS GRE tunnel
Date: Tue, 09 Jul 2013 10:41:06 +0800
Message-ID: <1373337666.4557.13.camel@cr0>
References: <1373277065.8227.26.camel@cr0>
	 <CALnjE+q4L9Q8Ebj+O-D8xQHyzSo=FZrb7A-XVEGERzeN-MZMGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36076 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564Ab3GIClo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jul 2013 22:41:44 -0400
In-Reply-To: <CALnjE+q4L9Q8Ebj+O-D8xQHyzSo=FZrb7A-XVEGERzeN-MZMGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-08 at 09:28 -0700, Pravin Shelar wrote:
> On Mon, Jul 8, 2013 at 2:51 AM, Cong Wang <amwang@redhat.com> wrote:
> > Hi, Jesse, Pravin
> >
> > I have a question on the design of OVS GRE tunnel. Why OVS GRE tunnel
> > doesn't register a netdev? I understand it is enough for GRE to function
> > without registering a netdev, just a GRE vport is sufficient and
> > probably even simpler.
> >
> kernel-gre device has gre-parameters/state associated with it and
> ovs-gre-vport is completely stateless. ovs-gre state is in user-space
> which make kernel module alot simpler. Therefore I doubt it will be
> easy or simpler to use netdev at this point.

Understood, from users' point of view, it is simpler. At least no one is
able to assign any IP address to it.

> 
> > However, I noticed there is some problem with such design:
> >
> > I saw very bad performance with the _default_ setup with OVS GRE. After
> > digging it a little bit, clearly the cause is that OVS GRE tunnel adds
> > an outer IP header and a GRE header for every packet that passed to it,
> > which could result in a packet whose length is larger than the MTU of
> > the uplink, therefore after the packet goes through OVS, it has to be
> > fragmented by IP before going to the wire.
> >
> I do not understand what do you mean, gre packets greater than MTU
> must be fragmented before sent on wire and it is done by GRE-GSO code.
> 

Well, I said fragment, not segment. This is exactly why performance is
so bad.

In my _default_ setup, every net device on the path has MTU=1500,
therefore, the packets coming out of a KVM guest can have length=1500,
after they go through OVS GRE tunnel, their length becomes 1538 because
of the added GRE header and IP header.

After that, since the packets are not GSO (unless you pass vnet_hdr=on
to KVM guest), the packets with length=1538 will be _fragmented_ by IP
layer, since the dest uplink has MTU=1500 too. This is why I proposed to
reuse GRO cell to merge the packets, which requires a netdev...

This is the problem.

From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v3 net-next 3/3] openvswitch: Fix skb->protocol for vlan
 frames.
Date: Fri, 2 Dec 2016 10:42:02 +0100
Message-ID: <20161202104202.426b2c80@griffin>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
        <1480462253-114713-3-git-send-email-jarno@ovn.org>
        <20161130153041.7a9590ef@griffin>
        <CAOrHB_CAR8G=BF6X_+HgkRRnb=Erc6CYpCL4EnJfDRe7qBR2vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39194 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751786AbcLBJmF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 04:42:05 -0500
In-Reply-To: <CAOrHB_CAR8G=BF6X_+HgkRRnb=Erc6CYpCL4EnJfDRe7qBR2vg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Dec 2016 12:31:09 -0800, Pravin Shelar wrote:
> On Wed, Nov 30, 2016 at 6:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > I'm not opposed to changing this but I'm afraid it needs much deeper
> > review. Because with this in place, no core kernel functions that
> > depend on skb->protocol may be called from within openvswitch.
> >
> Can you give specific example where it does not work?

I can't, I haven't reviewed the usage. I'm just saying that the stack
does not expect skb->protocol being ETH_P_8021Q for e.g. IPv4 packets.
It may not be relevant for the calls used by openvswitch but we should
be sure about that. Especially defragmentation and conntrack is worth
looking at.

Again, I'm not saying this is wrong nor that there is an actual
problem. I'm just pointing out that openvswitch has different
expectations about skb wrt. vlans than the rest of the kernel and we
should be reasonably sure the behavior is correct when passing between
the two.

> skb-protocol value is set by the caller, so it should not be
> arbitrary. is it missing in any case?

It's not set exactly by the caller, because that's what this patch is
removing. It is set by whoever handed over the packet to openvswitch.
The point is we don't know *what* it is set to. It may as well be
ETH_P_8021Q, breaking the conditions here. It should not happen in
practice but still, it seems weird to depend on the fact that the
packet coming to ovs has never skb->protocol equal to ETH_P_8021Q nor
ETH_P_8021AD.

 Jiri

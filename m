From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Fri, 23 Jan 2015 13:22:17 +0100
Message-ID: <1422015737.2824.8.camel@stressinduktion.org>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
	 <20150122224033.6e2db5ce@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53730 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750836AbbAWMWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 07:22:19 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 478D420990
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:22:19 -0500 (EST)
In-Reply-To: <20150122224033.6e2db5ce@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2015-01-22 at 22:40 -0800, Stephen Hemminger wrote:
> On Wed, 14 Jan 2015 12:17:19 -0700
> David Ahern <dsahern@gmail.com> wrote:
> 
> > Currently, ipv6 addresses are flushed when the interface is configured down:
> > 
> > [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> > [root@f20 ~]# ip addr show dev eth1
> > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
> >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> >     inet6 2000:11:1:1::1/64 scope global tentative
> >        valid_lft forever preferred_lft forever
> > [root@f20 ~]# ip link set dev eth1 up
> > [root@f20 ~]# ip link set dev eth1 down
> > [root@f20 ~]# ip addr show dev eth1
> > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
> >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> > 
> > Add a new sysctl to make this behavior optional. Setting defaults to flush
> > addresses to maintain backwards compatibility. When reset flushing is bypassed:
> > 
> > [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
> > [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> > [root@f20 ~]# ip addr show dev eth1
> > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
> >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> >     inet6 2000:11:1:1::1/64 scope global tentative
> >        valid_lft forever preferred_lft forever
> > [root@f20 ~]#  ip link set dev eth1 up
> > [root@f20 ~]#  ip link set dev eth1 down
> > [root@f20 ~]# ip addr show dev eth1
> > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
> >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> >     inet6 2000:11:1:1::1/64 scope global
> >        valid_lft forever preferred_lft forever
> >     inet6 fe80::4:11ff:fe22:3301/64 scope link
> >        valid_lft forever preferred_lft forever
> > 
> > Suggested-by: Hannes Frederic Sowa <hannes@redhat.com>
> > Signed-off-by: David Ahern <dsahern@gmail.com>
> > Cc: Hannes Frederic Sowa <hannes@redhat.com>
> 
> Would this break existing application expecting a particular semantic
> by listening to netlink?  What happens to packets received with the static
> address when interface is down? With IPv4 Linux is mostly a weak host
> model, and IPv6 somewhere in between.

IPv6 is mostly a weak end model, too, but IFA_LINK addresses are used
much more. So yes, it is somewhere in between.

Addresses bound to interfaces which are currently down will work with
IPv6 (in contrast to IPv4).

> For vendors that control the application stack or have limited number
> of services this would work fine, but what about RHEL?

The new model is only enabled if the sysctl is set. I don't expect a lot
of vendors or distributions switching anytime soon.

I wonder if we should try to come up with a way of IPV6_NEW_WORLD_ORDER
we can make some changes to the stack which align much better with the
RFCs, e.g. no default link local address generation, no default on-link
routes etc.

Bye,
Hannes

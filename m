From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Mon, 26 Jan 2015 23:56:53 -0500
Message-ID: <20150127045653.GB13164@gospo.home.greyhouse.net>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>
 <20150122224033.6e2db5ce@urahara>
 <1422015737.2824.8.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:58593 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbA0E45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 23:56:57 -0500
Received: by mail-qa0-f49.google.com with SMTP id v8so9976402qal.8
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 20:56:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1422015737.2824.8.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2015 at 01:22:17PM +0100, Hannes Frederic Sowa wrote:
> On Do, 2015-01-22 at 22:40 -0800, Stephen Hemminger wrote:
> > On Wed, 14 Jan 2015 12:17:19 -0700
> > David Ahern <dsahern@gmail.com> wrote:
> > 
> > > Currently, ipv6 addresses are flushed when the interface is configured down:
> > > 
> > > [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> > > [root@f20 ~]# ip addr show dev eth1
> > > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
> > >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> > >     inet6 2000:11:1:1::1/64 scope global tentative
> > >        valid_lft forever preferred_lft forever
> > > [root@f20 ~]# ip link set dev eth1 up
> > > [root@f20 ~]# ip link set dev eth1 down
> > > [root@f20 ~]# ip addr show dev eth1
> > > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
> > >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> > > 
> > > Add a new sysctl to make this behavior optional. Setting defaults to flush
> > > addresses to maintain backwards compatibility. When reset flushing is bypassed:
> > > 
> > > [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
> > > [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> > > [root@f20 ~]# ip addr show dev eth1
> > > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
> > >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> > >     inet6 2000:11:1:1::1/64 scope global tentative
> > >        valid_lft forever preferred_lft forever
> > > [root@f20 ~]#  ip link set dev eth1 up
> > > [root@f20 ~]#  ip link set dev eth1 down
> > > [root@f20 ~]# ip addr show dev eth1
> > > 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
> > >     link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
> > >     inet6 2000:11:1:1::1/64 scope global
> > >        valid_lft forever preferred_lft forever
> > >     inet6 fe80::4:11ff:fe22:3301/64 scope link
> > >        valid_lft forever preferred_lft forever
> > > 
> > > Suggested-by: Hannes Frederic Sowa <hannes@redhat.com>
> > > Signed-off-by: David Ahern <dsahern@gmail.com>
> > > Cc: Hannes Frederic Sowa <hannes@redhat.com>
> > 
> > Would this break existing application expecting a particular semantic
> > by listening to netlink?  What happens to packets received with the static
> > address when interface is down? With IPv4 Linux is mostly a weak host
> > model, and IPv6 somewhere in between.
> 
> IPv6 is mostly a weak end model, too, but IFA_LINK addresses are used
> much more. So yes, it is somewhere in between.
> 
> Addresses bound to interfaces which are currently down will work with
> IPv6 (in contrast to IPv4).
> 
> > For vendors that control the application stack or have limited number
> > of services this would work fine, but what about RHEL?
> 
> The new model is only enabled if the sysctl is set. I don't expect a lot
> of vendors or distributions switching anytime soon.

You are probably correct that many will not switch, but this sysctl
gives those who want to switch a nice option without having to carry
extra kernel patches.  I like it.

I have been pondering a few different changes to interface address and
route behavior on both interface and link (gasp!) down and would like to
use sysctls to make those options available to those who are interested
without changing the current model.

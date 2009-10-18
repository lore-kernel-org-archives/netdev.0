From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Question about IPV6 forwarding and proxy_ndp
Date: Sun, 18 Oct 2009 00:30:30 -0700
Message-ID: <55a4f86e0910180030s52484bffs4ca42eb1ff4d5131@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Networking <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:44603 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbZJRHa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 03:30:26 -0400
Received: by fxm18 with SMTP id 18so3898292fxm.37
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 00:30:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to have a machine:

* do IPv6 forwarding
- thus "echo 1 > /proc/sys/net/ipv6/conf/all/forwarding"

* accept router advertisements and default route from eth0
- thus "echo 0 > /proc/sys/net/ipv6/conf/eth0/forwarding"

* do proxy NDP on eth0 for a specific v6 address
- thus "echo 1 > /proc/sys/net/ipv6/conf/eth0/proxy_ndp"
- and "ip -6 neigh add proxy ${PROXIED_V6_IP} dev eth0"

Problem is, this doesn't work (no ndp responses for the proxied v6 ip)...
While, if I "echo 1 > /proc/sys/net/ipv6/conf/eth0/forwarding" than
proxy ndp starts working, but I lose my default route...

I think the problem is at:

http://lxr.linux.no/linux+v2.6.31/net/ipv6/ndisc.c#L832

 831                if (ipv6_chk_acast_addr(net, dev, &msg->target) ||
 832                    (idev->cnf.forwarding &&
 833                     (net->ipv6.devconf_all->proxy_ndp ||
idev->cnf.proxy_ndp) &&
 834                     (is_router = pndisc_is_router(&msg->target,
dev)) >= 0)) {
 835                        if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 836                            skb->pkt_type != PACKET_HOST &&
 837                            inc != 0 &&
 838                            idev->nd_parms->proxy_delay != 0) {

notice that we require idev->cnf.forwarding to be true.

Should this perhaps be changed to
    (net->ipv6.devconf_all->forwarding || idev->cnf.forwarding)

or even just
    net->ipv6.devconf_all->forwarding
?

It's not clear to me what the reasoning behind that if statement is...

- Maciej

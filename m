From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: Issue with GRE tunnel, created with "local any" on kernel 3.14
Date: Fri, 18 Jul 2014 22:32:04 +0400
Message-ID: <20140718223204.9422aa8df81f7ac5187588bb@qrator.net>
References: <53C91AA3.1020106@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Sergey Popov <pinkbyte@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:60115 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945934AbaGRScJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 14:32:09 -0400
Received: by mail-lb0-f171.google.com with SMTP id l4so3171646lbv.16
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2014 11:32:07 -0700 (PDT)
In-Reply-To: <53C91AA3.1020106@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Jul 2014 17:01:23 +0400
Sergey Popov <pinkbyte@gentoo.org> wrote:

> Hi. I have updated kernel on one of my servers to 3.14 and hit strange
> issue:

> serv1(172.30.0.100) <-> serv2(172.30.0.251)

> Gre tunnel(serv1):
> ip tunnel add tun_test mode gre remote 172.30.0.251 local any ttl 225
> ifconfig tun_test 192.168.0.1/30
> 
> Gre tunnel(serv2):
> ip tunnel add tun_test mode gre remote 172.30.0.100 local any ttl 225
> ifconfig tun_test 192.168.0.2/30

> 16:49:39.340971 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
> 192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 7, length 64

Hi!

It seems we have this issue since 7d442fab0 (ipv4: Cache dst in tunnels).
It is in ip_tunnel_xmit: fl4 is initialized with saddr = 0 in
init_tunnel_flow(&fl4, protocol, dst, ...), net/ipv4/ip_tunnel.c:610,
and isn't changed until iptunnel_xmit(skb->sk, ...), line 677, because 
connected = true and rt is almost always cached.

I have no patch to fix this issue, but as a workaround, you can use 
ip tunnel change tun_test tos inherit.

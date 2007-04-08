From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: two gateways with one NIC
Date: Sun, 8 Apr 2007 14:22:10 -0400
Message-ID: <20070408182210.GJ3508@csclub.uwaterloo.ca>
References: <1176003353.686.45.camel@owl.home.ie> <20070408150123.GA3511@csclub.uwaterloo.ca> <1176048615.686.78.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: W Agtail <wagtail@iol.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:52778 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751669AbXDHSWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 14:22:13 -0400
Content-Disposition: inline
In-Reply-To: <1176048615.686.78.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 08, 2007 at 05:10:15PM +0100, W Agtail wrote:
> Hi, and thanks very much for your response. Your guess sounds spot on. 
> 
> As you've mentioned, using one sync group works quite well and gives you
> an active/passive LVS cluster (not sure of correct terminology here -
> sorry), thus all traffic goes via LVS1, leaving LVS2 not doing much
> unless LVS1 fails.
> 
> I thought it would be a cool idea to setup two sync groups to ultimately
> handle several Apache instances on the two Apache servers. This way,
> both LVS servers would be used in a kind of active/active fashion and
> would be a master/slave to each other. For example, vip1 & gw1 could
> possibly end up on LVS2 with vip2 & gw2.
> 
> The challenge though in having two sync groups, with two GWs. I would
> like all traffic coming through vip1 to be returned via gw1 and all
> traffic coming through vip2 to be returned via gw2.
> 
> I am using keepalived (v1.1.13) with two sync groups. One with vip1 &
> gw1 and another with vip2 & gw2. Port 8088 will always comes through
> vip1/gw1, load balancing to web1:8088 and web2:8088. Port 8089 will
> always come through vip2/gw2, load balancing to web1:8089 and web2:8089.
> 
> Web1's default gw is set to gw1 and web2's default gw is set to gw2. But
> this causing issues when say, vip1:8088 gets forwarded through gw1 to
> web2:8088 and doesn't get back back via gw2. To get round this, I need
> something like iproute2 on web2 to send all 8088 traffic back through
> gw1.

You have to set up both web servers to use the same gateway.  You can
setup an alternate routing table and tag packets from the apache on port
8089 to use the other gateway IP instead, but any traffic handled by
LVS1 _must_ be returned through LVS1.  So both web servers have to have
identical configuration (which is also much simpler to maintain).

You can use iptables to tag packets matching the source port of 8089 and
have ip route route all packets with that specific tag using an
alternate routing table, which will then use the other LVS.

So if you have two VRRP groups, you have port 8088 return by the regular
default gateway going to the first group IP, and you have tagging flag
all port 8089 packets to go through the second vrrp IP.  If an LVS
fails, both vrrp groups end up on the working LVS and everything still
works, but while both works, one LVS handles one port, and the other the
other port.  Of course routing packets is hardly a lot of work, so it
may not really be worth the bother to do anything extra with two groups.
You really have to configure both web servers identically though in
terms of routes.

> Hope this makes a little more sense to what I'm trying to achieve?
> Thanks again.

--
Len Sorensen

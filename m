From: W Agtail <wagtail@iol.ie>
Subject: Re: two gateways with one NIC
Date: Sun, 08 Apr 2007 17:10:15 +0100
Message-ID: <1176048615.686.78.camel@owl.home.ie>
References: <1176003353.686.45.camel@owl.home.ie>
	 <20070408150123.GA3511@csclub.uwaterloo.ca>
Reply-To: wagtail@iol.ie
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc1-york1-0-0-cust229.leed.cable.ntl.com ([82.3.204.230]:31948
	"EHLO owl.home.ie" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751311AbXDHQKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 12:10:23 -0400
In-Reply-To: <20070408150123.GA3511@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, and thanks very much for your response. Your guess sounds spot on. 

As you've mentioned, using one sync group works quite well and gives you
an active/passive LVS cluster (not sure of correct terminology here -
sorry), thus all traffic goes via LVS1, leaving LVS2 not doing much
unless LVS1 fails.

I thought it would be a cool idea to setup two sync groups to ultimately
handle several Apache instances on the two Apache servers. This way,
both LVS servers would be used in a kind of active/active fashion and
would be a master/slave to each other. For example, vip1 & gw1 could
possibly end up on LVS2 with vip2 & gw2.

The challenge though in having two sync groups, with two GWs. I would
like all traffic coming through vip1 to be returned via gw1 and all
traffic coming through vip2 to be returned via gw2.

I am using keepalived (v1.1.13) with two sync groups. One with vip1 &
gw1 and another with vip2 & gw2. Port 8088 will always comes through
vip1/gw1, load balancing to web1:8088 and web2:8088. Port 8089 will
always come through vip2/gw2, load balancing to web1:8089 and web2:8089.

Web1's default gw is set to gw1 and web2's default gw is set to gw2. But
this causing issues when say, vip1:8088 gets forwarded through gw1 to
web2:8088 and doesn't get back back via gw2. To get round this, I need
something like iproute2 on web2 to send all 8088 traffic back through
gw1.

Hope this makes a little more sense to what I'm trying to achieve?
Thanks again.

On Sun, 2007-04-08 at 11:01 -0400, Lennart Sorensen wrote:
> On Sun, Apr 08, 2007 at 04:35:53AM +0100, W Agtail wrote:
> > Hope you can help.
> > 
> > I have the following setup using LVS (Linux Virtual Servers):
> > 
> > LAN--------------------192.168.0.0/24-----------------  <= CLIENTS
> >         |                               |
> >         |                               |
> >         LVS1                            LVS2
> >          vip1: 192.168.0.111             vip2: 192.168.0.121
> >          eth0: 192.168.0.110             eth0: 192.168.0.120
> >          eth1: 10.18.35.10               eth1: 10.18.35.20
> >          gw1:  10.18.35.11               gw2:  10.18.35.21
> >                 |                               |
> >                 |                               |
> > LAN--------------------10.18.35.0/24-----------------
> >                 |                               |
> >                 |                               |
> > Apache>         WEB1 10.18.35.51:8088           WEB2 10.18.35.52:8088
> > Apache>         WEB1 10.18.35.51:8089           WEB2 10.18.35.52:8088
> > 
> > 
> > ### LVS ###
> > The two LVS servers have a VIP and a GW.
> > LVS1 & LVS2 have ip_forward set to 1.
> > 
> > LVS1 has the following iptables:
> > iptables -t nat -A PREROUTING  -i eth0 -j DNAT --to 192.168.0.111
> > iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 192.168.0.111
> > with ipvsadm forwarding vip1:8088 to web1:8088 & web2:8088
> > 
> > LVS2 has the following iptables:
> > iptables -t nat -A PREROUTING  -i eth0 -j DNAT --to 192.168.0.121
> > iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 192.168.0.121
> > with ipvsadm forwarding vip1:8089 to web1:8089 & web2:8089
> > 
> > ### WEB ###
> > The two Web servers have 2 virtual web servers listening on ports 8088 &
> > 8089 and have the following iptables & iproute2 config:
> > iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j MARK
> > --set-mark 1
> > iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j MARK
> > --set-mark 2
> > 
> > ip route add table 1 default via 10.18.35.11 dev eth0
> > ip route add table 2 default via 10.18.35.21 dev eth0
> > 
> > ip rule add fwmark 1 table 1
> > ip rule add fwmark 2 table 2
> > 
> > WEB1's default GW is set to gw1.
> > WEB2's default GW is set to gw2.
> > 
> > CLIENTS should be able to connect to vip1:8088 and vip2:8089
> > 
> > ### MY PROBLEM ###
> > 
> > If i set WEB2's default GW to gw1, everything works as expected (as I
> > now only have one GW).
> > But when trying to set WEB2's default GW to gw2, things don't work.
> > For example, if i was to run: curl vip1:8088 from a CLIENT, I would be
> > able to connect to web1:8088 via LVS OK, but unable to connect to
> > web2:8088 should LVS take me to web2.
> > 
> > Its as though the iptables/ip route settings are not working as they
> > should.
> > 
> > Any ideas what I'm doing wrong?
> > Many thanks, W Agtail.
> 
> Well give I am not sure what you are trying to do, I will take a guess.
> I think you are trying to have redundant load balancers and multiple web
> servers behind those two load balancers.  Here is how I would do it:
> 
> LAN--------------------192.168.0.0/24-----------------  <= CLIENTS
>         |                               |
>         |                               |
>         LVS1                            LVS2
>          vrrp: 192.168.0.110 (linked)    vrrp: 192.168.0.110 (linked)
>          eth0: 192.168.0.111             eth0: 192.168.0.112
> 
>          eth1: 10.18.35.11               eth1: 10.18.35.12
>          vrrp: 10.18.35.10 (master)      vrrp: 10.18.35.10 (slave)
>                 |                               |
>                 |                               |
> LAN--------------------10.18.35.0/24-----------------
>                 |                               |
>                 |                               |
> Apache>         WEB1 10.18.35.51:8088           WEB2 10.18.35.52:8088
> Apache>         WEB1 10.18.35.51:8089           WEB2 10.18.35.52:8088
> 
> So using VRRP to have a shared virtual IP between the two load
> balancers, any client can connect to 192.168.0.110 and be sent through
> to one of the web servers.  The server side interface also has a VRRP
> virtual IP shared between the two load balancers, which is linked to the
> other virtual IP, so that if the link goes down on one side of the load
> balancer, it will automatically drop the virtual IP on both sides to let
> the slave machine take over control of the IP.  To the clients this
> should be pretty transparent since they don't need to know the IP
> changed, other than the momentary change in mac address (letting vrrp
> play with the mac address just causes a terrible mess in my experience,
> and I have had much better luck by simply changing IPs and letting the
> clients relear the new mac).
> 
> keepalived's vrrp works very well (Hmm, actually I think I made some
> fixes to it, which I don't remember if I sent back upstream yet.  I
> should check that tomorrow).
> 
> You could run multiple vrrps per interface if you want to somehow have
> one be the master of one IP and the other the master of another to allow
> different traffic to use each load balancer by default, but everything
> going through one in case of a failure.
> 
> --
> Len Sorensen

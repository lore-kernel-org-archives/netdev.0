From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: two gateways with one NIC
Date: Sun, 8 Apr 2007 11:01:23 -0400
Message-ID: <20070408150123.GA3511@csclub.uwaterloo.ca>
References: <1176003353.686.45.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: W Agtail <wagtail@iol.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:43458 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751286AbXDHPB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 11:01:26 -0400
Content-Disposition: inline
In-Reply-To: <1176003353.686.45.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 08, 2007 at 04:35:53AM +0100, W Agtail wrote:
> Hope you can help.
> 
> I have the following setup using LVS (Linux Virtual Servers):
> 
> LAN--------------------192.168.0.0/24-----------------  <= CLIENTS
>         |                               |
>         |                               |
>         LVS1                            LVS2
>          vip1: 192.168.0.111             vip2: 192.168.0.121
>          eth0: 192.168.0.110             eth0: 192.168.0.120
>          eth1: 10.18.35.10               eth1: 10.18.35.20
>          gw1:  10.18.35.11               gw2:  10.18.35.21
>                 |                               |
>                 |                               |
> LAN--------------------10.18.35.0/24-----------------
>                 |                               |
>                 |                               |
> Apache>         WEB1 10.18.35.51:8088           WEB2 10.18.35.52:8088
> Apache>         WEB1 10.18.35.51:8089           WEB2 10.18.35.52:8088
> 
> 
> ### LVS ###
> The two LVS servers have a VIP and a GW.
> LVS1 & LVS2 have ip_forward set to 1.
> 
> LVS1 has the following iptables:
> iptables -t nat -A PREROUTING  -i eth0 -j DNAT --to 192.168.0.111
> iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 192.168.0.111
> with ipvsadm forwarding vip1:8088 to web1:8088 & web2:8088
> 
> LVS2 has the following iptables:
> iptables -t nat -A PREROUTING  -i eth0 -j DNAT --to 192.168.0.121
> iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 192.168.0.121
> with ipvsadm forwarding vip1:8089 to web1:8089 & web2:8089
> 
> ### WEB ###
> The two Web servers have 2 virtual web servers listening on ports 8088 &
> 8089 and have the following iptables & iproute2 config:
> iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j MARK
> --set-mark 1
> iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j MARK
> --set-mark 2
> 
> ip route add table 1 default via 10.18.35.11 dev eth0
> ip route add table 2 default via 10.18.35.21 dev eth0
> 
> ip rule add fwmark 1 table 1
> ip rule add fwmark 2 table 2
> 
> WEB1's default GW is set to gw1.
> WEB2's default GW is set to gw2.
> 
> CLIENTS should be able to connect to vip1:8088 and vip2:8089
> 
> ### MY PROBLEM ###
> 
> If i set WEB2's default GW to gw1, everything works as expected (as I
> now only have one GW).
> But when trying to set WEB2's default GW to gw2, things don't work.
> For example, if i was to run: curl vip1:8088 from a CLIENT, I would be
> able to connect to web1:8088 via LVS OK, but unable to connect to
> web2:8088 should LVS take me to web2.
> 
> Its as though the iptables/ip route settings are not working as they
> should.
> 
> Any ideas what I'm doing wrong?
> Many thanks, W Agtail.

Well give I am not sure what you are trying to do, I will take a guess.
I think you are trying to have redundant load balancers and multiple web
servers behind those two load balancers.  Here is how I would do it:

LAN--------------------192.168.0.0/24-----------------  <= CLIENTS
        |                               |
        |                               |
        LVS1                            LVS2
         vrrp: 192.168.0.110 (linked)    vrrp: 192.168.0.110 (linked)
         eth0: 192.168.0.111             eth0: 192.168.0.112

         eth1: 10.18.35.11               eth1: 10.18.35.12
         vrrp: 10.18.35.10 (master)      vrrp: 10.18.35.10 (slave)
                |                               |
                |                               |
LAN--------------------10.18.35.0/24-----------------
                |                               |
                |                               |
Apache>         WEB1 10.18.35.51:8088           WEB2 10.18.35.52:8088
Apache>         WEB1 10.18.35.51:8089           WEB2 10.18.35.52:8088

So using VRRP to have a shared virtual IP between the two load
balancers, any client can connect to 192.168.0.110 and be sent through
to one of the web servers.  The server side interface also has a VRRP
virtual IP shared between the two load balancers, which is linked to the
other virtual IP, so that if the link goes down on one side of the load
balancer, it will automatically drop the virtual IP on both sides to let
the slave machine take over control of the IP.  To the clients this
should be pretty transparent since they don't need to know the IP
changed, other than the momentary change in mac address (letting vrrp
play with the mac address just causes a terrible mess in my experience,
and I have had much better luck by simply changing IPs and letting the
clients relear the new mac).

keepalived's vrrp works very well (Hmm, actually I think I made some
fixes to it, which I don't remember if I sent back upstream yet.  I
should check that tomorrow).

You could run multiple vrrps per interface if you want to somehow have
one be the master of one IP and the other the master of another to allow
different traffic to use each load balancer by default, but everything
going through one in case of a failure.

--
Len Sorensen

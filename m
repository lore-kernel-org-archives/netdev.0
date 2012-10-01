From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 18:37:16 +0200
Message-ID: <1349109436.12401.712.camel@edumazet-glaptop>
References: <5057455A.7050108@googlemail.com>
	 <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>
	 <1347979239.26523.267.camel@edumazet-glaptop>
	 <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>
	 <50643DA1.7070306@googlemail.com>
	 <1348748042.5093.1168.camel@edumazet-glaptop>
	 <50649567.2010704@googlemail.com>
	 <1348779826.5093.1750.camel@edumazet-glaptop>
	 <1348780624.5093.1767.camel@edumazet-glaptop>
	 <50656C4A.8090302@googlemail.com>
	 <1348831592.5093.2251.camel@edumazet-glaptop>
	 <5068648C.7050005@googlemail.com>
	 <1349034330.12401.210.camel@edumazet-glaptop>
	 <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <5069B300.9080308@googlemail.com>
	 <1349105498.12401.706.camel@edumazet-glaptop>
	 <5069C27A.3090706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Chris Clayton <chris2553@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49973 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112Ab2JAQhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 12:37:22 -0400
Received: by bkcjk13 with SMTP id jk13so5081258bkc.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 09:37:20 -0700 (PDT)
In-Reply-To: <5069C27A.3090706@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-01 at 17:19 +0100, Chris Clayton wrote:
> 
> On 10/01/12 16:31, Eric Dumazet wrote:
> > On Mon, 2012-10-01 at 16:13 +0100, Chris Clayton wrote:
> >>
> >> On 10/01/12 10:15, Eric Dumazet wrote:
> >>> On Mon, 2012-10-01 at 09:36 +0100, Chris Clayton wrote:
> >>>>
> >>>
> >>>>        0 ICMP messages received
> >>>>        0 input ICMP message failed.
> >>>>        ICMP input histogram:
> >>>>        0 ICMP messages sent
> >>>>        0 ICMP messages failed
> >>>>        ICMP output histogram:
> >>>
> >>>>
> >>>> After:
> >>>>
> >>>> $ netstat -s
> >>>> Icmp:
> >>>>        4 ICMP messages received
> >>>>        4 input ICMP message failed.
> >>>>        ICMP input histogram:
> >>>>            echo replies: 4
> >>>
> >>> So icmp replies come back and are delivered to host instead of being
> >>> forwarded.
> >>>
> >>> I wonder if MASQUERADE broke...
> >>>
> >>> Could you send
> >>>
> >>> iptables -t -nat -nvL
> >>
> >> $ iptables -t -nat -nvL
> >> iptables v1.4.15: can't initialize iptables table `-nat': Table does not
> >> exist (do you need to insmod?)
> >> Perhaps iptables or your kernel needs to be upgraded.
> >>
> >>> conntrack -L   # while ping is running from guest
> >>
> >> $ conntrack -L
> >> conntrack v1.2.2 (conntrack-tools): Operation failed: invalid parameters
> >>
> >
> > Thats not expected, you described you used MASQUERADE target, so
> > "iptables -t nat -nvL" should display something.
> >
> 
> To check this I've booted a 3.5.4 kernel. I get the same response to the 
> two commands. I also double checked that, with a 3.5.4 kernel, pinging 
> the router and browsing the internet from the client work and they do.
> 
> Except for the packets and bytes columns, the command iptables -nvL 
> gives the following output under both 3.5.4 and 3.6.0 kernels:
> 
> Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
>   pkts bytes target     prot opt in     out     source destination
>   3757 3240K ACCEPT     all  --  *      *       0.0.0.0/0 0.0.0.0/0 
>         state RELATED,ESTABLISHED
>     14   840 ACCEPT     all  --  *      *       127.0.0.1 127.0.0.1
>     41  4362 ACCEPT     all  --  *      *       192.168.0.0/24 0.0.0.0/0
>     90 12780 ACCEPT     all  --  *      *       192.168.200.0/24 0.0.0.0/0
>      0     0 ACCEPT     all  --  *      *       192.168.201.0/24 0.0.0.0/0
>      0     0 DROP       all  --  *      *       0.0.0.0/0 0.0.0.0/0
> 
> Chain FORWARD (policy ACCEPT 4470 packets, 3065K bytes)
>   pkts bytes target     prot opt in     out     source destination
> 
> Chain OUTPUT (policy ACCEPT 3243 packets, 349K bytes)
>   pkts bytes target     prot opt in     out     source destination
>     64  8344 ACCEPT     all  --  *      *       0.0.0.0/0 192.168.200.0/24
>      0     0 ACCEPT     all  --  *      *       0.0.0.0/0 192.168.201.0/24

I am lost, since n your first mail you said :
-----------------------------------------------------------------------------
# Load the connection-sharing for qemu/kvm guests
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
...
# allow traffic to and from the qemu/kvm virtual networks
NETS="200 201"
for net in $NETS; do
   iptables -A INPUT -s 192.168.$net.0/24 -j ACCEPT
   iptables -A OUTPUT -d 192.168.$net.0/24 -j ACCEPT
done
...

The network-related modules that are loaded are:

$ lsmod
Module                  Size  Used by
tun                    12412  0
xt_state                 891  1
iptable_filter           852  1
ipt_MASQUERADE          1222  1
iptable_nat             3087  1
nf_nat                 10901  2 ipt_MASQUERADE,iptable_nat
nf_conntrack_ipv4       4942  4 nf_nat,iptable_nat
nf_defrag_ipv4           815  1 nf_conntrack_ipv4
nf_conntrack           37644  5 
ipt_MASQUERADE,nf_nat,xt_state,iptable_nat,nf_conntrack_ipv4
...
r8169                  47159  0


-----------------------------------------------

Now you say you dont have nat ?

Something is wrong.

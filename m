From: Flavio Leitner <fbl@redhat.com>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Thu, 30 Jan 2014 16:08:11 -0200
Message-ID: <20140130180304.GA3793@plex.lan>
References: <20140118191107.GA21979@sesse.net>
 <20140119181806.GC16462@order.stressinduktion.org>
 <20140120184025.GA19972@sesse.net>
 <20140130104709.GA21178@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbaA3SIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 13:08:04 -0500
Content-Disposition: inline
In-Reply-To: <20140130104709.GA21178@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 11:47:09AM +0100, Steinar H. Gunderson wrote:
> On Mon, Jan 20, 2014 at 07:40:25PM +0100, Steinar H. Gunderson wrote:
> >> I currently only remember one commit 0a7e22609067ff ("ipv4: fix
> >> ineffective source address selection") which did affect multicast source
> >> address selection in recent times.
> > I tried 3.10.27, just to check something older. I also tried 3.10.27 with
> > 0a7e22609067ff reverted, and it's still wrong.
> > 
> > I am thinking this might have something to do with the machine switching to
> > systemd, presumably changing the order of DHCP and static addresses being
> > assigned...
> 
> Anything more I can do here?

I've tried with net-next kernel 3.13.0-08598-g77d143d and it seems to
be working fine here.

No special multicast route, so it should go out on em1/default route.
# ip route
default via 192.168.0.1 dev em1  proto static  metric 1024 
10.0.0.0/24 dev vlan10  proto kernel  scope link  src 10.0.0.1 
192.168.0.0/24 dev em1  proto kernel  scope link  src 192.168.0.2 

It looks correct:
[root@plex ~]# ip route get 224.0.0.11
multicast 224.0.0.11 dev em1  src 192.168.0.2 
    cache <local,mc> 

Looks good:
[root@plex ~]# tcpdump -i em1 -n -nn -vv
tcpdump: listening on em1, link-type EN10MB (Ethernet), capture size
65535 bytes
15:43:01.404504 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    192.168.0.2 > 224.0.0.22: igmp v3 report, 1 group record(s) [gaddr
224.0.0.11 to_ex { }]


then adding the multicast route:
# ip route add multicast 224.0.0.0/4 dev vlan10 src 10.0.0.1
# ip route flush cache

Checking:
# ip route get 224.0.0.11
multicast 224.0.0.11 dev vlan10  src 10.0.0.1 
    cache <mc> 

Finally:
[root@plex ~]# tcpdump -i vlan10 -n -nn -vv
tcpdump: listening on vlan10, link-type EN10MB (Ethernet), capture size
65535 bytes
15:44:00.856478 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto
IGMP (2), length 40, options (RA))
    10.0.0.1 > 224.0.0.22: igmp v3 report, 1 group record(s) [gaddr
224.0.0.11 to_ex { }]


Maybe your application is using wrong values to IP_MULTICAST_IF?
strace and /proc/net/igmp as suggested might help you find out.

fbl

From: Andre Tomt <andre@tomt.net>
Subject: Re: unregister_netdevice: waiting for tun6to4 to become free.
Date: Tue, 21 Sep 2004 08:24:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414FC92F.6090009@tomt.net>
References: <20040920212453.GA15392@ee.oulu.fi> <414F7CD9.3090008@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka Pietikainen <pp@ee.oulu.fi>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <414F7CD9.3090008@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> I hit this _once_ on my gateway (NAT'ing firewall IPv4, now also IPv6 
> router).
> 
> No idea why it went away, I just assumed a more recent kernel fixed 
> something.

We've been seeing this all the time on 2.6.8.1 + "critical fixes". 
Pretty much anytime a router with tunneling interfaces is taken down for 
shutdown or reboot, it hangs spinning waiting for the tunnel devices to 
get freed, as ifdown gets run.

It also happens when ifdown'ing them by themselfes.

It's rather annoying, as doing a sysrq-boot is pretty much the only way 
out. Not good at all on a router :-)

I'm having some problems getting this reproduced in the lab setup, but I 
did get a sysrq-t out of one of the affected production routers:

| Sep 18 00:53:36 ed-gw1 kernel: ip            S C0350720     0  1725 
1723                     (NOTLB)
| Sep 18 00:53:36 ed-gw1: dd02ceb4 00000082 dd678190 c0350720 0000007c 
dec44400 dd02c000 e00fddae
| Sep 18 00:53:36 ed-gw1 kernel:        e25ac5eb 0000007c c14b36f0 
00000199 0f055c16 0000007d dd678338 000351bf
| Sep 18 00:53:36 ed-gw1 kernel:        dd02cec8 dec44400 dd02c000 
c026cb73 dd02cec8 000351bf e0038d9c c0356380
| Sep 18 00:53:36 ed-gw1 kernel: Call Trace:
| Sep 18 00:53:36 ed-gw1 kernel:  [pg0+534273454/1070096384] 
addrconf_ifdown+0x3e/0x250 [ipv6]
| Sep 18 00:53:36 ed-gw1 kernel:  [schedule_timeout+99/192] 
schedule_timeout+0x63/0xc0
| Sep 18 00:53:36 ed-gw1 kernel:  [process_timeout+0/16] 
process_timeout+0x0/0x10
| Sep 18 00:53:36 ed-gw1 kernel:  [netdev_wait_allrefs+85/288] 
netdev_wait_allrefs+0x55/0x120
| Sep 18 00:53:36 ed-gw1 kernel:  [netdev_run_todo+237/512] 
netdev_run_todo+0xed/0x200
| Sep 18 00:53:36 ed-gw1 kernel:  [dev_ioctl+438/752] dev_ioctl+0x1b6/0x2f0
| Sep 18 00:53:36 ed-gw1 kernel:  [sock_ioctl+544/560] 
sock_ioctl+0x220/0x230
| Sep 18 00:53:36 ed-gw1 kernel:  [sys_ioctl+201/576] sys_ioctl+0xc9/0x240
| Sep 18 00:53:36 ed-gw1 kernel:  [sysenter_past_esp+82/113] 
sysenter_past_esp+0x52/0x71

The tunnel is defined like this in /etc/network/interfaces (Debian Sarge)
| auto vid
| iface vid inet6 v4tunnel
|         address 2001:730:f:ffff::11
|         netmask 126
|         endpoint <remote ip>
|         local <local ip>
|         up /sbin/ip -6 route add 2001:730:f:12::/64 dev vid metric 1
|         up /sbin/ip -6 tunnel change vid ttl 255

Next time I'm doing anything I'll be sure I run ifdown in verbose mode, 
but my best guess is it failing at "ip tunnel del %iface%"

The kernel does not have NAT and/or connection tracking loaded on this 
router. Connection tracking is available as modules, but not loaded. NAT 
is not enabled at all.

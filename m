From: Andre Tomt <andre@tomt.net>
Subject: Re: unregister_netdev Annoyance WAS(Re: ing_filter debug messages
Date: Fri, 31 Dec 2004 19:24:30 +0100
Message-ID: <41D5995E.1070005@tomt.net>
References: <20041230160643.GD24603@wiggy.net>	 <1104469666.1049.231.camel@jzny.localdomain>	 <20041231093827.GG24603@wiggy.net>	 <1104491510.1047.234.camel@jzny.localdomain>	 <20041231131553.GA7460@wiggy.net>	 <1104505838.1048.273.camel@jzny.localdomain>	 <20041231154844.GA11511@wiggy.net> <1104511697.1048.308.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wichert Akkerman <wichert@wiggy.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104511697.1048.308.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2004-12-31 at 10:48, Wichert Akkerman wrote:
> 
>>Previously jamal wrote:
>>
>>>Try also the attached patch with netfilter on and your rules installed.
>>
>>That seems to do the trick: I no longer see the debug messages appear.
>>The tunnel still works as well.
>>
>>However, the unregister_netdev problem still persists.
> 
> 
> I am pretty sure its a different problem. Quick scan shows the
> register/unregister state machine may be at fault. 
> Just changed the subject because there have been threads on this topic
> that other people have been discussing that i havent followed.
> Lets see if this gets their attention - If it doesnt i will poke around.

Just had this happen on a router yesterday, while booting for testing a 
netfilter bugfix. The dot1q VLAN interfaces got stuck waiting to become 
free on ifdown (part of the system shutdown process in this case)

There have been several such bugs in recent 2.6 kernel versions, and 
several refcounting leaks have been plugged since, but somehow it keeps 
coming back to hunt me from time to time. I'm about to disable ifdown -a 
on shutdown, but I find that a rather silly workaround to such a problem ;-)

Kernel is 2.6.10, ipv6 and ip_conntrack loaded, running 
zebra/ospfd/ospf6d. ipip and sch/cls modules loaded, but currently not 
in use (and wasn't since boot)

# lsmod
Module                  Size  Used by
dm_mod                 44668  0
sch_htb                18816  0
sch_sfq                 4480  0
cls_u32                 6788  0
softdog                 4368  0
ip6table_filter         2048  1
ip6t_limit              1920  0
ip6t_LOG                5888  0
ip6_tables             14976  3 ip6table_filter,ip6t_limit,ip6t_LOG
ip_conntrack_irc       70320  0
ip_conntrack_ftp       70960  0
iptable_filter          2944  1
ipt_limit               1920  6
ipt_REJECT              5120  2
ipt_LOG                 5376  3
ipt_state               1536  252
ip_conntrack           34164  3 ip_conntrack_irc,ip_conntrack_ftp,ipt_state
ip_tables              14336  5 
iptable_filter,ipt_limit,ipt_REJECT,ipt_LOG,ipt_state
ipip                    7396  0
xfrm4_tunnel            2820  1 ipip
8021q                  14728  0
8139too                17664  0
mii                     3712  1 8139too
crc32                   3968  1 8139too
ipv6                  189568  23
rtc                     8760  0
af_packet              14344  0
unix                   19124  145
ext3                   99208  6
jbd                    41496  1 ext3
mbcache                 5636  1 ext3

# cat /etc/sysctl.conf
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See sysctl.conf (5) for information.

net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.icmp_echo_ignore_broadcasts=1

net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.default.shared_media=0

net.ipv6.conf.default.forwarding=1
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.default.accept_redirects=0
net.ipv6.conf.default.autoconf=0
net.ipv6.conf.default.router_solicitations=0

net.ipv6.conf.all.forwarding=1
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.all.autoconf=0
net.ipv6.conf.all.router_solicitations=0

kernel.panic=60
kernel.panic_on_oops=1

vm.overcommit_memory=2

net.ipv4.netfilter.ip_conntrack_max=131072
net.ipv4.netfilter.ip_conntrack_log_invalid=6

From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] remove superfluous diverter printk'ing
Date: 16 Jan 2005 12:33:19 -0500
Message-ID: <1105896799.1097.733.camel@jzny.localdomain>
References: <20050114124700.GA4079@xi.wantstofly.org>
	 <20050114134642.4be4e2fc.davem@davemloft.net>
	 <20050115104750.GB14991@xi.wantstofly.org>
	 <1105895420.1090.708.camel@jzny.localdomain>
	 <20050116172202.GC20537@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        bdschuym@pandora.be
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050116172202.GC20537@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 12:22, Lennert Buytenhek wrote:
> On Sun, Jan 16, 2005 at 12:10:21PM -0500, jamal wrote:
> 
> > Diverter could simply be killed now that tc actions exist if theres no
> > maintainer or user.
> > Should be able to divert any packet of choce to any interface.
> 
> The diverter is not used for redirecting a packet to another interface.
> 
> What it does (IIRC) is overwrite the destination MAC address on selected
> packets so that the local host will process them.  You can do the same
> thing with iptables' "-j REDIRECT" but the diverter was made for use on
> ethernet bridges (REDIRECTing bridged packets) when the bridge-nf stuff
> didn't exist yet.

the action code is hit before bridging, so something along the lines of:

#attach to ingress of eth0
tc qdisc add dev eth0 ingress 
# Munge MAC address if coming from 192.168.200.200/32
tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match ip src 192.168.200.200/32 flowid 1:2 \
action pedit munge offset -16 u16 set 0x0000 \
munge offset -12 u32 set 0x00020200 \
munge offset -8 u32 set 0x0001AF0A \
munge offset -4 u32 set 0x06EC0800

pedit could be taught better (macros needed) to do:

action pedit munge set src MAC  00:01:AF:0A:06:EC 
instead of all that raw formating

Or if you want to redirect it after rewriting MAC to eth1:
tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match ip src 192.168.200.200/32 flowid 1:2 \
action pedit munge set src MAC  00:01:AF:0A:06:EC \
mirred egress redirect dev eth1

cheers,
jamal

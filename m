From: jamal <hadi@cyberus.ca>
Subject: Re: ipt_ROUTE and destination MAC address
Date: 12 Feb 2005 08:32:50 -0500
Message-ID: <1108215170.1178.106.camel@jzny.localdomain>
References: <S262133AbVBJPBt/20050210150149Z+8411@vger.kernel.org>
	 <20050211123718.M74819@toutatis.be>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: junk <junk@toutatis.be>
In-Reply-To: <20050211123718.M74819@toutatis.be>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Maybe if you describe your purpose it would help more. I dont know what
ROUTE or red0 is, but you could essentially use mirred action to mirror
or redirect packets to any interface you want; examples (part of
iproute/doc):

Host A is hooked  up to us on eth0 for these examples

1)
tc qdisc add dev lo ingress
# redirect all packets arriving on ingress of lo to eth0
tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:2 action mirred egress redirect dev eth0

2)
#allow every 10th packet to be sent to be copied to eth0
# you could sample better by using netrand insted of determ
#
tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:2 \
action drop random determ ok 10\
action mirred egress mirror dev eth0

3)
# for packets coming from 10.0.0.9:
#Redirect packets on egress (to ISP A) if you exceed a certain rate
# to eth1 (to ISP B) if you exceed a certain rate
#

tc qdisc add dev eth0 handle 1:0 root prio

tc filter add dev eth0 parent 1:0 protocol ip prio 6 u32 \
match ip src 10.0.0.9/32 flowid 1:16 \
action police rate 100kbit burst 90k ok \
action mirred egress mirror dev eth1

4)
# repeat above but send packets to dummy0 as well so you can see them
# with tcpdump:

tc filter add dev eth0 parent 1:0 protocol ip prio 6 u32 \
match ip src 10.0.0.9/32 flowid 1:16 \
action police rate 100kbit burst 90k ok \
action mirred egress mirror dev eth1 \
action mirred egress mirror dev dummy0

Again, dont know what you are trying to do, so i gave you a shotgun
answer and i could almost swear you are probably trying to hardcode one
of these scenarios by writting a driver ;->

cheers,
jamal

On Fri, 2005-02-11 at 07:39, junk wrote:
> Hello,
> 
> i'm coding a virtual interface. That virtual interface has to receive packets
> coming on eth0. For that purpose, i'm using ipt_ROUTE. That works great, i can
> see my packets arriving on red0 (my virtual interface).
> 
> But there is a problem..
> 
> If i send an icmp request to 10.0.1.1 from another computer:
> 
> The icmp request arrives on the physical interface, ROUTE target makes it
> arrive on red0
> 
> icmp request arriving on red0: 10.0.0.1
> 
> The problem is that the destination MAC is the one of eth0, so, it seems the
> kernel doesn't really deliver the packet to my driver. I can see it in tcpdump
> but my driver receive function is never called.
> 
> I tried every -j ROUTE option, --gw or --iif, with --continue, or not..
> 
> Any idea?
> 
> 

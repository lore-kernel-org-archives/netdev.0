From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: 02 Jul 2004 23:13:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088824432.1043.271.camel@jzny.localdomain>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	 <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Catalin BOIE <util@deuroconsult.ro>,
        netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-02 at 16:44, Stephen Hemminger wrote:
> Here is an enhancement to netem to do allow emulating lower speed 
> networks.  The resolution is close, but obviously limited by the
> granularity of timers and size of packets.
> 
> Also, fixes a rtnetlink dependency which showed up in some configurations
> and optimizes for the non-loss case by avoiding net_random call.
> 

I think its time i illustrate my comments earlier with some example
hopefully this will curb the amount of features on this qdisc.
I do think theres value in having this thing do delay and jitter, but
you have gone waay beyond that now; 
Let illustrate things which apply to what you are trying to do in
network condituions emulation. Although i show ingress qdisc , this
applies to egress just the same.

#drop 1 out 10 packets randomly using the netrand generator
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.0.21/32 flowid 1:16 \
action drop random netrand ok 0xa

Note, you can plugin another randomization algorithm (a point i was
trying to make earlier; currently supporting netrandom and deterministic
algorithms only)

#deterministically accept every second packet, drop the rest
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.0.22/32 flowid 1:16 \
action drop random determ ok 2 

# deterministically duplicate every second packet
# 
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.0.21/32 flowid 1:16 \
action ok random determ pipe 2 \
action mirred egress mirror dev dummy0

Interesting thing is depending on what you have attached on 
the dummy0 device you could reorder or delay. Example you could hookup
that qdisc to delay.

Lets do something more interesting ...
# 
# deterministically duplicate every second packet that
# exceeds 100Kbit for packets coming in from 10.0.0.31
# and give it a fwmark of 2. Dummy could do something
# with that info 
#  
#
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.0.31/32 flowid 1:16 \
action ipt -j mark --set-mark 1 \
action police rate 100kbit burst 90k pipe \
action ok random determ pipe 2 \
action ipt -j mark --set-mark 2 \
action mirred egress mirror dev dummy0

Lets do something even more interesting ..

tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.0.31/32 flowid 1:16 \
action police rate 100kbit burst 90k pipe \
action pedit munge offset 4 u32 set 0x12341234 \
action ok random determ pipe 2 \
action mirred egress mirror dev dummy0

Note: we introduced some error in the
packet bits by randomly setting some value in some offset;
checksums etc will be wrong as a result. This happens for all packets
exceeding 100Kbits. Every second packet which has been trampled is also
duplicated... 

I hope this makes my point clearer. For testing or emulating conditions
just create actions and serialize them for the flows and in/egress
device you want them on. Create new ones that dont exist.

cheers,
jamal

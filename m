From: jamal <hadi@cyberus.ca>
Subject: (Long) ANNOUNCE: IMQ replacement WAS(Re: [RFC/PATCH] IMQ port to
	2.6
Date: 11 Apr 2004 15:32:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081711933.1042.365.camel@jzny.localdomain>
References: <20040126093230.GA17811@usr.lcm.msu.ru>
	 <1075124312.1732.292.camel@jzny.localdomain>
	 <20040126135545.GA19497@usr.lcm.msu.ru>
	 <1075127396.1746.370.camel@jzny.localdomain>
	 <20040131185231.GA2608@usr.lcm.msu.ru>
	 <1075580812.1035.83.camel@jzny.localdomain>
	 <20040131205326.GA3089@usr.lcm.msu.ru>
	 <1075584318.1033.159.camel@jzny.localdomain>
	 <20040131213236.GA3451@usr.lcm.msu.ru>
	 <1075585764.1035.192.camel@jzny.localdomain>
	 <20040131215821.GA3615@usr.lcm.msu.ru>
	 <1075587994.1036.231.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <1075587994.1036.231.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Following up on a 3 month old email ;->

I finally hacked dummy device as a good replacement (IMO) for IMQ.
I am only subscribed to netdev so if there are other lists which
are of interest to this subject please forward on, but make sure
responses make it to netdev.

Well, why dummy you ask? Because it is such dumb a device ;->
Ok, that may not be funny enough, how about:
because nobody has touched the dummy device in 10 years - that cant be
right in Linux. On a serious note though, because i didnt think it was
worth writting another device for this. Dummy continues to work the same
way when not used with tc extensions. Like i said in my email at the
bottom that IMQ was just at the wrong abstraction layer. The dummy
extension can now pick ANY packets (not just IP and requiring to attach
to a few hooks to get IPV6, arp etc)
Of course all this needs the tc extensions (which has a lot of other
features that i wont discuss here).

Why dont i show an example:

----
export TC="/sbin/tc"
#
#attach prio qdisc to the dummy0 device
#
$TC qdisc add dev dummy0 root handle 1: prio
$TC qdisc add dev dummy0 parent 1:1 handle 10: sfq
$TC qdisc add dev dummy0 parent 1:2 handle 20: tbf rate 20kbit buffer
1600 limit 3000
$TC qdisc add dev dummy0 parent 1:3 handle 30:
sfq                                
# redirect packets coming in with fwmark 1 to class 1:1 (sfq)
$TC filter add dev dummy0 protocol ip pref 1 parent 1: handle 1 fw
classid 1:1
#redirect packets tagged with fwmark 2 to 1:2 (tbf)
$TC filter add dev dummy0 protocol ip pref 2 parent 1: handle 2 fw
classid 1:2

#bring up dummy0
ifconfig dummy0 up

#watch the ingress of eth0;
$TC qdisc add dev eth0 ingress

# redirect all IP packets arriving in eth0 to dummy0
# use mark 1 --> puts them onto class 1:1
$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action ipt -j MARK --set-mark 1 \
action mirred egress redirect dev dummy0

# note, the above just shows eth0 and only at ingress;
# you could repeat this on egress/ingress of any device
# and redirect to dummy0 if you wanted; 

A Little test:

from another machine ping so that you have packets going into the box:
-----
[root@jzny action-tests]# ping 10.22
PING 10.22 (10.0.0.22): 56 data bytes
64 bytes from 10.0.0.22: icmp_seq=0 ttl=64 time=2.8 ms
64 bytes from 10.0.0.22: icmp_seq=1 ttl=64 time=0.6 ms
64 bytes from 10.0.0.22: icmp_seq=2 ttl=64 time=0.6 ms

--- 10.22 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.6/1.3/2.8 ms
[root@jzny action-tests]#

Now look at some stats:
-----
[root@jmandrake]:~# tc -s filter show parent ffff: dev eth0
filter protocol ip pref 10 u32
filter protocol ip pref 10 u32 fh 800: ht divisor 1
filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:1 
  match 00000000/00000000 at 0
        action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
        target MARK set 0x1
        index 1 ref 1 bind 1 installed 4195sec  used 27sec
         Sent 252 bytes 3 pkts (dropped 0, overlimits 0)

        action order 2: mirred (Egress Redirect to device dummy0) stolen
        index 1 ref 1 bind 1 installed 165 sec used 27 sec
         Sent 252 bytes 3 pkts (dropped 0, overlimits 0)

[root@jmandrake]:~# ifconfig dummy0
dummy0    Link encap:Ethernet  HWaddr 00:00:00:00:00:00
          inet6 addr: fe80::200:ff:fe00:0/64 Scope:Link
          UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1
          RX packets:6 errors:0 dropped:3 overruns:0 frame:0
          TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:32
          RX bytes:504 (504.0 b)  TX bytes:252 (252.0 b)
-----

Note the three extra received packets on dummy0 were ndisc packets
sent by the stack when it booted up (which would normally be dropped -
they were). Also, the mirred action can do a _lot_ more, but thats not
the point of this email. Send me private email if you want to know more.
Additionaly note: the ipt report of NF_IP_PRE_ROUTING is a lie since
this happens waaay before IP.
This has been tested on both uni and smp machines. Unfortunately, the
code is only available for 2.4.x (2.4.25 patches available - more
vigorous testing happened on 2.4.21 - my two machines above)

What am i looking for? 
1) users and authors of IMQ to tell me if this achieves what IMQ started
as. I have to say I DONT like the level of obstrutiveness from IMQ as is
today. The code added by this is small (100 or less lines on top of
dummy) and doesnt touch any of the main core bits.
2) testing of the above by people who use IMQ
3) If someone has better ideas - i am not religious about keeping this;
but it certainly cant be the blasphemy that IMQ introduces.

I have also introduced hooks to easily add a -i <input dev> to tc
classifiers - still on the TODO list. So on the egress you could now
classify based on which incoming device the packet arrived on.

cheers,
jamal

On Sat, 2004-01-31 at 17:26, jamal wrote:
> On Sat, 2004-01-31 at 16:58, Vladimir B. Savkin wrote:
> 
> > Well, not, the primary reason being that there would be no single class
> > with appropriate bandwith limit (ceil). There would be multiple classes,
> 
> Ok - i think you made your point. 
> So i should add that a third condition is there are multiple devices
> towards the clients.
> You have convinced me there is value in such a scheme as IMQ provides
> for such conditions. As it is right now though IMQ needs to have the
> right abstraction (and not be dependent on netfilter).And may be we
> could abuse it to do other things. 
> Let me hear from Tomas and then we should take it from there.
> 
> cheers,
> jamal
> 
> 

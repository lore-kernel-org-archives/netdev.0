From: Ben Greear <greearb@candelatech.com>
Subject: Re: routing bug report for 2.4
Date: Sat, 28 Jun 2003 11:38:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFDE0BC.8040803@candelatech.com>
References: <Pine.LNX.4.44.0306280926250.1273-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>, netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0306280926250.1273-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:
> 	Hello,
> 
> 	I'll try to reply to some of your posts...
> 
> On Fri, 27 Jun 2003, Ben Greear wrote:
> 
> 
>>(This has been discussed with Alexey, but sending to the list for
>>general consumption).
> 
> 
> 	I remember your previous posts, I assume they were skipped
> because you do not use properly the routing system, you have to
> use preferred sources in your routes. Now I'm not sure if the case
> is same.
> 
> 
>>Here is how to reproduce this:
>>ifconfig eth1 192.1.1.2 netmask 255.255.255.0
>>ifconfig eth2 192.1.2.2 netmask 255.255.255.0
>>
>>
>>Set up policy based routing with the 'ip' tool to make packets with
>>source-address of each interface to use the gateway for that interface.
>>   Set gateway for eth1 to be 192.1.1.1
>>   Set gateway for eth2 to be 192.1.2.1
> 
> 
> 	But not all packets, may be you have to place the source-based
> rules after table main. This is the recommeneded way.

My test works if I ping the 192.1.2.1 router from the eth1 interface, the issue
is that the localness of eth2 over-rides the policy based routing.

Also, note that it does work when I BINDTODEVICE on eth1.  I had assumed that
because I was setting the source IP, and had a specific routing table for
that case, then it would use that routing table.  In the error case, it is
at least partially ignoring that routing table, though not entirely:  It is
trying to communicate on eth1, but it is arping instead of routing.

> 
> 
>>Now, use ping to try to send pkts from one interface to the other:
>>
>>ping -I 192.1.1.2 192.1.2.2
> 
> 
> 	Your report is damn wrong, why do you ping local IP?
> Or may be that is your test? Trying ping from ip-utils... sorry,
> not reproducible here (I hope it is the expected result).

What results do you get?  And did you set up policy based routing?
I tried ping with RH8, RH9, and downloaded the latest ip-utils I could
find.  Only when I hacked the ping source to bind to the local IP AND bind
specifically to the device did it work.

I am trying to ping a local IP but over the external network.  It is not something
most people try to do now, I am aware.  As well as my twisted reasons, it would
be good for determining path failures in an HA setup, so it's not completely
useless :)

> 
> 
>>You will see arps on eth1 for 192.1.2.2, whereas you should see packets
>>being sent to the default gateway for eth1.
> 
> 
> 	Why? 192.1.2.2 is local IP and the local table is first
> priority. We should not see any ARP packets for local targets, right?

Local table is not used in my case because I specifically bind to the sending IP
and have a table specifically for that case.

> 
> 
>>If you modify the ping source to BINDTODEVICE eth1, then it will send
>>correctly.  I am under the impression that you should not have to specifically
>>BINDTODEVICE in this case since the policy based routing should take care of
>>routing things correctly.  Or, maybe, the real bug is in ping in that it did
>>not BINDTODEVICE?
> 
> 
> 	Do you really ping local IP?

Yes.

> 
> 
>>Also, ping -I eth1 192.1.2.2 will fail to route externally.  That may
>>just be a feature of ping:  I'm unsure what the subtle difference is *supposed*
>>to be between using -I eth1 and -I 1.2.3.4
> 
> 
> 	I think, the root of your problems is that you specify
> 'ping -I device' and the routing is forced to construct result from
> unknown route by using source address autoselection.

I am open to suggestions as to other ways to make this work:  I want to ping from eth1
to eth2, and have at least the echo-request go out over eth1 and be routed back to eth2.

> 
> 	From previous post:
> 
> 
>>#  The other interface on the router machine (same machine as I just pinged above)
>>[root@localhost root]# ping -I eth1 10.3.2.1
>>PING 10.3.2.1 (10.3.2.1) from 10.3.1.4 eth1: 56(84) bytes of data.
>> From 10.3.1.4 icmp_seq=1 Destination Host Unreachable
>> From 10.3.1.4 icmp_seq=3 Destination Host Unreachable
>>
>>#  It is NOT using the default gateway for this traffic, but is instead
>>#  just trying to ARP.
>>[root@localhost root]# tcpdump -n -i eth1
>>tcpdump: listening on eth1
>>11:56:19.788336 arp who-has 10.3.2.1 tell 10.3.1.4
>>11:56:20.788134 arp who-has 10.3.2.1 tell 10.3.1.4
>>11:56:21.788149 arp who-has 10.3.2.1 tell 10.3.1.4
>>11:56:22.788379 arp who-has 10.3.2.1 tell 10.3.1.4
> 
> 
> 	'-I eth1 10.3.2.1' requests route
> "from 0.0.0.0 to 10.3.2.1 oif eth1". You do not have such routes.
> I assume the result is (quoting route.c):
> "Apparently, routing tables are wrong."
> "Assume, that the destination is on link."
> 
> For your setup I would say "The request is wrong". You see that
> the kernel even do not check whether eth1 is UP. You are lucky.
> 
> Then the kernel autoselects 10.3.1.4 as src for the forced eth1 device.
> Thus, you see this ARP probe. Later, it seems 10.3.2.1 does not
> want to reply to 10.3.1.4, I assume this is a known problem?
> 
> 	As for ping from iputils: you can specify device or saddr,
> not the both, so the only valid test for source based routing can
> be '-I IP'. Do you really need '-I eth1' ?

Actually, from the code I looked at, you can use two -I flags, but what appears
to be a bug actually keeps it from working completely (I could find no combo of arguments
to make it make the BINDTODEVICE call.)

During some of my earlier testing, I had various things wrong.  For instance, I
noticed that if I had policy-based routing on my router, it would not work correctly.
I have not debugged that issue in depth, as it does not really hinder the functionality
that I require.  If it still doesn't work in 2.6 I'll open a bug ;)

One final note, I am running a kernel with a patch that allows external comm over
two interfaces on the same machine on the same subnet (with policy based routing).
The normal ping works in this case, btw.  So, it may be that even if
you change ping, it may still not work for you (my patch mostly deals with getting
local ARPs to answer correctly, so I am not sure it comes into play in the routed case.)


Ben

> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 


-- 
Ben Greear <greearb@candelatech.com>          <Ben_Greear@excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

From: Julian Anastasov <ja@ssi.bg>
Subject: Re: routing bug report for 2.4
Date: Sat, 28 Jun 2003 12:02:29 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306280926250.1273-100000@u.domain.uli>
References: <3EFCCC95.3000709@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EFCCC95.3000709@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	I'll try to reply to some of your posts...

On Fri, 27 Jun 2003, Ben Greear wrote:

> (This has been discussed with Alexey, but sending to the list for
> general consumption).

	I remember your previous posts, I assume they were skipped
because you do not use properly the routing system, you have to
use preferred sources in your routes. Now I'm not sure if the case
is same.

> Here is how to reproduce this:
> ifconfig eth1 192.1.1.2 netmask 255.255.255.0
> ifconfig eth2 192.1.2.2 netmask 255.255.255.0
>
>
> Set up policy based routing with the 'ip' tool to make packets with
> source-address of each interface to use the gateway for that interface.
>    Set gateway for eth1 to be 192.1.1.1
>    Set gateway for eth2 to be 192.1.2.1

	But not all packets, may be you have to place the source-based
rules after table main. This is the recommeneded way.

> Now, use ping to try to send pkts from one interface to the other:
>
> ping -I 192.1.1.2 192.1.2.2

	Your report is damn wrong, why do you ping local IP?
Or may be that is your test? Trying ping from ip-utils... sorry,
not reproducible here (I hope it is the expected result).

> You will see arps on eth1 for 192.1.2.2, whereas you should see packets
> being sent to the default gateway for eth1.

	Why? 192.1.2.2 is local IP and the local table is first
priority. We should not see any ARP packets for local targets, right?

> If you modify the ping source to BINDTODEVICE eth1, then it will send
> correctly.  I am under the impression that you should not have to specifically
> BINDTODEVICE in this case since the policy based routing should take care of
> routing things correctly.  Or, maybe, the real bug is in ping in that it did
> not BINDTODEVICE?

	Do you really ping local IP?

> Also, ping -I eth1 192.1.2.2 will fail to route externally.  That may
> just be a feature of ping:  I'm unsure what the subtle difference is *supposed*
> to be between using -I eth1 and -I 1.2.3.4

	I think, the root of your problems is that you specify
'ping -I device' and the routing is forced to construct result from
unknown route by using source address autoselection.

	From previous post:

> #  The other interface on the router machine (same machine as I just pinged above)
> [root@localhost root]# ping -I eth1 10.3.2.1
> PING 10.3.2.1 (10.3.2.1) from 10.3.1.4 eth1: 56(84) bytes of data.
>  From 10.3.1.4 icmp_seq=1 Destination Host Unreachable
>  From 10.3.1.4 icmp_seq=3 Destination Host Unreachable
>
> #  It is NOT using the default gateway for this traffic, but is instead
> #  just trying to ARP.
> [root@localhost root]# tcpdump -n -i eth1
> tcpdump: listening on eth1
> 11:56:19.788336 arp who-has 10.3.2.1 tell 10.3.1.4
> 11:56:20.788134 arp who-has 10.3.2.1 tell 10.3.1.4
> 11:56:21.788149 arp who-has 10.3.2.1 tell 10.3.1.4
> 11:56:22.788379 arp who-has 10.3.2.1 tell 10.3.1.4

	'-I eth1 10.3.2.1' requests route
"from 0.0.0.0 to 10.3.2.1 oif eth1". You do not have such routes.
I assume the result is (quoting route.c):
"Apparently, routing tables are wrong."
"Assume, that the destination is on link."

For your setup I would say "The request is wrong". You see that
the kernel even do not check whether eth1 is UP. You are lucky.

Then the kernel autoselects 10.3.1.4 as src for the forced eth1 device.
Thus, you see this ARP probe. Later, it seems 10.3.2.1 does not
want to reply to 10.3.1.4, I assume this is a known problem?

	As for ping from iputils: you can specify device or saddr,
not the both, so the only valid test for source based routing can
be '-I IP'. Do you really need '-I eth1' ?

Regards

--
Julian Anastasov <ja@ssi.bg>

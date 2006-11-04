From: jamal <hadi@cyberus.ca>
Subject: Re: pktgen patch available for perusal.
Date: Sat, 04 Nov 2006 13:10:55 -0500
Message-ID: <1162663855.6237.116.camel@jzny2>
References: <45468F2E.4060809@candelatech.com>
	 <17736.54766.657083.873206@robur.slu.se> <4548F166.1020001@candelatech.com>
	 <1162643532.5166.34.camel@jzny2>  <454CCDE0.5040109@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:19158 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S965584AbWKDSK6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Nov 2006 13:10:58 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GgPyv-000594-Mz
	for netdev@vger.kernel.org; Sat, 04 Nov 2006 13:11:01 -0500
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <454CCDE0.5040109@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-04-11 at 09:29 -0800, Ben Greear wrote:
> jamal wrote:
   
> Please do send a script.  I match based on this method below.   Probably 
> you only
> need the part that checks for the MAGIC, 

What i do in my case is send to the SUT to UDP port 9. The SUT loops
back the packet to me after processing and i just have a simple check in
the traffic generator of:

a) Packet = IPV4, IP address matches what i want, port =9, 
b) If this matches i  account and drop it. This means all other traffic
(like ssh etc goes through fine).

I dont really need to check for length because _i know_ udp port 9 to
the SUT is test traffic.

For such a setup, the script would be as simple as (assuming SUT hooked
to eth0):

--
#interested in incoming packets on eth0
tc qdisc add dev eth0 ingress
#interested in packets coming from SUT(10.0.0.21) on UDP port 9
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.0.21/32 \
match udp port 9 0xffff \
flowid 1:16 \
action drop
---

When you do a listing of this filter you will see accounting info.
You list by saying:
---
tc -s filter ls dev eth0 parent ffff:
---

You can ofcourse add many of these based on other header info.

It seems to me your magic header is inside the UDP packet, correct?
In that case you will have to play with matches since you can specify
arbitraty offsets and values inside the packet.

Of course you can do this from your application instead of using tc.
I think that will be the best place to control this and sync with
pktgen sending.

> the rest can be in a method 
> called after you match in your script?
> 

If the packet/byte counters that the drop action provides are not good
enough, you can write yourself a little module that will do the
accounting the way you want it. For example this will be necessary to
the out-of-sequence cheques below. Timestamps are already being updated
Look at net/sched/act_simple.c and its associated user space code in
iproute2.

Now, Ben - are you listening really this time or am i wasting my time
for the nth time giving you all these details? ;->

If you are listening then start with:

1) Do a simple test with just udp traffic as above, doing simple
accounting. This helps you to get a feel on how things work.
2) modify the matching rules to match your magic cookie
3) write a simple action invoked by your matching rules and use tc to
add it to the policy.
4) integrate in your app now that you know what you are doing.

If you follow these steps or a variant-of i will spend time and help.

cheers,
jamal



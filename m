From: Ulf Samuelsson <netdev@emagii.com>
Subject: Re: Bug report: broadcast address as incomplete entry in arp table,
 effectively a blackhole; reproducer included
Date: Wed, 11 Mar 2015 21:56:53 +0100
Message-ID: <5500AC15.2020200@emagii.com>
References: <20140924161847.GG7118@soda.linbit> <20141119143958.GP307@soda.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Olaf Kirch <okir@suse.com>
To: Lars Ellenberg <lars.ellenberg@linbit.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf3.bahnhof.se ([213.80.101.27]:50603 "EHLO mxf3.bahnhof.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbbCKU5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 16:57:06 -0400
In-Reply-To: <20141119143958.GP307@soda.linbit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Den 2014-11-19 15:39, Lars Ellenberg skrev:
> Ping ...
> Any ideas?
>
> 	Lars
Did you ever solve this problem?

Have been working on a similar problem.

Are you sure that the entry is never removed?

Once you lose the entry, it is normally garbage collected,
and this takes a looong time (minutes).

Try leaving it alone for an hour once the problem occurs,
and check if the garbage collector has not taken the entry out.

The ARP state machine has, as far as I know, no way
to put an entry into INCOMPLETE once it has reached REACHABLE.

Once in REACHABLE it will move between the following valid states:

* REACHABLE
* DELAY
* PROBE

Lost communication will make the entry move into STALE.
Other failures will make it enter FAILED state.
In both these states, the garbage collector will delete the entry.

There might of course be some part of the code that aborts the delete.

BR
Ulf Samuelsson

> On Wed, Sep 24, 2014 at 06:18:47PM +0200, Lars Ellenberg wrote:
>> You have some interface you want to broadcast on,
>> so you resolve its broadcast address (once),
>> and keep sending (e.g. some continuous status updates, or "heartbeat").
>>
>> For some reason that interface goes down.
>> If you keep sending to the previously resolved address,
>> that will create an incomplete arp entry.
>>
>> Unfortunately, that entry *stays* there, even if the interface is then
>> brought back up (with the same network and broadcast settings).
>> Once the interface is up, you won't be able to delete that entry
>> (because, its a broadcast address; that arp entry is not supposed to be
>> there anyways; that deletion request will be filtered out early...)
>>
>> Anyone trying to send to that broadcast address will now effectively
>> send to a black hole: there is an incomplete arp entry.
>>
>>
>> Fix is then to stop all processes sending to that address,
>> bring down the device, delete the arp entry, bring it back up,
>> and then continue all processes sending to that address.
>>
>>
>> I can reproduce this easily with the script below, anywhere I tested,
>> on a large variety of platforms and kernels.
>> (you'll obviously have to adjust DEV, BROADCAST and possibly PORT).
>>
>>
>> I suspect this is not intentional, but there is simply some
>> neigh_flush_dev() or similar missing "somewhere".
>>
>> If you want to point me in the right direction as to probable values of
>> "somewhere", I'll likely be able to figure out a minimal patch myself.
>>
>> If you know the right place to fix this from the top of your head,
>> even better ;-)
>>
>> Thanks,
>> 	Lars
>>
>> ------------------------------------------------------
>>
>> #!/bin/bash
>>
>> DEV=eth1
>> BROADCAST=192.168.133.255
>> PORT=6666
>>
>> send_udp_broadcast()
>> {
>> exec python -c '
>> from socket import *
>> from time import sleep
>> from struct import pack
>> from datetime import datetime
>>
>>
>> s = socket(AF_INET, SOCK_DGRAM)
>> s.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)
>> s.setsockopt(SOL_SOCKET, SO_BINDTODEVICE, pack("'$(( 1+${#DEV} ))'s","'$DEV'"))
>>
>> while 1:
>>     s.sendto(datetime.now().strftime("hi there, it is now %T.%f"), ("'$BROADCAST'",'$PORT'))
>>     sleep(0.1)
>> '
>> }
>>
>> p() { printf "\n"; printf "::: %s\n" "$@"; printf "%s\n" "-----------"; }
>>
>> arp -n | grep $BROADCAST && {
>> 	echo >&2 "Sorry, fix the arp table first!"
>> 	exit 1
>> }
>>
>> ( set +x ; send_udp_broadcast ) &
>> kid=$!
>> p "[$kid] Started to send udp broadcasts on $DEV to $BROADCAST:$PORT"
>>
>> p "We should see the packets being sent on $DEV"
>> tcpdump -n -i $DEV -c 2 -xX udp and port $PORT
>>
>> p "We should not have any arp entries for $BROADCAST"
>> arp -n | grep $BROADCAST
>>
>> p "But we soon will, after we take down $DEV"
>> ip link set down $DEV
>>
>> sleep 2
>>
>> p "Now we should have an incomplete arp entry for $BROADCAST"
>> arp -n | grep $BROADCAST
>>
>> p "It will still be there after we bring $DEV back up"
>> ip link set up $DEV
>>
>> p "There won't be any packets now, this should timeout:"
>> while read -r -t 5 line ; do
>> 	echo "$line"
>> done < <(tcpdump -n -i $DEV -c 2 -xX udp and port $PORT 2>&1)
>>
>> p "Because we still have that arp entry"
>> arp -n | grep $BROADCAST
>>
>> p "And we cannot get rid of it, either, as long as this $DEV is up"
>> arp -d $BROADCAST
>> arp -n | grep $BROADCAST
>>
>> p "but we can stop the child," \
>>    "take down the device," \
>>    "remove the arp entry then," \
>>    "and bring the device back up"
>>
>> kill -STOP $kid
>> ip link set down $DEV
>> sleep 1
>> arp -d $BROADCAST
>> ip link set up $DEV
>> arp -n | grep $BROADCAST
>>
>> p "continue the child" \
>>    "and now we should see outgoing packets again"
>>
>> kill -CONT $kid
>> tcpdump -n -i $DEV -c 2 -xX udp and port $PORT
>>
>> p "and no more arp entry"
>> arp -n | grep $BROADCAST
>>
>> p "Done."
>> kill $kid
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

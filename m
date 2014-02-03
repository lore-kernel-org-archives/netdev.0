From: Greg Kuperman <gregk@MIT.EDU>
Subject: Re: Requeues and ECN marking
Date: Mon, 3 Feb 2014 12:48:15 -0500
Message-ID: <CAMvx-bccJce7U4=KAO-uaot8uguORtBK0kPxdFUUgDkNWJVmMQ@mail.gmail.com>
References: <CAMvx-beWMC8awScfEtHs8sSkzz0fGNqBH1fn7hC=k0iaFpJvSA@mail.gmail.com>
 <1391448503.28432.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-2.mit.edu ([18.9.25.13]:63222 "EHLO
	dmz-mailsec-scanner-2.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752639AbaBCRsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 12:48:39 -0500
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
	by mailhub-auth-2.mit.edu (8.13.8/8.9.2) with ESMTP id s13HmciO023873
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 12:48:38 -0500
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	(authenticated bits=0)
        (User authenticated as gregk@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.13.8/8.12.4) with ESMTP id s13Hmabh016004
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 12:48:37 -0500
Received: by mail-pa0-f52.google.com with SMTP id bj1so7363092pad.39
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 09:48:35 -0800 (PST)
In-Reply-To: <1391448503.28432.101.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the response. I agree that requeues should have nothing to
do with ECN marking, and that is why I am confused about what is
happening.

The entire setup is as follows. I am using the kernel version 3.2.44.
I am running a network emulator (CORE
http://www.nrl.navy.mil/itd/ncs/products/core), within which I have
four nodes. Each node becomes its own linux container, running its own
network control on its interfaces. The four nodes are the sender node
s, receiver node r, and two intermediate nodes 1 and 2. Node s is
connected to node 1, which is connected to node 2, which is connected
to node r. Link (1,2) is rate-limited to 1 Mbps (this rate limiting is
handled by another application that applies back pressure to the node
when its buffers are full and it can no longer send packets; the
buffer for that application is variable, and I have set it to hold up
to 10 packets).

I am running RED queuing discipline on the egress of node 1 with the
following setup:
tc qdisc add dev eth1 root red burst 1000000 limit 10000000 avpkt 1000
ecn bandwidth 125 probability 1

I also run it with the following (and have no change in behavior):
tc qdisc add dev eth1 root red min 2000 max 10000 probability 1.0
limit 1000000 burst 10 avpkt 1000 bandwidth 125 ecn probability 1

The odd thing that seems to be happening is that I can see the backlog
and requeues increasing, and once they hit 1000, then packet marking
begins. This is even though I have the minimum in RED set to 1 byte,
and max set to 0 (which, from my understanding means that packet
marking should begin when the backlog is 1 byte be the maximum
probability of marking right away because the max is set to 0). The
explanation I came up with is that it had something to do with the
requeues, but that may be entirely off base. I have no idea why it
does not begin marking packets right away (which is the desired
behavior).

Thank you again for all of your time, and please let me know if there
is anymore info that you guys need.

Some more queue statistics (I'm not sure how helpful this will be):

qdisc red 8004: root refcnt 2 limit 10000000b min 1b max 0b ecn
 Sent 1044606 bytes 996 pkt (dropped 0, overlimits 0 requeues 905)
 backlog 993072b 913p requeues 905
  marked 0 early 0 pdrop 0 other 0

qdisc red 8004: root refcnt 2 limit 10000000b min 1b max 0b ecn
 Sent 1131390 bytes 1076 pkt (dropped 0, overlimits 0 requeues 984)
 backlog 1080870b 992p requeues 984
  marked 0 early 0 pdrop 0 other 0

qdisc red 8004: root refcnt 2 limit 10000000b min 1b max 0b ecn
 Sent 1231386 bytes 1168 pkt (dropped 0, overlimits 179 requeues 1075)
 backlog 1179690b 1082p requeues 1075
  marked 179 early 0 pdrop 0 other 0

qdisc red 8004: root refcnt 2 limit 10000000b min 1b max 0b ecn
 Sent 1334640 bytes 1263 pkt (dropped 0, overlimits 368 requeues 1169)
 backlog 1283958b 1176p requeues 1169
  marked 368 early 0 pdrop 0 other 0



On Mon, Feb 3, 2014 at 12:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-02-03 at 09:50 -0500, Greg Kuperman wrote:
>> Hi all,
>>
>> I am testing a new congestion control protocol that relies on explicit
>> congestion notifications (ECN) to notify the receiver of a congestion
>> event. I have a rate limited link of 1 Mbps, and I am using the RED
>> queuing discipline with ECN enabled. What I have noticed is that no
>> matter how small I set my queue size, or how low I set my minimum
>> marking level, the first ECN marked packet does not get sent out for
>> about 10 seconds after the input rate exceeds the output rate. Further
>> examination shows that ECN marking does not occur until the number or
>> requeues hits 1000. Below are two queries of tc -s -d qdisc ls dev
>> eth1.
>>
>> qdisc red 8028: root refcnt 2 limit 10000000b min 1b max 0b ecn ewma
>> 30 Plog 21 Scell_log 31
>>  Sent 1307892 bytes 1247 pkt (dropped 0, overlimits 0 requeues 960)
>>  backlog 1052118b 962p requeues 960
>>   marked 0 early 0 pdrop 0 other 0
>>
>> qdisc red 8028: root refcnt 2 limit 10000000b min 1b max 0b ecn ewma
>> 30 Plog 21 Scell_log 31
>>  Sent 1379262 bytes 1312 pkt (dropped 0, overlimits 72 requeues 1024)
>>  backlog 1122468b 1027p requeues 1024
>>   marked 72 early 0 pdrop 0 other 0
>>
>>
>> The txqueuelen defaults to 1000 for the interface, so I figured that
>> packets maybe buffering there, and then dequeuing, before any packets
>> are marked. I set txqueuelen to lower values (all the way down to 1),
>> but the exact same behavior occurs (no marked packets until number of
>> dequeues hits 1000). In contrast, if I set txqueuele to something very
>> high, I get no requeues, drops, or marked packets.
>>
>> My goal is for packets to be marked as soon as the ingress rate
>> exceeds the egress. Am I correct in thinking that the requeuing
>> operation is the culprit? Can I eliminate requeues? Is there something
>> else I can do to get the behavior I am looking for?
>>
>> Thank you all for the help. And please cc me in your replies; I'm not
>> 100% sure if I get all the messages from this mailing list.
>
> requeues have nothing to do with ECN marking.
>
> How is done your rate limiting ?
>
> Post the whole setup, not part of it, it will help to spot the problem
> in one go, instead of many mail exchanges.
>
>

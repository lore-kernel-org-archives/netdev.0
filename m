From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 06:11:20 -0800
Message-ID: <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46894 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab3KGOLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 09:11:23 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa1so652613pad.41
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 06:11:22 -0800 (PST)
In-Reply-To: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 17:12 +0400, Anton 'EvilMan' Danilov wrote:
> Hello.
> 
> I'm experimenting with high performance linux router with 10G NICs.
> On high traffic rates the performance are limited by the lock of root
> queue discipline. For avoid impact of locking i've decided to build
> QoS scheme over the multiq qdisc.
> 
> And I have the issues with use to multiq discipline.
> 
> My setup:
> 1. Multiq qdisc is on top of interface.
> 2. To every multiq class i've attached htb discipline with own
> hierachy of child classes.
> 3. The filters (u32 with hashing) are attached to the root multiq discipline.
> 
> Graphical scheme of hierarchy -
> http://pixpin.ru/images/2013/11/07/multiq-hierarchy1.png
> 
> Fragments of script:
> 
> #add top qdisc and classes
>  qdisc add dev eth0 root handle 10: multiq
>  qdisc add dev eth0 parent 10:1 handle 11: htb
>  class add dev eth0 parent 11: classid 11:1 htb rate 1250Mbit
>  qdisc add dev eth0 parent 10:2 handle 12: htb
>  class add dev eth0 parent 12: classid 12:1 htb rate 1250Mbit
>  qdisc add dev eth0 parent 10:3 handle 13: htb
>  class add dev eth0 parent 13: classid 13:1 htb rate 1250Mbit
>  qdisc add dev eth0 parent 10:4 handle 14: htb
>  class add dev eth0 parent 14: classid 14:1 htb rate 1250Mbit
>  qdisc add dev eth0 parent 10:5 handle 15: htb
>  class add dev eth0 parent 15: classid 15:1 htb rate 1250Mbit
>  qdisc add dev eth0 parent 10:6 handle 16: htb
>  class add dev eth0 parent 16: classid 16:1 htb rate 1250Mbit
>  qdisc add dev eth0 parent 10:7 handle 17: htb
>  class add dev eth0 parent 17: classid 17:1 htb rate 1250Mbit
>  qdisc add dev eth0 parent 10:8 handle 18: htb
>  class add dev eth0 parent 18: classid 18:1 htb rate 1250Mbit
> 
> #add leaf classes and qdiscs (several hundreds)
>  ...
>  class add dev eth0 parent 11:1 classid 11:1736 htb rate 1024kbit
>  qdisc add dev eth0 parent 11:1736 handle 1736 pfifo limit 50
>  ...
> 
> But I see zero statistics on the leaf htb classes and nonzero
> statistics on the classifier filters:
> 
> ~$ tc -s -p filter list dev eth1
>  ...
>  filter parent 10: protocol ip pref 5 u32 fh 2:f2:800 order 2048 key
> ht 2 bkt f2 flowid 11:1736  (rule hit 306 success 306)
>    match IP src xx.xx.xx.xx/30 (success 306 )
>  ...
> 
> ~$ tc -s -s -d c ls dev eth1 classid 11:1736
>  class htb 11:1736 parent 11:1 leaf 1736: prio 0 quantum 12800 rate
> 1024Kbit ceil 1024Kbit burst 1599b/1 mpu 0b overhead 0b cburst 1599b/1
> mpu 0b overhead 0b level 0
>   Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>   rate 0bit 0pps backlog 0b 0p requeues 0
>   lended: 0 borrowed: 0 giants: 0
>   tokens: 195312 ctokens: 195312
> 
> I think I've lost from view the some aspects of settings.
> Has anyone setuped the like complex scheme over the multiq discipline?
> 

I think this is not going to work, because multiqueue selection happens
before applying the filters to find a flowid.

And queue selection selects the queue depending on factors that are not
coupled to your filters, like cpu number

It looks like you want to rate limit a large number of flows, you could
try the following setup :

for ETH in eth0
do
 tc qd del dev $ETH root 2>/dev/null

 tc qd add dev $ETH root handle 100: mq 
 for i in `seq 1 8`
 do
  tc qd add dev $ETH parent 100:$i handle $i fq maxrate 1Mbit
 done
done

From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Bridge does not forward packets to a tap device
Date: Tue, 10 Nov 2015 19:18:04 -0500
Message-ID: <5642893C.6050806@redhat.com>
References: <CAFmWiaRA01GZpLAa8DNu3-iBBQNrXZA1quohVacSz3OPXkKw8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ido Barkan <ibarkan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbbKKASH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2015 19:18:07 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 275558F27C
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 00:18:07 +0000 (UTC)
In-Reply-To: <CAFmWiaRA01GZpLAa8DNu3-iBBQNrXZA1quohVacSz3OPXkKw8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ido Barkan wrote:
> Hi all,
>
> We have this very disturbing issue on a few of our production servers,
> which disconnects VMs
> from their network.
> * The Vms are part of an oVirt host so each vm is attached to a l2
> bridge with a tap device.
> * The bridge has an IP on it and is connected via a bond
> Issue:
> --------
> when the machine pings outside to the host (8.8.8.8):
> * arp who-has packets are sent to the bridge and forwarded but the
> bridge is not forwarding the reply (is-at) (see tcpdump output in [1])
>
> 2 more interesting facts:
> ----------------------------------
> * ping directly to the bridge ip succeeds.
> * the host is a UCS host.
>
> <Versions>:
> [root@ucs1-b200-2 ~]# uname -r
> 2.6.32-573.7.1.el6.x86_64

This isn't an upstream kernel, you would generally probably be better 
off talking to folks who produce your kernel, particularly given your 
email address. :)

> [root@ucs1-b200-2 ~]# rpm -q libvirt
> libvirt-0.10.2-54.el6.x86_64
>
>
> <Network configuration on host>
> [root@ucs1-b200-2 ~]# ip l
> 2: eth0:<BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP>  mtu 1500 qdisc mq
> master bond0 state UP qlen 1000
>      link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
> 3: eth1:<BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP>  mtu 1500 qdisc mq
> master bond0 state UP qlen 1000
>      link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
> 4: bond0:<BROADCAST,MULTICAST,MASTER,UP,LOWER_UP>  mtu 1500 qdisc
> noqueue state UP
>      link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
> 5: rhevm:<BROADCAST,MULTICAST,UP,LOWER_UP>  mtu 1500 qdisc noqueue state UNKNOWN
>      link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
> 11: vnet0:<BROADCAST,MULTICAST,UP,LOWER_UP>  mtu 1500 qdisc pfifo_fast
> state UNKNOWN qlen 500
>      link/ether fe:1a:4a:23:12:a0 brd ff:ff:ff:ff:ff:ff

What are the underlying network cards? If they support LRO, I'm guessing 
the problem is LRO flag disabling not being propagated down the stack. 
You can confirm that by checking for large-receive-offload via ethtool 
on your physical interfaces:

ethtool -k eth0 | grep large
ethtool -k eth1 | grep large

This should already be fixed in a forthcoming el6 kernel build.

Dunno how much you can see, but its tracked here:
   https://bugzilla.redhat.com/show_bug.cgi?id=1259008

-- 
Jarod Wilson
jarod@redhat.com

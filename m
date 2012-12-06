From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next 0/1] fix vlan transmit performance
Date: Thu,  6 Dec 2012 15:54:55 -0500
Message-ID: <1354827296-12009-1-git-send-email-gallatin@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:34752 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947191Ab2LFUzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 15:55:06 -0500
Received: by mail-ye0-f174.google.com with SMTP id m6so1162099yen.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 12:55:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When doing some 10GbE perf measurments on very old athlon64
machines with myri10ge, I noticed that I was seeing CPU saturation
when transmitting vlan tagged traffic.  I think I traced the
problem to this line in netif_skb_features():

	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_TX);

The problem seems to be that packets travel through this function
twice, first on their way to the vlan xmit handler, and then on
their way to the backing device's xmit handler.  On the first
pass, "skb->dev" is the vlan device, and skb->dev->vlan_features
is blank.  This causes netif_skb_features() to strip the offloads
away.

The following patch (just copy dev->features to dev->vlan_features in
vlan_dev_init()) seems to be the simplest way to fix it. Perhaps this
is wrong, and there is a better way?  Given that this has apparently
been broken for nearly 2 years (since f01a5236), I'm worried that
either I'm doing something wrong in myri10ge, or that I'm missing
something in general.

At any rate, performance jumps from 5.6Gb/s with one CPU entirely
saturated on the sender, to 9Gb/s with idle time:

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

before:
 87380  65536  65536    10.00      5660.66   25.54    51.41    1.478   1.488  

after:
 87380  65536  65536    10.00      9081.39   15.66    76.42    0.565   1.379  



Andrew Gallatin (1):
  vlan: restore offload use on vlan transmit

 net/8021q/vlan_dev.c |    1 +
 1 file changed, 1 insertion(+)

-- 
1.7.9.5

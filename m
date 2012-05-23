From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 11:44:06 +0200
Message-ID: <1337766246.3361.2447.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
	 <1337678759.3361.147.camel@edumazet-glaptop>
	 <1337679045.3361.154.camel@edumazet-glaptop>
	 <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>
	 <1337703170.3361.217.camel@edumazet-glaptop>
	 <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>
	 <1337705135.3361.226.camel@edumazet-glaptop>
	 <1337720076.3361.667.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49865 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538Ab2EWJoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 05:44:14 -0400
Received: by mail-ey0-f174.google.com with SMTP id k11so1952398eaa.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 02:44:13 -0700 (PDT)
In-Reply-To: <1337720076.3361.667.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update :

My tests show that sk_backlog.len can reach 1.5MB easily on a netperf,
even with a fast machine, receiving a 10Gb flow (ixgbe adapter), if
LRO/GRO are off.

424 backlogdrop for 193.182.546 incoming packets (with my tcp_space()
patch applied)

I believe that as soon as ixgbe can use build_skb() and avoid the 1024
bytes overhead per skb, it should go away.

Of course, another way to solve the problem would be to change
tcp_recvmsg() to use lock_sock_fast(), so that no frame is backlogged at
all.

Locking the socket for the whole operation (including copyout to user)
is not very good. It was good enough years ago with small receive
window.

With a potentially huge backlog, it means user process has to process
it, regardless of its latency constraints. CPU caches are also
completely destroyed because of huge amount of data included in thousand
of skbs.

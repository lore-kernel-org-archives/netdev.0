From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Thu, 18 Sep 2014 06:33:29 -0700
Message-ID: <1411047209.7106.255.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140917152653.1c824a22@redhat.com>
	 <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5419A1E7.8040109@intel.com> <20140918085640.0815df6d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34389 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbaIRNdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 09:33:31 -0400
Received: by mail-pa0-f41.google.com with SMTP id et14so1510140pad.28
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 06:33:30 -0700 (PDT)
In-Reply-To: <20140918085640.0815df6d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 08:56 +0200, Jesper Dangaard Brouer wrote:

> After setting up XPS to CPU 1:1 binding, it works most of the time.
> Meaning, most of the traffic will go through the TXQ I've bound the
> process to, BUT some packets can still choose another TXQ (observed
> monitoring tc output and blqmon).

Note that for TCP, there are packets sent by the process doing the
send(), or packets sent by cpu doing TX completion (because of TSQ),
but also packets sent by ACK processing done in the reverse way.

As Alexander explained, if the ACK packets are delivered into another
CPU, then you might select another TX queue.

This is mostly prevented because of ooo_okay logic, meaning that a busy
bulk flow should stick into a single TX queue, no matter of XPS says.

A TCP_RR workload is free to chose whatever queue, because every packet
starting a RR block has the ooo_okay set (As prior data was delivered
and acknowledged by the opposite peer)

> 
> Could this be related to the missing RPS setup?

No, for this to really work, you need hardware support, so that ACK
packets take the same RX queue than the sent packets.

> 
> Can I get some hints setting up RPS?
> 

Documentation/networking/scaling.txt  is full of hints...

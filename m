From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: TSO not 10G friendly if peer is close enough
Date: Tue, 17 Apr 2012 23:38:42 +0200
Message-ID: <1334698722.2472.71.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl>  <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62939 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab2DQVit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 17:38:49 -0400
Received: by wibhj6 with SMTP id hj6so17187wib.1
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 14:38:48 -0700 (PDT)
In-Reply-To: <1334681204.2472.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After further analysis, I found we hit badly page refcounts games,
because when we transmit full size skb (64 KB), we can receive ACK for
the first MSS of the frame while skb was not completely sent by NIC.

(Needs 52 us to send a full TSO frame at 10Gb, and maybe NIC delays
interrupt to trigger TX completion ?)

In this case, tcp_trim_head() has to call pskb_expand_head(), because
skb clone is still alive in TX ring buffer.

pskb_expand_head() is really expensive, it has to make about 32 atomic
operations on page refcounts.

Hmm... maybe tcp_trim_head should not trim but only update an offset in
skb... With some luck, offset can reach skb->len when all data is
ACKnowledged...

Only in case of retransmit we would need to really trim the skb, and by
this time, clone would had been freed to : No more pskb_expand_head()
calls.

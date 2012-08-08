From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx
 confirmation processing
Date: Wed, 08 Aug 2012 18:44:27 +0200
Message-ID: <1344444267.28967.225.camel@edumazet-glaptop>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
	 <20120808162423.GC11043@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58103 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab2HHQoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 12:44:37 -0400
Received: by bkwj10 with SMTP id j10so368516bkw.19
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2012 09:44:36 -0700 (PDT)
In-Reply-To: <20120808162423.GC11043@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-08 at 12:24 -0400, Paul Gortmaker wrote:
> [[RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation processing] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:
> 
> > Hi all,
> > This set of patches basically splits the existing napi poll routine into
> > two separate napi functions, one for Rx processing (triggered by frame
> > receive interrupts only) and one for the Tx confirmation path processing
> > (triggerred by Tx confirmation interrupts only). The polling algorithm
> > behind remains much the same.
> > 
> > Important throughput improvements have been noted on low power boards with
> > this set of changes.
> > For instance, for the following netperf test:
> > netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
> > yields a throughput gain from oscilating ~500-~700 Mbps to steady ~940 Mbps,
> > (if the Rx/Tx paths are processed on different cores), w/ no increase in CPU%,
> > on a p1020rdb - 2 core machine featuring etsec2.0 (Multi-Queue Multi-Group
> > driver mode).
> 
> It would be interesting to know more about what was causing that large
> an oscillation -- presumably you will have it reappear once one core
> becomes 100% utilized.  Also, any thoughts on how the change will change
> performance on an older low power single core gianfar system (e.g.  83xx)?

I also was wondering if this low performance could be caused by BQL

Since TCP stack is driven by incoming ACKS, a NAPI run could have to
handle 10 TCP acks in a row, and resulting xmits could hit BQL and
transit on qdisc (Because NAPI handler wont handle TX completions in the
middle of RX handler)

So experiments would be nice, maybe by reducing a
bit /proc/sys/net/ipv4/tcp_limit_output_bytes 
(from 131072 to 65536 or 32768)

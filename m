From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: skb allocation from interrupt handler?
Date: Wed, 9 Aug 2017 16:31:26 -0700
Message-ID: <20170809163126.207392df@xeon-e3>
References: <598A3890.80705@ti.com>
        <20170808.160022.550877862496200067.davem@davemloft.net>
        <598B3A14.5020507@ti.com>
        <20170809222919.GA4101@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Murali Karicheri <m-karicheri2@ti.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:38113 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752135AbdHIXb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:31:29 -0400
Received: by mail-pg0-f42.google.com with SMTP id l64so33847445pge.5
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 16:31:29 -0700 (PDT)
In-Reply-To: <20170809222919.GA4101@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Aug 2017 00:29:19 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Murali Karicheri <m-karicheri2@ti.com> :
> [...]
> > The internal memory or FIFO can store only up to 3 MTU sized packets. So that has to
> > be processed before PRU gets another packets to send to CPU. So per above, 
> > it is not ideal to run NAPI for this scenario, right? Also for NetCP we use
> > about 128 descriptors with MTU size buffers to handle 1Gbps Ethernet link.
> > Based on that roughly we would need at least 10-12 buffers in the FIFO.
> > 
> > Currently we have a NAPI implementation in use that gives throughput of 95Mbps for
> > MTU sized packets, but our UDP iperf tests shows less than 1% packet loss for an
> > offered traffic of 95Mbps with MTU sized packets.  This is not good for industrial
> > network using HSR/PRP protocol for network redundancy. We need to have zero packet
> > loss for MTU sized packets at 95Mbps throughput. That is the problem description.  
> 
> Imvho you should instrument the kernel to figure where the excess latency that
> prevents NAPI processing to take place within 125 us of physical packet reception
> comes from.
> 
> > As an experiment, I have moved the packet processing to irq handler to see if we 
> > can take advantage of CPU cycle to processing the packet instead of NAPI
> > and to check if the firmware encounters buffer overflow. The result is positive 
> > with no buffer overflow seen at the firmware and no packet loss in the iperf test.
> > But we want to do more testing as an experiment and ran into a uart console locks
> > up after running traffic for about 2 minutes. So I tried enabling the DEBUG HACK 
> > options to get some clue on what is happening and ran into the trace I shared 
> > earlier. So what function can I use to allocate SKB from interrupt handler ?  
> 
> Is your design also so tight on memory that you can't even refill your own
> software skb pool from some non-irq context then only swap buffers in the
> irq handler ?
> 

The current best practice in network drivers is to receive into
an allocated page, then create skb meta data with build_skb() in the NAPI poll
routine.

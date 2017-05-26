From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] sky2: Do not deadlock on sky2_hw_down
Date: Fri, 26 May 2017 08:43:08 -0700
Message-ID: <20170526084308.091a41cb@xeon-e3>
References: <20170525105458.539dedba@xeon-e3>
        <CALH_86T3YW=VOCACJ+659GxZQQLtVafRpUTqQagWUdcsPDPH=A@mail.gmail.com>
        <20170525150502.4fe5c506@xeon-e3>
        <20170525.235830.986562840550889246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jemele@gmail.com, jemele@acm.org, netdev@vger.kernel.org,
        jemele@google.com, mlindner@marvell.com,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35076 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943742AbdEZPnN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 11:43:13 -0400
Received: by mail-pf0-f180.google.com with SMTP id n23so14966031pfb.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 08:43:13 -0700 (PDT)
In-Reply-To: <20170525.235830.986562840550889246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 May 2017 23:58:30 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 25 May 2017 15:05:02 -0700
> 
> > Ok, the issue is that lockdep is being stupid and thinking that
> > seqcount's behave like locks.  
> 
> Well.. they do.  That's why they have that annotation.

Your right, but it has some lock like properties because
the seqcount's assumption about odd and even values.

Lockdep is reporting that accessing a sequence count with softirq disabled
and in another case with softirq enabled is a problem. 

Potential race theoretical race:


 seqcount_begin()             ++count
  ...
		---> IRQ
                --->   Soft IRQ
                                    seqcount_begin()  ++count
					update stats
				    seqcount_end() ++count
      Anything doing seqcount read during this softirq 
      will spin thinking still in critical section

But for this case of statistics, there is nothing reading statistics in softirq
context so it can't happen. Lockdep needs to be smarter to know that.
Simplest way to shut this up is to just disable softirq during the cleanup.

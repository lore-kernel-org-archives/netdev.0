From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Sat, 06 Sep 2014 08:46:24 -0700
Message-ID: <1410018384.11872.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ED4354.9090904@intel.com>
	 <20140814.162024.2218312002979492106.davem@davemloft.net>
	 <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
	 <20140821.162406.2076033247433267586.davem@davemloft.net>
	 <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:58564 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaIFPq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 11:46:26 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so271113pab.31
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 08:46:26 -0700 (PDT)
In-Reply-To: <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-06 at 08:27 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Alexander Duyck reported high false sharing on dst refcount in tcp stack
> when prequeue is used. prequeue is the mechanism used when a thread is
> blocked in recvmsg()/read() on the TCP socket.
> 
> We already try to use RCU in input path as much as possible, but we were
> forced to take a refcount on the dst when skb escaped RCU protected
> region. When/if the user thread runs on different cpu, dst_release()
> will then touch dst refcount again.
> 
> Commit 093162553c33 (tcp: force a dst refcount when prequeue packet)
> was an example of a race fix.
> 
> It turns out the only remaining usage of skb->dst for a packet stored
> in a TCP socket prequeue is IP early demux.
> 
> We can add a logic to detect when IP early demux is probably going
> to use skb->dst.
> 
> In IPv4 stack, we also can drop dst when skb has to be queued into
> socket backlog. IPv6 needs extra care before doing the same.
> 
> Many thanks to Alexander for providing a nice bug report, git bisection,
> and reproducer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>

Works fine on IPv4, not on IPv6, I will submit a v2 (with a proper title
btw)

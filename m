From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: yield() in netlink_broadcast_filtered
Date: Fri, 6 Apr 2012 08:05:34 -0700
Message-ID: <20120406080534.33e0d1c4@nehalam.linuxnetplumber.net>
References: <4F7EF9AC.8050305@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Fredrick <fjohnber@zoho.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41047 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417Ab2DFPFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 11:05:37 -0400
In-Reply-To: <4F7EF9AC.8050305@zoho.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Apr 2012 07:11:56 -0700
Fredrick <fjohnber@zoho.com> wrote:

> 
> 
> I see there is a yield being called from
> netlink_broadcast_filtered.
> .....
> int netlink_broadcast_filtered(...)
> {
> ....
>          if (info.delivered) {
>                  if (info.congested && (allocation & __GFP_WAIT))
>                          yield();
>                  return 0;
>          }
>          return -ESRCH;
> }
> .....
> 
> But I don't see the point of calling it.
> After the yield, there is nothing being done.
> It just returns. So why yield ?
> Why can't it simply return?
> 

Because without that yield it is easily possible for one process
to generate lots of netlink messages and overrun the consumers.
The yield allows the now ready listening processes to run.
There is no good mechanism to totally prevent overrunning the
socket of processes reading for netlink events, but this yield()
is good enough to avoid the problem with the typical case.
The example we are familar with is a full route table (1M routes)
and a link change causing a routing flap.

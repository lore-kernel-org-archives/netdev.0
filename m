From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 3/3 net-next] tcp: implement RFC5682 F-RTO
Date: Wed, 20 Mar 2013 22:00:32 -0700
Message-ID: <1363842032.3333.48.camel@edumazet-glaptop>
References: <1363822380-16687-1-git-send-email-ycheng@google.com>
	 <1363822380-16687-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com, ilpo.jarvinen@cs.helsinki.fi,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:58141 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab3CUFAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 01:00:35 -0400
Received: by mail-da0-f48.google.com with SMTP id p8so1402644dan.21
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 22:00:35 -0700 (PDT)
In-Reply-To: <1363822380-16687-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 16:33 -0700, Yuchung Cheng wrote:
> This patch implements F-RTO (foward RTO recovery):
> 
> When the first retransmission after timeout is acknowledged, F-RTO
> sends new data instead of old data. If the next ACK acknowledges
> some never-retransmitted data, then the timeout was spurious and the
> congestion state is reverted.  Otherwise if the next ACK selectively
> acknowledges the new data, then the timeout was genuine and the
> loss recovery continues. This idea applies to recurring timeouts
> as well. While F-RTO sends different data during timeout recovery,
> it does not (and should not) change the congestion control.
> 
> The implementaion follows the three steps of SACK enhanced algorithm
> (section 3) in RFC5682. Step 1 is in tcp_enter_loss(). Step 2 and
> 3 are in tcp_process_loss().  The basic version is not supported
> because SACK enhanced version also works for non-SACK connections.
> 
> The new implementation is functionally in parity with the old F-RTO
> implementation except the one case where it increases undo events:
> In addition to the RFC algorithm, a spurious timeout may be detected
> without sending data in step 2, as long as the SACK confirms not
> all the original data are dropped. When this happens, the sender
> will undo the cwnd and perhaps enter fast recovery instead. This
> additional check increases the F-RTO undo events by 5x compared
> to the prior implementation on Google Web servers, since the sender
> often does not have new data to send for HTTP.
> 
> Note F-RTO may detect spurious timeout before Eifel with timestamps
> does so.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> ChangeLog in v2:
>  - Removed extra while spaces
>  - Allow F-RTO in sack reneging case to detect spurious retransmit(s)
>  - Re-tested after merging with the recent TCP tail loss probe patch
> 
>  Documentation/networking/ip-sysctl.txt | 18 +++------
>  include/linux/tcp.h                    |  3 +-
>  net/ipv4/tcp_input.c                   | 73 ++++++++++++++++++++++++++++------
>  3 files changed, 68 insertions(+), 26 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

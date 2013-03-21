From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 3/3 net-next] tcp: implement RFC5682 F-RTO
Date: Thu, 21 Mar 2013 09:26:17 -0400
Message-ID: <CADVnQym3WOtUZQLmyO6KtymyeErMWTphR452O3wN=ZqusvvQHQ@mail.gmail.com>
References: <1363822380-16687-1-git-send-email-ycheng@google.com>
	<1363822380-16687-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Ilpo Jarvinen <ilpo.jarvinen@cs.helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:52228 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755777Ab3CUN0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 09:26:18 -0400
Received: by mail-ea0-f174.google.com with SMTP id q10so864339eaj.19
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 06:26:17 -0700 (PDT)
In-Reply-To: <1363822380-16687-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 7:33 PM, Yuchung Cheng <ycheng@google.com> wrote:
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

Acked-by: Neal Cardwell <ncardwell@google.com>

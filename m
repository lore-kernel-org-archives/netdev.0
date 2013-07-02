From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] l2tp: make datapath resilient to packet loss when
 sequence numbers enabled
Date: Tue, 02 Jul 2013 20:32:56 +0400
Message-ID: <51D300B8.4030807@cogentembedded.com>
References: <1372759229-15178-1-git-send-email-jchapman@katalix.com> <1372759229-15178-4-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:50346 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370Ab3GBQdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 12:33:03 -0400
Received: by mail-la0-f53.google.com with SMTP id fs12so5754582lab.40
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 09:33:01 -0700 (PDT)
In-Reply-To: <1372759229-15178-4-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-07-2013 14:00, James Chapman wrote:

> If L2TP data sequence numbers are enabled and reordering is not
> enabled, data reception stops if a packet is lost since the kernel
> waits for a sequence number that is never resent. (When reordering is
> enabled, data reception restarts when the reorder timeout expires.) If
> no reorder timeout is set, we should count the number of in-sequence
> packets after the out-of-sequence (OOS) condition is detected, and reset
> sequence number state after a number of such packets are received.

> For now, the number of in-sequence packets while in OOS state which
> cause the sequence number state to be reset is hard-coded to 5. This
> could be configurable later.

> Signed-off-by: James Chapman <jchapman@katalix.com>
> ---
>   net/l2tp/l2tp_core.c |   37 ++++++++++++++++++++++++++++++++-----
>   net/l2tp/l2tp_core.h |    3 +++
>   2 files changed, 35 insertions(+), 5 deletions(-)

> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index cc7ece9..f572e93 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -572,12 +572,34 @@ static int l2tp_recv_data_seq(struct l2tp_session *session, struct sk_buff *skb)
[...]
> +		u32 nr_oos = L2TP_SKB_CB(skb)->ns;
> +		u32 nr_next = (session->nr_oos + 1) & session->nr_max;
> +
> +		if (nr_oos == nr_next)
> +			session->nr_oos_count++;
> +		else
> +			session->nr_oos_count = 0;
> +
> +		session->nr_oos = nr_oos;
> +		if (session->nr_oos_count > session->nr_oos_count_max) {
> +			session->reorder_skip = 1;
> +			l2tp_dbg(session, L2TP_MSG_SEQ,
> +				 "%s: %d oos packets received. "
> +				 "Resetting sequence numbers\n",

    Same comment about the long message string. Not breaking such 
strings facilitates grepping in the kernel for them. In theory, 
checkpatch.pl should have complained here, but it might not have 
recognized the function. If it complains about long string, just ignore it.

WBR, Sergei

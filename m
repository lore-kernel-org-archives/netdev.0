From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: detect loss above high_seq in recovery
Date: Wed, 28 Dec 2011 17:42:06 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi>
References: <1325033182-25905-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	nanditad@google.com, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57976 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab1L1PmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 10:42:08 -0500
In-Reply-To: <1325033182-25905-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Dec 2011, Yuchung Cheng wrote:

> Correctly implement a loss detection heuristic: New sequences (above
> high_seq) sent during the fast recovery are deemed lost when higher
> sequences are SACKed.
> 
> Current code does not catch these losses, because tcp_mark_head_lost()
> does not check packets beyond high_seq. The fix is straight-forward by
> checking packets until the highest sacked packet. In addition, all the
> FLAG_DATA_LOST logic are in-effective and redundant and can be removed.

I agree that FLAG_DATA_LOST never did anything very useful... I've never 
figure out why it was there (perhaps some earlier change made it broken or 
so before I've been tracking TCP dev).

> The new sequences sent during fast-recovery maybe marked as lost
> and/or retransmitted. It is possible these (new) losses are recovered
> within the current fast recovery and the state moves back to CA_Open
> without entering another fast recovery / cwnd redunction. This is
> especially possible for light losses.  Note RFC 3517 (implicitly)
> allows this as well.

No it doesn't! It does not allow you to avoid the second cwnd reduction. 
They're from different RTT. What you now claim is that we never need to 
do cwnd reduction until we visit CA_Open in between. That's very very 
dangerous if the congestion suddently spikes because nobody reduces twice 
causing everyone to get losses and continues in the recovery forever.

> Update the loss heuristic comments. The algorithm above is documented
> as heuristic B, but it is redundant too because heuristic A already
> covers B.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/linux/snmp.h |    1 -
>  net/ipv4/proc.c      |    1 -
>  net/ipv4/tcp_input.c |   41 +++++++++++++++--------------------------
>  3 files changed, 15 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/snmp.h b/include/linux/snmp.h
> index e16557a..c1241c42 100644
> --- a/include/linux/snmp.h
> +++ b/include/linux/snmp.h
> @@ -192,7 +192,6 @@ enum
>  	LINUX_MIB_TCPPARTIALUNDO,		/* TCPPartialUndo */
>  	LINUX_MIB_TCPDSACKUNDO,			/* TCPDSACKUndo */
>  	LINUX_MIB_TCPLOSSUNDO,			/* TCPLossUndo */
> -	LINUX_MIB_TCPLOSS,			/* TCPLoss */
>  	LINUX_MIB_TCPLOSTRETRANSMIT,		/* TCPLostRetransmit */
>  	LINUX_MIB_TCPRENOFAILURES,		/* TCPRenoFailures */
>  	LINUX_MIB_TCPSACKFAILURES,		/* TCPSackFailures */
> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
> index 3569d8e..6afc807 100644
> --- a/net/ipv4/proc.c
> +++ b/net/ipv4/proc.c
> @@ -216,7 +216,6 @@ static const struct snmp_mib snmp4_net_list[] = {
>  	SNMP_MIB_ITEM("TCPPartialUndo", LINUX_MIB_TCPPARTIALUNDO),
>  	SNMP_MIB_ITEM("TCPDSACKUndo", LINUX_MIB_TCPDSACKUNDO),
>  	SNMP_MIB_ITEM("TCPLossUndo", LINUX_MIB_TCPLOSSUNDO),
> -	SNMP_MIB_ITEM("TCPLoss", LINUX_MIB_TCPLOSS),

I don't think you can remove MIBs as they're userspace visible.


-- 
 i.

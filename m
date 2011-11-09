From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction during
 fast recovery
Date: Tue, 8 Nov 2011 17:18:34 -0800
Message-ID: <CAK6E8=dXtgi+W9JQg9ruwU8JxYJf-T7OMad7RhNckFAxsYFndg@mail.gmail.com>
References: <1320775631-16341-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50499 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab1KIBSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 20:18:55 -0500
Received: by qao25 with SMTP id 25so1100936qao.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 17:18:55 -0800 (PST)
In-Reply-To: <1320775631-16341-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 8, 2011 at 10:07 AM, Neal Cardwell <ncardwell@google.com> wrote:
> Fixes for some issues that prevent DSACKs from allowing TCP senders to
> undo cwnd reductions made during fast recovery.
>
> There were a few related bugs/issues:
>
> 1) Senders ignored DSACKs after recovery when there were no
> outstanding packets (a common scenario for HTTP servers).
>
> 2) When the ACK field is below snd_una (which can happen when ACKs are
> reordered), senders ignored DSACKs (preventing undo) and passed up
> chances to send out more packets based on any newly-SACKed packets.
>
> 3) Senders were overriding cwnd values picked during an undo by
> calling tcp_moderate_cwnd() in tcp_try_to_open().
>
> The fixes:
>
> (1) When there are no outstanding packets (the "no_queue" goto label),
> use DSACKs to undo congestion window reductions.
>
> (2) When the ACK field is below snd_una (the "old_ack" goto label),
> process any DSACKs and try to send out more packets based on
> newly-SACKed packets.
>
> (3) Don't moderate cwnd in tcp_try_to_open() if we're in TCP_CA_Open,
> since doing so is generally unnecessary and specifically would
> override a DSACK-based undo of a cwnd reduction made in fast recovery.
>
> (4) Simplify the congestion avoidance state machine by removing the
> behavior where SACK-enabled connections hung around in the
> TCP_CA_Disorder state just waiting for DSACKs. Instead, when snd_una
> advances to high_seq or beyond we typically move to TCP_CA_Open
> immediately and allow an undo in either TCP_CA_Open or TCP_CA_Disorder
> if we later receive enough DSACKs. Previously, SACK-enabled
> connections hung around in TCP_CA_Disorder state while
> snd_una==high_seq, just waiting to accumulate DSACKs and hopefully
> undo a cwnd reduction. This could and did lead to the following
> unfortunate scenario: if some incoming ACKs advance snd_una beyond
> high_seq then we were setting undo_marker to 0 and moving to
> TCP_CA_Open, so if (due to reordering in the ACK return path) we
> shortly thereafter received a DSACK then we were no longer able to
> undo the cwnd reduction.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>


FWIW. This undo-fix patch on Google Web servers increased the undos in
loss by 46% and in disorder by 17%. It also corrects the SNMP stats
TCPTimeouts, TCPRenoFailures, TCPSackFailures by moving state into
open, instead of disorder, after recovery.

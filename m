From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix a success return may hide an error
Date: Fri, 12 Aug 2016 21:11:13 -0700 (PDT)
Message-ID: <20160812.211113.1099230839994600349.davem@davemloft.net>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbcHMELP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 00:11:15 -0400
In-Reply-To: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 11 Aug 2016 20:52:58 +0800

> Now in the end of sctp_outq_flush, sctp calls sctp_packet_transmit
> in a loop. The return of current sctp_packet_transmit always covers
> the prior one's. If the last call of sctp_packet_transmit return a
> success, it may hide the error that returns from the prior call.
> 
> This patch is to fix this by keeping the old error until the new
> error returns from sctp_packet_transmit. Did TAHI test against this
> fix, no regression is found.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

This style of error handling is dangerous.  The first error can be
lost.

For example, if sctp_outq_flush_rtx() earlier in this function returns
an error, it will be lost if any invocation of the function
sctp_packet_transmit() at the end function signals an error.

I think you should always preserve the first error that is recorded
into 'error'.

I also wonder about why sctp_outq_flush_rtx() errors are completely
ignored and don't influence the control flow here in any way.

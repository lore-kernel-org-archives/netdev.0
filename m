From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: sctp: wake up all assocs if sndbuf policy
 is per socket
Date: Tue, 08 Apr 2014 13:08:49 -0400 (EDT)
Message-ID: <20140408.130849.2070157751349863276.davem@davemloft.net>
References: <1396970773-17500-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org, tgraf@suug.ch,
	nhorman@tuxdriver.com, vyasevic@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756359AbaDHRIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:08:52 -0400
In-Reply-To: <1396970773-17500-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  8 Apr 2014 17:26:13 +0200

> SCTP charges chunks for wmem accounting via skb->truesize in
> sctp_set_owner_w(), and sctp_wfree() respectively as the
> reverse operation. If a sender runs out of wmem, it needs to
> wait via sctp_wait_for_sndbuf(), and gets woken up by a call
> to __sctp_write_space() mostly via sctp_wfree().
> 
> __sctp_write_space() is being called per association. Although
> we assign sk->sk_write_space() to sctp_write_space(), which
> is then being done per socket, it is only used if send space
> is increased per socket option (SO_SNDBUF), as SOCK_USE_WRITE_QUEUE
> is set and therefore not invoked in sock_wfree().
> 
> Commit 4c3a5bdae293 ("sctp: Don't charge for data in sndbuf
> again when transmitting packet") fixed an issue where in case
> sctp_packet_transmit() manages to queue up more than sndbuf
> bytes, sctp_wait_for_sndbuf() will never be woken up again
> unless it is interrupted by a signal. However, a still
> remaining issue is that if net.sctp.sndbuf_policy=0, that is
> accounting per socket, and one-to-many sockets are in use,
> the reclaimed write space from sctp_wfree() is 'unfairly'
> handed back on the server to the association that is the lucky
> one to be woken up again via __sctp_write_space(), while
> the remaining associations are never be woken up again
> (unless by a signal).
> 
> The effect disappears with net.sctp.sndbuf_policy=1, that
> is wmem accounting per association, as it guarantees a fair
> share of wmem among associations.
> 
> Therefore, if we have reclaimed memory in case of per socket
> accounting, wake all related associations to a socket in a
> fair manner, that is, traverse the socket association list
> starting from the current neighbour of the association and
> issue a __sctp_write_space() to everyone until we end up
> waking ourselves. This guarantees that no association is
> preferred over another and even if more associations are
> taken into the one-to-many session, all receivers will get
> messages from the server and are not stalled forever on
> high load. This setting still leaves the advantage of per
> socket accounting in touch as an association can still use
> up global limits if unused by others.
> 
> Fixes: 4eb701dfc618 ("[SCTP] Fix SCTP sendbuffer accouting.")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks.

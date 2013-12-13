From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 09:56:04 -0800
Message-ID: <1386957364.19078.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B748E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:39506 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab3LMR4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 12:56:08 -0500
Received: by mail-yh0-f44.google.com with SMTP id f64so1756656yha.31
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 09:56:07 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B748E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-13 at 16:58 +0000, David Laight wrote:
> > From: Neal Cardwell
> ...
> > Seems like a nice improvement, but if we apply this patch then AFAICT
> > to get the Nagle-enabled case right we also have to update
> > tcp_minshall_update() to notice these new non-MSS-aligned segments
> > going out, and count those as non-full-size segments for the
> > minshall-nagle check (to ensure we have no more than one outstanding
> > un-ACKed sub-MSS packet). Maybe something like (please excuse the
> > formatting):
> 
> This sort of begs the question about how Nagle should work.
> IIRC Nagle just suppresses short segments when there is unacked data? [1]
> 
> If you have sent a TSO packet then nagle will always be 'waiting for an ack',
> so should only send full segments. What is questionable is whether you should
> send the final short segment, or buffer it waiting for further data from
> the application to fill the segment (or an ack from the remote system).

Point is the current code does a grouped send of the two skbs, without
any wait or even release of socket lock, allowing a tcp_sendmsg() to
aggregate/coalesce more data to the last (partial) segment.

Nagle test is properly done _before_ the call to tcp_mss_split_point()

I think the current behavior of tcp_mss_split_point() is a leftover of
the old days, when David Miller (and others) added TSO support to the
stack.

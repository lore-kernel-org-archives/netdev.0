From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 16:58:26 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B748E@saturn3.aculab.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com> <CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>,
	"Yuchung Cheng" <ycheng@google.com>,
	"Nandita Dukkipati" <nanditad@google.com>,
	"Van Jacobson" <vanj@google.com>
To: "Neal Cardwell" <ncardwell@google.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40128 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752018Ab3LMQ7h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 11:59:37 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11372-09 for <netdev@vger.kernel.org>;
 Fri, 13 Dec 2013 16:59:33 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Neal Cardwell
...
> Seems like a nice improvement, but if we apply this patch then AFAICT
> to get the Nagle-enabled case right we also have to update
> tcp_minshall_update() to notice these new non-MSS-aligned segments
> going out, and count those as non-full-size segments for the
> minshall-nagle check (to ensure we have no more than one outstanding
> un-ACKed sub-MSS packet). Maybe something like (please excuse the
> formatting):

This sort of begs the question about how Nagle should work.
IIRC Nagle just suppresses short segments when there is unacked data? [1]

If you have sent a TSO packet then nagle will always be 'waiting for an ack',
so should only send full segments. What is questionable is whether you should
send the final short segment, or buffer it waiting for further data from
the application to fill the segment (or an ack from the remote system).

If you split the data (as I think the code used to) then presumably
with nagle the final short segment won't actually be sent (until timeout
or an ack is received). So the transmitted segments are likely to all
be full.

OTOH with the change you'll send a partial segment.
If this only happens when the tx socket buffer (etc) is empty it is probably
an improvement!
Run vi in a large window and page forwards, the data displayed is larger
than a segment, so you have to wait for the nagle timeout before the entire
screen is updated.
Since the data is a single write() it would be a single TSO send - and
you want it all to get sent.

	David



[1] So that single characters typed into rlogin get sent together when
the remote system finally finishes processing the previous one(s).
While ftp can still send bulk data without waiting for responses.

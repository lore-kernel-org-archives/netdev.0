From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [RFC PATCH net-next] tcp: add CDG congestion control
Date: Thu, 4 Jun 2015 18:19:00 +0200
Message-ID: <CA++eYdsG5Jw15BNqLv6AE3LivhsDpHNjRxvx3T3qZF248z6fRQ@mail.gmail.com>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
	<CAK6E8=eV=0YDs5VY8EfhnVH1=gEZ+X4OzZJzDZihvSOUq6ErGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	netdev <netdev@vger.kernel.org>,
	David Hayes <davihay@ifi.uio.no>,
	Andreas Petlund <apetlund@simula.no>,
	Dave Taht <dave.taht@gmail.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33014 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbbFDQTB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:19:01 -0400
Received: by wgez8 with SMTP id z8so37627252wge.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:19:00 -0700 (PDT)
In-Reply-To: <CAK6E8=eV=0YDs5VY8EfhnVH1=gEZ+X4OzZJzDZihvSOUq6ErGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> why not just call tcp_init_cwnd_reduction()?

I deferred considering the ECN implications of doing so. The code to
start PRR was based on tcp_enter_cwr()/tcp_init_cwnd_reduction(), save
that both of these functions ensure a call to tcp_ecn_queue_cwr().

The upcoming patch set instead exports tcp_enter_cwr() and calls it,
which sets CWR on ECN-capable connections.

Consider CDG at the sender-side. The RFC 3168 Errata says that a
receiver should:
"First, reset ECE because of CWR
Second, set ECE because of CE"

Thus, in "good networks", setting CWR on a CDG backoff should not
affect ECN signalling =E2=80=93 we still get ECE from the receiver.

It is conceivable that fringe scenarios of ECN in the forward path and
losses in the ACK path creates a situation where CDG's backoff could
inhibit some ECN signals from the receiver. That is, setting CWR will
inhibit the signalling reliability of standard ECN in TCP. But we are
arguably still in good faith since we have reduced the congestion
window by some beta.

From: Calvin Owens <calvinowens@fb.com>
Subject: Re: [PATCH] tcp: Restore RFC5961-compliant behavior for SYN packets
Date: Thu, 20 Nov 2014 17:47:27 -0800
Message-ID: <20141121014727.GA1536781@mail.thefacebook.com>
References: <1416524993-26228-1-git-send-email-calvinowens@fb.com>
 <1416526940.8629.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Eric Dumazet <edumazet@google.com>, <kernel-team@fb.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416526940.8629.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 11/20 at 15:42 -0800, Eric Dumazet wrote:
> On Thu, 2014-11-20 at 15:09 -0800, Calvin Owens wrote:
> > Commit c3ae62af8e755 ("tcp: should drop incoming frames without ACK
> > flag set") was created to mitigate a security vulnerability in which a
> > local attacker is able to inject data into locally-opened sockets by
> > using TCP protocol statistics in procfs to quickly find the correct
> > sequence number.
> > 
> > This broke the RFC5961 requirement to send a challenge ACK in response
> > to spurious RST packets, which was subsequently fixed by commit
> > 7b514a886ba50 ("tcp: accept RST without ACK flag").
> > 
> > Unfortunately, the RFC5961 requirement that spurious SYN packets be
> > handled in a similar manner remains broken.
> > 
> > RFC5961 section 4 states that:
> > 
> >    ... the handling of the SYN in the synchronized state SHOULD be
> >    performed as follows:
> > 
> >    1) If the SYN bit is set, irrespective of the sequence number, TCP
> >       MUST send an ACK (also referred to as challenge ACK) to the remote
> >       peer:
> > 
> >       <SEQ=SND.NXT><ACK=RCV.NXT><CTL=ACK>
> > 
> >       After sending the acknowledgment, TCP MUST drop the unacceptable
> >       segment and stop processing further.
> > 
> >    By sending an ACK, the remote peer is challenged to confirm the loss
> >    of the previous connection and the request to start a new connection.
> >    A legitimate peer, after restart, would not have a TCB in the
> >    synchronized state.  Thus, when the ACK arrives, the peer should send
> >    a RST segment back with the sequence number derived from the ACK
> >    field that caused the RST.
> > 
> >    This RST will confirm that the remote peer has indeed closed the
> >    previous connection.  Upon receipt of a valid RST, the local TCP
> >    endpoint MUST terminate its connection.  The local TCP endpoint
> >    should then rely on SYN retransmission from the remote end to
> >    re-establish the connection.
> > 
> > This patch lets SYN packets through the discard added in c3ae62af8e755,
> > so that spurious SYN packets are properly dealt with as per the RFC.
> > 
> > The challenge ACK is sent unconditionally and is rate-limited, so the
> > original vulnerability is not reintroduced by this patch.
> 
> 
> I think this patch makes sense. But I wonder if the rate limiting wont
> hurt anyway, as I presume you need that after some server being
> rebooted, and if many connections are attempted in a small amount of
> time, some of them wont get any answer ?

That's actually not what led to finding this, but it's a good point. :)

What if the challenge-ACK counter were decremented in tcp_validate_incoming()
when a valid RST packet is seen? That would allow legitimate remote
hosts to reestablish connections without being ratelimited, and still
prevent a malicious host from guessing sequence numbers.

There would need to be a way to tell if a challenge ACK had in fact been
sent and only decrement in that case, since otherwise a local attacker
could establish and immediately reset lots of connections to keep the
counter below the ratelimit threshold and guess sequence numbers.

Simply adding a flag to struct tcp_sock would work: just set the flag
whenever a challenge ACK is sent, and clear it and decrement the counter
only if it is set when a valid RST packet is seen.

I suppose that should be a seperate patch?

Thanks,
Calvin 

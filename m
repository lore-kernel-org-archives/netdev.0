From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Restore RFC5961-compliant behavior for SYN packets
Date: Thu, 20 Nov 2014 15:42:20 -0800
Message-ID: <1416526940.8629.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416524993-26228-1-git-send-email-calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Eric Dumazet <edumazet@google.com>, kernel-team@fb.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416524993-26228-1-git-send-email-calvinowens@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-11-20 at 15:09 -0800, Calvin Owens wrote:
> Commit c3ae62af8e755 ("tcp: should drop incoming frames without ACK
> flag set") was created to mitigate a security vulnerability in which a
> local attacker is able to inject data into locally-opened sockets by
> using TCP protocol statistics in procfs to quickly find the correct
> sequence number.
> 
> This broke the RFC5961 requirement to send a challenge ACK in response
> to spurious RST packets, which was subsequently fixed by commit
> 7b514a886ba50 ("tcp: accept RST without ACK flag").
> 
> Unfortunately, the RFC5961 requirement that spurious SYN packets be
> handled in a similar manner remains broken.
> 
> RFC5961 section 4 states that:
> 
>    ... the handling of the SYN in the synchronized state SHOULD be
>    performed as follows:
> 
>    1) If the SYN bit is set, irrespective of the sequence number, TCP
>       MUST send an ACK (also referred to as challenge ACK) to the remote
>       peer:
> 
>       <SEQ=SND.NXT><ACK=RCV.NXT><CTL=ACK>
> 
>       After sending the acknowledgment, TCP MUST drop the unacceptable
>       segment and stop processing further.
> 
>    By sending an ACK, the remote peer is challenged to confirm the loss
>    of the previous connection and the request to start a new connection.
>    A legitimate peer, after restart, would not have a TCB in the
>    synchronized state.  Thus, when the ACK arrives, the peer should send
>    a RST segment back with the sequence number derived from the ACK
>    field that caused the RST.
> 
>    This RST will confirm that the remote peer has indeed closed the
>    previous connection.  Upon receipt of a valid RST, the local TCP
>    endpoint MUST terminate its connection.  The local TCP endpoint
>    should then rely on SYN retransmission from the remote end to
>    re-establish the connection.
> 
> This patch lets SYN packets through the discard added in c3ae62af8e755,
> so that spurious SYN packets are properly dealt with as per the RFC.
> 
> The challenge ACK is sent unconditionally and is rate-limited, so the
> original vulnerability is not reintroduced by this patch.


I think this patch makes sense. But I wonder if the rate limiting wont
hurt anyway, as I presume you need that after some server being
rebooted, and if many connections are attempted in a small amount of
time, some of them wont get any answer ?

Thanks !

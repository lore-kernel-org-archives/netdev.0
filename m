From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Question with secure_ipv4_port_ephemeral() implementation
Date: Sun, 22 Apr 2012 15:21:02 +0100
Message-ID: <1335104462.3209.377.camel@deadeye>
References: <201204202130.IJF95312.tQJFLMFOFSVHOO@I-love.SAKURA.ne.jp>
	 <1335065393.3209.361.camel@deadeye>
	 <201204221420.GJB51054.OtHOFSQJFOVMFL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10520 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751725Ab2DVOVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 10:21:07 -0400
In-Reply-To: <201204221420.GJB51054.OtHOFSQJFOVMFL@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-22 at 14:20 +0900, Tetsuo Handa wrote:
> Ben Hutchings wrote:
> > As I understand it, that 8-bit counter was used for all connections, so
> > in order to spoof the source of a TCP connection it was only necessary
> > to guess 24 bits of the ISN.  On a sufficiently fast network, it would
> > now be feasible to carry out a brute force attack that ACKs all possible
> > ISNs before the handshake times-out.  That's not yet feasible if the
> > attacker has to guess all 32 bits of the ISN.
> 
> So, the purpose was to make the initial sequence number more random. OK.
> 
> > The original reason for periodically regenerating the secret was that
> > the hash function was quite weak and the secret could presumably be
> > found in a reasonably short time.  So, without regeneration, the hash
> > also has to be stronger.
> 
> My concern is the purpose of making the automatic local port number selection
> algorithm less random. That commit removed uptime factor from factors that
> determine starting point of available local port scanning (due to removal of
> periodic get_random_bytes() calls).
> 
> 368 static inline u32 inet_sk_port_offset(const struct sock *sk)
> 369 {
> 370         const struct inet_sock *inet = inet_sk(sk);
> 371         return secure_ipv4_port_ephemeral(inet->inet_rcv_saddr,
> 372                                           inet->inet_daddr,
> 373                                           inet->inet_dport);
> 374 }
> 
> secure_ipv4_port_ephemeral() no longer depends on uptime.
> 
> 565 int inet_hash_connect(struct inet_timewait_death_row *death_row,
> 566                       struct sock *sk)
> 567 {
> 568         return __inet_hash_connect(death_row, sk, inet_sk_port_offset(sk),
> 569                         __inet_check_established, __inet_hash_nolisten);
> 570 }
> 
> inet_sk_port_offset() no longer depends on uptime.
> It returns same port offset for same addresses.
[...]

All this randomisation is concerned with preventing spoofing attacks by
attackers that can't see any packets routed to the spoofed address.  If
they can see the return packets then this is all in vain, which is why
we generally want cryptography at the transport or application level.
But if they can't then the port offset remains secret - right?

(Port randomisation is not very useful on it own due to the small number
space, but see
<http://en.wikipedia.org/wiki/DNS_cache_poisoning#Prevention_and_mitigation>.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

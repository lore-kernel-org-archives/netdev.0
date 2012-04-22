From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Question with secure_ipv4_port_ephemeral() implementation
Date: Sun, 22 Apr 2012 04:29:53 +0100
Message-ID: <1335065393.3209.361.camel@deadeye>
References: <201204202130.IJF95312.tQJFLMFOFSVHOO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14746 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751975Ab2DVDaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 23:30:00 -0400
In-Reply-To: <201204202130.IJF95312.tQJFLMFOFSVHOO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-20 at 21:30 +0900, Tetsuo Handa wrote:
> Commit 6e5714ea "net: Compute protocol sequence numbers and fragment IDs using
> MD5." removed periodic get_random_bytes() calls. After that commit,
> 
>   static u32 net_secret[MD5_MESSAGE_BYTES / 4] ____cacheline_aligned;
> 
> is filled with random bytes for only once upon boot and is never updated again.
> Then, shouldn't net_secret be marked as __read_mostly?
> 
> Just from curiosity... what was the reason for changing
> secure_ipv4_port_ephemeral() generate same return value for same arguments?
> Was periodically changing return value for same arguments unfriendly with NAT
> or something?

The commit message says:

> Furthermore, only having 24-bits of the sequence number be truly
> unpredictable is a very serious limitation.  So the periodic
> regeneration and 8-bit counter have been removed.  We compute and
> use a full 32-bit sequence number.

As I understand it, that 8-bit counter was used for all connections, so
in order to spoof the source of a TCP connection it was only necessary
to guess 24 bits of the ISN.  On a sufficiently fast network, it would
now be feasible to carry out a brute force attack that ACKs all possible
ISNs before the handshake times-out.  That's not yet feasible if the
attacker has to guess all 32 bits of the ISN.

The original reason for periodically regenerating the secret was that
the hash function was quite weak and the secret could presumably be
found in a reasonably short time.  So, without regeneration, the hash
also has to be stronger.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

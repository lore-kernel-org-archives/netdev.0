From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Improve sequence number generation.
Date: Sat, 06 Aug 2011 18:50:16 -0700 (PDT)
Message-ID: <20110806.185016.1873324984758346741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan@doxpara.com, w@1wt.eu, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, dccp@vger.kernel.org,
	mpm@selenic.com, herbert@gondor.hengli.com.au,
	gerrit@erg.abdn.ac.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756915Ab1HGBwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 21:52:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dan Kaminsky pointed out that using partial MD4 and using that to
generate a sequence number, of which only 24-bits are truly
unguessable, seriously undermine the goals of random sequence number
generation.

In particular, with only 24-bits being truly unguessable, packet
injection into a session using even something like brute force is a
real potential possibility.

We only use 24-bits because we regenerate the random number every 5
minutes "just in case."  But what does is trade a "we don't know" kind
of theoretical issue for a provably real one (brute force attack).

Therefore I'm moving us more in line with RFC1948 (as well as OpenBSD
and Solaris), to use MD5 and a full 32-bit result in the generated
sequence number.

MD5 was selected as a compromise between performance loss and
theoretical ability to be compromised.  Willy Tarreau did extensive
testing and SHA1 was found to harm performance too much to be
considered seriously at this time.

We may later add a sysctl for various modes (ie. a "super secure" mode
that uses SHA1 if people want that, and an "insecure" mode that doesn't
use cryptographic hashing at all for people in protected environments
where that might be safe to do).

I've also moved the sequence number generators out of random.c (they
never really belonged there, and are only there due to historical
artifacts), and fixed a bug in DCCP sequence number generation
(on ipv6 the 43-bit sequence number was truncated to 32-bits).

This work is already pushed out to the net GIT tree and I'll ask
Linus to pull it in a moment, we've been discussing how to handle
this issue for weeks on security@kernel.org already.

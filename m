From: Michael Tokarev <mjt@tls.msk.ru>
Subject: rare bad TCP checksum with 2.6.19?
Date: Mon, 15 Jan 2007 01:59:16 +0300
Message-ID: <45AAB5C4.8010002@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:20244 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713AbXANXIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jan 2007 18:08:25 -0500
Received: from paltus.tls.msk.ru (paltus.tls.msk.ru [192.168.1.1])
	by hobbit.corpit.ru (Postfix) with ESMTP id 0AE8935662
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 01:59:19 +0300 (MSK)
	(envelope-from mjt@tls.msk.ru)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticied, after running with 2.6.19 for more than a month, that
sometimes, a file transfer, when one of the ends is running 2.6.19,
stalls at the very end of the file, forever.

Playing with tcpdump, I noticied that the host sends out packets with
wrong checksums, like this:

01:28:07.608457 IP (tos 0x0, ttl  64, id 11740, offset 0, flags [DF], length: 82)
    81.13.94.6.80 > 216.168.29.244.57064: FP [bad tcp cksum b011 (->7ae2)!]
    140062:140092(30) ack 125 win 2896 <nop,nop,timestamp 87610 145676467>

(here, 81.13.94.6 is running linux 2.6.19).

It happens only on rare cases, and not reliable repeatable.

After further playing I noticied that - almost - only packets with FIN flag
set (like the above), *and* containing some data in them (again, like the
above), shows this behaviour.

With FIN set, the thing is 100% repeatable (the only problem is to force the
system to actually send such a packet -- for that, one has to push quite some
data to the socket and immediately close it, so that there will be some data
to send in kernel buffer still at the moment of close).

This explains the observed behaviour - rare, unreliable stalls at the end of
a transfer -- because it's relatively rare when FIN packet contains some data.

But sometimes, other packets go out with bad checksum, too:

01:20:01.712146 IP (tos 0x0, ttl  64, id 52870, offset 0, flags [DF], length: 1500)
    81.13.94.6.80 > 216.168.29.244.57655: . [bad tcp cksum ab7e (->dcbd)!]
    112945:114393(1448) ack 125 win 2896 <nop,nop,timestamp 39006 145190996>

(again, 81.13.94.6 is a machine running linux 2.6.19).  That's one in a row of
other pretty normal packets - it has been retransmitted a bit later, with correct
checksum.

When switching back to 2.6.17 (previous kernel which was running on this
machine), things goes back to normal, or at least so it seems.

Note there's no funny/interesting hardware involved, like network cards with
tcp checksumming offload capabilities (this is plain dumb 8139 card).

I'll try to collect further information tomorrow.  But if someone has some
clue before.... ;)

Thanks!

/mjt

From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 15 Jan 2007 16:34:41 +0300
Message-ID: <45AB82F1.9000409@tls.msk.ru>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:21198 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932332AbXAONeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 08:34:46 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Michael Tokarev <mjt@tls.msk.ru> wrote:
>> Note there's no funny/interesting hardware involved, like network cards with
>> tcp checksumming offload capabilities (this is plain dumb 8139 card).
> 
> The 8139 card might be dumb, but the driver isn't :) It emulates
> checksum offload in software, meaning that tcpdump will show bogus
> checksums.
> 
> So please disable hardware checksum offload with ethtool -K and
> then try again.

# ethtool -k eth0
Offload parameters for eth0:
Cannot get device rx csum settings: Operation not supported
Cannot get device tx csum settings: Operation not supported
Cannot get device scatter-gather settings: Operation not supported
Cannot get device tcp segmentation offload settings: Operation not supported
no offload info available

# ethtool -K eth0 rx off tx off tso off
Cannot set device rx csum settings: Operation not supported

So I guess the problem is not related to hw checksumming offloading.

Meanwhile, I tried many times to reproduce the problem - with little
success.  With different sizings, options, et al - I can't force the
sending side to send some data within a FIN packet.  I.e, most of the
time, the thing just works, because no data goes with FIN packet.
But once every 50..100 tries, I see single FIN-with-data packet, and
that one ALWAYS has bad checksum.

I was never able to reproduce the problem on a LAN, only when going from
a distant host.  And even with that distant host, it's very difficult to
reproduce.

At least one network (also distant) triggers this problem on every 2nd
try or so (the one I experimented with yesterday).  But I've no access
to that network - I kindly asked for help yesterday, but I can't abuse
their willingness to help more.

And another thing I noticed.  Right now I'm experimenting with another
machine, running 2.6.17(.13) - it also shows similar behavior with bad
csums, but MUCH rarer than this 2.6.19.  Like this:

16:29:32.490976 IP (tos 0x60, ttl  48, id 14110, offset 0, flags [DF], length: 80)
 69.42.67.34.2612 > 81.13.94.6.1234: . [bad tcp cksum f4b4 (->c1cc)!] ack 93407 win 9821
 <nop,nop,timestamp 1046528199 5497679,nop,nop,sack sack 3 {104991:109335}{110783:112231}{104991:109335} >
16:29:32.525988 IP (tos 0x60, ttl  48, id 14112, offset 0, flags [DF], length: 80)
 69.42.67.34.2612 > 81.13.94.6.1234: . [bad tcp cksum 3fb1 (->1819)!] ack 93407 win 9821
 <nop,nop,timestamp 1046528202 5497679,nop,nop,sack sack 3 {110783:113679}{122367:123815}{110783:113679} >
16:29:32.561407 IP (tos 0x60, ttl  48, id 14116, offset 0, flags [DF], length: 80)
 69.42.67.34.2612 > 81.13.94.6.1234: . [bad tcp cksum 87c0 (->2610)!] ack 93407 win 9821
 <nop,nop,timestamp 1046528205 5497679,nop,nop,sack sack 3 {122367:127103}{128551:129572}{122367:127103} >

Here, 69.42.67.34 is 2.6.17 from which I'm requesting data, and
81.13.94.6 is the sender.  This behavior so far is demonstrated with
sack packets only, but I've seen it in other direction too (also with
sack), at least once.

Any idea how to force sending FIN-with-data?

Thanks!

/mjt

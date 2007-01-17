From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Wed, 17 Jan 2007 17:12:47 +0300
Message-ID: <45AE2EDF.4060709@tls.msk.ru>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au> <45ABF620.3070405@tls.msk.ru> <20070116032739.GA12746@gondor.apana.org.au> <20070116033849.GA12856@gondor.apana.org.au> <45AC8813.9000204@tls.msk.ru> <20070116115053.GA16529@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:20839 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932270AbXAQOMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 09:12:54 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20070116115053.GA16529@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Jan 16, 2007 at 11:08:51AM +0300, Michael Tokarev wrote:
>> Ok.  Here's another trace, from that remote network that triggers
>> this thing more-or-less reliable (every 2nd transfer at least) --
>> http://www.corpit.ru/mjt/bh-bad-cksum-dmp.bin . It's a full session
>> between 216.168.29.244 - the requesting/receiving side -- and
>> 81.13.94.6 -- our sending side (the file being transferred is some
>> trojan horse I found on a friend's PC, so be careful ;)
> 
> I'll have a look at this tomorrow.
> 
> Since you're certain that this is being seen on the wire, one
> possibility is that we've got a bug somewhere that's zeroing
> skb->ip_summed on a packet with a partial checksum.

Here's another sample, which may be more useful.  I've seen quite
alot of very similar stuff while running tcpdump.

  http://www.corpit.ru/mjt/bad-cksum-session3-dmp.bin

The scenario looks like this.

A client (82.84.172.37 -- a zombie machine trying to send us spam
in this case) connects to a port 25 here (81.13.94.6:25).  SYN+ACK
sequence completes.  Next, our server send an initial SMTP greething
message, but almost right after that, the client sends a FIN packet,
WITHOUT acknowleging that it received the (first and only) data
packet.  So some time later our machine re-sends the data, AND adds
FIN flag to the packet (also replying to the FIN received from the
client).  And *that* packet - original data packet which is modified
to also include FIN - has incorrect checksum.

So it looks like the checksum isn't being updated WHEN ADDING MORE
FLAGS to the original data packet.

/mjt


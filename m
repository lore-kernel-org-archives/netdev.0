From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 00:46:08 +0300
Message-ID: <45ABF620.3070405@tls.msk.ru>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:20202 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbXAOVqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 16:46:13 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20070115201001.GA9510@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Jan 15, 2007 at 04:34:41PM +0300, Michael Tokarev wrote:
[]
>> So I guess the problem is not related to hw checksumming offloading.
> 
> Nope, it just means that 8139too doesn't provide ethtool handlers to
> disable checksum offloading.
> 
> So I suggest that you try doing the tcpdump on the receive side as
> that should show the real checksum.

I'm doing the capture on an intermediate host - the whole day today ;)

> BTW, the reason tcpdump only shows some packets with bogus checksums
> is because it cuts packets off at 100 bytes by default so for most
> packets it can't verify the checksum at all.  If you run it with
> -s 1600 you should see bogus checksums on every packet with payload.

And I'm capturing with -s 2000.  By the way, tcpdump just does not
verify the cheksum of truncated (due to capture size) packets.  At
least not the version I'm using (which is 3.9.5).

Herbert, the problem IS real, it's not due to some bad behavior due
to improper capturing or something like that.  Yes it's difficult to
come to it, but it is real.

I've saved quite alot of packets today, but it's all quite.. useless
as the thing is difficult to hit.  Here's some traces made with the
following filter:

 proto TCP and tcp[tcpflags] & (tcp-fin|tcp-push) == (tcp-fin|tcp-push)

(I've choosen FIN+PUSH because this combination is where the problem
is seen most - to be fair, it looks like I haven't seen it with other
flags).

In there, some packets are ok, but some are not.  So - again, it seems
like - I was wrong about 100% "hit ratio" -- ie, that the "bad checksum"
is ALWAYS the case with packets where some data goes in FIN packets --
this is incorrect, because the trace shows quite a few examples of right
behavior.

The trace is here: http://www.corpit.ru/mjt/bad-tcp-cksum-dmp.bin

(it contains some data which it sholdn't - but I hope there's nothing
confidential in there ;)

So, after the whole day digging around, I still don't have any more-or-less
clean way to reproduce it.  But I've noticied another thing as well: many
different machines here, with different kernels, behave the same way.
So it can't be a hardware problem for example.

And only at VERY rare cases, the thing causes noticeable transfer slowdowns
or stalls.  But some networks triggers those rare cases more often than others
(so the only more or less sane conclusion I can come with is that it's
somehow timing-related).

Thanks!

/mjt

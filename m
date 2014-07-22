From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 3/3] net: sctp: Add support for MSG_MORE on
 SCTP
Date: Tue, 22 Jul 2014 13:45:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727B2A0@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com>
 <53CE65B5.3090903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"Linux Networking Development Mailing List" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43567 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752171AbaGVNq6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 09:46:58 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04047-03 for <netdev@vger.kernel.org>;
 Tue, 22 Jul 2014 14:46:49 +0100 (BST)
In-Reply-To: <53CE65B5.3090903@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich 
> On 07/22/2014 04:59 AM, David Laight wrote:
> > If MSG_MORE is set then the data chunk will be buffered until either
> > a full packet would be generated, or something causes a chunk to be
> > sent (eg data without MSG_MORE or a heartbeat).
> 
> heartbeat will not cause a data flush.  Only SACKs do that as they control
> congestion and flow.

Experimentally heartbeats cause data to be sent.
I'd only got one IP address at each end - so don't know what happens to
any 'probe' HBs.
I frigged my code to set MSG_MORE if the data chunk was over 200 bytes.
A single long fragment would be collected by a short one, or by a heartbeat.
I did wonder if that was a bug - but it would happen for data delayed by Nagle.

> That's might actually be a good solution to the problem of the an incorrectly
> using MSG_MORE.  When a SACK drops inflight to 0, clear MSG_MORE from the
> association thus allowing any queued data (even less then MTU) to be flushed.
> 
> This way, when the data flow just starts, you can use MSG_MORE to control
> bundling.  However, the app stops sending, even if it forgot to clear MSG_MORE,
> we'll clear it ourselves once inflight drops to 0.

That will only work if there is enough data to actually send something.
So more likely to cause confusion than be useful.

All this is really defining the behaviour for 'broken' apps.
It wouldn't be completely unreasonable if a single message sent with 'MSG_MORE'
never actually got sent.

> > The MSG_MORE flag is saved 'per association' along with a copy
> > of the SCTP_NODELAY/Nagle flag.
> >
> > It is expected that an application will only set MSG_MORE when it
> > has an additional data chunk ready to send. The sends could be done
> > with a single sendmmsg() system call.
> 
> Is that really true?  If the application has 5 messages and it sends all
> 5 with the sendmmsg(), then MSG_MORE will never get cleared and a flush
> would not get triggered.

Hmmm.... I was thinking that each entry in msgvec[] had its own flags field.
But I guess that is only used for receive.

I looked at that code at the beginning to see if it made sense to just bundle
data sent with sendmmsg() - and decided it wasn't worth the effort because
semdmmsg() is mostly a system call saver, I'd still need to implement the
same code inside sctp.
This is made more difficult for 1-many sockets because the buffers for sendmmsg()
can all have different addresses.

One option for sendmmsg() is set a different flag on all but the last buffer
if there are no addresses present, and treat it the same as MSG_MORE for sctp.

I'm on holiday for the next 2 weeks. I'll probably manage to read netdev, but
won't be able to repost the patches from here - and certainly can't test
anything.

It would be nice to get the current patches (especially 1/3 and 2/3) in now.

	David

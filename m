From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v3 3/3] net: sctp: Add support for MSG_MORE on
 SCTP
Date: Tue, 22 Jul 2014 10:54:34 -0400
Message-ID: <53CE7B2A.90104@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com> <53CE65B5.3090903@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1727B2A0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:41023 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154AbaGVOyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 10:54:38 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727B2A0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 09:45 AM, David Laight wrote:
> From: Vlad Yasevich 
>> On 07/22/2014 04:59 AM, David Laight wrote:
>>> If MSG_MORE is set then the data chunk will be buffered until either
>>> a full packet would be generated, or something causes a chunk to be
>>> sent (eg data without MSG_MORE or a heartbeat).
>>
>> heartbeat will not cause a data flush.  Only SACKs do that as they control
>> congestion and flow.
> 
> Experimentally heartbeats cause data to be sent.
> I'd only got one IP address at each end - so don't know what happens to
> any 'probe' HBs.
> I frigged my code to set MSG_MORE if the data chunk was over 200 bytes.
> A single long fragment would be collected by a short one, or by a heartbeat.
> I did wonder if that was a bug - but it would happen for data delayed by Nagle.

That sounds kind like a bug.  The end of packet usually causes a flush of the outqueue,
but any delayed data shouldn't be sent as HB should not cause a data flush.

The delay is either due to Nagle or closed windows (congestion or receive) and HB
doesn't effect either.

> 
>> That's might actually be a good solution to the problem of the an incorrectly
>> using MSG_MORE.  When a SACK drops inflight to 0, clear MSG_MORE from the
>> association thus allowing any queued data (even less then MTU) to be flushed.
>>
>> This way, when the data flow just starts, you can use MSG_MORE to control
>> bundling.  However, the app stops sending, even if it forgot to clear MSG_MORE,
>> we'll clear it ourselves once inflight drops to 0.
> 
> That will only work if there is enough data to actually send something.
> So more likely to cause confusion than be useful.
> 
> All this is really defining the behaviour for 'broken' apps.
> It wouldn't be completely unreasonable if a single message sent with 'MSG_MORE'
> never actually got sent.

Actually, this code opens up a way to eat kernel memory.  Consider an application
that does:
   while (1) {
       socket(IPPROTO_SCTP);
       connect()
       sendmsg(MSG_MORE); <- write 1 byte
       close();
   }

Because we send with MSG_MORE, the 1 byte gets queued to the association.  The close()
causes us to enter SHUTDOWN_PENDING state and we never flush the buffer and close
the association.

This is a malicious example.  Similarly, a broken application could just forget to
clear MSG_MORE and when we end up in a condition where the amount of queued data is
smaller then MTU and all inflight data has been acked, we'd once again be stuck.

Just because application isn't doing the right thing, we can't assume it's broken.  It
could be malicious.  We need to make this behavior robust.

>>> The MSG_MORE flag is saved 'per association' along with a copy
>>> of the SCTP_NODELAY/Nagle flag.
>>>
>>> It is expected that an application will only set MSG_MORE when it
>>> has an additional data chunk ready to send. The sends could be done
>>> with a single sendmmsg() system call.
>>
>> Is that really true?  If the application has 5 messages and it sends all
>> 5 with the sendmmsg(), then MSG_MORE will never get cleared and a flush
>> would not get triggered.
> 
> Hmmm.... I was thinking that each entry in msgvec[] had its own flags field.
> But I guess that is only used for receive.
> 
> I looked at that code at the beginning to see if it made sense to just bundle
> data sent with sendmmsg() - and decided it wasn't worth the effort because
> semdmmsg() is mostly a system call saver, I'd still need to implement the
> same code inside sctp.
> This is made more difficult for 1-many sockets because the buffers for sendmmsg()
> can all have different addresses.
> 
> One option for sendmmsg() is set a different flag on all but the last buffer
> if there are no addresses present, and treat it the same as MSG_MORE for sctp.
> 
> I'm on holiday for the next 2 weeks. I'll probably manage to read netdev, but
> won't be able to repost the patches from here - and certainly can't test
> anything.
> 
> It would be nice to get the current patches (especially 1/3 and 2/3) in now.

I've acked patched 1 and 2.  This one needs a little bit more work.

-vlad

> 
> 	David
> 
> 
> 
> 

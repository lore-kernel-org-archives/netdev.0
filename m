From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Subject: Re: [PATCH] net: sctp: Fix a_rwnd/rwnd management to reflect real
 state of the receiver's buffer
Date: Wed, 22 Jan 2014 20:48:47 +0100
Message-ID: <52E0209F.4020200@nsn.com>
References: <52D8D544.5050501@nsn.com> <063D6719AE5E284EB5DD2968C1650D6D463A0F@AcuExch.aculab.com> <52DFDB1E.7070701@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D463CC4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "'Vlad Yasevich'" <vyasevich@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:14276 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbaAVTt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 14:49:29 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D463CC4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On 01/22/2014 04:30 PM, ext David Laight wrote:
> From: Vlad Yasevich 
> ...
>>> IIRC the 'size' taken of the socket buffer is the skb's 'true size'
>>> and that includes any padding before and after the actual rx data.
>>> For short packets the driver may have copied the data into a smaller
>>> skb, for long packets it is likely to be more than that of a full
>>> length ethernet packet.
>>> In either case it can be significantly more than sizeof(sk_buff)
>>> (190?) plus the size of the actual data.
>>
>> SCTP currently doesn't support GRO, so each packet is limited to
>> ethernet packet plus sk_buff overhead.
> 
> The ethernet driver might still pass up a 2k buffer, or even a 4k one.
> Especially if it supports GRO for TCP.
> 
>> What throws a real monkey
>> wrench into this whole accounting business is SCTP bundling.  If you
>> bundle multiple messages into the single packet, accounting for it
>> is a mess.
> 
> How about dividing the 'truesize' by the reference count?
> (except that isn't quite right...)
> I assume there are multiple skb headers but only one data buffer?
> At least the chunks are all for the same connection so end up on
> one socket (except I remember some other horrid stuff for datagrams).
>  
>>> I'm also not sure that continuously removing 'credit' is a good idea.
>>> I've done a lot of comms protocol code, removing credit and 'window
>>> slamming' acks are not good ideas.
>>
>> This patch doesn't continuously remove 'credit'.  It advertises the
>> closest approximation of the window that we support and computes it
>> the same way as we do for Initial Window (available sk_rcvbuff >> 1).
>> As the receiver drains the receive queue, available buffer will increase
>> and the available window will grow.
> 
> Let's assume the socket buffer size is 100k.
> We advertise a window of 50k.
> We now receive 100 bytes of data, the remote has 49900 window left.
> The 'truesize' is something like 190+64(ish)+100+tail_pad, say 400.
> Socket buffer space is reduced to 99600 and any ack would give 49800.
> So we have reduced the window by 100 bytes.
> With that much space it probably doesn't matter much.
> 
> However if the connection is receive limited then the remote system
> will have a second packet in flight that uses the rest of the window.
> We then receive an in-sequence but out-of-window packet that refers
> to window that we had previously given to the remote system.

AFAIK, if the packet is not discarded due to depleted buffer, it will normally be processed.
In case its discarded, sender will have to resend it since it wont be acked.

> I don't know what the sctp (or tcp) code does with such packets.
> In my experience it is best to treat them as valid data (unless
> there are larger free memory issues) and ack them at some point.
> Hopefully the rules of the underlying protocol let you do this!
> 
> If you discard these packets then every packet gets sent twice
> (or even more often if the data is very short).

For small packets we will not get into trouble since sctp has same as tcp sws avoidance algorithm

Regards,

Matija

> 	David
> 

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 4/6] dlm: use sctp 1-to-1 API
Date: Wed, 12 Aug 2015 13:42:54 -0300
Message-ID: <55CB778E.4050002@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
 <479a4fd07289ea9043d84a27d706cccd2c968fb0.1439330654.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB794EB@AcuExch.aculab.com>
 <55CB4729.2060203@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB7979F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>,
	"tan.hu@zte.com.cn" <tan.hu@zte.com.cn>
To: David Laight <David.Laight@ACULAB.COM>,
	"cluster-devel@redhat.com" <cluster-devel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36583 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbbHLQnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:43:03 -0400
Received: by qgdd90 with SMTP id d90so14188921qgd.3
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:43:03 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB7979F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 12-08-2015 12:33, David Laight escreveu:
> From: Marcelo Ricardo Leitner
>> Sent: 12 August 2015 14:16
>> Em 12-08-2015 07:23, David Laight escreveu:
>>> From: Marcelo Ricardo Leitner
>>>> Sent: 11 August 2015 23:22
>>>> DLM is using 1-to-many API but in a 1-to-1 fashion. That is, it's not
>>>> needed but this causes it to use sctp_do_peeloff() to mimic an
>>>> kernel_accept() and this causes a symbol dependency on sctp module.
>>>>
>>>> By switching it to 1-to-1 API we can avoid this dependency and also
>>>> reduce quite a lot of SCTP-specific code in lowcomms.c.
>>> ...
>>>
>>> You still need to enable sctp notifications (I think the patch deleted
>>> that code).
>>> Otherwise you don't get any kind of indication if the remote system
>>> 'resets' (ie sends an new INIT chunk) on an existing connection.
>>
>> Right, it would miss the restart event and could generate a corrupted
>> tx/rx buffers by glueing parts of old messages with new ones.
>
> Except that it is SCTP so you'd expect DATA chunks to contain entire
> messages and so get unexpected message sequences rather than corrupt
> messages.

I was thinking on cases where the buf for recvmsg is not enough to hold 
the chunk, so that the remaining is left for another attempt 
(sctp_recvmsg, around line 2130), but sounds like we won't purge rx 
buffer when the reset happens so that doesn't matter. The association is 
replaced, but the buffers are kept.

Out of order messages aren't a problem for dlm. It can recover from that 
just fine, as it doesn't have a specific handshake at beginning or 
something like that and upper layers are agnostic to that state 
transition (disconnect/reconnect/...), this should be fine.

> The problem is that the recovery is likely to be another reset.
> (Particularly with M3UA where the source and destination port numbers
> are likely to be the same and fixed.)
>
>>> It is probably enough to treat the MSG_NOTIFICATION as a fatal error
>>> and close the socket.
>>
>> Just so we are on the same page, you mean that after accepting the new
>> association and enabling notifications on it, any further notification
>> on it can be treated as fatal errors, right? Seems reasonable to me.
>
> That's what I had to do.
> The far end will probably see an additional disconnect, but it shouldn't
> matter.

Okay

>>> This is probably a bug in the sctp stack - if a connection is reset
>>> but the user hasn't requested notifications then it should be
>>> converted to a disconnect indication and a new incoming connection.
>>
>> Maybe in such case resets shouldn't be allowed at all? Because unless it
>> happens on a moment of silence it will always lead to application buffer
>> corruption. Checked the RFCs now but couldn't find anything restricting
>> them to some condition.

As said above, such corruption doesn't exist, and while checking this, 
the reset is actually reported by a double report of established state 
via sk_state_change(). The reset will trigger a call to 
sctp_sf_do_dupcook_a() which will later schedule a state transition to 
established for !udp sockets. For users in kernel at least, one could 
use that as the reconnect signal.

> I certainly expected the 'reset' to cause an inwards abortive disconnect
> on the old socket and a new indication on the listening socket.

I was thinking that too but now seeing that it seems to work out of the 
box with dlm, I liked the feature. ;)

> I think (hope) that is what you get for a TCP SYN that matches an existing
> connection.
>
> In our case I think they were happening when the remote system was power
> cycled.

And it has to be a fast one, so that heartbeats won't catch it in time.

Thanks,
Marcelo

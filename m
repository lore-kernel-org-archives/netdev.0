From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v3 3/3] net: sctp: Add support for MSG_MORE on
 SCTP
Date: Tue, 22 Jul 2014 12:38:17 -0400
Message-ID: <53CE9379.4030500@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com> <53CE65B5.3090903@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1727B2A0@AcuExch.aculab.com> <53CE7B2A.90104@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1727B3E7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:35657 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbaGVQiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 12:38:20 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727B3E7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 11:22 AM, David Laight wrote:
> ...
>>> All this is really defining the behaviour for 'broken' apps.
>>> It wouldn't be completely unreasonable if a single message sent with 'MSG_MORE'
>>> never actually got sent.
>>
>> Actually, this code opens up a way to eat kernel memory.  Consider an application
>> that does:
>>    while (1) {
>>        socket(IPPROTO_SCTP);
>>        connect()
>>        sendmsg(MSG_MORE); <- write 1 byte
>>        close();
>>    }
>>
>> Because we send with MSG_MORE, the 1 byte gets queued to the association.  The close()
>> causes us to enter SHUTDOWN_PENDING state and we never flush the buffer and close
>> the association.
>>
>> This is a malicious example.  Similarly, a broken application could just forget to
>> clear MSG_MORE and when we end up in a condition where the amount of queued data is
>> smaller then MTU and all inflight data has been acked, we'd once again be stuck.
> 
> From a system point of view that one doesn't really matter.
> 
>> Just because application isn't doing the right thing, we can't assume it's broken.  It
>> could be malicious.  We need to make this behavior robust.
> 
> Hmmm....
> The amount of data per-socket is limited by the mtu and socket buffer size,
> so a malicious app would have to create a lot of sockets to use a significant
> amount of kernel memory.

it's not just the data, all the corresponding data structures which are particularly
fat in sctp.

> 
> If close() blocks forever, isn't there a worse problem with a remote app
> that causes the window to be zero - and so data can't be sent and the
> close will block forever anyway?

No, this doesn't happen since there are triggered as retransmissions and
once we enter SHUTDOWN-PENDING, we can start the shutdown-guard timer
once we've hit the max retransmit count.  This solves this issue.

> I've never liked protocols that wait forever for send data to drain on disconnect.
> Seems like an 'accident' waiting to happen.
> 
> I'm not sure what would be needed to be done to cause queued send data to be
> sent when SCTP_F_TX_MSG_MORE is cleared by close() or set/clear SCTP_NODELAY.
> It is probably a simple call to the correct function.

OK. I'll try to come up with some code for this.

-vlad

> 
> 	David
> 
> 
> 
> 

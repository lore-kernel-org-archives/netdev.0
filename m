From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Three way TCP handshake : can we avoid the third packet ?
Date: Tue, 12 Oct 2004 10:15:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416B92BC.1010504@cosmosbay.com>
References: <41504117.9010108@cosmosbay.com> <Pine.LNX.4.61.0409211838390.31157@filer.marasystems.com> <415136D1.7030600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Henrik Nordstrom <hno@marasystems.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <415136D1.7030600@cosmosbay.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Following this discussion on netdev, sorry to bother you again :)

Currently, linux cannot easily avoids the third packet (ACK only) of TCP 
handshake, for connections initiated from linux side.

The send(socket, data) is denied (EAGAIN) if the socket is in NODELAY 
mode and socket not yet connected  (connect() done , but not in 
ESTABLISHED state).

So basically, a daemon willing to avoid the third packet must use one 
thread for each outgoing pending connection, seting the socket in 
blocking mode and blocking in send()/write() syscall. In my case, I 
would need about 1000 threads :(

Could we just delay (say up to 200ms) the ACK packet the tcp stack sends ?

If the application uses send() or write() a short time after the 
established state is notified, then the ACK could be suppressed.

This way, every application could benefit from this.


Thank you
Eric Dumazet

Eric Dumazet wrote:
> Henrik Nordstrom wrote:
> 
>> On Tue, 21 Sep 2004, Eric Dumazet wrote:
>>
>>> I discovered today that some TCP stacks were able to initiate TCP
>>> sockets with 2 packets "only".
>>>
>>> The third packet (ACK packet) is just delayed and integrated into the
>>> data packet.
>>
>>
>>
>> The TCP standard even allows you to have data in the SYN packet if you 
>> like. There however needs to be an exchange of three packets before 
>> the connection is considered established. The SYN flag is just like 
>> "octet 0" in the data stream of from sending direction. SYN + data is 
>> just that. As having data in the SYN or SYN+ACK packets is very 
>> uncommon not all TCP stacks are prepared to handle this and is 
>> therefore not recommended.
>>
>> All should handle a data payload in the ACK packet I think however, 
>> but there may obviously be some odd ones which does not.
>>
>>> Is it possible to achieve the same thing with linux 2.4/2.6, for 
>>> connections initiated by us ?
>>
>>
>>
>> Looking at the kernel source... seems to be the case if you simply 
>> initiate a non-blocking connect and then queue some data to be sent on 
>> the connection while the connect is taking place. Testing.. yes this 
>> does work.
>>
>>    set non-blocking
>>    connect
>>    set blocking
> 
> 
> Thank you for the hint. But the "set blocking" makes me nervous, since I 
> need to be sure not to block at write()/send() time...
> 
>>    write
>>
>> Regards
>> Henrik
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

From: Jason Baron <jbaron@akamai.com>
Subject: Re: strange Mac OSX RST behavior
Date: Fri, 1 Jul 2016 13:19:03 -0400
Message-ID: <5776A607.70800@akamai.com>
References: <1467385815-6357-1-git-send-email-jbaron@akamai.com>
 <5776A3A4.8000503@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>
To: Rick Jones <rick.jones2@hpe.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5776A3A4.8000503@hpe.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/01/2016 01:08 PM, Rick Jones wrote:
> On 07/01/2016 08:10 AM, Jason Baron wrote:
>> I'm wondering if anybody else has run into this...
>>
>> On Mac OSX 10.11.5 (latest version), we have found that when tcp
>> connections are abruptly terminated (via ^C), a FIN is sent followed
>> by an RST packet.
> 
> That just seems, well, silly.  If the client application wants to use
> abortive close (sigh..) it should do so, there shouldn't be this
> little-bit-pregnant, correct close initiation (FIN) followed by a RST.
> 
>> The RST is sent with the same sequence number as the
>> FIN, and thus dropped since the stack only accepts RST packets matching
>> rcv_nxt (RFC 5961). This could also be resolved if Mac OSX replied with
>> an RST on the closed socket, but it appears that it does not.
>>
>> The workaround here is then to reset the connection, if the RST is
>> is equal to rcv_nxt - 1, if we have already received a FIN.
>>
>> The RST attack surface is limited b/c we only accept the RST after we've
>> accepted a FIN and have not previously sent a FIN and received back the
>> corresponding ACK. In other words RST is only accepted in the tcp
>> states: TCP_CLOSE_WAIT, TCP_LAST_ACK, and TCP_CLOSING.
>>
>> I'm interested if anybody else has run into this issue. Its problematic
>> since it takes up server resources for sockets sitting in TCP_CLOSE_WAIT.
> 
> Isn't the server application expected to act on the read return of zero
> (which is supposed to be) triggered by the receipt of the FIN segment?
>

yes, we do in fact see a POLLRDHUP from the FIN in this case and
read of zero, but we still have more data to write to the socket, and
b/c the RST is dropped here, the socket stays in TIME_WAIT until
things eventually time out...

Thanks,

-Jason

> rick jones
> 
>> We are also in the process of contacting Apple to see what can be done
>> here...workaround patch is below.

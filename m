From: Alex Pankratov <apankrat@telus.net>
Subject: Re: RST business
Date: Thu, 22 Apr 2004 08:17:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4087E219.7000308@telus.net>
References: <40875F2F.7010204@swapped.cc> <4087D29E.6010907@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Pankratov <ap@swapped.cc>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com, Michael Rozhavsky <mike@minantech.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
In-Reply-To: <4087D29E.6010907@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yeah, sure, I understand that. But how realistis is this synchronization 
loss ? Ie I cannot immediately think of a sequence of events, which 
would result in two sides both in Established state with de-synchronized 
recp/send windows.

Steve Modica wrote:

> If one of the potential causes for RST is that SEQ/ACK synchronization 
> has been lost, then you can't do this.
> 
> Alex Pankratov wrote:
> 
>>
>> Looking at the hype around 'TCP vulnerability' the following
>> occured to me, and I wonder if it makes any sense -
>>
>> A host may recieve legitimate RST packet only in response to
>> something that it has previously sent (let's call it a 'trigger').
>>
>> SEQ/ACK values in RST packet are correlated to SEQ/ACK of the
>> trigger. If the correlation is not there, then RST packet is
>> most certainly spoofed and should be dropped even if its SEQ
>> falls into host's rcpt window.
>>
>> In other words, it seems to be possible to stregthen ingress
>> RST checking (and thus better protect against blind RST attacks)
>> while maintaining _full RFC compliance_. Here's a how-to sketch.
>>
>>     RFC 793 (page 35) states that for the connection in
>>     non-established state -
>>
>>     If the incoming segment has an ACK field, the reset takes its
>>     sequence number from the ACK field of the segment, otherwise
>>     the reset has sequence number zero and the ACK field is set to
>>     the sum of the sequence number and segment length of the incoming
>>     segment.
>>
>> Hence the second RST check (after standard window check) is
>>
>>     if (! pkt->seq)
>>         check if we've recently sent a segment without
>>         an ACK with (pkt->ack - pkt->seq) bytes in it
>>     else
>>         check if we've recently sent a segment with ACK
>>         of (pkt->seq) and with (pkt->ack - pkt->seq)
>>         bytes in it
>>
>> If RST passes the check, it's accepted. Otherwise checks continue.
>>
>>     RFC 793 (page 36) states that for the connection in
>>     established state -
>>
>>     .. elicit only an empty
>>     acknowledgment segment containing the current send-sequence number
>>     and an acknowledgment indicating the next sequence number expected
>>     to be received ..
>>
>> At this point seeing a RST means that
>> (a) remote host is an ESTABLISHED state
>> (b) we sent a segment that it considers not to be a part of the
>>     current connection
>>
>> And (b) is something that we can always check since we're now sure
>> about (a).
>>
>> The above obviously requires keeping some sort of 'outbound history',
>> plus (b) involves some non-trivial logic, which however seems to be
>> doable from the first glance.
>>
>> Comments ?
>>
>> Alex
> 
> 
> 

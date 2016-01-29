From: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>
Subject: Re: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Fri, 29 Jan 2016 11:57:46 +0100
Message-ID: <4AD903B1-5EEA-476C-A353-C17EEAA65D51@lurchi.franken.de>
References: <cover.1453913331.git.marcelo.leitner@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1CCCEDE4@AcuExch.aculab.com> <9D5B8E18-A20A-4E27-8EB8-EE8856DFB184@lurchi.franken.de> <20160128210326.GD6602@mrl.redhat.com> <7DA10E71-2CE2-41E6-B53B-4C4D5BF341DA@lurchi.franken.de> <20160129011828.GE6602@mrl.redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"marek@cloudflare.com" <marek@cloudflare.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"pabeni@redhat.com" <pabeni@redhat.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:41145 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbcA2K5w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 05:57:52 -0500
In-Reply-To: <20160129011828.GE6602@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 29 Jan 2016, at 02:18, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com> wrote:
> 
> On Fri, Jan 29, 2016 at 12:36:05AM +0100, Michael Tuexen wrote:
>> 
>>> On 28 Jan 2016, at 22:03, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com> wrote:
>>> 
>>> On Thu, Jan 28, 2016 at 06:54:06PM +0100, Michael Tuexen wrote:
>>>>> On 28 Jan 2016, at 14:51, David Laight <David.Laight@ACULAB.COM> wrote:
>>>>> 
>>>>> From: Marcelo Ricardo Leitner
>>>>>> Sent: 27 January 2016 17:07
>>>>>> This patchset is merely a RFC for the moment. There are some
>>>>>> controversial points that I'd like to discuss before actually proposing
>>>>>> the patches.
>>>>> 
>>>>> You also need to look at how a 'user' can actually get SCTP to
>>>>> merge data chunks in the first place.
>>>>> 
>>>>> With Nagle disabled (and it probably has to be since the data flow
>>>>> is unlikely to be 'command-response' or 'unidirectional bulk')
>>>>> it is currently almost impossible to get more than one chunk
>>>>> into an ethernet frame.
>>>>> 
>>>>> Support for MSG_MORE would help.
>>>> What about adding support for the explicit EOR mode as specified in
>>>> https://tools.ietf.org/html/rfc6458#section-8.1.26
>>> 
>>> Seizing the moment to clarify my understanding on that. :)
>>> Such multiple calls to send system calls will result in a single data
>>> chunk. Is that so? That's what I get from that text and also from this
>> No. It results in a single user message. This means you can send
>> a user message larger than the send buffer size. How the user message
>> is fragmented in DATA chunks is transparent to the upper layer.
>> 
>> Does this make things clearer?
> 
> I think so, yes. So it allows delaying setting the Ending fragment bit
> until the application set SCTP_EOR. All the rest before this stays as
> before: first send() will generate a chunk with Beginning bit set and
> may generate some other middle-fragments (no B nor E bit set) if
> necessary, second to N-1 call to send will generate only middle
> fragments, while the last send, with SCTP_EOF, will then set the Ending
> fragment in the last one. Right?
Yes. But there are no restrictions on the user data provided in send()
calls and DATA chunks. So you can
send(100000 byte, no SCTP_EOR)
resulting in one DATA chunk with the B bit, several with no B and no E bit.
send(100000 byte, no SCTP_EOR)
resulting in several chunks with no B and no E bit.
send(100000 byte, SCTP_EOR)
resulting in several chunks with no B and no E bit and one (the last) chunk
with the E bit.

On the other hand you can do
send(1 byte, no SCTP_EOR)
resulting in a single DATA chunk with the E bit set.
send(1 byte, no SCTP_EOR)
send(1 byte, no SCTP_EOR)
send(1 byte, no SCTP_EOR)
send(1 byte, no SCTP_EOR)
send(1 byte, no SCTP_EOR)
All resulting in a single DATA chunk with 5 bytes user data and no B or E bit.
(For example if Nagle is enabled and only after the last send call the SACK arrives).
send(1 byte, SCTP_EOR)
results in a single DATA chunk with the E bist set.

Best regards
Michael
> 
> Thanks,
> Marcelo
> 
>> 
>> Best regards
>> Michael
>>> snippet:
>>> "Sending a message using sendmsg() is atomic unless explicit end of
>>> record (EOR) marking is enabled on the socket specified by sd (see
>>> Section 8.1.26)."
>>> 
>>> Best regards,
>>> Marcelo
>>> 
>>>> Best regards
>>>> Michael
>>>>> 
>>>>> Given the current implementation you can get almost the required
>>>>> behaviour by turning nagle off and on repeatedly.
>>>>> 
>>>>> I did wonder whether the queued data could actually be picked up
>>>>> be a Heartbeat chunk that is probing a different remote address
>>>>> (which would be bad news).
>>>>> 
>>>>> 	David
>>>>> 
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>> 
>>>> 
>>> 
>> 
> 

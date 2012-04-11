From: Arvid Brodin <Arvid.Brodin@xdin.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Wed, 11 Apr 2012 00:00:13 +0000
Message-ID: <4F84CA36.7020209@xdin.com>
References: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
 <4F7CD4BC.4000006@enea.com>
 <20120404165559.5223ab95@s6510.linuxnetplumber.net>
 <20120404.202109.2046106039992811660.davem@davemloft.net>
 <4F7F10FC.3020308@enea.com> <1333731991.3282.17.camel@deadeye>
 <20120406111912.172bb1fb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:49594 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759841Ab2DKAOZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:14:25 -0400
In-Reply-To: <20120406111912.172bb1fb@nehalam.linuxnetplumber.net>
Content-Language: en-US
Content-ID: <0ECA069770C4AF4382233EF46BAF10CB@redbull.xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-04-06 20:19, Stephen Hemminger wrote:
> On Fri, 6 Apr 2012 18:06:31 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
>> On Fri, 2012-04-06 at 17:51 +0200, Arvid Brodin wrote:
>>> David Miller wrote:
>>>> From: Stephen Hemminger <shemminger@vyatta.com>
>>>> Date: Wed, 4 Apr 2012 16:55:59 -0700
>>>>
>>>>> That isn't so bad, doing a memcpy versus a structure copy.
>>>>
>>>> GCC is going to inline the memcpy and thus we'll still do the
>>>> unaligned accesses.  This change therefore won't fix the problem.
>>>
>>> Well, it does work for me, with gcc-4.2.2-compiled linux-2.6.37 running
>>> on an AVR32 board.
>>>
>>> Just out of curiosity, what's the mechanism behind this inline
>>> assignment that turns the memcpy into an unaligned access? If gcc is 
>>> "smart" enough to detect a bunch of char * accesses and turn them 
>>> into unaligned 32-bit accesses, isn't that a bug in gcc?
>>
>> If I remember correctly, casting a char* pointer to foo* where the
>> original pointer isn't properly aligned for type foo results in
>> undefined behaviour.  And that is what icmp_hdr() is doing, so there is
>> no requirement that the compiler does anything reasonable with the
>> result.  Removing that cast (using skb_transport_header() instead of
>> icmp_hdr()) should avoid that.
>>
>> (We do generally assume, however, that if the processor can handle
>> unaligned accesses in a useful way then the compiler will be reasonable
>> and not break them.)
>>
>> Ben.
>>  
>>> Or will this only happen on archs which __HAVE_ARCH_MEMCPY? (But looking
>>> at a couple of arch/xxx/lib/string.c, these too seem to take alignment
>>> into account.)
>>>
>>
> 
> Since icmp_hdr is 64 bits you might be able to use get_unaligned64
> in some way.
> 

I'm sorry, I have no idea how to do this. Besides, get_unaligned64 seems to be implemented
for the "c6x" arch only?

So far we have:

1) icmp_hdr() casts an unaligned char * to a wider type, which is bad (undefined).
2) We cannot use skb_transport_header():

On 2012-04-06 00:31, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 5 Apr 2012 20:21:08 +0100
>>
>> So presumably icmp_hdr() should be changed to skb_transport_header().
>
> I would not say so.  Otherwise we introduce ugly casts everywhere.
>

3) My feeble suggestion to cast icmp_hdr() to (char *) is of course even worse (it doesn't
even avoid the erroneous cast in the first place).

So what do we do?

-- 
Arvid Brodin
Enea Services Stockholm AB - since February 16 a part of Xdin in the Alten Group. Soon we
will be working under the common brand name Xdin. Read more at www.xdin.com.
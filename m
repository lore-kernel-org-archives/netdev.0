From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 11:25:05 +0100
Message-ID: <4BAB3A01.1090909@trash.net>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net> <4BA90F72.6010404@linux-ipv6.org> <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu> <4BAAE496.8000701@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BAAE496.8000701@linux-ipv6.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:
> (2010/03/24 5:10), Jozsef Kadlecsik wrote:
> 
>> On Wed, 24 Mar 2010, YOSHIFUJI Hideaki wrote:
>>
>>>> In this case without conntrack, IPv6 would send an ICMPv6 message,
>>>> so in my opinion the transparent thing to do would be to still send
>>>> them. Of course only if reassembly is done on an end host.
>>>
>>> Well, no.  conntrack should just forward even uncompleted fragments
>>> to next process (e.g. core ipv6 code), and then the core would send
>>> ICMP error back.  ICMP should be sent by the core ipv6 code according
>>> to decision of itself, not according to netfilter.
>>
>> But what state could be associated by conntrack to the uncompleted
>> fragments but the INVALID state? In consequence, in any sane setup, the
>> uncompleted fragments will be dropped silently by a filter table rule
>> and no ICMP error message will be sent back.
>>
>> Therefore I think iff the destination of the fragments is the host
>> itself, then conntrack should generate an ICMP error message. But that
>> error message must be processed by conntrack to set its state and then
>> the fate of the generated packet can be decided by a rule.
> 
> Well.... no.
> 
> First of all. in "sane" setup, people should configure according
> to their own requirements.  They may or may not want send back
> icmp packet.  And, even if the core is to send icmp back, the
> state would be correctly assigned.
> 
> We cannot (and should not) do something "cleaver" (excluding
> packet drops) in conntrack in PRE_ROUTING chain.
> 
> One reason is that in PRE_ROUTING context, we can NOT determine
> if the address we see in the IP header is really the final
> destination.  The overall situation is the same even if the
> routing entry corresponding the "current" destination points
> the node itself, or even if the node is configured as host.

Agreed, that is a problem.

> It might seems that we could do something in the "filter"
> table in LOCAL_IN, FORWARD or LOCAL_OUT (after routing header
> process).
> 
> But well, we unfortunately cannot do this (at least
> automatically) because even in LOCAL_IN, the final
> destination has not been decided until we process all
> of extension headers.
> 
> Sending ICMP in netfilter (especially in conntrack) is too
> patchy, and is not right.  If we do the right thing (and
> I believe we should do so),  I'd propose to have hooks
> around handlers inside ip6_input_finish().
> 
> ...I remember that I was thinking about this before.
> 
> For my conclusion, first option is just to drop
> uncompleted fragments as we do today.  Second option
> would be  to forward them to the next process so that
> core code could send ICMPv6 etc. or, we could have
> new code to send ICMPV6_TIME_EXCEED in REJECT target.
> In longer term, I think it is better to introduce
> per-exthdr hooks.

We'd need something that allows to process the incomplete fragments
long enough so they can actually reach the IPv6 core (people usually
don't allow incoming fragments when using conntrack).

But for now you've convinced me that this patch is wrong.

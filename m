From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC][PATCH] IP: Send a fragment reassembly time exceeded packet
 when enabling connection track
Date: Wed, 13 Jan 2010 09:27:41 +0100
Message-ID: <4B4D83FD.5040604@trash.net>
References: <4B3191E7.8060509@cn.fujitsu.com> <4B42D1C3.3020207@trash.net> <4B4D3AD3.6050403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B4D3AD3.6050403@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei wrote:
> Patrick McHardy wrote, at 01/05/2010 01:44 PM:
>> Shan Wei wrote:
>>> Default, a host may send a fragment reassembly time exceeded packet
>>> (ICMP Time Exceeded Message with code value of 1) when defraging fragments timeout.
>>> But, when enabling connection track, a host can't send the packet.
>>>
>>> Because, the module of nf_defrag_ipv4 selected by connection track is registered 
>>> in PRE_ROUTING HOOK and assembles all accepted fragments(here, not begin to routing).
>>> After defrag timeout, the host can't send fragment reassembly time exceeded packet, 
>>> because of lack of router information.
>>>
>>> RFC 792 says:
>>>>>>>   If a host reassembling a fragmented datagram cannot complete the
>>>>>>>   reassembly due to missing fragments within its time limit it
>>>>>>>   discards the datagram, and it may send a time exceeded message.
>>>>>>>
>>>>>>>   If fragment zero is not available then no time exceeded need be
>>>>>>>   sent at all.
>>>>>>>
>>>>>>>
>>>>>>> Read more: http://www.faqs.org/rfcs/rfc792.html#ixzz0aOXRD7Wp
>>> So, the patch try to fix it with filling router information before sending fragment reassembly
>>> time exceeded packet when defrag timeout.
>> I guess the question is whether we really want to send an ICMP
>> message in this case. The above quote applies to end hosts,
> 
> Yes, what you guess is what i want to ask. :-)
> Should end hosts which are using conntrack send a fragment reassembly time exceeded message?

Yes, they should.

>> while conntrack is also (probably more commonly) used on routers,
>> which normally shouldn't attempt reassembly.  
> 
> There are two point:
> 1.Take security into account, end hosts also used conntrack. 
> 
>   For example: When a host is attacked by denial of service TCP flaws, RedHat used the conntrack&recent
>   match to limit the TCP connections.
>   
>   About details, see the phenomenon description:
>     http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2008-4609
>     http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2008-4609
> 
>   See RedHat's solution:
>     http://kbase.redhat.com/faq/docs/DOC-18730

I'm not sure I get the connection to this patch.

> 2.On the latest kernel, a router on which the conntrack is used, reassemble fragments and 
>   forward reassembled intact packet. This implementation is not coincide with what you said.

Yes, thats a necessity for conntrack to work, but its not what
a router usually does. But it actually does refragment the packet
if it exceeds the MTU of the outgoing interface.

>   nf_defrag_ipv4 module is registered on PRE_ROUTING hook with the highest priority. So, search router table 
>   after completing the reassembly and forward it to destination host.


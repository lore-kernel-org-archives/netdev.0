From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Thu, 21 Jan 2010 12:47:57 -0000
Message-ID: <0b01c450344abffd72a5b1b037ee6584e6db6b82@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>
    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
    <4B55D372.4020807@gmail.com>
    <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
    <4B5773C2.2010000@simon.arlott.org.uk>
    <alpine.LSU.2.01.1001202238400.18680@obet.zrqbmnf.qr>
    <alpine.LSU.2.01.1001202240350.18680@obet.zrqbmnf.qr>
    <4B578E59.8090203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Jan Engelhardt" <jengelh@medozas.de>,
	"William Allen Simpson" <william.allen.simpson@gmail.com>,
	"netdev" <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B578E59.8090203@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, January 20, 2010 23:14, Patrick McHardy wrote:
> Jan Engelhardt wrote:
>> On Wednesday 2010-01-20 22:39, Jan Engelhardt wrote:
>>> On Wednesday 2010-01-20 22:21, Simon Arlott wrote:
>>>> The TCPMSS target is dropping SYN packets where:
>>>>  1) There is data, or
>>>>  2) The data offset makes the TCP header larger than
>>>>  the packet.
>>>>
>>>> Both of these result in an error level printk.
>>>>
>>>> This change fixes the drop of SYN packets with data
>>>> (because the MSS option can safely be modified) and
>>>> passes packets with no MSS option instead of adding
>>>> one (which is not valid).
>>> Can you explain why the automatic addition of a MSS option is removed?
>>
>> That is, of course, for the git log. If I followed the thread right, it
>> was that adding the option could exceed the MTU. Well, can't we check
>> for the outgoing MTU?
>
> We certainly can, and in fact the packet would get fragmented
> by the IP layer in case we would exceed the PMTU. Additionally
> we currently check that the packet contains no data, even with
> the first version of this patch, so there's no way the packet
> could exceed the MTU.

If DF is set and the MTU is exceeded (for the SYN packet) at a
hop further away, the original host will not understand that it
needs to allow for the MSS option being added.

(Header + Data + New MSS Option) can't exceed 576 bytes and
there's no way to know that more than 576 bytes is allowed
because the ICMP error message may not go via the same host that
is mangling the packet.

Of course, it could just allow fragmentation for this one SYN
packet but that doesn't work for IPv6.

> This feature has been there from day one since the TCPMSS target
> has been merged and people are using this with knowledge of their
> MTUs to work around broken ISPs. I'm not apply this.

The TCPMSS target can be applied to more than just one direction
of traffic. I'm modifying incoming traffic too, so adding the MSS
option and setting it to over 536 is wrong (although the first ICMP
error will fix it).

Existing users use this target precisely because their hosts are
sending an unwanted MSS value, so it will never need to be added.

> The first version seemed fine to me though :)

The first version is ok with me. Only SYN packets with data and
no MSS option will be dropped. William objects to ever adding the
MSS option.

Although ideally SYN packets with data and no MSS option should
be accepted without adding an option. Dropping arbitrary traffic
(especially when new kernels allow data to be sent with SYN
packets) is not a good idea. If that is ok with you then I'll
make another patch to do it and update the comments.

-- 
Simon Arlott

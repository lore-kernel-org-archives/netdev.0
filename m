From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 09/14] igb: Report L4 Rx hash via skb->l4_rxhash
Date: Thu, 17 Jan 2013 10:46:52 -0800
Message-ID: <CAEP_g=8WrUgb0BahQHWZHTbL9yR8TzhR5xqkzqV6jc8rCgCMvA@mail.gmail.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1358422519-20981-10-git-send-email-jeffrey.t.kirsher@intel.com>
 <1358432385.29723.6.camel@edumazet-glaptop> <50F82FCA.9090709@intel.com>
 <1358442889.29723.58.camel@edumazet-glaptop> <50F8337E.9030302@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:40982 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755841Ab3AQSrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 13:47:14 -0500
Received: by mail-ia0-f198.google.com with SMTP id y25so2162840iay.1
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 10:47:13 -0800 (PST)
In-Reply-To: <50F8337E.9030302@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 9:23 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> On 01/17/2013 09:14 AM, Eric Dumazet wrote:
>> On Thu, 2013-01-17 at 09:07 -0800, Alexander Duyck wrote:
>>
>>> Isn't the same true of TCP?  I believe STT is intended to run over the
>>> TCP protocol, or am I getting ahead of myself since STT is not supported
>>> by the kernel?
>>>
>>
>> probably ;)
>>
>>>> Also, is IGB really using the ports in the rss for UDP packets ?
>>>
>>> Not by default.  The default is to only hash on the IP header for UDP
>>> packets.
>>>
>>> As such the default would only be setting the l4_rxhash on TCP frames
>>> only.  The user would have to specifically request L4 port hashing for
>>> UDP via the "ethtool -N" command for configuring rx-flow-hash.
>>
>> So you should rewrite this patch ?
>>
>> Or have I missed something ?
>
> I'm probably going to scrap it.  No point in rewriting it.
>
> I has assumed that there were other uses for the l4_rxhash value.  If
> all it is meant for is to indicate that the inner header of a tunnel was
> used to compute the hash then there isn't much point to adding support
> for this in igb/ixgbe since they don't support any inner header hashing.
>
> It might add value at some point to rename the l4_rxhash flag to
> something else though since it seems like there are now tunnels that are
> encapsulated inside of l4 headers and it is going to get confusing.

I think there is value in setting it for TCP since it is used by
things like RPS and VXLAN (on the encapsulation side, to generate the
source port).

Ultimately, the semantics that I think we are looking for here is
whether the software flow dissector would look deeper into the packet
than the NIC.  In the case of STT, the answer to this is going to be
no, so there's no reason to not set the flag.  Even for protocols like
VXLAN, in software we don't currently look deeply into the packet on
receive, so we could set it there as well.  Both of these protocols
also have the advantage that the outer header contains an inner hash.

In the case of UDP tunnels, it would be nice to use the ports for RSS
since they often do contain these hashes.  We just have to make sure
that they aren't IP fragments.

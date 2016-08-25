From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH iproute] iptuntap: show processes using tuntap interface
Date: Thu, 25 Aug 2016 21:37:58 +0200
Message-ID: <ced543a3-b8d8-d508-bcfc-8e7822e28d85@stressinduktion.org>
References: <1472062105-17995-1-git-send-email-hannes@stressinduktion.org>
 <20160825084424.73a31b8a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41497 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754378AbcHYUYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 16:24:01 -0400
In-Reply-To: <20160825084424.73a31b8a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.08.2016 17:44, Stephen Hemminger wrote:
> On Wed, 24 Aug 2016 20:08:25 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
>> Show which processes are using which tun/tap devices, e.g.:
>>
>> $ ip -d tuntap
>> tun0: tun
>> 	Attached to processes: vpnc(9531)
>> vnet0: tap vnet_hdr
>> 	Attached to processes: qemu-system-x86(10442)
>> virbr0-nic: tap UNKNOWN_FLAGS:800
>> 	Attached to processes:
>>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> I think reading all of /proc like this will scale really badly on large systems.

Yes, it is quite heavy weight but so far I didn't see any major latency
on even more busy systems (tens of thousands of fds). Also this code is
only entered if details are requested. I don't see a cheaper way to
determine those information currently without further patches (which
probably all will have the same n:m problem, as fds can be shared
between multiple processes).

> Why reinvent lsof?

lsof currently doesn't provide this information and would also have to
brute force in the same way (it scans all fds anyway, thought). In my
opinion it is just very helpful on virtualization boxes to quickly
identify the vm associated with an interface.

I would propose that in case we see people reporting latency issues to
speed it up in possibly two ways:

a) not glob over the whole pid/fd space, but just take one number at a
time, e.g. /proc/1*/fd/*, /proc/2*/fd/* etc.

b) or/and we just push everything into an internal hash table so for
multiple interfaces we don't need to walk again.

I would just try to not add the complexity if it is not necessary.

Thoughts?

Bye,
Hannes

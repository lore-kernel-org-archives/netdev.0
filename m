From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route after
 encountering pmtu exception
Date: Sat, 15 Aug 2015 09:48:26 +0200
Message-ID: <55CEEECA.8000702@ahsoftware.de>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
 <55B89C14.2070700@ahsoftware.de> <55BA1144.9090203@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>, stable@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:59850 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbHOHsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2015 03:48:46 -0400
In-Reply-To: <55BA1144.9090203@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 30.07.2015 um 13:57 schrieb Alexander Holler:
> Am 29.07.2015 um 11:25 schrieb Alexander Holler:
>> Am 23.05.2015 um 05:55 schrieb Martin KaFai Lau:
>>
>>> This series is to avoid creating a RTF_CACHE route whenever we are
>>> consulting
>>> the fib6 tree with a new destination.  Instead, only create RTF_CACHE
>>> route
>>> when we see a pmtu exception.
>>
>> That even helps on systems without an IPv6-connection to world because
>> it avoids the IPv6 route add/delete pairs which happened before whenever
>> an IPv6-connection was tried (e.g. by Happy Eyeballs algorithms).
>>
>> I think that's worse a laud. thanks.
>
> Of course, I meant worth. Sorry, but the left part of my brain seems to
> be sometimes in a (maybe forced) power save mode. ;)
>
> Also I wonder how the previous algorithm went into the kernel at all or
> why it wasn't fixed earlier. Anyway, it's great that someone took the
> time to fix that annoying behaviour (I've had on my radar since quiet
> some time).

To complete the discussion, that "annoying behaviour" is also a big 
information leak.

Because routes aren't considered confidential and aren't subject to 
privacy, that broken behaviour enabled *everyone* on the same system to 
see *all* the remote IPv6 systems to which there have been connection 
establishment tries.

E.g. I can see the following on a system when browsing to facebook.com 
and google.com:

--------
[aholler@krabat snetmanmon.git]$ ./snetmanmon snetmanmon.conf.simple_example

snetmanmon V1.3-5-g9f06

(C) 2015 Alexander Holler

(...)
New route 2a00:1450:4001:80c::100a (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a03:2880:2130:cf05:face:b00c:0:1 (gateway 
fe80::21f:7bff:feb4:d13, type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1007 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:400f:803::101f (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1008 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1017 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4016:804::200d (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1000 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1016 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:400f:803::1013 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1006 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1018 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4016:804::2009 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
New route 2a00:1450:4001:80c::1005 (gateway fe80::21f:7bff:feb4:d13, 
type v6, scope universe) on interface 'virbr0'
Route 2a00:1450:4001:80c::100a (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a03:2880:2130:cf05:face:b00c:0:1 (gateway 
fe80::21f:7bff:feb4:d13, type v6, scope universe) on interface 'virbr0' 
was deleted
Route 2a00:1450:4001:80c::1000 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4001:80c::1005 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4001:80c::1006 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4001:80c::1007 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4001:80c::1008 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4001:80c::1016 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4001:80c::1017 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4001:80c::1018 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:400f:803::1013 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:400f:803::101f (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4016:804::2009 (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
Route 2a00:1450:4016:804::200d (gateway fe80::21f:7bff:feb4:d13, type 
v6, scope universe) on interface 'virbr0' was deleted
--------
(those deletes happen because I've no IPv6 connection to the outside 
world on that system)

Also this doesn't give me the used URLs (or the user). it gives me quiet 
some good idea about what happens on a system.

Therefor I think it's worse to think about backporting this patch series 
at least to the current long term stable kernel (4.1) too.

Regards,

Alexander Holler

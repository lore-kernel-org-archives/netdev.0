From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH net 0/2] net: marvell: Fix highmem support on non-TSO
 path
Date: Thu, 22 Jan 2015 15:45:56 -0300
Message-ID: <54C14564.7060408@free-electrons.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com> <20150121150159.GS26493@n2100.arm.linux.org.uk> <54C1443C.80909@tpi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: deang@tpi.com, Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:45665 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752473AbbAVSsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 13:48:04 -0500
In-Reply-To: <54C1443C.80909@tpi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 03:41 PM, Dean Gehnert wrote:
> On 01/21/2015 07:01 AM, Russell King - ARM Linux wrote:
>> On Wed, Jan 21, 2015 at 09:54:08AM -0300, Ezequiel Garcia wrote:
>>> These two commits are fixes to the issue reported by Russell King o=
n
>>> mv643xx_eth. Namely, the introduction of a regression by commit
>>> 69ad0dd7af22
>>> which removed the support for highmem skb fragments. The guilty com=
mit
>>> introduced the assumption of fragment's payload being located in
>>> lowmem pages.
>> I do wonder whether 69ad0dd7af22 is the real culpret, or whether the=
re is
>> some other change in the netdev layer that we're missing.  That comm=
it is
>> in 3.16, but from what I remember, 3.17 works fine, it's 3.18 which
>> fails.
>>
>>> A similar pattern can be found in the original mvneta driver (in
>>> fact, the
>>> regression was introduced by copy-pasting the mvneta code).
>>>
>>> These fixes are for the non-TSO egress path in mvneta and mv643xx_e=
th
>>> drivers.
>>> The TSO path needs a more intrusive change, as the TSO API needs to
>>> be fixed
>>> (e.g. to make it work in skb fragments, instead of pointers to data=
).
>>>
>>> Russell, as I'm still unable to reproduce this, do you think you ca=
n
>>> give it a spin over there?
>> Sure - I think the only one I can test is mv643xx_eth, I don't think=
 I
>> have any device which supports mv_neta.
>>
>> The test scenario is for a NFS mount (the Marvell device as the NFS
>> client) over IPv6.
>>
>> Initial testing looks good, I'll let it run for a while with various
>> builds on the NFS share (which iirc was one of the triggering
>> workloads).
>>
>> Thanks.
>>
> FYI, I found a way to reproduce the mv643xx_eth transmit corruption
> without using a network filesystem by using SOCAT (should also be abl=
e
> to use NETCAT or NC) and I have a bit more information about the
> corruption that looks like it is somehow related to the cache line si=
ze.
>=20
> 1) Create a "large" input file with known data on the target (saved t=
o
> RAM disk or other storage):
>     % php -r 'for ($x =3D 0; $x < 0x2000000; $x++) { printf("%08X\n",=
 $x);
> }' > ExpectData.in
>       or
>     % perl -e 'for ($x =3D 0; $x < 0x2000000; $x++) { printf("%08X\n"=
,
> $x); }' > ExpectData.in
>     % md5sum ExpectData.in
>     4a4727232209b85badc1ca25ed4df222  ExpectData.in
> 2) Start SOCAT on the host system to perform Ethernet receive MD5
> checksum of the data:
>     % socat -s -u TCP4-LISTEN:4000,fork,reuseaddr EXEC:md5sum
> 3) Enable TSO on the target:
>     % ethtool -K eth0 tso on
> 4)  Send the data file from the target to the host using SOCAT with a
> non-cache aligned block size:
>     % socat -b$(((1024*10)+1)) -u ExpectData.in TCP:192.168.1.212:400=
0
> 5) The SOCAT running on the host system will report the MD5 checksum.=
 If
> the MD5 is correct, it should be 4a4727232209b85badc1ca25ed4df222.
>=20
> What I am seeing is every now and then, there are 32-bits (4 bytes) o=
f
> data in the transmit Ethernet stream that are corrupted. If I change =
the
> SOCAT block size to something that is Armada 300 (Kirkwood) cache lin=
e
> aligned (ie. -b$(((1024*10)+0)) or -b$(((1024*10)+8))), it works just
> fine... If you want to capture the actual file and look at it, you ca=
n
> use SOCAT:
>   % socat -u TCP4-LISTEN:4000,fork,reuseaddr OPEN:ActualData.in,creat
> and since the data file is text, it is really easy to see the corrupt=
ion
> (diff ExpectData.in ActualData.in | less).
>=20
> I can disable TSO (ethtool -K eth0 tso off) and re-run the tests and =
the
> corruption does not occur.
>=20
> I will give Ezequiel's latest patches a test a today and let you know=
 if
> they change the behavior.
>=20

Sigh, this smells like a completely different bug. Which kernel version
are you testing?
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com

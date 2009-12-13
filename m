From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: nfs broken in net-next? -- now in mainline -- bisected:
	d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Date: Sat, 12 Dec 2009 18:41:53 -0800
Message-ID: <86802c440912121841j34cde8ecv892d7d74a32313ac@mail.gmail.com>
References: <86802c440912112125v4aa72189ifcc2d16ecbf79cc4@mail.gmail.com>
	 <20091211.214117.200029438.davem@davemloft.net>
	 <86802c440912121705y59eea3ebq3bdbd3e7459e748e@mail.gmail.com>
	 <86802c440912121757g474a7df4od6b50f6d5a210cf0@mail.gmail.com>
	 <86802c440912121825h20663affv9ff8d004974d0d31@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, sri@us.ibm.com, herbert@gondor.apana.org.au,
	torvalds@linux-foundation.org, sjayaraman@suse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:61776 "HELO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932448AbZLMClx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 21:41:53 -0500
In-Reply-To: <86802c440912121825h20663affv9ff8d004974d0d31@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 12, 2009 at 6:25 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> On Sat, Dec 12, 2009 at 5:57 PM, Yinghai Lu <yinghai@kernel.org> wrot=
e:
>> On Sat, Dec 12, 2009 at 5:05 PM, Yinghai Lu <yinghai@kernel.org> wro=
te:
>>>
>>> [f86dcc5aa8c7908f2c287e7a211228df599e3e71] udp: dynamically
>>> size hash tables at boot time
>>
>> commit f86dcc5aa8c7908f2c287e7a211228df599e3e71
>> Author: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: =A0 Wed Oct 7 00:37:59 2009 +0000
>>
>> =A0 =A0udp: dynamically size hash tables at boot time
>>
>> =A0 =A0UDP_HTABLE_SIZE was initialy defined to 128, which is a bit s=
mall for
>> =A0 =A0several setups.
>>
>> =A0 =A04000 active UDP sockets -> 32 sockets per chain in average. A=
n
>> =A0 =A0incoming frame has to lookup all sockets to find best match, =
so long
>> =A0 =A0chains hurt latency.
>>
>> =A0 =A0Instead of a fixed size hash table that cant be perfect for e=
very
>> =A0 =A0needs, let UDP stack choose its table size at boot time like =
tcp/ip
>> =A0 =A0route, using alloc_large_system_hash() helper
>>
>> =A0 =A0Add an optional boot parameter, uhash_entries=3Dx so that an =
admin can
>> =A0 =A0force a size between 256 and 65536 if needed, like thash_entr=
ies and
>> =A0 =A0rhash_entries.
>>
>> =A0 =A0dmesg logs two new lines :
>> =A0 =A0[ =A0 =A00.647039] UDP hash table entries: 512 (order: 0, 409=
6 bytes)
>> =A0 =A0[ =A0 =A00.647099] UDP Lite hash table entries: 512 (order: 0=
, 4096 bytes)
>>
>> =A0 =A0Maximal size on 64bit arches would be 65536 slots, ie 1 MByte=
s for non
>> =A0 =A0debugging spinlocks.
>>
>> =A0 =A0Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> cause the problem: nfs mount fail.
>>
>> the setup is:
>> 64bit kernel, have all needed drivers in kernel, and boot with
>> ip=3Ddhcp, root disk is 256M ramdisk.
>> then try to mount nfs....
>>
>
> change entries default value from 65536 to 256,
> nfs mount will work.
>
> YH
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 1f95348..57c13c3 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2054,7 +2054,7 @@ void udp4_proc_exit(void)
> =A0}
> =A0#endif /* CONFIG_PROC_FS */
>
> -static __initdata unsigned long uhash_entries;
> +static __initdata unsigned long uhash_entries =3D UDP_HTABLE_SIZE_MI=
N;
> =A0static int __init set_uhash_entries(char *str)
> =A0{
> =A0 =A0 =A0 =A0if (!str)
>

interesting:

m:~/dump # grep UDP dmesg.txt
[   28.996034] UDP hash table entries: 65536 (order: 11, 10485760 bytes=
)
[   29.032364] UDP-Lite hash table entries: 65536 (order: 11, 10485760 =
bytes)

will not work

but 32768 will work.

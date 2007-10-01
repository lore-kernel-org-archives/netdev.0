From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 2.6.21 -> 2.6.22 & 2.6.23-rc8 performance regression
Date: Mon, 01 Oct 2007 07:59:12 +0200
Message-ID: <47008CB0.7010808@cosmosbay.com>
References: <20070930144443.M52139@visp.net.lb> <46FFE17C.9020202@cosmosbay.com> <200709301425.37564.nickpiggin@yahoo.com.au> <20070930223503.M8966@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Denys <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37385 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbXJAF71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 01:59:27 -0400
In-Reply-To: <20070930223503.M8966@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys a =C3=A9crit :
> Hi=20
>=20
> I got
>=20
> pi linux-git # git bisect bad
> Bisecting: 0 revisions left to test after this
> [f85958151900f9d30fa5ff941b0ce71eaa45a7de] [NET]: random functions ca=
n use=20
> nsec resolution instead of usec
>=20
> I will make sure and will try to reverse this patch on 2.6.22
>=20
> But it seems "that's it".

Well... thats interesting...

No problem here on bigger servers, so I CC David Miller and netdev on t=
his one.

AFAIK do_gettimeofday() and ktime_get_real() should use the same underl=
ying=20
hardware functions on PC and no performance problem should happen here.

(relevant part of this patch :

@ -1521,7 +1515,6 @@ __u32 secure_ip_id(__be32 daddr)
  __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
                                  __be16 sport, __be16 dport)
  {
-       struct timeval tv;
         __u32 seq;
         __u32 hash[4];
         struct keydata *keyptr =3D get_keyptr();
@@ -1543,12 +1536,11 @@ __u32 secure_tcp_sequence_number(__be32 saddr, =
__be32=20
daddr,
          *      As close as possible to RFC 793, which
          *      suggests using a 250 kHz clock.
          *      Further reading shows this assumes 2 Mb/s networks.
-        *      For 10 Mb/s Ethernet, a 1 MHz clock is appropriate.
+        *      For 10 Gb/s Ethernet, a 1 GHz clock is appropriate.
          *      That's funny, Linux has one built in!  Use it!
          *      (Networks are faster now - should this be increased?)
          */
-       do_gettimeofday(&tv);
-       seq +=3D tv.tv_usec + tv.tv_sec * 1000000;
+       seq +=3D ktime_get_real().tv64;


Thank you for doing this research.

>=20
>=20
> On Sun, 30 Sep 2007 14:25:37 +1000, Nick Piggin wrote
>> Hi Denys, thanks for reporting (btw. please reply-to-all when=20
>> replying on lkml).
>>
>> You say that SLAB is better than SLUB on an otherwise identical=20
>> kernel, but I didn't see if you quantified the actual numbers? It=20
>> sounds like there is still a regression with SLAB?
>>
>> On Monday 01 October 2007 03:48, Eric Dumazet wrote:
>>> Denys a  :
>>>> I've moved recently one of my proxies(squid and some compressing
>>>> application) from 2.6.21 to 2.6.22, and notice huge performance dr=
op. I
>>>> think this is important, cause it can cause serious regression on =
some
>>>> other workloads like busy web-servers and etc.
>>>>
>>>> After some analysis of different options i can bring more exact nu=
mbers:
>>>>
>>>> 2.6.21 able to process 500-550 requests/second and 15-20 Mbit/s of
>>>> traffic, and working great without any slowdown or instability.
>>>>
>>>> 2.6.22 able to process only 250-300 requests and 8-10 Mbit/s of tr=
affic,
>>>> ssh and console is "freezing" (there is delay even for typing
>>>> characters).
>>>>
>>>> Both proxies is on identical hardware(Sun Fire X4100),
>>>> configuration(small system, LFS-like, on USB flash), different onl=
y
>>>> kernel.
>>>>
>>>> I tried to disable/enable various options and optimisations - it d=
oesn't
>>>> change anything, till i reach SLUB/SLAB option.
>>>>
>>>> I've loaded proxy configuration to gentoo PC with 2.6.22 (then upg=
raded
>>>> it to 2.6.23-rc8), and having same effect.
>>>> Additionally, when load reaching maximum i can notice whole system
>>>> slowdown, for example ssh and scp takes much more time to run, eve=
n i do
>>>> nice -n -5 for them.
>>>>
>>>> But even choosing 2.6.23-rc8+SLAB i noticed same "freezing" of ssh=
 (and
>>>> sure it slowdown other kind of network performance), but much less
>>>> comparing with SLUB. On top i am seeing ksoftirqd taking almost 10=
0%
>>>> (sometimes ksoftirqd/0, sometimes ksoftirqd/1).
>>>>
>>>> I tried also different tricks with scheduler (/proc/sys/kernel/sch=
ed*),
>>>> but it's also didn't help.
>>>>
>>>> When it freezes it looks like:
>>>>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMA=
ND
>>>>     7 root      15  -5     0    0    0 R   64  0.0   2:47.48 ksoft=
irqd/1
>>>>  5819 root      20   0  134m 130m  596 R   57  3.3   4:36.78 globa=
x
>>>>  5911 squid     20   0 1138m 1.1g 2124 R   26 28.9   2:24.87 squid
>>>>    10 root      15  -5     0    0    0 S    1  0.0   0:01.86 event=
s/1
>>>>  6130 root      20   0  3960 2416 1592 S    0  0.1   0:08.02 oprof=
iled
>>>>
>>>>
>>>> Oprofile results:
>>>>
>>>>
>>>> Thats oprofile with 2.6.23-rc8 - SLUB
>>>>
>>>> 73918    21.5521  check_bytes
>>>> 38361    11.1848  acpi_pm_read
>>>> 14077     4.1044  init_object
>>>> 13632     3.9747  ip_send_reply
>>>> 8486      2.4742  __slab_alloc
>>>> 7199      2.0990  nf_iterate
>>>> 6718      1.9588  page_address
>>>> 6716      1.9582  tcp_v4_rcv
>>>> 6425      1.8733  __slab_free
>>>> 5604      1.6339  on_freelist
>>>>
>>>>
>>>> Thats oprofile with 2.6.23-rc8 - SLAB
>>>>
>>>> CPU: AMD64 processors, speed 2592.64 MHz (estimated)
>>>> Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) wit=
h a
>>>> unit mask of 0x00 (No unit mask) count 100000
>>>> samples  %        symbol name
>>>> 138991   14.0627  acpi_pm_read
>>>> 52401     5.3018  tcp_v4_rcv
>>>> 48466     4.9037  nf_iterate
>>>> 38043     3.8491  __slab_alloc
>>>> 34155     3.4557  ip_send_reply
>>>> 20963     2.1210  ip_rcv
>>>> 19475     1.9704  csum_partial
>>>> 19084     1.9309  kfree
>>>> 17434     1.7639  ip_output
>>>> 17278     1.7481  netif_receive_skb
>>>> 15248     1.5428  nf_hook_slow
>>>>
>>>> My .config is at http://www.nuclearcat.com/.config (there is SPARS=
EMEM
>>>> enabled, it doesn't make any noticeable difference)
>>>>
>>>> Please CC me on reply, i am not in list.
>>> Could you try with SLUB but disabling CONFIG_SLUB_DEBUG ?
>=20
>=20
> --
> Denys Fedoryshchenko
> Technical Manager
> Virtual ISP S.A.L.
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
>=20


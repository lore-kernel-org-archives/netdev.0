From: Fan Du <fan.du@windriver.com>
Subject: [PATCH] {iproute2, xfrm}: Use memcpy to suppress gcc phony buffer
 overflow warning
Date: Sun, 29 Sep 2013 09:49:04 +0800
Message-ID: <52478710.702@windriver.com>
References: <524411AE.7000404@linux.vnet.ibm.com> <52447DAC.2060701@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7361@saturn3.aculab.com> <5246D88F.7090906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@aculab.com>,
	<stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: Sohny Thomas <sthomas@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56723 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab3I2Bte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 21:49:34 -0400
In-Reply-To: <5246D88F.7090906@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B409=E6=9C=8828=E6=97=A5 21:24, Sohny Thomas wrote:
> On Friday 27 September 2013 01:56 PM, David Laight wrote:
>>> ip xfrm state add causes a SIGABRT due to a strncpy_chk .
>>> This happens since strncpy doesn't account for the '\0' .
>>> I have fixed this using sizeof instead of strlen .
>>>
>>> There is a redhat bug which documents this issue
>>>
>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D982761
>>>
>>> Signed-off-by: Sohny Thomas <sohthoma@in.ibm.com>
>>>
>>> --------------
>>>
>>> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
>>> index 389942c..7dd8799 100644
>>> --- a/ip/xfrm_state.c
>>> +++ b/ip/xfrm_state.c
>>> @@ -117,7 +117,7 @@ static int xfrm_algo_parse(struct xfrm_algo *al=
g,
>>> enum xfrm_attr_type_t type,
>>> char *name, char *key, char *buf, int max)
>>> {
>>> int len;
>>> - int slen =3D strlen(key);
>>> + int slen =3D sizeof(key);
>>
>> you definitely don't want sizeof(key) - that is either 4 or 8.
> oh damn my bad.
> I think i will go with strlen(key) + 1.
>
> or i will pass slen+1 to strncpy .

You must be kidding about this slen+1 or strlen(key) + 1 , right?



 From 3895b3d88bcb873988089392079645f2c9665e95 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Sun, 29 Sep 2013 09:38:12 +0800
Subject: [PATCH] {iproute2, xfrm}: Use memcpy to suppress gcc phony buf=
fer
  overflow warning.

This bug is reported from below link:
https://bugzilla.redhat.com/show_bug.cgi?id=3D982761

An simplified command from its original reproducing method in bugzilla:
ip xfrm state add src 10.0.0.2 dst 10.0.0.1 proto ah spi 0x12345678 aut=
h md5 12
will cause below spew from gcc:

*** buffer overflow detected ***: ./ip terminated
=3D=3D=3D=3D=3D=3D=3D Backtrace: =3D=3D=3D=3D=3D=3D=3D=3D=3D
/lib/x86_64-linux-gnu/libc.so.6(__fortify_fail+0x37)[0x7f894ae2b817]
/lib/x86_64-linux-gnu/libc.so.6(+0x109710)[0x7f894ae2a710]
/lib/x86_64-linux-gnu/libc.so.6(+0x1089f6)[0x7f894ae299f6]
=2E/ip[0x42119d]
=2E/ip(do_xfrm_state+0x231)[0x4217f1]
=2E/ip[0x405d05]
=2E/ip(main+0x2b4)[0x405934]
/lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0xed)[0x7f894ad4276d]
=2E/ip[0x405bb9]
=3D=3D=3D=3D=3D=3D=3D Memory map: =3D=3D=3D=3D=3D=3D=3D=3D
00400000-0043c000 r-xp 00000000 08:01 1997183                          =
  /workbench/iproute2/ip/ip
0063b000-0063c000 r--p 0003b000 08:01 1997183                          =
  /workbench/iproute2/ip/ip
0063c000-00640000 rw-p 0003c000 08:01 1997183                          =
  /workbench/iproute2/ip/ip
00640000-00643000 rw-p 00000000 00:00 0
017c7000-017e8000 rw-p 00000000 00:00 0                                =
  [heap]
7f894ab0b000-7f894ab20000 r-xp 00000000 08:01 6032986                  =
  /lib/x86_64-linux-gnu/libgcc_s.so.1
7f894ab20000-7f894ad1f000 ---p 00015000 08:01 6032986                  =
  /lib/x86_64-linux-gnu/libgcc_s.so.1
7f894ad1f000-7f894ad20000 r--p 00014000 08:01 6032986                  =
  /lib/x86_64-linux-gnu/libgcc_s.so.1
7f894ad20000-7f894ad21000 rw-p 00015000 08:01 6032986                  =
  /lib/x86_64-linux-gnu/libgcc_s.so.1
7f894ad21000-7f894aed6000 r-xp 00000000 08:01 6033273                  =
  /lib/x86_64-linux-gnu/libc-2.15.so
7f894aed6000-7f894b0d5000 ---p 001b5000 08:01 6033273                  =
  /lib/x86_64-linux-gnu/libc-2.15.so
7f894b0d5000-7f894b0d9000 r--p 001b4000 08:01 6033273                  =
  /lib/x86_64-linux-gnu/libc-2.15.so
7f894b0d9000-7f894b0db000 rw-p 001b8000 08:01 6033273                  =
  /lib/x86_64-linux-gnu/libc-2.15.so
7f894b0db000-7f894b0e0000 rw-p 00000000 00:00 0
7f894b0e0000-7f894b0e2000 r-xp 00000000 08:01 6033272                  =
  /lib/x86_64-linux-gnu/libdl-2.15.so
7f894b0e2000-7f894b2e2000 ---p 00002000 08:01 6033272                  =
  /lib/x86_64-linux-gnu/libdl-2.15.so
7f894b2e2000-7f894b2e3000 r--p 00002000 08:01 6033272                  =
  /lib/x86_64-linux-gnu/libdl-2.15.so
7f894b2e3000-7f894b2e4000 rw-p 00003000 08:01 6033272                  =
  /lib/x86_64-linux-gnu/libdl-2.15.so
7f894b2e4000-7f894b306000 r-xp 00000000 08:01 6033287                  =
  /lib/x86_64-linux-gnu/ld-2.15.so
7f894b4e3000-7f894b4e6000 rw-p 00000000 00:00 0
7f894b503000-7f894b506000 rw-p 00000000 00:00 0
7f894b506000-7f894b507000 r--p 00022000 08:01 6033287                  =
  /lib/x86_64-linux-gnu/ld-2.15.so
7f894b507000-7f894b509000 rw-p 00023000 08:01 6033287                  =
  /lib/x86_64-linux-gnu/ld-2.15.so
7fff9a3c2000-7fff9a3e3000 rw-p 00000000 00:00 0                        =
  [stack]
7fff9a3ff000-7fff9a400000 r-xp 00000000 00:00 0                        =
  [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                =
  [vsyscall]

This is a false positive warning as the destination pointer "buf" point=
ers to
an ZERO length array, which actually will occupy alg.buf mostly.
=46ix this by using memcpy.

struct xfrm_algo {
         char            alg_name[64];
         unsigned int    alg_key_len;    /* in bits */
         char            alg_key[0];
};

struct {
         union {
                 struct xfrm_algo alg;
                 struct xfrm_algo_aead aead;
                 struct xfrm_algo_auth auth;
         } u;
         char buf[XFRM_ALGO_KEY_BUF_SIZE];
} alg =3D {};

buf =3D alg.u.alg.alg_key;
---
  ip/xfrm_state.c |    2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 0d98e78..5cc87d3 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -159,7 +159,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, e=
num xfrm_attr_type_t type,
  			if (len > max)
  				invarg("\"ALGO-KEY\" makes buffer overflow\n", key);

-			strncpy(buf, key, len);
+			memcpy(buf, key, len);
  		}
  	}

--=20
1.7.9.5




> Regards,
> Sohny
>>
>> David
>>
>>
>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan

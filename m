From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: PATCH: ipv6: avoid wraparound for expired lifetimes
Date: Thu, 25 Jun 2009 17:25:17 +0800
Message-ID: <4A43427D.3030109@cn.fujitsu.com>
References: <20090625073943.GO21357@jayr.de> <Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI> <20090625090603.GP21357@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57937 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbZFYJZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 05:25:59 -0400
In-Reply-To: <20090625090603.GP21357@jayr.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom wrote:
> On Thu, Jun 25, 2009 at 11:40:19AM +0300, Ilpo J=E4rvinen wrote:
>  =20
>> On Thu, 25 Jun 2009, Jens Rosenboom wrote:
>>
>>    =20
>>> If the valid or preferred lifetime for an address expires, the kern=
el
>>> shows huge values for these due to a counter wrap,
>>>      =20
>> I suspect we have plenty of potentially counter-wrapped printouts al=
l=20
>> around the kernel. So you're fixing just a tip of the iceberg.
>>    =20
>
> So are you implying that because I don't fix all of them at once, I
> shouldn't bother to start at all?
>
> On Thu, 2009-06-25 at 01:42 -0700, David Miller wrote:
> ...
>  =20
>> Jens, don't even bother posting patches that fail to
>> build.
>>    =20
>
> Sorry for that, here is the correct version.
>
> --- linux-2.6.30.orig/net/ipv6/addrconf.c	2009-06-10 05:05:27.0000000=
00 +0200
> +++ linux-2.6.30/net/ipv6/addrconf.c	2009-06-25 10:52:27.000000000 +0=
200
> @@ -3361,9 +3361,18 @@
>  		valid =3D ifa->valid_lft;
>  		if (preferred !=3D INFINITY_LIFE_TIME) {
>  			long tval =3D (jiffies - ifa->tstamp)/HZ;
> -			preferred -=3D tval;
> -			if (valid !=3D INFINITY_LIFE_TIME)
> -				valid -=3D tval;
> +			if (preferred > tval) {
> +				preferred -=3D tval;
> +			} else {
> +				preferred =3D 0;
> +			}
> +			if (valid !=3D INFINITY_LIFE_TIME) {
> +				if (valid > tval) {
> +					valid -=3D tval;
> +				} else {
> +					valid =3D 0;
> +				}
> +			}
>  		}
>  	} else {
>  		preferred =3D INFINITY_LIFE_TIME;
>
>  =20

checkpatch tell me the following errors:

# ./scripts/checkpatch.pl /root/PATCH\ \ ipv6\ \ avoid\ wraparound\ for=
\ expired\ lifetimes.eml

WARNING: braces {} are not necessary for any arm of this statement
#90: FILE: net/ipv6/addrconf.c:3364:
+                       if (preferred > tval) {
[...]
+                       } else {
[...]

ERROR: spaces required around that '-=3D' (ctx:WxV)
#91: FILE: net/ipv6/addrconf.c:3365:
+                               preferred -=3D3D tval;
                                          ^

ERROR: spaces required around that '=3D' (ctx:WxV)
#93: FILE: net/ipv6/addrconf.c:3367:
+                               preferred =3D3D 0;
                                          ^

ERROR: spaces required around that '!=3D' (ctx:WxV)
#95: FILE: net/ipv6/addrconf.c:3369:
+                       if (valid !=3D3D INFINITY_LIFE_TIME) {
                                  ^

ERROR: spaces required around that '-=3D' (ctx:WxV)
#97: FILE: net/ipv6/addrconf.c:3371:
+                                       valid -=3D3D tval;
                                              ^

ERROR: spaces required around that '=3D' (ctx:WxV)
#99: FILE: net/ipv6/addrconf.c:3373:
+                                       valid =3D3D 0;
                                              ^

ERROR: Missing Signed-off-by: line(s)

total: 6 errors, 1 warnings, 21 lines checked

/root/PATCH  ipv6  avoid wraparound for expired lifetimes.eml has style=
 problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.


> And to show you where this appears:
>
> Output with plain 2.6.30
>
> # ip -6 addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 2001:db8::202:a5ff:fee8:20be/64 scope global dynamic=20
>        valid_lft 870sec preferred_lft 7sec
>     inet6 fe80::202:a5ff:fee8:20be/64 scope link=20
>        valid_lft forever preferred_lft forever
> # sleep 30
> # ip -6 addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 2001:db8::202:a5ff:fee8:20be/64 scope global deprecated dyn=
amic=20
>        valid_lft 840sec preferred_lft 4294967266sec
>     inet6 fe80::202:a5ff:fee8:20be/64 scope link=20
>        valid_lft forever preferred_lft forever
>
> Output with patched 2.6.30
>
> # ip -6 addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 2001:db8::202:a5ff:fee8:12e1/64 scope global dynamic=20
>        valid_lft 897sec preferred_lft 27sec
>     inet6 fe80::202:a5ff:fee8:12e1/64 scope link=20
>        valid_lft forever preferred_lft forever
> # sleep 30
> # ip -6 addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 2001:db8::202:a5ff:fee8:12e1/64 scope global deprecated dyn=
amic=20
>        valid_lft 862sec preferred_lft 0sec
>     inet6 fe80::202:a5ff:fee8:12e1/64 scope link=20
>        valid_lft forever preferred_lft forever
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
>  =20



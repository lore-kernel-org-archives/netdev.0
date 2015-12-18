From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev <device_name> ' command
Date: Sat, 19 Dec 2015 00:45:40 +0300
Message-ID: <1335891450475140@web23o.yandex.ru>
References: <5917221449918579@web5j.yandex.ru>
	 <20151216161558.265296c7@redhat.com>
	 <20151216160400.GJ6555@orbit.nwl.cc>
	 <1313271450456765@web7g.yandex.ru> <20151218165518.GE19288@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward7o.cmail.yandex.net ([37.9.109.53]:39600 "EHLO
	forward7o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965054AbbLRVxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 16:53:25 -0500
In-Reply-To: <20151218165518.GE19288@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil,

18.12.2015, 19:55, "Phil Sutter" <phil@nwl.cc>:
> On Fri, Dec 18, 2015 at 07:39:25PM +0300, Dmitrii Shcherbakov wrote:
>> =9A> Dmitrii, did iproute2 without your change even print the overhe=
ad as set
>> =9A> by you before? Looking at the code, I'd assume not.
>>
>> =9ATried building iproute2 (as of tag 4.2) and using the upstream li=
nux kernel (also tag 4.2 - 64291f7db5bd8150a74ad2036f1037e6a0428df2):
>
> This is without your patch, right?

Yes (ec4ef6aebd5a52ab1acf1f5be1749320b3188659).=20

>
>> =9A~/src/iproute2/tc$ sudo ./tc class add dev eth0 parent 1: classid=
 1:1 htb rate 100kbps ceil 100kbps mpu 256 overhead 64
>
> Setting an mpu of 256 is suitable to get 0 as output value, as the co=
de
> before your patch ANDs it with 0xff.

True, but then I think I would get the 'old' (encoded) overhead output =
of '1b' then and the first 8 bits which are treated as mpu would be 0 a=
nyway. And its 0 for both mpu and overhead ("mpu 0b overhead 0b") which=
 is strange. I am going to have to take a look at the kernel state with=
 gdb.

What I would expect instead (notice 'overhead 1b'):

[root@localhost ~]# tc -d class show dev eth0
[root@localhost ~]# tc qdisc add dev eth0 root handle 1: htb default 12
[root@localhost ~]# tc class add dev eth0 parent 1: classid 1:1 htb rat=
e 100kbps ceil 100kbps mpu 256 overhead 64
[root@localhost ~]# tc -d class show dev eth0
class htb 1:1 root prio 0 quantum 10000 rate 800000bit overhead 64 ceil=
 800000bit burst 1600b/1 mpu 0b overhead 1b cburst 1600b/1 mpu 0b overh=
ead 1b level 0 =20

>
>> =9ASo it looks like the overhead is being set correctly, but the mpu=
 is not, even though the respective kernel module is loaded judging by =
what I see.
>
> To really know what is being set, you would have to look at the kerne=
l
> variables not what iproute prints. This is nitpicking mostly, but
> relevant in this case as your patches to fix iproute's output show.
>
> Cheers, Phil

I am going to try and take a look at it. I have not delved into the ker=
nel's network subsystem so it may take some time.

Thanks,
Dima

From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 01 Apr 2005 18:34:18 +0200
Message-ID: <424D780A.9000101@cosmosbay.com>
References: <42370997.6010302@cosmosbay.com>	<20050315103253.590c8bfc.davem@davemloft.net>	<42380EC6.60100@cosmosbay.com>	<20050316140915.0f6b9528.davem@davemloft.net>	<4239E00C.4080309@cosmosbay.com>	<20050331221352.13695124.davem@davemloft.net>	<424D5D34.4030800@cosmosbay.com> <16973.28254.203492.400896@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16973.28254.203492.400896@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson a =E9crit :
>  Hello!
>=20
>  Did you check for performance changes too? From what I understand=20
>  we can add new lookup and cache miss in the fast packet path.

Performance is better because in case of stress (lot of incoming packets =
per second), the 1024 bytes of the locks are all in cache.
As the size of the hash is divided by a 2 factor, rt_check_expire() and/o=
r rt_garbage_collect() have to touch less cache lines.

According to oprofile, an unpatched kernel was spending more than 15% of =
time in route.c routines, now I see ip_route_input() at 1.88%

>=20
>  > > Anyways, I think perhaps you should dynamically allocate this lock=
 table.
>  >=20
>  > Maybe I should make a static sizing, (replace the 256 constant by so=
mething based on MAX_CPUS) ?
>=20
>  IMO we should be careful with adding new complexity the route hash.
>  Also was this dynamic behavior gc_interval needed to fix the overflow?

In my case yes, because I have huge route cache.

>  gc_interval is only sort of last resort timer.

Actually not : gc_interval controls the rt_check_expire() to clean the ha=
sh table after use.

All old enough entries can be deleted smoothly, on behalf of a timer tick=
 (so network interrupts can still occur)

I found it was better to adjust gc_interval to 1 (to let it fire every se=
cond and examine 1/300 table slots, or more if the dynamic behavior=20
triggers), and ajust params so that rt_garbage_collect() doesnt run at al=
l : rt_garbage_collect() can take forever to complete, blocking=20
network trafic.


Eric Dumazet

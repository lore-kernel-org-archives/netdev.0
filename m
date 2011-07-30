From: Rui Ueyama <rui314@gmail.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Fri, 29 Jul 2011 22:09:36 -0700
Message-ID: <CACKH++afaAaa7a6ViYjo_PjpF1bXYtOuJaa-4umEOSVgW1+g3w@mail.gmail.com>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
 <1311931816.2843.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57797 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab1G3FJ4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2011 01:09:56 -0400
Received: by iyb12 with SMTP id 12so4746410iyb.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 22:09:56 -0700 (PDT)
In-Reply-To: <1311931816.2843.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The result of benchmark looks good. A simple benchmark that sends 10M U=
DP
packets to lo took 76.24 seconds on average on Core 2 Duo L7500@1.6GHz.=
when
tcpdump is running. With this patch it took 75.41 seconds, which means =
we save
80ns for each packet on that processor.

I think converting the VM to threaded code is low hanging fruit, even
if we'd have
JIT compilers for popular architectures. Most of the lines in my patch
are indentation
change, so the actual change is not big.

Vanilla kernel:

(without tcpdump)
ruiu@blue:~$ time ./udpflood 10000000
real	0m57.909s
user	0m1.368s
sys	0m56.484s

ruiu@blue:~$ time ./udpflood 10000000
real	0m57.686s
user	0m1.360s
sys	0m56.288s

ruiu@blue:~$ time ./udpflood 10000000
real	0m58.457s
user	0m1.300s
sys	0m57.116s

(with tcpdump)
ruiu@blue:~$ time ./udpflood 10000000
real	1m16.025s
user	0m1.464s
sys	1m14.505s
ruiu@blue:~$ time ./udpflood 10000000

real	1m15.860s
user	0m1.232s
sys	1m14.573s
ruiu@blue:~$ time ./udpflood 10000000

real	1m16.861s
user	0m1.504s
sys	1m15.301s


Kernel with the patch:

(without tcpdump)
ruiu@blue:~$ time ./udpflood 10000000

real	0m59.272s
user	0m1.308s
sys	0m57.924s

ruiu@blue:~$ time ./udpflood 10000000

real	0m59.624s
user	0m1.336s
sys	0m58.244s

ruiu@blue:~$ time ./udpflood 10000000

real	0m59.340s
user	0m1.240s
sys	0m58.056s

(with tcpdump)
ruiu@blue:~$ time ./udpflood 10000000

real	1m15.392s
user	0m1.372s
sys	1m13.965s

ruiu@blue:~$ time ./udpflood 10000000

real	1m15.352s
user	0m1.452s
sys	1m13.845s

ruiu@blue:~$ time ./udpflood 10000000

real	1m15.508s
user	0m1.464s
sys	1m13.989s

Tcpdump I used is this: tcpdump -p -n -s -i lo net 192.168.2.0/24

On Fri, Jul 29, 2011 at 2:30 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 29 juillet 2011 =E0 01:10 -0700, Rui Ueyama a =E9crit :
>> Convert the BPF VM to threaded code to improve performance.
>>
>> The BPF VM is basically a big for loop containing a switch statement=
=2E =A0That is
>> slow because for each instruction it checks the for loop condition a=
nd does the
>> conditional branch of the switch statement.
>>
>> This patch eliminates the conditional branch, by replacing it with j=
ump table
>> using GCC's labels-as-values feature. The for loop condition check c=
an also be
>> removed, because the filter code always end with a RET instruction.
>>
>
> Well...
>
>
>> +#define NEXT goto *jump_table[(++fentry)->code]
>> +
>> + =A0 =A0 /* Dispatch the first instruction */
>> + =A0 =A0 goto *jump_table[fentry->code];
>
> This is the killer, as this cannot be predicted by the cpu.
>
> Do you have benchmark results to provide ?
>
> We now have BPF JIT on x86_64 and powerpc, and possibly on MIPS and A=
RM
> on a near future.
>
>
>
>

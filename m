From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH linux v3 1/1] fs/proc: use a rb tree for the directory
 entries
Date: Wed, 15 Oct 2014 11:02:55 +0200
Message-ID: <543E383F.5010907@6wind.com>
References: <20141006.181448.1696747135961247651.davem@davemloft.net>	<1412672559-5256-1-git-send-email-nicolas.dichtel@6wind.com>	<1412672559-5256-2-git-send-email-nicolas.dichtel@6wind.com>	<543BB42B.30505@6wind.com> <87y4sis9wk.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org,
	adobriyan@gmail.com, rui.xiang@huawei.com, viro@zeniv.linux.org.uk,
	oleg@redhat.com, gorcunov@openvz.org,
	kirill.shutemov@linux.intel.com, grant.likely@secretlab.ca,
	tytso@mit.edu, Linus Torvalds <torvalds@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4sis9wk.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/10/2014 21:56, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 07/10/2014 11:02, Nicolas Dichtel a =C3=A9crit :
>>> The current implementation for the directories in /proc is using a =
single
>>> linked list. This is slow when handling directories with large numb=
ers of
>>> entries (eg netdevice-related entries when lots of tunnels are open=
ed).
>>>
>>> This patch replaces this linked list by a red-black tree.
>>>
>>> Here are some numbers:
>>>
>>> dummy30000.batch contains 30 000 times 'link add type dummy'.
>>>
>>> Before the patch:
>>> $ time ip -b dummy30000.batch
>>> real	2m31.950s
>>> user	0m0.440s
>>> sys	2m21.440s
>>> $ time rmmod dummy
>>> real	1m35.764s
>>> user	0m0.000s
>>> sys	1m24.088s
>>>
>>> After the patch:
>>> $ time ip -b dummy30000.batch
>>> real	2m0.874s
>>> user	0m0.448s
>>> sys	1m49.720s
>>> $ time rmmod dummy
>>> real	1m13.988s
>>> user	0m0.000s
>>> sys	1m1.008s
>>>
>>> The idea of improving this part was suggested by
>>> Thierry Herbelot <thierry.herbelot@6wind.com>.
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> Acked-by: David S. Miller <davem@davemloft.net>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>> ---
>>
>> I'm not sure who is in charge of taking this patch. Should I resend =
it to
>> someone else or is it already included in a tree?
>
> There are a couple of things going on here.
>
> This patch came out at the beginning of the merge window which is a t=
ime
> when everything that was ready and well tested ahead of time gets
> merged.
>
> Your numbers don't look too bad, so I expect this code is ready to go
> (although I am a smidge disappointed in the small size of the
> performance improvement), my quick read through earlier did not show
> anything scary.   Do you have any idea why going from O(N^2) algorith=
m
> to a O(NlogN) algorithm showed such a small performance improvement w=
ith
> 30,000 entries?
perf top shows that a lot of time was wasted in vsscanf().
With my previous test file (dummy30000.batch), kernel needs to calculat=
e
the interface name (iproute2 command was : 'link add type dummy'). Here=
 is
another bench:

=46iles dummywithnameX.batch are created like this:
for i in `seq 1 X`; do echo "link add dummy$i type dummy" >>=20
dummywithnameX.batch; done

Before the patch:
$ time ip -b dummywithname10000.batch
real	0m22.496s
user	0m0.196s
sys	0m5.924s
$ rmmod dummy
$ time ip -b dummywithname15000.batch
real	0m37.903s
user	0m0.348s
sys	0m13.160s
$ rmmod dummy
$ time ip -b dummywithname20000.batch
real	0m52.941s
user	0m0.396s
sys	0m20.164s
$ rmmod dummy
$ time ip -b dummywithname30000.batch
real	1m32.447s
user	0m0.660s
sys	0m43.436s

After the patch:
$ time ip -b dummywithname10000.batch
real	0m19.648s
user	0m0.180s
sys	0m2.260s
$ rmmod dummy
$ time ip -b dummywithname15000.batch
real	0m29.149s
user	0m0.256s
sys	0m3.616s
$ rmmod dummy
$ time ip -b dummywithname20000.batch
real	0m39.133s
user	0m0.440s
sys	0m4.756s
$ rmmod dummy
$ time ip -b dummywithname30000.batch
real    0m59.837s
user    0m0.520s
sys     0m7.780s

Thus an improvement of ~35% for 30k ifaces, but more importantly, after=
 the
patch, it scales linearly.

perf top output after the patch:
      4.30%  [kernel]          [k] arch_local_irq_restore
      2.92%  [kernel]          [k] format_decode
      2.10%  [kernel]          [k] vsnprintf
      2.08%  [kernel]          [k] arch_local_irq_enable
      1.82%  [kernel]          [k] number.isra.1
      1.81%  [kernel]          [k] arch_local_irq_enable
      1.41%  [kernel]          [k] kmem_cache_alloc
      1.33%  [kernel]          [k] unmap_single_vma
      1.10%  [kernel]          [k] do_raw_spin_lock
      1.09%  [kernel]          [k] clear_page
      1.00%  [kernel]          [k] arch_local_irq_enable

>
> Normally proc is looked at by a group of folks me, Alexey Dobriyan, a=
nd
> Al Viro all sort of tag team taking care of the proc infrastructure w=
ith
> (except for Al) Andrew Morton typically taking the patches and mergin=
g
> them.
>
> I am currently in the middle of a move so I don't have the time to ca=
rry
> this change or do much of anything until I am settled again.
>
> What I would recommend is verifying your patch works against v3.18-rc=
1
> at the begginning of next week and sending the code to Andrew Morton.
Ok, thank you. I will do this.

Nicolas

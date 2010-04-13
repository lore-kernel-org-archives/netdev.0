From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Tue, 13 Apr 2010 12:23:47 +0200
Message-ID: <1271154227.16881.235.camel@edumazet-laptop>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	 <1271146112.16881.213.camel@edumazet-laptop>
	 <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
	 <1271153942.16881.233.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:48129 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab0DMKX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:23:56 -0400
Received: by bwz19 with SMTP id 19so111958bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 03:23:54 -0700 (PDT)
In-Reply-To: <1271153942.16881.233.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 12:19 +0200, Eric Dumazet a =C3=A9crit :
> Le mardi 13 avril 2010 =C3=A0 17:50 +0800, Changli Gao a =C3=A9crit :
> > On Tue, Apr 13, 2010 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
> > > Use of 'volatile' is strongly discouraged, I would say, forbidden=
=2E
> > >
> >=20
> > volatile is used to avoid compiler optimization.
>=20
> volatile might be used on special macros only, not to guard a variabl=
e.
> volatile was pre SMP days. We need something better defined these day=
s.
>=20
> >=20
> > > Its usually a sign of 'I dont exactly what memory ordering I need=
, so I
> > > throw a volatile just in case'. We live in a world full of RCU, r=
ead ,
> > > write, full barriers. And these apis are well documented.
> > >
> >=20
> > There isn't memory accessing order problem.
> >=20
>=20
> Really ? If you persist using this volatile thing, then you'll have t=
o
> convince Mr Linus Torvald himself. Prepare your best guns, because in
> fact you'll have to convince about one hundred people that know for s=
ure
> how volatile is weak.

$ cat Documentation/volatile-considered-harmful.txt
Why the "volatile" type class should not be used
------------------------------------------------

C programmers have often taken volatile to mean that the variable could=
 be
changed outside of the current thread of execution; as a result, they a=
re
sometimes tempted to use it in kernel code when shared data structures =
are
being used.  In other words, they have been known to treat volatile typ=
es
as a sort of easy atomic variable, which they are not.  The use of vola=
tile in
kernel code is almost never correct; this document describes why.

The key point to understand with regard to volatile is that its purpose=
 is
to suppress optimization, which is almost never what one really wants t=
o
do.  In the kernel, one must protect shared data structures against
unwanted concurrent access, which is very much a different task.  The
process of protecting against unwanted concurrency will also avoid almo=
st
all optimization-related problems in a more efficient way.

Like volatile, the kernel primitives which make concurrent access to da=
ta
safe (spinlocks, mutexes, memory barriers, etc.) are designed to preven=
t
unwanted optimization.  If they are being used properly, there will be =
no
need to use volatile as well.  If volatile is still necessary, there is
almost certainly a bug in the code somewhere.  In properly-written kern=
el
code, volatile can only serve to slow things down.

Consider a typical block of kernel code:

    spin_lock(&the_lock);
    do_something_on(&shared_data);
    do_something_else_with(&shared_data);
    spin_unlock(&the_lock);

If all the code follows the locking rules, the value of shared_data can=
not
change unexpectedly while the_lock is held.  Any other code which might
want to play with that data will be waiting on the lock.  The spinlock
primitives act as memory barriers - they are explicitly written to do s=
o -
meaning that data accesses will not be optimized across them.  So the
compiler might think it knows what will be in shared_data, but the
spin_lock() call, since it acts as a memory barrier, will force it to
forget anything it knows.  There will be no optimization problems with
accesses to that data.

If shared_data were declared volatile, the locking would still be
necessary.  But the compiler would also be prevented from optimizing ac=
cess
to shared_data _within_ the critical section, when we know that nobody =
else
can be working with it.  While the lock is held, shared_data is not
volatile.  When dealing with shared data, proper locking makes volatile
unnecessary - and potentially harmful.

The volatile storage class was originally meant for memory-mapped I/O
registers.  Within the kernel, register accesses, too, should be protec=
ted
by locks, but one also does not want the compiler "optimizing" register
accesses within a critical section.  But, within the kernel, I/O memory
accesses are always done through accessor functions; accessing I/O memo=
ry
directly through pointers is frowned upon and does not work on all
architectures.  Those accessors are written to prevent unwanted
optimization, so, once again, volatile is unnecessary.

Another situation where one might be tempted to use volatile is
when the processor is busy-waiting on the value of a variable.  The rig=
ht
way to perform a busy wait is:

    while (my_variable !=3D what_i_want)
        cpu_relax();

The cpu_relax() call can lower CPU power consumption or yield to a
hyperthreaded twin processor; it also happens to serve as a compiler
barrier, so, once again, volatile is unnecessary.  Of course, busy-
waiting is generally an anti-social act to begin with.

There are still a few rare situations where volatile makes sense in the
kernel:

  - The above-mentioned accessor functions might use volatile on
    architectures where direct I/O memory access does work.  Essentiall=
y,
    each accessor call becomes a little critical section on its own and
    ensures that the access happens as expected by the programmer.

  - Inline assembly code which changes memory, but which has no other
    visible side effects, risks being deleted by GCC.  Adding the volat=
ile
    keyword to asm statements will prevent this removal.

  - The jiffies variable is special in that it can have a different val=
ue
    every time it is referenced, but it can be read without any special
    locking.  So jiffies can be volatile, but the addition of other
    variables of this type is strongly frowned upon.  Jiffies is consid=
ered
    to be a "stupid legacy" issue (Linus's words) in this regard; fixin=
g it
    would be more trouble than it is worth.

  - Pointers to data structures in coherent memory which might be modif=
ied
    by I/O devices can, sometimes, legitimately be volatile.  A ring bu=
ffer
    used by a network adapter, where that adapter changes pointers to
    indicate which descriptors have been processed, is an example of th=
is
    type of situation.

=46or most code, none of the above justifications for volatile apply.  =
As a
result, the use of volatile is likely to be seen as a bug and will brin=
g
additional scrutiny to the code.  Developers who are tempted to use
volatile should take a step back and think about what they are truly tr=
ying
to accomplish.

Patches to remove volatile variables are generally welcome - as long as
they come with a justification which shows that the concurrency issues =
have
been properly thought through.


NOTES
-----

[1] http://lwn.net/Articles/233481/
[2] http://lwn.net/Articles/233482/

CREDITS
-------

Original impetus and research by Randy Dunlap
Written by Jonathan Corbet
Improvements via comments from Satyam Sharma, Johannes Stezenbach, Jesp=
er
	Juhl, Heikki Orsila, H. Peter Anvin, Philipp Hahn, and Stefan
	Richter.



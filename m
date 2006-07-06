From: Russell Stuart <russell@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Thu, 06 Jul 2006 10:39:36 +1000
Message-ID: <1152146376.4215.59.camel@ras.pc.brisbane.lube>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
	 <449C06E3.3090406@trash.net>
	 <1151282720.4210.46.camel@ras.pc.brisbane.lube>
	 <449FC0AF.1050904@trash.net> <44A0CE01.4010109@stuart.id.au>
	 <44AA6D25.9000707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Z3i00SYif5fJQ6Gllhh1"
Cc: hadi@cyberus.ca, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:52619 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S965098AbWGFAlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 20:41:24 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AA6D25.9000707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Z3i00SYif5fJQ6Gllhh1
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2006-07-04 at 15:29 +0200, Patrick McHardy wrote:
> Unfortunately I still didn't got to cleaning them up, so I'm sending
> them in their preliminary state. Its not much that is missing, but
> the netem usage of skb->cb needs to be integrated better, I failed
> to move it to the qdisc_skb_cb so far because of circular includes.

Cleanups aside, architecturally the bulk of your patch 
looks like a no-brainier to me.  The calculation of
packet length should be in one place.  Caching it in
skb->cb was a nice touch.

> But nothing unfixable. I'm mostly interested if the current size-tables
> can express what you need for ATM, I wasn't able to understand the
> big comment in tc_core.c in your patch.

Unfortunately you do things in the wrong order for ATM.
See: http://mailman.ds9a.nl/pipermail/lartc/2006q1/018314.html
for an overview of the problem, and then the attached email for
a detailed description of how the current patch addresses it.
It is a trivial fix.

As I said earlier, RTAB and STAB contain the same numbers,
just scaled differently.  The ATM patch stuffed around with
RTAB.  With your patch in place it will have to do the same 
exactly the same thing with STAB - because RTAB and STAB
carry the same data.  So to me the two patches seem
orthogonal.

One observation is the size optimisation you applied to STAB, 
making it variable length, could also be applied to RTAB.  
In fact it should be.  Then they would be identical, apart 
from the scaling.  Even the lookup operation (performed in
qdisc_init_len in your patch) would be identical.

However, now you lot have made me go away and think, I have
another idea on how to attack this.  Perhaps it will be
more palatable to you.  It would replace RTAB and STAB with
a 28 byte structure for most protocol stacks - well all I can
think of off the top of my head, anyway.  RTAB would have to
remain for backwards compatibility, of course.


--=-Z3i00SYif5fJQ6Gllhh1
Content-Disposition: inline
Content-Description: Attached message - Re: Getting ATM patches into the
	kernel
Content-Type: message/rfc822

Subject: Re: Getting ATM patches into the kernel
From: Russell Stuart <russell@stuart.id.au>
To: Jesper Dangaard Brouer <jdb@comx.dk>
In-Reply-To: <1147862206.30209.5.camel@localhost.localdomain>
References: <1147258683.9996.82.camel@ras.pc.brisbane.lube>
	 <1147266374.27161.37.camel@localhost.localdomain>
	 <1147296491.9996.84.camel@ras.pc.brisbane.lube>
	 <1147357724.27161.56.camel@localhost.localdomain>
	 <1147406394.4517.19.camel@ras.pc.brisbane.lube>
	 <1147771837.27674.44.camel@localhost.localdomain>
	 <1147774429.4202.36.camel@ras.pc.brisbane.lube>
	 <1147862206.30209.5.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 19 May 2006 22:59:34 +1000
Message-Id: <1148043575.4206.259.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
X-Mailer: Evolution 2.0.4 
X-Evolution-Transport: 
	smtp://russell;auth=CRAM-MD5@smtp.stuart.id.au:587/;use_ssl=when-possible
X-Evolution-Account: russell@stuart.id.au
X-Evolution-Fcc: email://local@local/Sent
X-Evolution-Format: text/plain
Content-Transfer-Encoding: 7bit
Disposition-Notification-To: Russell Stuart <russell@stuart.id.au>

Explanation of rate calculation code.

tc_core.c lines 53..61, tc_align_to_cells():

  Does the same thing as you function of the same name.
  Code is intended to be semantically equivalent.


tc_core.c lines 145..160, in tc_calc_ratespec:

  There are two material differences to your code.  Both
  are in this line:

    int sz = ((i+1)<<cell_log) - 1 + overhead;

  The first is that where I add the overhead, you don't.
  This is because I am calculating the rate table so it
  works as well as close to optimal as possible on an
  unpatched kernel.  Given the background in your draft
  email, I assume I don't have to prove you that it does
  in fact calculate the best possible table for an 
  unpatched kernel.

  The second change is I use:
    ((i+1)<<cell_log) - 1
  Whereas you had:
    ((i+1)<<cell_log)

  The number calculated by this expression:
    ((i+1) << cell_log)
  is the shortest packet length rtab[(i+1)] applies to.  
  Ergo, that number minus 1 must be the longest packet 
  length the previous rtab entry, rtab[i], applies to.
  So the intent of the change is that in unpatched kernels,
  rtab[i] will contain the time to send the longest 
  packet that uses it.  I suspect your code ends up doing 
  the same thing on kernels that add overhead to the 
  packet length.

There should be no other semantic differences between and
how you and I calculate the rate table.  If so this should
be sufficient to show that if your code calculated an ideal
rate table for kernels that added the overhead to the 
packet length before looking up the rate table, my code 
should calculate the best possible table for unpatched 
kernels.  It won't be ideal because some table entries will
apply to packets using different numbers of ATM cells.  
This is unavoidable.  But where that happens my code will 
always be conservative, ie use the longest packet length.

I think backward the compatibility increases the odds of
the patch being accepted.  The next step is to patch the
kernel it can get 100% accurate results by using this
table.

Consider this "diagram":

Overhead 0
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             39 40 41 42 43 44 45 46 47 48 49 50
rtab[skb->len/8]:      1  1  1  1  1  1  1  1  1 x2  2  2

Each column is for a particular packet length.  The rows
show the packet length as seen by a layer of the protocol.  
The top row, "ATM Payload", contains packet length seen 
by the ATM layer - ie the ATM payload.  It includes all 
overheads bar cell overhead and padding.  It is always 
equal to: skb->len + overhead.

The second row, "skb->len" contains the packet seen by 
the kernel.  It is just the figure in the first line
less the "overhead" passed to tc.

The third line shows how "tc" will calculate the rate 
table entry for the packet length.  It contains the
number of ATM cells "tc" thinks the packet will occupy.
I am assuming a cell_log of 3 here, meaning each rate
table entry is used for 8 different packet lengths.  
In an unpatched kernel a single rate table entry may 
apply to packets which use different numbers of ATM 
cells.  Since the rate table entry is a single number 
it cant be right for all packet lengths when that 
happens.  If faced with this ambiguity tc uses the number
of cells occupied by the longest packet the rate table 
entry applies to. This means the rate table will be wrong 
for the shorter packets, and this is highlighted in the
diagram an "x".

Thus we see from the table that for a 39 byte packet tc
thinks it will take 1 cell to send.  But for a 48 byte
packet the table says it will take "x2" packets.  The "x"
means it will really take 1 packet, but because this rate
table entry is also used by 49..55 byte packets tc used
the bigger value for that rate table entry.

We can fix the errant "x2" entry by sliding the rate
table along so it sits under the smallest packet length
it could apply to (in this case 49).  To achieve that
the rate table must be slide one byte to right.  This 
can be achieved by adding an "alignment" figure of -1 
to the packet length before looking up the rate table.
Here is the same diagram as above, but with two 
additional lines added showing the effect of adding the
alignment:

Overhead 0
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             39 40 41 42 43 44 45 46 47 48 49 50
rtab[skb->len/8]:      1  1  1  1  1  1  1  1  1 x2  2  2
skb->len-1:           38 39 40 41 42 43 44 45 46 47 48 49
rtab[(skb->len-1)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

The rows "skb->len-1" and "rtab[(skb->len-1)/8]" are
copies of the rows above that have been moved slightly.
They have to be copies, as the rtab computed by tc hasn't
changed, so for example 47 must still yield 1 cell, and
48 must still yield 2 cells.

Below is the same diagram repeated for overheads 1 .. 9.
The are all pretty much the same as the one above.  The
only changes is the increasing overhead, which in turn 
changes the number of columns in error.  The alignment 
changes to compensate.  You will see it follows a 
straightforward pattern as the overhead increases.  

Overhead 1
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             38 39 40 41 42 43 44 45 46 47 48 49
rtab[skb->len/8]:      1  1  1  1  1  1  1  1  1  1  2  2
skb->len-0:           38 39 40 41 42 43 44 45 46 47 48 49
rtab[(skb->len-0)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 2
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             37 38 39 40 41 42 43 44 45 46 47 48
rtab[skb->len/8]:      1  1  1 x2 x2 x2 x2 x2 x2 x2  2  2
skb->len-7:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-7)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 3
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             36 37 38 39 40 41 42 43 44 45 46 47
rtab[skb->len/8]:      1  1  1  1 x2 x2 x2 x2 x2 x2  2  2
skb->len-6:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-6)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 4
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             35 36 37 38 39 40 41 42 43 44 45 46
rtab[skb->len/8]:      1  1  1  1  1 x2 x2 x2 x2 x2  2  2
skb->len-5:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-5)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 5
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             34 35 36 37 38 39 40 41 42 43 44 45
rtab[skb->len/8]:      1  1  1  1  1  1 x2 x2 x2 x2  2  2
skb->len-4:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-4)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 6
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             33 34 35 36 37 38 39 40 41 42 43 44
rtab[skb->len/8]:      1  1  1  1  1  1  1 x2 x2 x2  2  2
skb->len-3:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-3)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 7
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             32 33 34 35 36 37 38 39 40 41 42 43
rtab[skb->len/8]:      1  1  1  1  1  1  1  1 x2 x2  2  2
skb->len-2:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-2)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 8
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             31 32 33 34 35 36 37 38 39 40 41 42
rtab[skb->len/8]:      1  1  1  1  1  1  1  1  1 x2  2  2
skb->len-1:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-1)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Overhead 9
----------
ATM Payload:          39 40 41 42 43 44 45 46 47 48 49 50
skb->len:             30 31 32 33 34 35 36 37 38 39 40 41
rtab[skb->len/8]:      1  1  1  1  1  1  1  1  1  1  2  2
skb->len-0:           30 31 32 33 34 35 36 37 38 39 40 41
rtab[(skb->len-0)/8]:  1  1  1  1  1  1  1  1  1  1  2  2

Notice that at overhead 8 has an alignment of -1, and this
is the same alignment as overhead 0 had.  This is because
the errors have moved through one rate table entry and are
now into the next one, so the "fix" is the same.

We can draw up a table showing the required alignment for
each overhead, like this:

  overhead | alignment
  ---------+----------
      0    |    -1
      1    |     0
      2    |    -7
      3    |    -6
      4    |    -5
      5    |    -4
      6    |    -3
      7    |    -2

We only need 8 elements, as once we get to 8 (or more
accurately 1<<cell_log) it repeats.  If the kernel
adds the alignment figure from the table to the packet
size before looking up the rate table, then it will 
always get accurate results from the optimal table for 
the unpatched kernel.

The alignment figure is calculated by "tc" and passed to
the kernel, much as you passed the "overhead" to the 
kernel in your code.  In my case it will always be small.

And finally, we come to ......

tc_core.c line 122, in tc_calc_cell_align.  The expression 
I use to calculate the alignment is:

    return (overhead + cell_size - 2) % cell_size - cell_size + 1

You could try and mathematically prove it does yield the
table above, but since there are only 8 values that
matter (the % in the expression ensures it repeats after
that), it much easier to just plug in the overheads 0..7
and verify it does come up with the correct alignment.

QED, for a cell_log of 3 anyway.

--=-Z3i00SYif5fJQ6Gllhh1--


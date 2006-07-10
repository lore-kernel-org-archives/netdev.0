From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Mon, 10 Jul 2006 18:44:10 +1000
Message-ID: <1152521050.4236.180.camel@ras.pc.brisbane.lube>
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
	<1152146376.4215.59.camel@ras.pc.brisbane.lube>
	<44AE1497.6010904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AE1497.6010904@trash.net>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Fri, 2006-07-07 at 10:00 +0200, Patrick McHardy wrote:
> Russell Stuart wrote:
> > Unfortunately you do things in the wrong order for ATM.
> > See: http://mailman.ds9a.nl/pipermail/lartc/2006q1/018314.html
> > for an overview of the problem, and then the attached email for
> > a detailed description of how the current patch addresses it.
> > It is a trivial fix.
> 
> Actually that was the part I didn't understand, you keep talking
> (also in that comment in tc_core.c) about an "unknown overhead".
> What is that and why would it be unknown? The mail you attached
> is quite long, is there an simple example that shows what you
> mean?

The "unknown overhead" is just the overhead passed to tc
using the "tc ... overhead xxx" option.  It is probably
what you intended to put into your addend attribute.

It is "unknown" because the kernel currently doesn't use
it.  It is passed in the tc_ratespec, but is ignored by
the kernel as are most fields in there.

The easy way to fix the "ATM" problem described in the big
comment is simply to add the "overhead" to the packet 
length before doing the RTAB lookup.  (Identical comments 
apply to STAB).  If you don't accept this or understand
why, then go read the "long emails" which attempt to
explain it in detail.  Jesper's initial version of the
patch did just that, BTW.

However if you do that then you have to adjust RTAB for
all cases (not just ATM) to reflect that the kernel is 
now adding the overhead.  Thus the RTAB tc sends to the 
kernel now changes for different kernel versions, making 
modern versions of tc incompatible with older kernels, 
and visa versa.  I didn't consider that acceptable.

My solution to this to give the kernel the old format
RTAB (ie the one that assumed the kernel didn't add the
overhead) and a small adjustment.  This small adjustment 
is called cell_align in the ATM patch.  You do the same 
thing with cell_align as the previous solution did with 
the overhead - ie add it in just before looking up RTAB.  
This is in effect all the kernel part of the ATM patch
does - make the kernel accept the cell_align option,
and add it to skb->len before looking up RTAB.

The difference between cell_align and overhead is that
cell_align is always 0 when there is no packetisation,
and even when non zero it is small (less than 1<<cell_log, 
ie less than 8 for typical MTU's).  So for anything bar 
ATM it is zero which means old kernels are completely
unaffected, and even for ATM not sending it produces a 
small error which means older kernels still benefit from
the "ATM" user space patch.   This makes the proposed 
"ATM" version of tc both forward and  backward compatible.

One other point arises here.  The fields in "tc_ratespec"
that "tc" fills and the kernel ignores are there so "tc 
show" will work.  The essence of the problem is "tc"
compiles the stuff you give it into a single "RTAB".  
That "RTAB" can't be reverse compiled into the original 
numbers the user provided.  So if "tc show" is to work,
"tc" has to save that information somewhere.  I don't
think the "tc_ratespec" was the best choice for two
reasons.

Firstly, having the fields show up in tc_ratespec 
makes it seem like the kernel can use them.  It can't,
as the "overhead" example above shows.  Secondly, from
tc's point of view it is inflexible.  Over time new
features have been be added to "tc", and each time a
new way of encoding it in the existing "tc_ratespec" 
has to be invented.  Thus we now have hacks like the
storing the "overhead" in the upper bits of the MPU
figure.

A better solution would be to provide a TLV (ie a 
TCA_XXX constant) for TC's private use.  From the 
kernels point of view it would be an opaque structure
which just saves and echos back when asked.  This
would solve both problems.

> > However, now you lot have made me go away and think, I have
> > another idea on how to attack this.  Perhaps it will be
> > more palatable to you.  It would replace RTAB and STAB with
> > a 28 byte structure for most protocol stacks - well all I can
> > think of off the top of my head, anyway.  RTAB would have to
> > remain for backwards compatibility, of course.
> 
> Can you describe in more detail?

OK, but first I want to make the point that the only
reason I suggest this is to get some sort of ATM
patch into the kernel, as the current patch on the
table is having a rough time.

Alan Cox made the point earlier (if I understood him
correctly) that this tabling lookup probably isn't
a big win on modern CPU's - we may be better off
moving it all into the kernel.  Thinking about this,
I tried to come up with a way of describing the
mapping between skb->len and the on the wire packet
length for every protocol I know.  This is what I
came up with.

Assume we have a packet length L, which is to be
transported by some protocol.  For now we consider
one protocol only, ie: TCP, PPP, ATM, Ethernet or
whatever.   I will generalise it to multiple protocols
later.  I think a generalised transformation can be 
made using using 5 numbers which are applied in this
order:

  Overhead - A fixed overhead that is added to L.

  Mpu      - Minimum packet size.  If the result of
             (Overhead+L) is smaller that this, then 
             the new result becomes this size.

  Round    - The result is then rounded up to this
             many bytes.  For protocols that always
             transmit single bytes this figure would be
             1.  If there were some protocol that
             transmitted data as 4 byte chunks then this
             would be 4.  For ATM it is 48.

  CellPay  - If the packet is broken down into smaller
             packets when sent, then this is the amount
             of data that will fit into each chunk.

  CallOver - This is the additional overhead each cell
             carries.

The idea is the kernel would do this calculation on the
fly for each packet.  If you represent this set of number 
numbers as a comma separated list in the order they were 
presented above, then here are some examples:

  IP:       20
  Ethernet: 18,64
  PPP:      2
  ATM:      0,0,48,48,5

It may be that 5 numbers are a overkill.  It is for all
protocols I am aware of - for those you could get away
with 4.  But I am no expert.

The next step is to generalise for many protocols.  As
the protocols are stacked the length output by one 
protocol becoming the input length for the downstream 
one.  So we just need to apply the same transformation 
serially. I will use '+' to indicate the stacking.  For 
a typical ATM stack, PPPoE over LLC, we have:

  ppp:2+pppoe:6+ethernet:14,64+llc:8+all5:4+atm:0,0,48,48,5

If this were implemented naively, then the kernel would
have to apply the above calculation 6 times, like this:

  Protocol   InputLength    OutputLength
  ---------  ------------   ----------------
  ppp        skb->len       skb->len+2
  pppoe:     skb->len+2     skb->len+2+6
  ethernet:  skb->len+2+6   skb->len+2+6+14
  ... and so on.

But it can be optimised.  In this particular case we can
combine those six operations into 1:

  adsl_pppoe_llc:34,64,48,48,5

The five numbers have the same meaning as before.  It
it not difficult to come up with a generalised rule that
allows you to do this for most cases.  For the remainder
(if they exist - I can't think of any) the kernel would
have to apply the transformation iteratively.

Before going on, it is worth while comparing this to the
current RTAB solution (and by implication STAB):

  1.  Oddly, the number of steps and hence speed for 
      common protocols is probably the same.  Compare:
        RTAB - You have to add an OverHead in the general
               case.
             - You have to scale by cell_log.
             - You have to ensure the overhead+skb->len
               doesn't overflow / underflow the RTAB.
             - You have to do the lookup.
        New  - You have to add overhead.
             - You have to check the MPU.
             - You have to check if you have to apply
               Round,CellPay,CellOver - but you won't
               have to for any protocol except ATM.

  2.  Because of the cell_log, RTAB gives an 100% accurate
      answer 1 time in every (1<<cell_log) packet lengths.
      The new version is always 100% accurate.

  3.  The new version isn't as flexible as RTAB, as least
      from the kernels point of view.  Conceivably there are 
      protocols that could be handled by RTAB that are not 
      handled by the new one.  Since RTAB is computed in
      user space, this implies these new protocols might
      be handled by a user space change only.  The new
      version would always require a kernel change.  Note 
      however that even RTAB required a kernel change for
      ATM, however.

So far we have what your STAB would provide us with - a
way to calculate the packet length.  It takes 5 int's for 
every protocol stack I can think of.  It probably runs
faster for most protocols but is less robust to the
introduction of new protocols.

But some qdisc's need to know how long it takes to send a 
packet.  This is what RTAB provides us with, in fact.  
So if we were to do away with RTAB completely, then we need
a way for the kernel to covert packet lengths into the time
it takes to send a packet.  This is what I discuss next.
The comments apply to both STAB and the new algorithm above,
as they both compute packet lengths.

If J is the time it takes to send one byte over a link, 
then we can compute RTAB from STAB like this:

  for (int i = 0; i < array_length(STAB); i += 1)
    RTAB[i] = STAB[i] * J;

This is exactly the operation "tc" performs now in user
space.  It is possibly in user space because J is usually
less than 1, and thus is most conveniently represented as
a floating point number.  Floating point operations in
the kernel are verboten.

I can think of two ways to move this operation into the
kernel.  The straight forward way is to represent J as a 
scale and a division.  Ie the kernel does:

  RTAB[i] = (STAB[i] << scale) / divisor.

The second way depends on that fact that most CPU's can
multiply two 32 uint's to produce a 64 bit result in a
single operation.   I don't know whether this operation is
available to kernel code.  But if it is, J can be 
represented as a 32 bit fixed point number, with the
implied decimal point after the most significant 8 bits.
Then this operation would suffice:

  extern long long mul64(unsigned long, a, unsigned long b);

  RTAB[i] = (unsigned long)(mul64(STAB[i], J) >> 24);

This method doesn't use division, and is probably faster
on lower end CPU's.  It would handle 100G Ethernet on a 
machine with Hz == 1000, and 1200 bits/sec on a machine
with Hz == 10000.

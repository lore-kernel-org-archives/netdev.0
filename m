From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Mon, 13 Mar 2006 14:44:23 +1000
Message-ID: <1142225063.14909.77.camel@ras.pc.brisbane.lube>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1142082696.5184.53.camel@jzny2>
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

On Sat, 2006-03-11 at 08:11 -0500, jamal wrote: 
> > On my machine tc does not parse filter "sample" for the u32
> > filter.  Eg:
> > 
> > tc filter add dev eth2 parent 1:0 protocol ip prio 1 u32 ht 801: \ 
> >     classid 1:3 \
> >     sample ip protocol 1 0xff match ip protocol 1 0xff
> >   Illegal "sample"
> > 
> 
> The syntax is correct but ht 801: must exist - that is why it is being
> rejected.. So there is absolutely categorically _no way in hell_ your
> memset would have fixed it ;-> Apologies for being overdramatic ;->

You are wrong on both counts.

Firstly, the error message came from tc when it parsed
the line.  If tc gets an error talking to the kernel it 
says, among other things:
  "We have an error talking to the kernel"
Ergo, it hadn't given the command to the kernel yet.
This is significant, because the only place that
knows whether ht 801: has been created or not is
the kernel.  So obviously the error message can't
depend on whether the table had been created.

As it happens I did create the ht before issuing the
prior command when I first struck the bug - but I
didn't show it in my example because it was not
relevant.

As for _no way in hell_ - there are apparently more ways
in hell then you are aware of.  If you look at the 
function pack_key() in tc/f_u32.c, you will see it
assumes the "sel" parameter it is passed is initialised.
Without the added "memset()" it isn't - it just contains
random crap.  Of course on some machines (perhaps yours?)
that random crap might be 0, and then it would work.  
That is why I said at the start of my patch "On my 
machine tc does not ...".  On other machines the bug
may not appear.

> sample never worked 100% of the time with that hash. It works _most_ of
> the time with 256 buckets. Infact it will work some of the time as it is
> right now with 2.6.x. Can you post the output of tc -s filter ls on 2.6
> with and without your user space change?

Re: "sample never worked 100% of the time with that 
hash".  Can you give an example?  As far as I know it
always worked.

Re: "it will work some of the time as it is right now 
with 2.6.x".  Yes - it will work when you are sampling
one byte.   I am sampling port numbers, which are two
bytes.  It will not work in any case where there are
two non-zero bytes.

Re: "Can you post the output of tc -s filter ls on 2.6 
with and without your user space change?".  Here it is:

  With my change:
    tc qdisc add dev eth0 root handle 1: htb
    tc filter add dev eth0 parent 1:0 prio 1 protocol ip u32 ht 801: divisor 256
    tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample tcp src 0x369 0xffff match tcp src 0x0369 0xffff
    tc -s filter show dev eth0
    filter parent 1: protocol ip pref 1 u32
    filter parent 1: protocol ip pref 1 u32 fh 801: ht divisor 256
    filter parent 1: protocol ip pref 1 u32 fh 801:3:800 order 2048 key ht 801 bkt 3 flowid 1:
      match 03690000/ffff0000 at nexthdr+0
    filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1

  On the orginal "tc" shipped with debian "sarge":
    tc qdisc add dev eth0 root handle 1: htb
    tc filter add dev eth0 parent 1:0 prio 1 protocol ip u32 ht 801: divisor 256
    tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample tcp src 0x369 0xffff match tcp src 0x0369 0xffff
    Illegal "sample"
  Ooops.  Looks like I can't get out of this without patching
  and compiling:
    tc qdisc add dev eth0 root handle 1: htb
    tc filter add dev eth0 parent 1:0 prio 1 protocol ip u32 ht 801: divisor 256
    tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample tcp src 0x369 0xffff match tcp src 0x0369 0xffff
    tc -s filter show dev eth0filter parent 1: protocol ip pref 1 u32
    filter parent 1: protocol ip pref 1 u32 fh 801: ht divisor 256
    filter parent 1: protocol ip pref 1 u32 fh 801:6a:800 order 2048 key ht 801 bkt 6a flowid 1:
      match 03690000/ffff0000 at nexthdr+0
    filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1

Note: this also answers you request in your other email re:
"can you give me an example that doesn't work".

> Heres how you should fix this:
> Patch1) fix kernel 2.4.x to be like 2.6.x
> patch 2) fix iproute2 to have the same syntax as for 2.6 and put a big
> bold note in the code that if anyone changes that part of the code to
> look at the kernel u32_hash_fold() routine.
> no need for the utsname check.

Why do it that way?  If you want to put the 2.6 hashing
algorithm in 2.4 then go ahead - but that is a separate 
decision which is not related to the issue of making tc 
backwards compatible.  Making tc work with all versions of
the kernel is what I am doing there. As an example of why
this is a good idea, Debian ships 2.4 and 2.6 kernels, 
and one version of tc.  That tc should work with both 
kernels.

Finally, regarding which hashing algorithm is better,
your results differ from mine.  First a bit of 
background: I am trying make VOIP work over some 256/64 
and 512/128 links that carry all sorts of other traffic.
The patches you see here are a result of me trying to
make that work over a range of sites (companies and
home setups).  The end result is that it did work, better
than I expected it to.  On a 512/128 ADSL link, I can:

  a.  Saturate the incoming direction with a large wget,
  b.  Saturate the outgoing direction with a large wget,
  c.  Hit the incoming direction with a "while :; do
      wget http://www.google.com/ -O /dev/null; done".
  d.  Hit the outgoing direction with an external box
      doing the same while loop.

While all that is going on, I can sustain 2 VOIP calls
with perfect clarity on that link.  I wasn't expecting to
be able to pull that off.  To pull it off I created the
u32 filter from hell.  This long winded explanation is to
forestall the inevitable "why the hell you want want to do
that" flame when you see the script that follows.

You can find the shell script that creates the filter here:
  http://www.stuart.id.au/russell/files/tc/setup-traffic-control.sh
The script itself is not that important.  What is important
is that it is a real-life use of u32, and there are approx 
1200 hashed u32 filter lines.

So how to means how good a job the hash is doing.  The
easiest would seem to be to use a least squares fit, ie:
  
  Number of elements to be hashed       = E
  Number of buckets                     = B   (== 256)
  Optimal number of elements per bucket = E/B
  Hash function "goodness" metric       = M =
    sqrt(sum foreach bucket i: [ (NrOfElementsInBucket(i) - E/B)^2 ] / B)

For a good hash function M < 1.  The bigger M is the
worse the hash function is.  I wrote a python program to 
compute M for my u32 filter.  The python program can be 
found here:
  http://www.stuart.id.au/russell/files/tc/tc-ports
The dataset it operates on can be found here:
  http://www.stuart.id.au/russell/files/tc/m.py

Results:
  tcp 2.6: E=534  M=2.35
  tcp 2.4: E=534  M=0.82
  udp 2.6: E=711  M=2.91
  udp 2.4: E=711  M=0.92

As you can probably tell, I see the new hash function in 2.6
as a backward step - not an improvement.

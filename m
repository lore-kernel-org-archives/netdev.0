From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Fri, 17 Mar 2006 09:24:41 +1000
Message-ID: <1142551481.17608.589.camel@ras.pc.brisbane.lube>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
	<1142225063.14909.77.camel@ras.pc.brisbane.lube>
	<1142269090.5242.29.camel@jzny2> <4415B217.30507@trash.net>
	<20060313100421.7df7f9ed@localhost.localdomain>
	<1142286237.17608.7.camel@ras.pc.brisbane.lube>
	<20060313135048.27b09fba@localhost.localdomain>
	<1142296295.17608.112.camel@ras.pc.brisbane.lube>
	<1142303082.5219.16.camel@jzny2>
	<1142306212.17608.178.camel@ras.pc.brisbane.lube>
	<1142307572.5219.73.camel@jzny2>
	<1142312708.17608.270.camel@ras.pc.brisbane.lube>
	<1142436098.5346.3.camel@jzny2>
	<1142470323.17608.341.camel@ras.pc.brisbane.lube>
	<1142472481.5417.20.camel@jzny2>
	<1142476647.17608.394.camel@ras.pc.brisbane.lube>
	<1142478478.5417.46.camel@jzny2>
	<1142488027.17608.485.camel@ras.pc.brisbane.lube>
	<1142517116.5417.137.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1142517116.5417.137.camel@jzny2>
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

On Thu, 2006-03-16 at 08:51 -0500, jamal wrote:
> > BTW, in this example, the new hash I suggested would be as good 
> > as the 2.6 case.
> > 
> 
> Yes, if you used 256 buckets per hash table ;->

No - you haven't understood what the new algorithm does.
It will get the same performance of the 2.6 version with
the same memory.  In fact for all cases where the number
of bits used is <= 8, ie is _identical_ to the 2.6
algorithm.

> Wait till you start getting into V6. Or try

It is odd that you keep mention IPv6.  The IPv6 header
has no fields that are less that 8 bits, and there are
none that are not aligned on a 8 bit boundary.  In fact 
even within the IPv6 addresses, there are no sub-fields 
less that 8 bits.  It would be a happy hunting ground for
the 2.4 algorithm.

> building an effective fast lookup scheme for a five tuple lookup using
> u32; five tuples being {src/dst IP, IP protocol, src/dst port}
> So in simple setups where you say dont exceed a few hundred hash tables,
> and a few hundred to thousand filters, the old hash was fine.

> > Now lets take the case that we hashing a number of bytes with
> > a 256 divisor (my case).  If these bytes contain truly random 
> > values, then again 2.4 and 2.6 will be the same.  
> 
> But they are not.

Well, this is the crux of the matter, isn't it?  You are
apparently used to looking up well known patterns - probably
ones you determine. As such, you can arrange these in nice
logical ranges.

Guess what?  The very thing that started this off was me
looking up TCP & UDP port numbers.  I didn't determine those
port numbers.  They are all over the shop - for me they are
effectively random data.  And they are sparse too, as in
they occupy 16 bits.  The whole point of the rant that
followed was to explain to you why in a case like that the
2.6 hash runs substantially slower that the 2.4 one.  Whats
more, it can't be fixed by simply trading off more memory.

But you seem to be burying you head in the sand and saying
"such data sets don't exist".  Well they do.  And I gave
you a real life one.

Here is another one: I have contemplated at times giving
priority to Australian traffic.  So I went and found myself
a list of Australian IP addresses.  Being allocated by some
central authority, I expected some nice ordered data set.
How naive.  There are some 400 subnets, and after trying
to find some pattern I gave up after an hour.  Another
random dataset.  The 2.4 algorithm will handle that well.

When you changed the hash algorithm, you optimised it for
your particular world - at the expense of people who have 
data sets like mime.  Note that users of 2.4 with your
dataset have a way out - waste a bit of memory and it will
run just as fast.  With a large dataset and 2.6 there is 
no way out.  You are probably doubting this as you are it -
I explain why below.

> > The 2.4 XOR's
> > the two values together.  XOR has the property that it "adds"
> > the randomness of the bits together, unless they are correlated.
> > So if you take two partially random bits, and XOR them together,
> > then the resulting bit will be more random that the original two
> > bits.  An illustration of this from crypto is a stream cypher 
> > like rc4.  rc4 effectively produces a random stream of bits.
> > To use rc4, you XOR your plain text with this random stream.
> > Even though your plain text is highly non-random, the cypher
> > text is at least as random as the rc4 stream - and thus looks
> > like gibberish.  Anyway, the end result for 2.4 is that if you
> > XOR two perfectly random bytes, the result is a perfectly random
> > byte.  So for random data 2.6 and 2.4 are the same.
> > 
> 
> To use a term which makes sense up here, you are treading on thin ice
> now ;->  You dont wanna skate on this river ;->
> 
> Randomness has nothing to do with this. It doesnt matter whether
> random traffic patterns arrive at all. 
> - assume that in 8 bits of data, 6 bits provide the most entropy.
> - assume 256 hosts (just to cover the range of the 8 bits)
> 
> a) If i built a hash table with 256 buckets, i can guarantee that
> i will find any host using either scheme in 4 lookups.
> Except 75% of the buckets will not be used by either.

You miss one point.  While you can guarantee it will
happen in 4 lookups, 2.4 averages slightly more than
1 lookup it if hashes the entire value in one hit.
In 2.6, you are stuck with your 4 lookups, as you say.

> b) If i built a hash table with 128 buckets, I can guarantee i will
> find any host in 4 lookups with the new scheme but it will take
> a best case of 8 lookups with the old scheme.
> Except 50% of the buckets will not be used by the new scheme and
> 75% not be used by the old scheme.
> 
> c) if i built a hash table with 64 buckets, I can guarantee that i will
> find any host in 4 lookups with the new scheme and 16 in the old scheme.
> 100% of the buckets will be used by the new scheme; only 25% will be
> used by the old scheme.
> 
> d) If i built a hash table of 32 buckets, I can guarantee that i will
> find any host in 8 lookups with new scheme and _32_ with old.
> 100% used by the new scheme and 25% by old
> 
> See the pattern? But this is not the worst part. The nasty part
> is if i built a newer level of hash tables so i can reduce the lookups,
> it totally reduces my effectiveness; i need to figure out which buckets
> are being hit etc.

The pattern is based on the (unstated) premise that you
are dropping the least significant bits in the byte in
your hashing function.  Perhaps you are assuming you know
where these random bits live in the address.  I wasn't
so lucky with my dataset.  However lets go with the original
premise - the data is truly random, and you don't know
where bits are.  When you drop the least significant bits 
2.4 behaves badly.  But since the data is random, you are 
better off dropping the upper bits when using 2.4.  If 
you do that then the 2.4 and 2.6 hashes perform 
identically when used as you describe above.

In other words, the example didn't show what you intended 
it to show.  It showed that if you do the optimal thing 
for 2.6 and use a tree of hash tables then 2.4 and 2.6 can 
be made to perform identically.  If you do the optimal 
thing for 2.4, then on average 2.4 can be made to run 
almost 4 times faster than 2.6, on average.

> You have not convinced me that, in the case of multibyte, the old one is
> good for anything other than the one example you had with a fixed mask
> and fixed number of buckets.  
> I hope you see the value of varying the parameters i mentioned now (it
> should be very clear on the hash bucket count and mask i hope).
> Sorry, but a lot more work is needed and you seem to be in a rush to get
> there ;->

As you can probably gather, all we seem to of done here
is concluded that there are two sorts of data sets -
those that are nicely behaved like yours, and those that
aren't - like mine.  You seem to be denying mine exist,
which is a pity.  2.6 works well for yours.  2.4 works
well for mine.

Judging from these initial comments:

  russell: BTW, in this example, the new hash I suggested 
           would be as good as the 2.6 case.
  jamal:   Yes, if you used 256 buckets per hash table.

I don't seem to have explained the new algorithm very well.
Let me try again.  There is nothing inherently new about 
it.  It is just a combination of Alexy's 2.4 algorithm, 
and your 2.6 version:

  2.4 Algorithm:           2.6 algorithm:       New Algorithm:
  --------------           --------------       --------------
  hash = (hash>>16)^hash;  hash = hash>>shift;  hash = hash>>shift;
  hash = (hash>>8)^hash;   return hash & 0xff;  hash = (hash>>16)^hash;
  return hash & 0xff;                           hash = (hash>>8)^hash;
						return hash & 0xff;

How the new one performs:

(a) For all fields <= 8 bits, it is identical to 2.6.

(b) For all fields aligned on a 8 bit boundary, it is
    identical to 2.4.

(c) Importantly, on a single 8 bit aligned value, it is
    identical to 2.4 and 2.6: it is the identity function.
    This keeps the cut & pasters happy.

Now everyone wins: those with nice orderly datasets like 
yours, and those with sparse, random data sets like mine.  
Why not change over to it?

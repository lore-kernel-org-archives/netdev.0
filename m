From: Michal Soltys <soltys@ziu.info>
Subject: Re: More understanding HFSC
Date: Mon, 05 Dec 2011 23:18:26 +0100
Message-ID: <4EDD4332.7090109@ziu.info>
References: <1322979139.3347.147.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:2614 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932377Ab1LEWSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 17:18:30 -0500
In-Reply-To: <1322979139.3347.147.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-04 07:12, John A. Sullivan III wrote:
> To try to understand more about HFSC, I've tried to map out a real
> world scenario and how we'd handle it.  My apologies in advance for a
> consequently long email :(
> 
> As others have pointed out, we immediately noticed that
> http://trash.net/~kaber/hfsc/SIGCOM97.pdf 

For the paper, use: http://www.cs.cmu.edu/~istoica/hfsc-tr.ps.gz
or
http://www.cs.cmu.edu/~istoica/hfsc_extended.ps.gz

More detailed, with correct sub/superscripts. You might need to treat
it first with:

sed "s|\[FontBBox\]|/FontBBox load |"

as it was generated with a little bit old (ancient) idraw version.

> seems to speak of sc and ul whereas the Linux implementation adds rt
> and ls.  Is it correct to assume that this is because the Linux
> implementation foresaw instances where one might not want the sharing
> ratio of available bandwidth to be the same as the ratio of guaranteed
> bandwidth?

The paper talks only about LS and RT curves, which (in context of the
example implementation) were assumed to be the same (meaning, not
literally 1 curve - two separate ones, but defined in identical way).

The actual altq implementation (initially ported to Linux ~2003) allows
them to be specified separately, and adds an UL curve which is used to
limit LS. It also allows specifying leaf classes with only one kind of
the curve.

In a nutshell, RT's role is to guarantee certain bandwidth and latency
(within limits of what the cpu and whole network path can deliver), LS's
role is to distribute remaining bandwidth, and UL's role is to make sure
LS doesn't send too fast (or in more exotic case, to make sure that some
subtrees never get more bandwidth than some predetermined value due to
some policies). UL is ... ugly thing working a bit against LS, but it's
necessary to shape properly for speeds other than interface's native
speed (which is almost always the case).

> I'm guessing a practical illustration would be a bulk class where I
> have low rt just to keep the class from being starved but want it to
> obtain available bandwidth more aggressively.  Is that correct?

Hmmmm ... The class will never be starved in HFSC (if things are setup
correctly). It's more about non-linearity and using real clock for RT
case. LS is just simple arbitrator - go down the tree, selecting
smallest virtual times. RT ignores tree hierarchy completely, and
chooses a set of all eligible leaf classes, and from those the one with
smallest deadline time. Due to non-linearity, it has to use two curves
(eligible and deadline) to achieve its endes. It's all detailed in the
paper and man pages, though not necessarily an easy chunk to read.

> So trying to put the four possible parameters together,

Four ? LS, RT, UL. Unless you also mean RT's split in to eligible and
deadline parts.

> it sounds like ul is normally used to specify the maximum link speed
> and can be specified at the root, no, next child from root class and
> then flow down to all descendants without being explicitly specified?

UL set for some node is only applicable to that node. It prohibits that
node (and implicitly, its whole subtree - so in this context you can
think of it as "flowing down") from participating in LS. But only LS.

> But one can also give a class an explicit ul if one wants to limit the
> amount of bandwidth a leaf or branch can consume when sharing
> available bandwidth?

+/- yes. Keep in mind, that RT is independent from LS (and UL will not
block it in any way), but it still updates cumulative total amount of
service a class received, so it implicitly influences virtual times used
by LS.

> sc would be used where rt=ls?

yes (2 identical curves used for 2 different things)

> ls is used solely to determine ratios of sharing available bandwidth
> between peers, does not need to aggregate to<= ul but normally does by
> convention?

Only ratio, yes. Actual values are irrelevant for LS (only). 2 linear
curves with 10kbit slopes will have the same effect like 100kbit ones.

But, like mentioned above, UL so-to-speak decides whenever a class (and
its subtree, implicitly) is "eligible" to participate in LS, so its
subtree will never push more than UL using LS criterion.

> rt only applies to leaves and is the guaranteed bandwidth and must
> aggregate to<= ul if all guarantees are to be honored?

Only leafs, yes.

RT completely ignores LS[+UL] though.

> Very important for my understanding, specifying rt and ls in the same
> class is NOT the mechanism used for decoupling latency guarantees from
> bandwidth allocations.  That is simply specifying that available
> bandwidth will be obtained in a different proportion than the
> guaranteed bandwidth.

yes

> The decoupling of latency from bandwidth happens by having a dilinear
> service curve, i.e., specifying either m1, d, and m2 or specifying
> umax, dmax, and rate where umax/dmax != rate.  Is that correct?

yes

> So, it then seems like: virtual time is dependent upon ls

yes

> eligible time is dependent upon available bandwidth as determined by
> ul and ls

no, eligible curve is derived from RT curve. For linear and concave
curves it's the same as RT curve. For convex RT - eligible curve is
linear using RT's second slope. The time calculated from it is relative
to packets' heads - essentially answering question: which packets should
be in transit already by current time (and for convex - which should be
sent earlier, so when the curve is violated later by some other
class(es), everything remains fine with reference to the amount of
service received by some time). RT ignores LS/UL.

> deadline time is dependent on the curve which is why a dilinear curve
> can be used to "jump the queue" so to speak or to drop back in the
> queue.

deadline curve is also derived from RT curve, and it's always of the
same parameters. But packets tails are used here - essentialy answering
question: what packet should go first (as only 1 can be send at a time
after all). No relevance to LS/UL in any way or form either.

So more correct way to say is: RT *is* deadline and eligible.

> This raises an interesting question about dilinear curves and ul. If
> m1 is being used to "jump the queue" and not to determine guaranteed
> bandwidth, do we need to take into account the resultant bandwidth
> calculation of m1 when ensuring rt<= ul? To illustrate, let's say we
> have a 100kbits link.  We give interactive traffic 40kbits, VoIP
> 20kbits, and bulk 40kbits so rt = ul.  However, we specify interactive
> as rt 1534b 10ms 40kbits and VoiP as rt 254b 10ms 20kbits.  puts us
> way over ul (~= 400kbits + 200kbits + 40kbits). Is this OK since it
> is not actually the guaranteed bandwidth but just the data used to
> calculate deadline? I am guessing that if we are in the situation
> where packets simply cannot be transmitted fast enough to meet the
> requested deadline that this implies we do not have sufficient
> eligible time and so deadline becomes moot.

1534b/10ms is roughly 1.2mbit rate. So you effectively defined (~1.2mbit
for 10ms, then 40kbit) and (~200kbit for 10ms, then 20kbit). HFSC will
of course schedule this - and such approach to keep certain class
favored on fresh backlog pariod is ok, but keep in mind the side effects
(there're example in man pages mentioned in previous reply):

- any excess like that contributes to total service => influences
  virtual times. the class will have to pay for that during LS
- LS main point is to keep all virtual times as equal as possible; if
  they drift apart that means something is wrong. It's not a big deal
  (or not a deal at all, if user knows what he wants and what he's
  doing) during m1, but might have disastrous effects during m2 (on
  other sibling classes in particular)
- in your example, LS is unusable, as there's always something eligible
  by RT; even if your interface's native speed is 10gbit, RT will cover
  100kbit of the real uplink, and UL will block any LS attempts.

Interesting point is, that some other OSes (BSDs using pf) try to pamper
the user, and won't even let you specify RT going beyond LS, or sum(RTs)
going beyond 80% of interface's speed (iirc). It's bad approach
(limiting legitimate tricks/uses), but certainly a way to avoid misuse
... 

> [cut]

later, though you might want to update the questions first by now :)

From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: 07 Aug 2003 15:58:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060286331.1025.73.camel@jzny.localdomain>
References: <200307141045.40999.nf@hipac.org>
	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org>
	 <1059934468.1103.41.camel@jzny.localdomain>  <3F2E5CD6.4030500@hipac.org>
	 <1060012260.1103.380.camel@jzny.localdomain>  <3F302E04.1090503@hipac.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
In-Reply-To: <3F302E04.1090503@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

On Tue, 2003-08-05 at 18:21, Michael Bellion and Thomas Heinz wrote:
> Hi Jamal
> 
> You wrote:
> > I promise i will. I dont think i will do it justice spending 5 minutes
> > on it. I take it you have written extensive docs too ;->
> 
> Of course ;-)
> Well, actually we are going to present an overview of the hipac
> algorithm at the netfilter developer workshop in Budapest.
> Hope to see you there.
> 

Unfortunately due to economical reasons i wont be able to make it. I
mentioned it to LaForge.

> > Unfortunately it is more exciting to write code than documents. I almost
> > got someone to document at least its proper usage but they backed away
> > at the last minute.
> 
> lol
> 

It was very close ;-> The guy looked motivated i felt scared for a while
that he will be asking a lot of questions. Then i never heard about it
again ;-> I think he left town too. 

> Yes, it does. Still the question is how to solve this
> generally. Consider the following example ruleset:
> 
> 1) src ip 10.0.0.0/30 dst ip 20.0.0.0/20
> 2) src ip 10.0.0.0/28 dst ip 20.0.0.0/22
> 3) src ip 10.0.0.0/26 dst ip 20.0.0.0/24
> 4) src ip 10.0.0.0/24 dst ip 20.0.0.0/26
> 5) src ip 10.0.0.0/22 dst ip 20.0.0.0/28
> 6) src ip 10.0.0.0/20 dst ip 20.0.0.0/30
> 
> So you have 1 src ip hash and #buckets(src ip hash) many
> dst ip hashes. In order to achieve maximum performance
> you have to minimize the number of collisions in the
> hash buckets. How would you choose the hash function
> and what would the construction look like?
> 

It can be done by using the masks - but it would look really ugly. I
suppose just providing a good user interface is valuable.

> In principle the tree of hashes approach is capable to
> express a general access list like ruleset, i.e. a set
> of terminal rules with different priorities. The problem
> is that the approach is only efficient if the number of
> collisions is O(1) -> no amortized analysis but rather
> per bucket.
> 

true.

> In theory you can do the following. Let's consider one
> dimension. The matches in one dimension form a set of
> elementary intervals which are overlapped by certain rules.
> Example:
> 
>           |------|                      |---------|
>       |----------------|
>              |------------------|
>                            |---------------|
> 
> |----|---|--|---|-----|---|----|-------|--|------|-------|
> 
> The '|-----|' reflect the matches and the bottom line
> represents the set of elementary intervals introduced
> by the matches. Now, you can decide for each elementary
> interval which rule matches since the rules are terminal
> and uniquely prioritized.
> 

right. Why do you refer to this as one dimension?

> The next step would be to create a hash with #elementary
> intervals many buckets and create a hash function which
> maps the keys to the appropriate buckets like in the picture.
> In this case you have exactly 1 entry per hash bucket.
> Sounds fine BUT it is not possible to generically deduce
> an easily (= fast) computable hash function with the
> described requirements.
> 

nod.

> BTW, this approach can be extended to 2 or more dimensions
> where the hash function for each hash has to meet the
> requirement. Of course this information is not very helpful
> since the problem of defining appropriate hash functions
> remains ;)
> 

Is that problem even solvable?

> Obviously this way is not viable but supposedly the only
> one to achieve ultimate performance with the tree of hashes
> concept.
> 
> BTW, the way hipac works is basically not so different
> from the idea described above but since we use efficient
> btrees we don't have to define hash functions.
> 

This is why i was wondering how fast your instertions and deletions are.
Seems to me you will have to sort the rules everytime.

> > sure position could be used as a priority. It is easier/intuitive to
> > just have explicit priorities.
> 
> Merely a matter of taste. The way iptables and nf-hipac use
> priorities is somewhat more dynamic than the tc way because
> they are automatically adjusted if a rule is inserted in between
> others.
> 

Dont you think this "dynamic adjustment" is unnecessary. Essentially you
enforce a model where every rule is a different priority.

> > What "optimizes" could be a user interface or the thread i was talking
> > about earlier.
> 
> Hm, this rebalancing is not clear to us. Do you want to rebalance
> the tree of hashes? This seems a little strange at the first
> glance because the performance of the tree of hashes is dominated
> by the number of collisions that need to be resolved and
> not the depth of the tree.
> 

The general idea is to recreate the tree if need be based on colisions.
I just hope some idiot reading this doesnt go and patent it(has happened
before). Think of it as dynamic hash adjustment. Talk to me in private
if you are really interested.

> > Is your plan to put this in other places other than Linux?
> 
> Currently we are working on the integration in linux.
> In general the hipac core is OS and application independent,
> so basically it could also be used for some userspace program
> which is related to classification and of course in other OS's.
> 
> Any special reason why you are asking this question?
> 

I was wondering why not just optimize it for Linux. You are trying to
center the world around nf-hipac - I would just center it around 
Linux ;->

> > So you got this thought from iptables and took it to the next level?
> 
> Well, in order to support iptables matches and targets we had
> to create an appropriate abstraction for them on the hipac
> layer. This abstraction can also be used for tc classifiers
> if the tcf_result is ignored, i.e. you just consider whether
> the filter matched or not.
> 

I am not sure i understood the part about ignoring tcf_result.

> > I am still not sure i understand why not use what already exists - but
> > i'll just say i dont see it right now.
> 
> If hipac had no support for embedded classifiers you couldn't
> express a ruleset like:
> 1) [native hipac matches] [u32 filter] [classid]
> 2) [native hipac matches] [classid]
> You would have to construct rule 1) in a way that it "jumps"
> to an external u32 filter. Unfortunately, you cannot jump
> back to the hipac filter again in case the u32 filter does
> not match so rule 2) is unreachable. This problem is caused
> by the fact that cls_hipac can occur at most once per interface.
> 

You show only one classid per rule .. I think i can see what you meant
by ignoring tcf_result - essentially you want to have a series of filter
rules with different classification enngines, no? But could you not have
the filters repeat the same classid for every filter? 
Also it seems you want to be able to have an action defined for
"nomatch" as well as "match" - is that correct? Some form of
reclassification when nomatch ?

cheers,
jamal

From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Tue, 12 Aug 2003 00:39:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F381B3E.6080807@hipac.org>
References: <200307141045.40999.nf@hipac.org>	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org>	 <1059934468.1103.41.camel@jzny.localdomain>  <3F2E5CD6.4030500@hipac.org>	 <1060012260.1103.380.camel@jzny.localdomain>  <3F302E04.1090503@hipac.org> <1060286331.1025.73.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD08EFA7D1F7173B3DB5092FE"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060286331.1025.73.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD08EFA7D1F7173B3DB5092FE
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jamal

Sorry for the late reply.

You wrote:
> Unfortunately due to economical reasons i wont be able to make it. I
> mentioned it to LaForge.

It's a pity. Anyway, we should keep in touch to discuss the
future directions of hipac, tc and stuff. We are going to
post the new hipac design as soon as it is sufficiently
elaborated.

> It was very close ;-> The guy looked motivated i felt scared for a while
> that he will be asking a lot of questions. Then i never heard about it
> again ;-> I think he left town too. 

Too bad, you should have told the guy about all the fame
and glory ;-)

>>Yes, it does. Still the question is how to solve this
>>generally. Consider the following example ruleset:
>>
>>1) src ip 10.0.0.0/30 dst ip 20.0.0.0/20
>>2) src ip 10.0.0.0/28 dst ip 20.0.0.0/22
>>3) src ip 10.0.0.0/26 dst ip 20.0.0.0/24
>>4) src ip 10.0.0.0/24 dst ip 20.0.0.0/26
>>5) src ip 10.0.0.0/22 dst ip 20.0.0.0/28
>>6) src ip 10.0.0.0/20 dst ip 20.0.0.0/30
> 
> It can be done by using the masks - but it would look really ugly. I
> suppose just providing a good user interface is valuable.

Well, let's discuss the problem in a more general way. First of
all we should clearly agree on the goal. For simplicity we focus
on the 1 dimensional case (e.g. src ip, see also next paragraph
for a explanation of the term "dimension" in that context) and we
allow only prefixes (no general masks).

Problem: We are given an access list of n 1-dimensional prefix rules,
          i.e. (v_1/p_1, ..., v_n/p_n) where v_i is the value
          (e.g. src ip) and p_1 is the length of the prefix.
          [The target of the rules can be ignored since it is
           irrelevant for the considerations.]
          The priority of each rule is determined by its position
          in the tuple (-> smaller value means higher priority).
          Furthermore we assume: p_i >= p_j for all i <= j to avoid
          never matching rules.
          Now, we want to construct a hash with m = O(n) buckets
          where each bucket contains O(1) rules. Therefore we need
          to find a prefix length PREF and a hash function HASH
          where given a key k the number of the bucket is computed
          via: HASH(k & ~(~0 >> PREF))

Let's take a look at the elementary intervals (see our last e-mail)
created by the ruleset. There are at most 2 * n + 1 elementary
intervals and each interval can be described in the form of a
prefix: eval/epref where eval is the value and epref the length of
the prefix.

 From the description above we know that p_1 =: p_max is the maximal
prefix length and p_n := p_min is the minimal prefix length of the
ruleset. We can conclude that epref_min >= p_min and epref_max = p_max
where epref_min is the minimal prefix length of all elementary
intervals (epref_max analog).

Now to the main question: How to choose PREF? Obviously, we would
choose it such that epref_min <= PREF <= epref_max.
Well, here we are in trouble because if you choose PREF < epref_max
the number of elements per bucket is in the worst case:
  Sum[i := 1 to epref_max - PREF] min(2^(PREF + i), count(PREF + i))
  where count(j) := number of rules with prefix length j

So, we have to choose PREF very close to epref_max or even epref_max
if we want to have O(1) rules per bucket. Unfortunately, if we're
doing this we run into another problem. Assume PREF = epref_max.
Since we allow O(n) buckets we can assign all rules with prefix length
PREF to separate buckets -> no collisions. But what about
the remaining rules with prefix lengths < PREF? Those prefixes
are distributed over multiple buckets which breaks the O(1)
requirement for buckets. The reason is as follows.
We know that each of the remaining n - count(PREF) rules terminate
in at least 1 elementary interval. The elementary interval of a
rule with prefix length p contains at most 2^p keys. It is distributed
over 2^(PREF - p) buckets (at most).
Therefore we have at most:
      N := Sum[i := p_min to PREF - 1] count(i) * 2^(PREF - i)
rules in all buckets, that is N / O(n) (> O(1)) rules per bucket.

This estimation is rather rough but it clearly shows that choosing
PREF near to epref_max breaks the O(1) requirement for buckets.

This is a fundamental issue related to the use of hashes in this
context. It shows that it is _impossible_ to create a hash which
meets the requirement of O(1) rules per bucket in the setting
described above regardless how clever you choose the hash function.

What do you think about it? Do you agree?

>>In theory you can do the following. Let's consider one
>>dimension. The matches in one dimension form a set of
>>elementary intervals which are overlapped by certain rules.
>>
>> [snipped]
> 
> right. Why do you refer to this as one dimension?

The term 'dimension' is related to the PCP (packet
classification problem):
Given a d-dimensional universe {i | 0 <= i < U}^d,
       a set of n rules {r_1, ..., r_n} where
         r_i = (cost, ([a_1, b_1], ..., [a_d, b_d]))
         with 0 <= a_i <= b_i < U
   and a packet (p_1, ..., p_d) where 0 <= p_i < U
one has to find the least cost rule matching the packet.
[The cost values must be unique per ruleset]

Translated to real world packet classification a dimension
is for example src ip, dst ip, proto, src port, dst port etc.

>>BTW, this approach can be extended to 2 or more dimensions
>>where the hash function for each hash has to meet the
>>requirement. Of course this information is not very helpful
>>since the problem of defining appropriate hash functions
>>remains ;)
> 
> Is that problem even solvable?

Well, one could argue that the _problem_ is not precisely
defined to answer this question since "easily (= fast)
computable hash function" is rather spongy.

Ignoring the "fast computable" requirement, the problem
is solvable simply because the hash function is finite ...
but again this does not help a bit ;-)

So, do you agree that it is _impossible_ to express arbitrary
access lists using the hash tree approach if each hash bucket
is required to hold O(1) rules?
[You already agreed that this requirement is needed for the
  tree of hashes to perform optimally.]

> This is why i was wondering how fast your instertions and deletions are.
> Seems to me you will have to sort the rules everytime.

No, there is no sorting of rules involved. Each rule insert
operation inserts the native matches of the rule into the
(dim)tree.

> Dont you think this "dynamic adjustment" is unnecessary. Essentially you
> enforce a model where every rule is a different priority.

Well, we consider the model beneficial for the user.
First of all the requirement is also present in the
classical PCP definition ;) and secondly it supports
dynamic rulesets better because using static priorities
you ran into the problem of redefining a lot of prios
manually sooner or later.

> The general idea is to recreate the tree if need be based on colisions.
> I just hope some idiot reading this doesnt go and patent it(has happened
> before).

Well, this would be bad of course although it shouldn't be
possible to reverse engineer the algorithm from your
descrition ;)

> I was wondering why not just optimize it for Linux. You are trying to
> center the world around nf-hipac - I would just center it around 
> Linux ;->

LOL, this is _really_ funny :-))
In fact, we just try to be as general as possible without
degrading performance. So far, everything integrates fine
into Linux. Although the nf-hipac patch is rather large
(530 KB), only 205 lines of code have to be added to existing
kernel files.

>>Well, in order to support iptables matches and targets we had
>>to create an appropriate abstraction for them on the hipac
>>layer. This abstraction can also be used for tc classifiers
>>if the tcf_result is ignored, i.e. you just consider whether
>>the filter matched or not.
> 
> I am not sure i understood the part about ignoring tcf_result.

If there would be no tcf_result then classifiers are
simply matches, e.g. like iptables matches. They don't have
an action associated with them. In iptables, from a technical
viewpoint you could say that a target is basically the same
as a match with an action attached to it.

> You show only one classid per rule .. I think i can see what you meant
> by ignoring tcf_result - essentially you want to have a series of filter
> rules with different classification enngines, no?

Hm, rather one rule with several classifiers and native matches.

> But could you not have
> the filters repeat the same classid for every filter? 

Each rule can only have one action or return "value"
attached to it so if we want to use embedded classifiers
(as matches) their classid (= action) must be ignored.
The reason why we want to have several non-native
matches in one rule is to allow the expression of a
conjunction of these matches. This is not possible using
several rules.

> Also it seems you want to be able to have an action defined for
> "nomatch" as well as "match" - is that correct? Some form of
> reclassification when nomatch ?

No, we don't want special actions defined for "match" or
"nomatch". The action for a rule is already given by
its classid.


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
|    High Performance Packet Classification    |
|       nf-hipac: http://www.hipac.org/        |
+----------------------------------------------+

--------------enigD08EFA7D1F7173B3DB5092FE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Using GnuPG with Debian - http://enigmail.mozdev.org

iD8DBQE/OBs/tXh2AYIMjggRAsjjAKCcZ7c2qKN3Boum8QSp6D6EQs602wCgiJwu
1xa1kcx7Mkq+OmVtgNsDNeI=
=cVmV
-----END PGP SIGNATURE-----

--------------enigD08EFA7D1F7173B3DB5092FE--

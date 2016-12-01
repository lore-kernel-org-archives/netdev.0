From: Tom Herbert <tom@herbertland.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 13:51:32 -0800
Message-ID: <CALx6S34+Brx-JERLhexxv9CGE9moH_Pi-H_OK=hQ-iJ2g2yYgg@mail.gmail.com>
References: <20161201091108.GF26507@breakpoint.cc> <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain> <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com> <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36445 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758393AbcLAVve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 16:51:34 -0500
Received: by mail-qt0-f196.google.com with SMTP id n34so25327036qtb.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 13:51:34 -0800 (PST)
In-Reply-To: <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 1:27 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 01.12.2016 22:12, Tom Herbert wrote:
>> On Thu, Dec 1, 2016 at 12:44 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>> Hello,
>>>
>>> this is a good conversation and I simply want to bring my worries
>>> across. I don't have good solutions for the problems XDP tries to solve
>>> but I fear we could get caught up in maintenance problems in the long
>>> term given the ideas floating around on how to evolve XDP currently.
>>>
>>> On 01.12.2016 17:28, Thomas Graf wrote:
>>>> On 12/01/16 at 04:52pm, Hannes Frederic Sowa wrote:
>>>>> First of all, this is a rant targeted at XDP and not at eBPF as a whole.
>>>>> XDP manipulates packets at free will and thus all security guarantees
>>>>> are off as well as in any user space solution.
>>>>>
>>>>> Secondly user space provides policy, acl, more controlled memory
>>>>> protection, restartability and better debugability. If I had multi
>>>>> tenant workloads I would definitely put more complex "business/acl"
>>>>> logic into user space, so I can make use of LSM and other features to
>>>>> especially prevent a network facing service to attack the tenants. If
>>>>> stuff gets put into the kernel you run user controlled code in the
>>>>> kernel exposing a much bigger attack vector.
>>>>>
>>>>> What use case do you see in XDP specifically e.g. for container networking?
>>>>
>>>> DDOS mitigation to protect distributed applications in large clusters.
>>>> Relying on CDN works to protect API gateways and frontends (as long as
>>>> they don't throw you out of their network) but offers no protection
>>>> beyond that, e.g. a noisy/hostile neighbour. Doing this at the server
>>>> level and allowing the mitigation capability to scale up with the number
>>>> of servers is natural and cheap.
>>>
>>> So far we e.g. always considered L2 attacks a problem of the network
>>> admin to correctly protect the environment. Are you talking about
>>> protecting the L3 data plane? Are there custom proprietary protocols in
>>> place which need custom protocol parsers that need involvement of the
>>> kernel before it could verify the packet?
>>>
>>> In the past we tried to protect the L3 data plane as good as we can in
>>> Linux to allow the plain old server admin to set an IP address on an
>>> interface and install whatever software in user space. We try not only
>>> to protect it but also try to achieve fairness by adding a lot of
>>> counters everywhere. Are protections missing right now or are we talking
>>> about better performance?
>>>
>> The technical plenary at last IETF on Seoul a couple of weeks ago was
>> exclusively focussed on DDOS in light of the recent attack against
>> Dyn. There were speakers form Cloudflare and Dyn. The Cloudflare
>> presentation by Nick Sullivan
>> (https://www.ietf.org/proceedings/97/slides/slides-97-ietf-sessb-how-to-stay-online-harsh-realities-of-operating-in-a-hostile-network-nick-sullivan-01.pdf)
>> alluded to some implementation of DDOS mitigation. In particular, on
>> slide 6 Nick gave some numbers for drop rates in DDOS. The "kernel"
>> numbers he gave we're based in iptables+BPF and that was a whole
>> 1.2Mpps-- somehow that seems ridiculously to me (I said so at the mic
>> and that's also when I introduced XDP to whole IETF :-) ). If that's
>> the best we can do the Internet is in a world hurt. DDOS mitigation
>> alone is probably a sufficient motivation to look at XDP. We need
>> something that drops bad packets as quickly as possible when under
>> attack, we need this to be integrated into the stack, we need it to be
>> programmable to deal with the increasing savvy of attackers, and we
>> don't want to be forced to be dependent on HW solutions. This is why
>> we created XDP!
>
> I totally understand that. But in my reply to David in this thread I
> mentioned DNS apex processing as being problematic which is actually
> being referred in your linked slide deck on page 9 ("What do floods look
> like") and the problematic of parsing DNS packets in XDP due to string
> processing and looping inside eBPF.
>
I agree that eBPF is not going to be sufficient from everything we'll
want to do. Undoubtably, we'll continue see new addition of more
helpers to assist in processing, but at some point we will want a to
load a kernel module that handles more complex processing and insert
it at the XDP callout. Nothing in the design of XDP precludes doing
that and I have already posted the patches to generalize the XDP
callout for that. Taking either of these routes has tradeoffs, but
regardless of whether this is BPF or module code, the principles of
XDP and its value to help solve some class of problems remains.

 Tom

> Not to mention the fact that you might have to deal with fragments in
> the Internet. Some DOS mitigations were already abused to generate
> blackholes for other users. Filtering such stuff is quite complicated.
>
> I argued also under the aspect of what Thomas said, that the outside
> world of the cluster is already protected by a CDN.
>
> Bye,
> Hannes
>

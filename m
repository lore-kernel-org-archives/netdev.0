From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: arp_filter and IPv6 ND
Date: Fri, 2 Dec 2016 17:45:00 +0100
Message-ID: <cead0544-5a5b-ccd0-e02d-abb44a41c054@stressinduktion.org>
References: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
 <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
 <CAAeewD_2tfNHhWmtwXb_28DicmipReimRvGqv1Q6PQ0AjkBPGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Saku Ytti <saku@ytti.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39472 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754997AbcLBQpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 11:45:09 -0500
In-Reply-To: <CAAeewD_2tfNHhWmtwXb_28DicmipReimRvGqv1Q6PQ0AjkBPGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 02.12.2016 16:42, Saku Ytti wrote:
> On 2 December 2016 at 16:08, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> 
> Hey,
> 
>> May I ask why you want to turn it off?
> 
> Certainly. I don't want device to answer with link address for L3
> address it does not have on the link. In my case it triggers this bug
> https://supportforums.cisco.com/document/12098096/cscse46790-cef-prefers-arp-adjacency-over-rib-next-hop

Okay, that should not happen.

Redirects and neighbor advertisements are the only way how you can
announce prefixes on-link. Unfortunately historically we automatically
add device routes for prefixes, too. We can't change this anymore but
this is wrong.

> In this particular case, for one reason or another my Cisco device
> would have ND entry for Linux loopback pointing to an interface with
> completely different network.  Which itself would be just weird, but
> combined with weird behaviour of Cisco it actually causes the loopback
> route advertised by BGP not to be installed. If the ND entry didn't
> exist, the BGP route would be installed.

Hmmmm... Loopback route advertised by BGP? Do you use filter to get rid
of that on your AS-border? So you probably don't use an IGP? Do you use
next-hop-self attribute on your neighbor in that direction? BGP in
general doesn't lead to ND entry installs, protocols like IS-IS afair
can short circuit here.

Hmm, I would keep the Loopback announcements out of the BGP.

> I don't really even know why the ND entry exists, all I can think of
> is that Linux must have sent gratuitous reply, because I don't se why
> Cisco would have tried to discover it.
>
> Expected behaviour is that the loopback/128 BGP route resolves to
> on-link next-hop, and on-link next hop is then ND'd. Observed
> behaviour is that loopback/128 BGP route also appears in ND cache.

Yep, exactly.

>> In IPv6 this depends on the scope. In IPv4 this concept doesn't really
>> exist.
>>
>> Please notice that in IPv4 arp_filter does not necessarily mean that the
>> system is operating in strong end system mode but you end up in an
>> hybrid clone where arp is acting strong but routing not and thus you
>> also have to add fib rules to simulate that.
> 
> It's just very peculiar behaviour to have ARP or ND entries on a
> interface where given subnet does not exist, it rudimentarily causes
> difficult to troubleshoot problems and is surprising/unexpected
> behaviour.

For enterprise and cloud stuff it is certainly very surprising, as some
isolations don't work as expected. OTOH it is really easy to build up
home networks and things are more plug and play.

> Of course well behaving device wouldn't accept such replies, because
> it itself could be attack vector (imagine me telling you 8.8.8.8 is on
> the link, or worse, your bank).
> 
> I'm curious, why does this behaviour exist? When is this desirable?
> I've never seen any other device than Linux behave like this, and when
> ever I've heard about the problem, I've only seen surprised faces that
> it does behave like this.

I don't feel comfortable to answer that, just some thoughts...

Some RFCs require that for some router implementations (CPE), on the
other hand weak end model in Linux was probably inherited by IPv4. The
addition of duplicate address detection (which of course only makes
sense in strong end systems) to IPv6, basically shows that IPv6 is more
or less designed to be a strong end system model.

Anyway, a patch to suppress ndisc requests on those interfaces will
probably be accepted.

For unicast reverse filtering e.g. there is actually no sysctl available
anymore, instead you are supposed to install a netfilter rule to handle
this, which automatically takes care of this.

Bye,
Hannes

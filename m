From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/6] tcp_metrics: Add a field tcpm_net and verify it matches on lookup
Date: Tue, 10 Mar 2015 12:56:58 -0500
Message-ID: <877fuoka6t.fsf@x220.int.ebiederm.org>
References: <87pp8hnxqz.fsf@x220.int.ebiederm.org>
	<20150310.123642.2054908032137423526.davem@davemloft.net>
	<87fv9clr3b.fsf@x220.int.ebiederm.org>
	<20150310.132901.107747405992138134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ja@ssi.bg, edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37487 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbbCJSAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:00:38 -0400
In-Reply-To: <20150310.132901.107747405992138134.davem@davemloft.net> (David
	Miller's message of "Tue, 10 Mar 2015 13:29:01 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 10 Mar 2015 12:06:32 -0500
>
>> David Miller <davem@davemloft.net> writes:
>> 
>>> From: ebiederm@xmission.com (Eric W. Biederman)
>>> Date: Tue, 10 Mar 2015 01:59:48 -0500
>>>
>>>> If we actually really care about struct net going away it would be
>>>> much better to globally replace struct net with a typedef that looks
>>>> something like:
>>>> 
>>>> #ifdef CONFIG_NET_NS
>>>> struct net_ref {
>>>>        struct net *net;
>>>> };
>>>> #else
>>>> struct net_ref {
>>>> };
>>>> #endif
>>>> typedef struct net_ref net_t;
>>>> 
>>>> That would remove the need for write_pnet and read_pnet, make it
>>>> impossible to forget net_eq and make network namespace arguments to
>>>> functions also boil away at compile time if the network namespace code
>>>> was not enabled.
>>>> 
>>>> That was the original design and I forget why we didn't do that with
>>>> struct net.  But we did not.
>>>
>>> This keeps the ifdefs out of foo.c code, so I like it.
>> 
>> Alright.  It does wind up requiring things like:
>
> Another approach is to use a macro for the instantiation of a "struct
> net *" member.
>
> It could evaluate to "struct { } x;" when NETNS is disabled.
>
> Then you don't need all the special accessors, read_pnet() and
> write_pnet() are sufficient.

Looking at read_pnet we always wrap it in a special accessor that
is appropriate for it's type.

But yes all that is really missing from read_pnet and write_pnet
fundamentally is a typedef to make the structure definitions not
require typedefs.

The part that spooks me from using them is essentially:
net_eq(read_pnet(&tm->tcpm_net), net)

Which is a long and ugly and ick.

The classic solution to that is of course to make it.

net_eq(tm_net(tm), net)

Which doesn't look too bad.  And is just a small wrapper around
read_pnet.

And that I can implement without much work.

The invasive bit would be writing something that would require us to use
net_eq to compare network namespaces.  But I can live without that for
now.


Eric

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 09:47:28 -0400
Message-ID: <49BFA9F0.6070702@hp.com>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <20090317125845.GB9754@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Felix von Leitner <felix-kernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:7628 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbZCQNrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 09:47:32 -0400
In-Reply-To: <20090317125845.GB9754@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix von Leitner wrote:
>> I don't think this ever worked on Linux, from the very beginning of inet6_bind():
> 
>>         /* Check if the address belongs to the host. */
>>         if (addr_type == IPV6_ADDR_MAPPED) {
>>                 v4addr = addr->sin6_addr.s6_addr32[3];
>>                 if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
>>                         err = -EADDRNOTAVAIL;
>>                         goto out;
>>                 }
>>         } else {
> 
> What is the harm in allowing this?  That way an application ported to
> IPv6 can still bind IPv4-only.  Why would it be legal to bind to a
> specific IPv4 address but not to all IPv4 addresses?
> 
> The specific case is a bittorrent tracker.  The code was ported to IPv6,
> but since there is so much overhead in storing IPv6 addresses you are
> supposed to run two processes, one on the IPv6 address and one on the
> IPv4 address (the IPv4 one then does not have overhead).  The sane way
> to do this is to bind the IPv6 socket to ::ffff:0.0.0.0 then.  Otherwise
> you would need some kind of giant abstraction layer in the application.
> And we specifically added the ipv4 mapped addresses so applications
> would not need to have a giant abstraction layer.

Sorry, I just don't buy this.  You imply that you don't want the overhead
of storing IPv6 addresses, but you still get this with ::ffff:0.0.0.0.
In fact, now your overhead is even worse since ever IPv4 address will be
stored stored and interpreted as IPv6 128 bit address.

If you really care about overhead, run 2 services.  Your IPv6 service
will only track real IPv6 addresses and will reduce you total overhead.

If you don't care about overhead, just bind a single socket to :: and
you will get behavior identical for the ::fff:0.0.0.0 case, but with
the added benefit of tracking real ipv6 addresses as well.

Having written support for ::ffff:0.0.0.0, I've always thought it was
a bastardized case that didn't provide any benefits.  It was like saying:
"I've got IPv6 on my system, but I don't really support it, even though
I pretend that I do."

> 
> Did I mention *BSD and OSX allow this?
> 
>> So are you trying to get IPv4-only behavior out of this socket?  Seems
>> like the wrong way to go about it.
> 
> Why would you say that?

Because that case doesn't provide any benefits.  It only has the drawback that
you have to deal with ipv4-mapped IPv6 addresses witch is the overhead of
the whole thing.

If you are prepared to deal with it, you might as well deal with real ipv6 addresses
at the same time and mitigate your overhead somewhat.

-vlad
> 
> Felix
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


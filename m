From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 12:00:38 +0300
Message-ID: <4BB06C36.9060105@iki.fi>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f222.google.com ([209.85.219.222]:48670 "EHLO
	mail-ew0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887Ab0C2JAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 05:00:43 -0400
Received: by ewy22 with SMTP id 22so1742256ewy.37
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 02:00:41 -0700 (PDT)
In-Reply-To: <20100329084018.GA22547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Mar 25, 2010 at 12:26:11PM -0700, David Miller wrote:
>> Maybe we can make the dead state check safe to do asynchronously
>> somehow?  I wonder if the policy layer is overdue for an RCU
>> conversion or similar.
> 
> In fact, now that I read this again, we don't even need to grab
> the lock to perform the deadness check.  This is because the
> existing never did it anyway.  The liveliness is guaranteed by
> the policy destruction code doing a synchronous cache flush.
> 
> Timo, what was the reason for getting rid of the synchronous
> flush again?

No, just having the flush call is not enough to guarantee
liveliness. The flushing happens in delayed work, and the flows
might be in use before the flush has been finished or even
started.

I was also hoping to move the "delayed" deletion part to
flow cache core so the code would be shared with policies and
bundles.

As stated before, we don't really need lock for the 'dead' check.
It's only written once, and actually read without lock in some
other places too. And all the other places that do take the lock,
release it right away making the resulting dead check result
"old" anyway. 

Looks to me that the whole policy locking is not up-to-date
anymore. Apparently the only place that actually needs it is
the migration code (which just happens to be broke anyway since
bundle creation does not take read lock). But it could be
relatively easily changed to replace policy with new
templates... and the whole policy stuff converted to RCU.

However, now that I've almost done the code ready. I'm thinking
if this is such a good idea or not. I was hoping to have bundles
always in the flow cache, but it's not sufficient. In case we
have socket bound policy that results in a bundle, we might need
create bundles outside the flow cache.

It turns out the generic flow cache might not be so easily
done that could host bundles and policies. Or at least the
shared code would not be as much as hoped for. Given that it
makes also sense to store other objects for outgoing stuff
(we might need reference to multiple policies if matching
a sub and main policy), it might be a consideration to make
the flow cache specialized to contain those objects. Or do
we have other possible users for the flow cache?

- Timo

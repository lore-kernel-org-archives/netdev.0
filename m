From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: Re: [PATCH] [Syncookies:] Add support for TCP-options via
	timestamps.
Date: Mon, 31 Mar 2008 11:19:46 -0700
Message-ID: <47f12aa2.0d87460a.31a3.ffff8345@mx.google.com>
References: <1206922182-2214-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Glenn Griffin <ggriffin.kernel@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:54881 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbYCaSRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 14:17:10 -0400
Received: by ti-out-0910.google.com with SMTP id 28so508060tif.23
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 11:17:08 -0700 (PDT)
In-Reply-To: <1206922182-2214-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The downside is that the timestamp sent in the packet after the synack
> will increase by several seconds.

I didn't see any huge downsides quickly scanning over it.  This could
cause a difference of upto ~500 jiffies from what we will send on the
first packet sent after receiving an ack.  If you were connecting to
another linux peer I don't believe this would cause any huge issues, and
the rtt calculations would quickly recover once actual data
communications took place.  The problem is the interpretation of our
timestamp is dependant on the remote systems logic and while smart peers
could quickly recover from the relatively small discrepancy during the
handshake it's hard to determine what effect it will have on other
hosts.

Considering this only matters when we are already in the midst of a DOS
attack, and tcp timestamps would otherwise be disabled it seems like an
okay tradeoff to me.

> +static u32 options_encode(u32 options)
> +{
> +	u32 ts, ts_now = tcp_time_stamp;
> +
> +	if (unlikely(options > ts_now)) { /* recent overflow */
> +		options |= ~(TSMASK);
> +		return options;
> +	}
> +	ts = ts_now & ~TSMASK;
> +	ts |= options;
> +	if (ts > ts_now) { /* try to fix up ... */
> +		ts >>= TSBITS;
> +		ts--;
> +		ts <<= TSBITS;
> +		ts |= options;
> +	}
> +        return ts;
> +}

I may be missing something obvious, but I'm failing to see where the
initial if(options > ts_now) does anything different from the more
generic logic below it.  In order for ts_now to be smaller than options
it would need to have all bits above TSBITS off.  If that's the case
then 

ts >>= TSBITS;
ts--;
ts <<= TSBITS;

will flip all those bits on just as you do with

options |= ~(TSMASK)

Also the 'return ts' line is indented using spaces rather than tabs.

--Glenn Griffin

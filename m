From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH 1/4] TCPCT part 1: initial SYN exchange with
 SYNACK data
Date: Thu, 15 Oct 2009 12:29:56 -0400
Message-ID: <4AD74E04.4040009@gmail.com>
References: <4AD6B31B.3060402@gmail.com> <20091014.231540.01186298.davem@davemloft.net> <4AD70B73.2040401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:42827 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932843AbZJOQak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 12:30:40 -0400
Received: by ywh6 with SMTP id 6so988863ywh.4
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 09:30:03 -0700 (PDT)
In-Reply-To: <4AD70B73.2040401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> #3 It's not possible to wrap and extend request_sock, as that is already
> done by IPv6 and others, causing a conflict.  That was suggested by
> another maintainer, and I drafted some code last week, but wasn't able to
> figure out a non-conflicting code path.
> 
After private discussion with others, I'm proposing a wrapper over a union
of those other header files, that would ensure new fields would be beyond
the previous extensions.  It would have to be in its own .h file, and
would have the unfortunate side effect of hauling in other protocols, but
only into a very few net/ipv4/tcp*.c files.

The only advantage is that it doesn't matter how big this request_sock
will become, as it is thrown away immediately after use (just like stack
parameters in the previous proposal).  Fourth time's the charm?

That is, something like:

#include <linux/ipv6.h>
#include <net/dccp/ipv6.h>

struct extend_request_sock {
	union {
		/* the biggest known */
		struct tcp6_request_sock tcp6rsk;
		struct dccp6_request_sock dccp6rsk;
	} wrap;

	u8	cookie_bakery[TCP_COOKIE_MAX];
	u8	cookie_plus;
	u8	cookie_in_always:1,
		cookie_out_never:1;
}

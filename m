From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Wed, 20 May 2015 22:46:54 -0700
Message-ID: <CAE4R7bAB2+Oy92w9RpLKL5LUq7gP1mBazBK9y4ZQ4b0k8t2WhQ@mail.gmail.com>
References: <555AD11E.5040709@cumulusnetworks.com>
	<20150519.123418.481170679256206928.davem@davemloft.net>
	<20150519194731.GK9559@gospo.home.greyhouse.net>
	<20150519.162845.955021778058631119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	john fastabend <john.fastabend@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33436 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbbEUFqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 01:46:55 -0400
Received: by qkgv12 with SMTP id v12so46711334qkg.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 22:46:54 -0700 (PDT)
In-Reply-To: <20150519.162845.955021778058631119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 1:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Tue, 19 May 2015 15:47:32 -0400
>
>> Are you actually saying that if users complain loudly enough about
>> the current behavior (not the change Roopa has proposed) that you
>> would be open to considering a change the current behavior?
>
> I am saying that we have a contract with users not to break existing
> behavior.  Full stop.

After rehearing David's argument, we should probably explore option d)
which is a refinement on the fib_offload_disable mechanism we have
today.  fib_offload_disable is global for all routes.  Once we hit a
HW install problem, the global flag is set and all routes fallback to
SW.  We did this because we can't allow the failed route to exist in
SW and not in HW because it could mess up LPM searches (HW could hit
on a lesser prefix even when SW has the true LPM, because HW gets
first shot at match).  The refinement on fib_offload_disable is this:
make it per-related-prefix rather than global, and on a HW install
problem, set the flag for the related-prefix and uninstall only those
routes from HW.  Related-prefix (is there a correct term for this?)
are routes to the same dst addr but with different prefix lengths.  I
haven't parsed the fib_trie structure to see how routes are organized,
but I suspect since it's optimized for lookup the related-prefix
tracking is already there and we can build on that.

Option d) requires no application changes.  It requires no additional
understanding or input from the user.  Kernel fallback happens
transparently.  In the case where the HW install failure was due to
out-of-resource in HW, there may be some oscillation as
related-prefixes are removed from HW, freeing up a little space, only
to be filled as new routes come in, and so on.  Actually, now that I
think of it, the device/driver could decide which related-prefix to
evict from HW, if driver/device wanted to have a sense of which routes
are more important to offload than others, when resources are limited.

I think the parts we need are:

1) A new fib_offload_disable bit for related-prefixes.
2) On switchdev fib offload, look up if route is marked as
fib_offload_disabled based on it's related-prefix membership
3) A notification mechanism from driver to indicate a related-prefix
is fib_offload_disabled.

Feasible?

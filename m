From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving
 an mldv2 query
Date: Thu, 25 Sep 2014 19:23:52 -0400
Message-ID: <5424A408.5000208@oracle.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com> <1411455828-5196-3-git-send-email-dborkman@redhat.com> <54243C89.6060405@oracle.com> <542475E3.6030508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22465 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbaIYXYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 19:24:04 -0400
In-Reply-To: <542475E3.6030508@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/25/2014 04:06 PM, Daniel Borkmann wrote:

> One of the problems I see (also with this argumentation -- next to the fact
> that it's not specified by the RFC) is that we're blindly overwriting with

You say "not specfied by the RFC" as if it's contrary to the RFC, when the RFC
also doesn't specify that it be set per-host via sysctl. It isn't specified means
that it is up to the implementation how to set it, and the implementation sets it
based on MRD. It does not say "SHOULD" or "MUST" for how this value is set, so
to be clear: the current mechanism is RFC-compliant.

Now you want to change this mechanism that is not covered by RFC to a different
mechanism. Is your change better?

I'm not sure what problem you're trying to fix (which is what I was asking),
but I think a fixed-value specified at each host, rather than one done via the
querier, is in fact worse, especially if that value is much greater or much smaller
than the MRD value, since it is effectively for the same purpose -- just for
unsolicited instead of queried reports.

Now, probably that discussion should've happened when the tunables were put in, but
having the sysctl's is still useful for setting the values when there is no querier
present.

When there is a querier, however, the original code IMO makes more sense, especially
in the absence of any input from an administrator.

I'm generally for allowing administrators complete flexibility, even if they use it
for evil, so I think I'd prefer something along the lines of:

1) have an initial default of 1sec (v2) or 10sec (v1)
2) if an administrator sets the sysctl, override any
	other choice with that setting
3) if an administator has not set it, use the querier value

That combination allows the querier to effectively set an appropriate interval for
the entire network, allows an admin to change it per-host if desired, and uses the
suggested defaults when there is no querier or admin intervention.

Or maybe split the sysctls into one that forces the value and one that just sets
a default which can be overridden by queriers.

I don't think your patches are incorrect, but I don't think the original behavior
is either. With your interpretation, the URI (but not the MRD or QRV), must be
changed on every individual host to tune a network away from the default values.
The current code doesn't have that problem.

							+-DLS

From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in preparation for IPv6 support
Date: Fri, 9 May 2008 15:46:58 +0200
Message-ID: <f4845fc0805090646i6ff5d7e8p3d52775419dc44a4@mail.gmail.com>
References: <f4845fc0805070732v516fc8c6y2cdddfd4f99c8f96@mail.gmail.com>
	 <Pine.LNX.4.64.0805070734580.6164@wm7d.net>
	 <f4845fc0805070851y7f1f00d0xd2dfcc7feb79c173@mail.gmail.com>
	 <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	Horms <horms@vergenet.net>
To: "Joseph Mack NA3T" <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:32948 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbYEINrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 09:47:05 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m49Dl0qE006971
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 14:47:00 +0100
Received: from wr-out-0506.google.com (wrac49.prod.google.com [10.54.54.49])
	by zps18.corp.google.com with ESMTP id m49DkxVd018117
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 06:46:59 -0700
Received: by wr-out-0506.google.com with SMTP id c49so535757wra.19
        for <netdev@vger.kernel.org>; Fri, 09 May 2008 06:46:59 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0805090536120.22107@wm7d.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 9, 2008, Joseph Mack NA3T wrote:
> are you at a stage where it's all split up, after which you'll only be
> working on the ipv6 part and leaving the ipv4 untouched? Have you tested the
> ipv4 part to make sure it's still OK. ie the code is reorthogonalised but
> with no change in functionality?

No, I'm not at this stage yet, I'm approaching the problem from the
other direction, following your earlier advice: try to come up with
something that actually does something (hopefully in a couple of
weeks, due to other obligations), then worry about separation /
cleanup and more features. So everything is pretty hacky with lots of
open TODOs and stupid questions. It compiles, but running it wouldn't
make much sense (partially because of lacking userspace ipsvadm
support for the changes). I'm not even #ifdef-ing away my IPv6 code at
the moment...

What I did:

I basically copied lots of IPVS functions (yep, too much duplication,
unfortunately) that depend on the IP version and made corresponding
IPv6 versions of the function. A lot of this duplication could
probably be avoided by doing some heavy refactoring, but I tried to
stay away from that to minimize the chances of breaking the existing
code. Some few, not often called functions now handle both IP versions
in one function. The multiplexing of IPv4/IPv6 code is done either by
implicitly knowing which code path we're in (different paths resulting
from different NF hooks for IPv4/IPv6) or by looking at the new "af"
address family (AF_INET or AF_INET6) field introduced into all the
relevant IPVS data structures.

I didn't duplicate any data structures, even the actual hash tables
contain both IPv4 and IPv6 entries (differentiation done via the "af"
field). So far, this seems to work quite well... what I don't like
about this is that you have an additional space-taking IPv6 address
field in all data structures, even when it is not used. E.g., when
IPv6 support is compiled as a module, but it is not loaded. A later
move to use different structs for the cases that actually matter
(probably only the table of active connections) should be pretty easy,
though.

> One of the things I worry about (from personal experience) is people working
> on projects and getting stuck for time and later having to drop the work. If
> you can submit the reorthogonalised code, and have to stop sometime later,
> at least we've got that far down the road.

Yes, let's hope that will not happen. But sadly, I'm not at the stage
of having cleanly separated code, so submitting code isn't possible
yet :(

Julius

-- 
Google Switzerland GmbH

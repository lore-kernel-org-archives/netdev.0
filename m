From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Wed, 27 Mar 2013 17:46:05 -0700
Message-ID: <87620cpd0y.fsf@xmission.com>
References: <CD78B3C3.76D3%blourdel@juniper.net> <874nfwri6o.fsf@xmission.com>
	<20130327104746.0ec9dcb5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36043 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab3C1AqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 20:46:16 -0400
In-Reply-To: <20130327104746.0ec9dcb5@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Wed, 27 Mar 2013 10:47:46 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> If you need to do lots of operations the --batch mode will be significantly faster.
> One command start and one link map.

The problem in this case as I understand it is lots of independent
operations. Now maybe lxc should not shell out to ip and perform the
work itself.

> I have an updated version of link map hash (index and name). Could you test this patch
> which applies to latest version in git.

This still dumps all of the interfaces in ll_init_map causing things to
slow down noticably.

# with your patch
# time ~/projects/iproute/iproute2/ip/ip link add a4511 type veth peer name b4511

real	0m0.049s
user	0m0.000s
sys	0m0.048s

# With a hack to make ll_map_init a nop.
# time ~/projects/iproute/iproute2/ip/ip link add a4512 type veth peer name b4512

real	0m0.003s
user	0m0.000s
sys	0m0.000s
eric-ThinkPad-X220 6bed4 # 

# Without any patches.
# time ~/projects/iproute/iproute2/ip/ip link add a5002 type veth peer name b5002

real	0m0.052s
user	0m0.004s
sys	0m0.044s

So it looks like dumping all of the interfaces is taking 46 miliseconds,
longer than otherwise.  Causing ip to take nearly an order of magnitude
longer to run when there are a lot of interfaces, and causing ip to slow
down with each command.

So the ideal situation is probably just to fill in the ll_map on demand
instead of up front.

Eric

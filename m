From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/6] tcp_metrics: Network namespace bloat reduction v3
Date: Fri, 13 Mar 2015 00:04:07 -0500
Message-ID: <87y4n1xzco.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com,
	Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38346 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbCMFHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 01:07:50 -0400
In-Reply-To: <87vbi7fq92.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 11 Mar 2015 11:33:29 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a small pile of patches that convert tcp_metrics from using a
hash table per network namespace to using a single hash table for all
network namespaces.

This is broken up into several patches so that each small step along
the way could be carefully scrutinized as I wrote it, and equally so
that each small step can be reviewed.

There are several cleanups included in this series.  The addition of
panic calls during boot where we can not handle failure, and not trying
simplifies the code.  The removal of the return code from
tcp_metrics_flush_all.

The motivation for this change is that the tcp_metrics hash table at
128KiB is one of the largest components of a freshly allocated network
namespace.

I am resending the the previous version I sent has suffered bitrot, so I
have respun the patches so that they apply.  I believe I have addressed
all of the review concerns except optimal behavior on little machines
with 32-byte cache lines, which is beyond me as even the current code
has bad behavior in that case.

Eric W. Biederman (6):
      tcp_metrics: panic when tcp_metrics_init fails.
      tcp_metrics: Mix the network namespace into the hash function.
      tcp_metrics: Add a field tcpm_net and verify it matches on lookup
      tcp_metrics: Remove the unused return code from tcp_metrics_flush_all
      tcp_metrics: Rewrite tcp_metrics_flush_all
      tcp_metrics: Use a single hash table for all network namespaces.

 include/net/netns/ipv4.h |   2 -
 net/ipv4/tcp_metrics.c   | 137 +++++++++++++++++++++++++----------------------
 2 files changed, 73 insertions(+), 66 deletions(-)

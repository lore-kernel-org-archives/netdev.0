From: Xavier Roche <roche*lkml@httrack.com>
Subject: Follow-up to routing IPv6 source address selection bug in kernel
Date: Sun, 18 Sep 2011 16:11:45 +0200
Message-ID: <4E75FC21.10309@httrack.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gob75-8-88-165-216-99.fbx.proxad.net ([88.165.216.99]:56421
	"EHLO smtp-1.httrack.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab1IROtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 10:49:50 -0400
Received: from [192.168.1.1] (machine-1.localnet [192.168.1.1])
	by smtp-1.httrack.com (8.14.4/8.14.4/Debian-2) with ESMTP id p8IEBoU3001193
	for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 16:11:50 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Moved from linux-kernel where it did not belong ]

Hi folks,

I reported a year ago a bug regarding source address selection in the
kernel for Ipv6, but it seem to be still there. If anyone has any
insightful advice on possible workarounds, or (better) possible fixes,
it would be great.

Basically, the "src" attribute of "ip -6 route add" is ignored, and
default source address selection is selected by the kernel.

This is probably related to the way the kernel handles RFC 3484 source
address selection [ The RFC states that [RFC 3484] "If the eight [source
address selection] rules fail to choose a single address, some
unspecified tie-breaker should be used". The unspecified tie-breaker
would then be the src routing information, or any additional netfilter
setting. ]

Selecting the source address according to outgoing parameters
(destination network, destination protocol, for example, but it could be
running uid/gid with advanced netfilter rules) is kind of handy when you
want to have dedicated addresses for, say, outgoing SMTP, outgoing HTTP,
outgoing SSH and so on..

This is especially true with IPv6: the default allocated size is at
least 16 billions billions IP addresses. Being able to use more than one
address per server is then kind of handy.

Binding to a special IP address for outgoing connections is difficult in
most cases, because the application would have to do the logic the
kernel is computing normally (destination on local network ? or on the
same interface ..) and would prevent proper use when multiple
interfaces/networks are in use.

The simplest way to achieve that would be to build a dedicated route for
a specific netblock, for example (this would not solve the
"per-destination-protocol" case, but this is a beginning). As I said
before, it unfortunately does not work.

Note that:

- Marking packets and using policy-based routing is not possible either
(as I understood, the source address has already been computed at this
point and the packet is built, so this is too late)

- Source NATing is also impossible (not implemented on IPv6)

- The /etc/gai.conf tuning file is no help for this purpose either.

I understand this is not a major kernel issue, but this is a really
annoying limitation when you have an almost infinite address space unused :)

[ Note: see also "src attribute ignored for IPv6 (preferred source
address selection)" in linux-netdev mailing-list one year ago. ]

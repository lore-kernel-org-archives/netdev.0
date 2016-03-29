From: Phil Sutter <phil@nwl.cc>
Subject: ss filter problem
Date: Tue, 29 Mar 2016 21:32:42 +0200
Message-ID: <20160329193242.GA28502@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39356 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757976AbcC2Tcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 15:32:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to fix a bug in ss filter code, but feel quite lost right
now. The issue is this:

| ss -nl -f inet '( sport = :22 )'

prints not only listening sockets (as requested by -l flag), but
established ones as well (reproduce by opening ssh connection to
127.0.0.1 before calling above).

In contrast, the following both don't show the established sockets:

| ss -nl '( sport = :22 )'
| ss -nl -f inet

My investigation led me to see that current_filter.states is altered
after ssfilter_parse() returns, and using gdb with a watchpoint I was
able to identify parse_hostcond() to be the bad guy: In line 1560, it
calls filter_af_set() after checking for fam != AF_UNSPEC (which is the
case, since fam = preferred_family and the latter is changed to AF_INET
when parsing '-f inet' parameter).

This whole jumping back and forth confuses me quite effectively. Since
you did some fixes in the past already, are you possibly able to point
out where/how this tiny mess has to be fixed?

I guess in an ideal world we would translate '-l' to 'state listen', '-f
inet' to 'src inet:*' and pass everything ANDed together to
ssfilter_parse(). Or maybe that would make things even worse. ;)

Cheers, Phil

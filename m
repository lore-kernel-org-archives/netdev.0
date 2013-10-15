From: Damian Pietras <damianp@daper.net>
Subject: "xfrm: Fix the gc threshold value for ipv4" broke my IPSec connections
Date: Tue, 15 Oct 2013 22:40:53 +0200
Message-ID: <525DA855.1010905@daper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from isp1.vx1.pl ([188.165.119.169]:40894 "EHLO isp1.vx1.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759846Ab3JOUs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 16:48:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by isp1.vx1.pl (Postfix) with ESMTP id 47CCF60AE7
	for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 22:42:29 +0200 (CEST)
Received: from isp1.vx1.pl ([127.0.0.1])
	by localhost (isp1.vx1.pl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id Se4aMD0uX+67 for <netdev@vger.kernel.org>;
	Tue, 15 Oct 2013 22:42:28 +0200 (CEST)
Received: from [192.168.156.1] (87-205-28-158.ip.netia.com.pl [87.205.28.158])
	(Authenticated sender: damianp@daper.net)
	by isp1.vx1.pl (Postfix) with ESMTPSA id BF14E608B3
	for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 22:42:28 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've recently upgraded from 3.4.x to 3.10.x and this broke my IPSec
setup in transport mode. The simplest test case is to setup few such
connections with few boxes like this:

spdadd 192.168.1.100 192.168.2.100 any -P out ipsec
           esp/transport//require
           ah/transport//require;

spdadd 192.168.2.100 192.168.1.100 any -P in ipsec
           esp/transport//require
           ah/transport//require;

Then set up an HTTP server on one box and run ab on the other box to
create come TCP connections:

ab -n 10000 -c 50 http://192.168.1.100/

Then the connect() call will very quickly start returning ENOBUFS. I
haven't seen anything wrong with my simple setup (just copy of
ipsec-howto.org in transport mode and pre shared keys) and started
bisecting. That way I found this commit to break my case:

703fb94ec58e0e8769380c2877a8a34aeb5b6c97
xfrm: Fix the gc threshold value for ipv4

Reverting it on 3.10.15 fixes my issue. This seems to be there from 3.7
and I don't really believe such simple case stayed broken for so long.
Em I missing something or there is really a bug?

If smeone is interested in details of this configuration and commands
I'm running, just let me know. This was reproduced with few VMs under XEN.

-- 
Damian Pietras

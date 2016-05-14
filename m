From: Marcin Szewczyk <Marcin.Szewczyk@wodny.org>
Subject: No "unreachable" response for an outgoing TCP connection when using
 fwmark
Date: Sat, 14 May 2016 02:13:41 +0200
Message-ID: <20160514001341.GB3256@orkisz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n26.netmark.pl ([94.124.9.61]:36001 "EHLO n26.netmark.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201AbcENBDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 21:03:08 -0400
Received: from 87-207-218-242.dynamic.chello.pl ([87.207.218.242]:43425 helo=orkisz)
	by n26.netmark.pl with esmtpsa (TLSv1:DHE-RSA-AES256-SHA:256)
	(Exim 4.87)
	(envelope-from <Marcin.Szewczyk@wodny.org>)
	id 1b1NDB-003EVE-J9
	for netdev@vger.kernel.org; Sat, 14 May 2016 02:13:48 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I hope this is the right group even though it concerns mainly
development but I have not found a better one.

I would like to route locally-generated traffic:
- to a TCP port "A" of host "H" via the interface "A",
- to a TCP port "B" of host "H" via the interface "B".

Interface "B" is sometimes unavailable. Then I would like the kernel to
notify the user with "Network is unreachable" error if one tries to
connect to the TCP port "B".

I have tried the following settings (when the interface "B" is down):

# iptables -t mangle -nvL OUTPUT
Chain OUTPUT (policy ACCEPT 2 packets, 120 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    2   120 MARK       all  --  *      *       0.0.0.0/0            host-H-ip         MARK set 0x64
(for simplicity the rule does not include ports yet)

# ip rule
0:      from all lookup local 
32765:  from all fwmark 0x64 lookup 200 
32766:  from all lookup main 
32767:  from all lookup default

# ip route show table 200
prohibit default

There are no surprises when the interface "B" is available and the 200
table contains a regular routing rule.

But when the interface "B" is not available I get satisfactory results
only for ICMP and UDP:

$ ping host-H-ip
PING host-H-ip (host-H-ip) 56(84) bytes of data.
ping: sendmsg: Network is unreachable

$ nc -nuv host-H-ip 5000
(UNKNOWN) [host-H-ip] 5000 (?) open
foo
too many output retries : Network is unreachable

For TCP it just hangs:
$ nc -nv host-H-ip 5000

I have found some threads that seem to be connected with the topic:
http://marc.info/?l=linux-netdev&m=136633466813095&w=2
http://www.spinics.net/lists/netdev/msg281954.html
http://netfilter-devel.vger.kernel.narkive.com/8ggjpr4G/netfilter-core-mangle-table-rules-are-not-taken-into-account-in-preliminary-routing-decision

Unfortunately, I still do not understand why I do not get "Network is
unreachable" for TCP as well. Could anybody explain it to me?

Best regards,

-- 
Marcin Szewczyk
http://wodny.org

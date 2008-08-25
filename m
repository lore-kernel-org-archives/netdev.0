From: bsilva <bsilva@sonic.net>
Subject: Policy routing issue.
Date: Mon, 25 Aug 2008 10:31:34 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0808251025100.15402@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.mail.sonic.net ([64.142.19.5]:58043 "EHLO b.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536AbYHYRwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 13:52:36 -0400
Received: from newshell.sonic.net (bolt.sonic.net [208.201.242.19])
	by b.mail.sonic.net (8.13.8.Beta0-Sonic/8.13.7) with ESMTP id m7PHVYSu011978
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 10:31:34 -0700
Received: from bolt.sonic.net (IDENT:OcfvIrkSFRWTqsZZYHl1SrkYbg51pHqs@localhost.localdomain [127.0.0.1])
	by newshell.sonic.net (8.13.6/8.12.1) with ESMTP id m7PHVYjI026186
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 10:31:34 -0700
Received: from localhost (bsilva@localhost)
	by bolt.sonic.net (8.13.6/8.12.1/Submit) with ESMTP id m7PHVYq3026183
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 10:31:34 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pardon my posting to this list, I'm pretty sure this is the wrong
mailing list for this topic, but I'm hoping someone here can point me at a
forum or mailing list that has discussion of advanced routing topics and
issues.

The LARTC (Linux Advanced Routing and Traffic Control) mailing list would
be my first choice, but that appears to be dead.  The other places I've
tried do not seem to have anyone who understands the problem.

I think I've found a bug in the source address selection in IPv4 routing,
but I'm not sure.

Anyway, I've attached my barebones description of the problem.

Thanks,
Brad


------------------------------------------------


I'm having an unusual problem with a Policy Routing setup.  I have a
combination of IPtables and Policy Routing rules that force certain
protocols out one interface and other protocols out the other interface.
The problem is that SNMP traps are exiting the correct interface, but
with the IP address of the other interface!

Furthermore, the situation only occurs if the destination is not local.
If the destination is local, the packet exits the correct interface with
the correct source IP.  If the destination is via a gateway, then the
packet exits via the correct interface, but with the wrong source IP.

I'm at a loss.  The rules and routes all appear to work correctly, it's
just the final assignment of the source IP that seems to be wrong.  It
appears to me that I've found a bug in the kernel, but I'm not sure.  Any
clues or further things to look at would be very helpful.


Thanks in advance,
Brad

---------------------------------------------------

I'm running kernel 2.6.16.55 on a custom distribution.

Here's the route rules and route tables: (I've simplified the setup for
this problem)

$ iptables -L -t mangle
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
MARK       tcp  --  anywhere             anywhere            tcp dpt:162
MARK set 0x1

$ ip rule list
0:	from all lookup 255
2000:	from all fwmark 0x1 lookup 1
32766:	from all lookup main
32767:	from all lookup default

(I know that route table 1 is being selected since I can change these
routes and the result changes as expected)
$ ip route list table 1
192.168.105.0/24 dev bond2  scope link  src 192.168.105.79
default via 192.168.105.6 dev bond2  src 192.168.105.79

(note that even though the route specifies a "src 192.168.105.79" and
the cache entry shows the correct "via" address, the "from" address is
192.168.123.79!)
$ ip route list cache
....
192.168.100.254 from 192.168.123.79 via 192.168.105.6 dev bond2
    cache  (null) 1500 ssthresh 1460 advmss 64
....





--
To unsubscribe from this list: send the line "unsubscribe netfilter" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


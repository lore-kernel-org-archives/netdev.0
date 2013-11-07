From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Linux sends IPv6 NS packets with the link-local address
Date: Thu, 7 Nov 2013 01:29:46 +0100
Message-ID: <20131107002946.GA16324@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: ayourtch@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:45214 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab3KGA3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 19:29:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We've been noticing that a specific Linux host on our network (3.10.7) had
problems communicating with certain other Linux hosts (3.2.x). When doing
ping6, tcpdump shows that it takes a long time before the communication
actually gets set up:

  00:36:02.615204 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:03.613120 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:04.613107 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:05.707462 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:06.703119 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:07.703101 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:08.799892 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:09.793103 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:10.793104 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:11.886412 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:12.883112 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:13.883117 IP6 fe80::230:48ff:fe55:5743 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:14.962985 IP6 2001:67c:29f4::31 > ff02::1:ff00:5105: ICMP6, neighbor solicitation, who has 2001:67c:29f4::5105, length 32
  00:36:14.966647 IP6 2001:67c:29f4::5105 > 2001:67c:29f4::31: ICMP6, neighbor advertisement, tgt is 2001:67c:29f4::5105, length 32
  00:36:14.966681 IP6 2001:67c:29f4::31 > 2001:67c:29f4::5105: ICMP6, echo request, seq 11, length 64
  00:36:14.966797 IP6 2001:67c:29f4::5105 > 2001:67c:29f4::31: ICMP6, echo reply, seq 11, length 64

As you can see, the first packets are sent from the link-local address,
and suddenly Linux switches to a global address, and then it works.

Now, the fact that it doesn't work with link-local as a source is a bug in
the MLD snooping of the switches we are using; the vendor has been notified
and is into it. But I wonder if there's a Linux bug here as well.

RFC 4168 has this to say:

   If the source address of the packet prompting the solicitation is the
   same as one of the addresses assigned to the outgoing interface, that
   address SHOULD be placed in the IP Source Address of the outgoing
   solicitation.  Otherwise, any one of the addresses assigned to the
   interface should be used.  Using the prompting packet's source
   address when possible ensures that the recipient of the Neighbor
   Solicitation installs in its Neighbor Cache the IP address that is
   highly likely to be used in subsequent return traffic belonging to
   the prompting packet's "connection".

Since this is a SHOULD, there's nothing inherently _illegal_ about sending the
packets with the link-layer address as source, but the RFC does have a point.
Most of the time, Linux indeed seems to be sending with the global source
address (heeding the SHOULD), and again, for some reason it suddenly switches
to it in this case.

Would anyone happen to know why it uses the link-local in the first place,
and why it suddenly changes its mind after ten tries or so? I'm not sure if I
can _force_ this behavior, but judging from a tcpdump, it happens many times
a day from that specific machine.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

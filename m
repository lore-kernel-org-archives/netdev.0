From: Andre Tomt <andre@tomt.net>
Subject: [Fwd: Remote DoS vulnerability in Linux kernel 2.6.x]
Date: Wed, 30 Jun 2004 21:38:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E316C4.30205@tomt.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050502080407020203090706"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050502080407020203090706
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I would guess you guys know about this one - but just in case.

Is the patch provided safe? Is the problem real?

--------------050502080407020203090706
Content-Type: message/rfc822;
 name="Remote DoS vulnerability in Linux kernel 2.6.x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Remote DoS vulnerability in Linux kernel 2.6.x"

Return-Path: <bugtraq-return-14993-andre=tomt.net@securityfocus.com>
Delivered-To: andre@tomt.net
Received: (qmail 20334 invoked by uid 107); 30 Jun 2004 19:09:12 -0000
Received: from bugtraq-return-14993-andre=tomt.net@securityfocus.com by ns1 by uid 1003 with qmail-scanner-1.21
 (clamdscan: 0.72. spamassassin: 2.63.  Clear:RC:0(205.206.231.26):SA:0(1.9/5.0):.
 Processed in 1.463814 secs); 30 Jun 2004 19:09:12 -0000
X-Spam-Level: *
Received: from unknown (HELO outgoing2.securityfocus.com) (205.206.231.26)
  by mail.skjellin.no with SMTP; 30 Jun 2004 19:09:10 -0000
Received: from lists2.securityfocus.com (lists2.securityfocus.com [205.206.231.20])
	by outgoing2.securityfocus.com (Postfix) with QMQP
	id 8E2F0143784; Wed, 30 Jun 2004 17:49:20 -0600 (MDT)
Mailing-List: contact bugtraq-help@securityfocus.com; run by ezmlm
Precedence: bulk
List-Id: <bugtraq.list-id.securityfocus.com>
List-Post: <mailto:bugtraq@securityfocus.com>
List-Help: <mailto:bugtraq-help@securityfocus.com>
List-Unsubscribe: <mailto:bugtraq-unsubscribe@securityfocus.com>
List-Subscribe: <mailto:bugtraq-subscribe@securityfocus.com>
Delivered-To: mailing list bugtraq@securityfocus.com
Delivered-To: moderator for bugtraq@securityfocus.com
Received: (qmail 30875 invoked from network); 30 Jun 2004 04:45:26 -0000
Date: Wed, 30 Jun 2004 12:57:17 +0200
From: Adam Osuchowski <adwol@polsl.gliwice.pl>
To: bugtraq@securityfocus.com
Subject: Remote DoS vulnerability in Linux kernel 2.6.x
Message-ID: <20040630105717.GA4294@polsl.gliwice.pl>
Reply-To: Adam Osuchowski <adwol@polsl.gliwice.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Organization: Computer Centre of The Silesian University of Technology
X-nic-hdl: AO3196-RIPE
X-Spam-Checker-Version: SpamAssassin 2.63 (2004-01-11) on ns1.skjellin.no
X-Spam-Status: No, hits=1.9 required=5.0 tests=DATE_IN_FUTURE_06_12
	autolearn=no version=2.63

1. Overview
-----------

There is a remotely exploitable bug in all Linux kernel 2.6 series due to
using incorrect variable type. Vulnerability is connected to netfilter
subsystem and may cause DoS. It's disclosed only when using iptables with
rules matching TCP options (i.e.  --tcp-option). There is no difference
what action is taking up by matching rule.

Vulnerability was detected on i386 architecture. The other ones weren't tested
but it seems to be vulnerable too.

2. Details
----------

Problem lies in tcp_find_option() function (net/ipv4/netfilter/ip_tables.c).
There is local array `opt' defined as:

    char opt[60 - sizeof(struct tcphdr)];

which contains TCP options extracted from packet. Function mentioned above
searches for specified option in this array.

Options in TCP packet, with some exceptions, are organized in the following
way:

	Octet no.	Length	Field
	-----------------------------
		0	1	Opcode
		1	1	Length of all option (N + 2)
		2	N	Params


The function iterates over options in array:

    for (i = 0; i < optlen; ) {
	    if (opt[i] == option) return !invert;
	    if (opt[i] < 2) i++;
	    else i += opt[i+1]?:1;
    }

moving counter by the option length.

But, in case the `length' value is greater than 127, the value of this octet
in `opt' is implicitly casted to char, which results in negative number and
the loop counter moving back. In some cases it is possible, that counter
cycles throught the contents of this array infinitely.

3. Impact
---------

After sending one suitably prepared TCP packet to victim host, kernel goes
into infinite loop consuming all CPU resources, rendering the box
unresponsable. Of course, there is no need to have a shell access to attacked
host.

4. Exploitation
---------------

Example of packet-of-death:

0x0000:  4500 0030 1234 4000 ff06 e83f c0a8 0001
0x0010:  c0a8 0002 0400 1000 0000 0064 0000 0064
0x0020:  7000 0fa0 dc6a 0000 0204 05b4 0101 04fd

5. Fix
------

There is only need to change type of `opt' array from signed char to unsigned
(or, better to u_int8_t) as it was defined in 2.4 kernel or prior to version
1.16 of net/ipv4/netfilter/ip_tables.c file.

--- net/ipv4/netfilter/ip_tables.c.orig	2004-04-04 05:36:47.000000000 +0200
+++ net/ipv4/netfilter/ip_tables.c	2004-06-24 21:24:26.000000000 +0200
@@ -1461,7 +1461,7 @@
 		int *hotdrop)
 {
 	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
-	char opt[60 - sizeof(struct tcphdr)];
+	u_int8_t opt[60 - sizeof(struct tcphdr)];
 	unsigned int i;
 
 	duprintf("tcp_match: finding option\n");

6. Credits
----------

Vulnerability was discovered, identified and fixed by Adam Osuchowski
and Tomasz Dubinski.

-- 
##  Adam Osuchowski   adwol@polsl.gliwice.pl, adwol@silesia.linux.org.pl
##  Silesian University of Technology, Computer Centre   Gliwice, Poland

--------------050502080407020203090706--

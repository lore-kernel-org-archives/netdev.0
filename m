From: Peter Bieringer <pb@bieringer.de>
Subject: Bug in order of multiple IPv6 addresses per interface? Newest added
 one is preferred in difference to IPv4
Date: Mon, 21 Aug 2006 07:36:19 +0200
Message-ID: <44E94653.1040002@bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.aerasec.de ([212.18.21.178]:64470 "EHLO smtp1.aerasec.de")
	by vger.kernel.org with ESMTP id S932603AbWHUFg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 01:36:27 -0400
Received: from [IPv6:2001:a60:f011:f101::11] (unknown [IPv6:2001:a60:f011:f101::11])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp1.aerasec.de (Postfix) with ESMTP id A6DDB27245
	for <netdev@vger.kernel.org>; Mon, 21 Aug 2006 07:36:25 +0200 (CEST)
To: Maillist netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

if I add an additional IPv4 address of the same subnet ("IP aliasing",
used for virtual hosting), it's added after the first one and also get
the flag "secondary":

# ip -4 addr show dev eth0 | grep -w inet
    inet 192.0.2.11/24 brd 192.0.2.255 scope global eth0

# ip -4 addr add 192.0.2.253/24 dev eth0

# ip -4 addr show dev eth0 | grep -w inet
    inet 192.0.2.11/24 brd 192.0.2.255 scope global eth0  <-  #1
    inet 192.0.2.253/24 scope global secondary eth0       <-  #2

The new added address is also *not* used for outgoing connections by
default.


In IPv6, the behavior is completly different:

# ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
    inet6 2001:db8:0:1::11/64 scope global

# ip -6 addr add 2001:db8:0:1::253/64 dev eth0

# ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
    inet6 2001:db8:0:1::253/64 scope global   <- #2 !!!!
    inet6 2001:db8:0:1::11/64 scope global    <- #1

So the last added on is now the first in list. Also, it gets no
"secondary" flag and "ip" doesn't even support this flag.

And the worse thing is that the first one in list (= last added one) is
now used as default for outgoing connections. Can be easily tested using
"ping6".


Is this a bug (I hope so) or a (undocumented?) feature?

How can I add additional IPv6 addresses from the same subnet to an
interface without changing implicit the default outgoing address.

Current workaround: adding new address, remove and readd primary IPv6
address (which is afterwards the first one in list again).


BTW: this can break at least initscripts, which support more than one
address per interface (a primary and some secondary ones), see also:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=199862 (a
workaround is described here)

Used versions:

kernel-2.6.17-1.2174_FC5 (happen also below, e.g. 2.6.9 from RHEL4)
iproute-2.6.15-1.2

Regards,
	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/



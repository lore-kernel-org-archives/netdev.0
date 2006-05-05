From: David Woodhouse <dwmw2@infradead.org>
Subject: IPv6 connect() from site-local to global IPv6 address.
Date: Fri, 05 May 2006 22:00:32 +0100
Message-ID: <1146862832.2766.54.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([205.233.218.70]:17877 "EHLO
	canuck.infradead.org") by vger.kernel.org with ESMTP
	id S1751779AbWEEVAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 17:00:39 -0400
Received: from pmac.infradead.org ([81.187.2.168])
	by canuck.infradead.org with esmtpsa (Exim 4.61 #1 (Red Hat Linux))
	id 1Fc7Ph-0005MD-1y
	for netdev@vger.kernel.org; Fri, 05 May 2006 17:00:38 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been using and testing IPv6 on a private network.

Machines have RFC1918 IPv4 addresses, with connectivity by NAT to the
outside world. They also have site-local IPv6 addresses. There is
approximately zero chance of getting corporate approval to have external
IPv6 connectivity.

Since updating the kernel to 2.6.16, I've got problems with external
connectivity to hosts which have both IPv4 and (Global) IPv6 addresses
in DNS. Glibc used to return the IPv4 address in the A record first, and
all was well. But now it returns the IPv6 address in the AAAA record
first, and I can't communicate with that. So I get a three-minute
timeout whenever I try to connect to anything in the outside which has
both A and AAAA records.

One of the things which glibc's implementation of RFC3484 address
selection (http://people.redhat.com/drepper/linux-rfc3484.html) does is
to perform a dummy connect() of a SOCK_DGRAM socket to each of the
potential addresses. On older kernels this used to fail when we
attempted to connect to a global IPv6 address and we didn't have a
global IPv6 address of our own...

socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET6, sin6_port=htons(80), inet_pton(AF_INET6, "2001:8b0:10b:1:20d:93ff:fe7a:3f2c", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EADDRNOTAVAIL (Cannot assign requested address)
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("81.187.2.168")}, 16) = 0
getsockname(3, {sa_family=AF_INET, sin_port=htons(33450), sin_addr=inet_addr("172.16.18.126")}, [16]) = 0
Trying 81.187.2.168...

On the newer kernel, the connect() succeeds:

socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET6, sin6_port=htons(80), inet_pton(AF_INET6, "2001:8b0:10b:1:20d:93ff:fe7a:3f2c", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
getsockname(3, {sa_family=AF_INET6, sin6_port=htons(32772), inet_pton(AF_INET6, "::172.16.18.67", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("81.187.2.168")}, 16) = 0
getsockname(3, {sa_family=AF_INET, sin_port=htons(32772), sin_addr=inet_addr("172.16.18.67")}, [16]) = 0
Trying 2001:8b0:10b:1:20d:93ff:fe7a:3f2c...

Is this change in behaviour intentional? Is it useful?

How can we get sane behaviour from glibc again? What we had before was
ideal -- if we have an IPv6 default route _and_ we have a Global IPv6
address of our own, then return the Global IPv6 address in the AAAA
record first. Else return the IPv4 address in the A record.

-- 
dwmw2


From: Mick McCreath <mick_mccreath@au.securecomputing.com>
Subject: raw sockets ignore IP_HDRINCL data
Date: Fri, 01 Jun 2007 15:36:27 +1000
Message-ID: <1180676187.5956.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:58845 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752869AbXFAGCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 02:02:53 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by hex.internal.moreton.com.au (Postfix) with ESMTP id 88747EBA80
	for <netdev@vger.kernel.org>; Fri,  1 Jun 2007 15:36:28 +1000 (EST)
Received: from hex.internal.moreton.com.au ([127.0.0.1])
	by localhost (bne.snapgear.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 25239-08 for <netdev@vger.kernel.org>;
	Fri, 1 Jun 2007 15:36:27 +1000 (EST)
Received: from mmccreat0.sw.moreton.com.au (mmccreat0.sw.moreton.com.au [10.46.1.36])
	by hex.internal.moreton.com.au (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Fri,  1 Jun 2007 15:36:27 +1000 (EST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have a multi-homed system like this:

eth1: 1.2.3.4 GW: 1.2.3.1
eth2: 2.3.4.5 GW: 2.3.4.1

route ouput snippet is:

default 2.3.4.1 0.0.0.0 UG 3 0 0 eth2
default 1.2.3.1 0.0.0.0 UG 4 0 0 eth1
default 2.3.4.1 0.0.0.0 UG 4 0 0 eth2

When I run traceroute -i eth1 5.4.3.2, the UDP packets are routed out
eth2.

Has anybody seen this behaviour with traceroute??

I have done some debugging, and believe this to be an ipv4 kernel bug.
My research came up with the following:

By the traceroute source code, it uses raw sockets and relies on
IP_HDRINCL (which is defined in the kernel source <netinet/in.h>) to
select the routing interface and does not bind the socket to the source
IP address.

I hacked the traceroute source code to do a bind if the -i option is us=
ed,
and the correct GW is used.

I am using a 2.4.29 kernel and have traced through the kernel and
in .../net/ipv4/raw.c, raw_sendmsg() does not read the data to get the
IP header and the source address, which then results in a 0.0.0.0 sourc=
e
address and hence the routing, ip_route_output(), pulls the default
gateway with the lowest metric, in this case eth2.

I have also used a 2.6.21 kernel and similiar behaviour happens. The
2.6.21 kernel source code does not read the IP header from the data
either.

Am I reading/interpreting the source code correctly?

Any other suggestions/more information would be great.

Cheers,

Mick

--=20
--
Mick McCreath
Sr Engineer

Secure Computing=C2=AE
your trusted source for enterprise security=E2=84=A2
www.securecomputing.com
NASDAQ: SCUR

61 7 3435 2803 (Direct Phone)
mick_mccreath@securecomputing.com

Secure Computing Corporation
825 Stanley Street
Woolloongabba
Queensland 4102
Australia

The information contained in this email message may be privileged,
confidential and protected from disclosure. If you are not the intended
recipient, any review, dissemination, distribution or copying is
strictly prohibited. If you have received this email message in error,
please notify the sender by reply email and delete the message and any
attachments.


From: Erik Hugne <erik.hugne@ericsson.com>
Subject: tcp: ip_local_reserved_ports impact on inet_csk_get_port()
Date: Tue, 5 May 2015 14:47:59 +0200
Message-ID: <20150505124759.GA23707@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Richard Alpe <richard.alpe@ericsson.com>,
	Onar Olsen <onar.olsen@ericsson.com>, <ying.xue@windriver.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:61547 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758717AbbEEMxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 08:53:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defining a port range in net.ipv4.ip_local_reserved_ports can cause a linear
and predictable behavior of inet_csk_get_port().
This occurs when smallest_rover = rover = prandom_u32() % remaining + low;
hits a value in the reserved range. The algorithm will then try the next
consecutive port number until a free port is found.

Example:
net.ipv4.ip_local_port_range = 32768	61000
net.ipv4.ip_local_reserved_ports = 35000-61000

This will give ~92% chance that the initial random port will be in the
reserved range, and that the port selection will be done linearly
starting from 32768.
Section 3.3 in RFC6056[1] describes several port selection algorithms, and Linux
seems to follow #1. This does not seem to be the best alternative since
e3826f1e946e ("net: reserve ports for applications using fixed port numbers")

If the local port range is set not to overlap with the reserved ports,
inet_csk_get_port will give a better randomness in the port selection.

//E

[1] https://tools.ietf.org/html/rfc6056

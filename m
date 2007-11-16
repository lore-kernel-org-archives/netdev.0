From: "Jonas Danielsson" <the.sator@gmail.com>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Fri, 16 Nov 2007 09:30:11 +0100
Message-ID: <cac0ab7d0711160030w149c7a7s2db55ac56d0a05cc@mail.gmail.com>
References: <cac0ab7d0711150340p58eda94ah92894072ba328205@mail.gmail.com>
	 <20071115154032.GA30391@ms2.inr.ac.ru>
	 <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
	 <20071115.152813.89410917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:5622 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbXKPIaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 03:30:12 -0500
Received: by py-out-1112.google.com with SMTP id u77so4064817pyb
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 00:30:11 -0800 (PST)
In-Reply-To: <20071115.152813.89410917.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/11/16, David Miller <davem@davemloft.net>:
> From: "Jonas Danielsson" <the.sator@gmail.com>
> Date: Thu, 15 Nov 2007 22:40:13 +0100
>
> > Is there a reason that the target hardware address isn't the target
> > hardware address?
>


> Because of this, in cases where a choice can be made Linux will
> advertise what is most likely to result in successful communication.
>
> This is likely why we are changing that target address to the one of
> the interface actually sending back the reply rather than the zero
> value you used.
>
> In fact I think this information can be useful to the sender of
> the DAD request.
>

There seem to be some confusion about what my patch really does. It
does not set the hardware address to a zero value.

An example to illustrate:

We have two computers.
Computer A
IP: 192.168.0.1
HW: 00:AA:00:AA:00:AA

Computer B
IP: None
HW: 00:BB:00:BB:00:BB

Computer B want to find out if IP 192.168.0.1 is free for use. It
sends an arp-request.

Request:
Opcode: request (0x0001)
Sender HW: 00:BB:00:BB:00:BB
Sender IP:    0.0.0.0
Target HW:   00:00:00:00:00:00
Target IP:     192.168.0.1

The reply from the Linux kernel in computer A, before the patch would look like:

Reply:
Opcode: reply (0x0002)
Sender HW: 00:AA.00:AA:00:AA
Sender IP:   192.168.0.1
Target HW:  00:AA:00:AA:00:AA
Target IP:    192.168.0.1

And the reply from the Linux kernel, in computer A, after the patch
would look like:

Reply:
Opcode: reply (0x0002)
Sender HW: 00:AA.00:AA:00:AA
Sender IP:   192.168.0.1
Target HW:  00:BB:00:BB:00:BB
Target IP:    0.0.0.0

It is the fact that the Target HW  address is set to computer A and
not computer B that my patch wants to fix. And the Target IP: 0.0.0.0
is because OpenBSD and windows replied in that way.

I wanted to change this because, among other things, dhcpcd-2.0.3 has
the following code in its arpCheck-function:

if ( memcmp(ArpMsgRecv.tHaddr,ClientHwAddr,ETH_ALEN) )
if ( DebugFlag )
	    	syslog(LOG_DEBUG,
	    	"target hardware address mismatch:"  [...]

This check will always fail when replies come from Linux machines,
since the target hardware address will not match the client mac
address.


-Jonas

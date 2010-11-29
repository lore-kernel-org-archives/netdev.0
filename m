From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [net-next-2.6] XFRM: remove unused member in xfrm_encap_tmpl.
Date: Mon, 29 Nov 2010 21:27:01 +0200
Message-ID: <4CF3FE85.6040406@iki.fi>
References: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>	<4CF3EBF2.5060308@iki.fi> <AANLkTinQ1qbp9SyWgw7TdvH=5x_1AA6zqLkaa7c4PBGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54804 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab0K2T1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 14:27:04 -0500
Received: by eye27 with SMTP id 27so2222790eye.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 11:27:03 -0800 (PST)
In-Reply-To: <AANLkTinQ1qbp9SyWgw7TdvH=5x_1AA6zqLkaa7c4PBGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2010 09:15 PM, David Shwatrz wrote:
> But isn't something wrong here ?
> 
> According to RFC 3948:
> ...
> 3.1.2.  Transport Mode Decapsulation NAT Procedure
> 
> When a transport mode has been used to transmit packets, contained
>    TCP or UDP headers will have incorrect checksums due to the change of
>    parts of the IP header during transit.  This procedure defines how to
>    fix these checksums
> ...
> incrementally recompute the
>        TCP/UDP checksum:
> 
>        *  Subtract the IP source address in the received packet from the
>           checksum.
>        *  Add the real IP source address received via IKE to the
>           checksum (obtained from the NAT-OA)
> ...
> 
> So where do we pass the NAT-OA, received from IKE messages,  to this
> checksum recalculation process, which should be done in the kernel
> (layer 4 TCP/UDP I suppose) ?
> 
> Should'nt this process be done in the kernel ?
> 
> Isn't there something missing here ?

That's what the field was intended for. Also it's passed around by e.g.
'ip xfrm' command. The header change would break compilation of iproute2
too.

Alternatively the other RFCs say that the checksum can be just
recalculated. That's what the linux stack does: it throws the old
checksum away (ignored on local receive and recalculated on send /
forward paths). The ESP/AH packets are usually also configured to
contain a cryptographic hash, so the packet modifications are detected
even before trying to check the TCP/UDP checksum (making the check
redundant).

There's also probably some legacy reasons why the nat-oa field is useful
in kernel; and why the tcp/udp is not updated according the above
mentioned scheme. I guess doing that might speed up forwarding from one
tunnel to another where hardware checksum acceleration is not available;
maybe no one just had the time to implement it.

- Timo

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 5/6] net/faraday: Enable NCSI interface
Date: Tue, 10 Nov 2015 17:12:50 +1100
Message-ID: <20151110061249.GA8006@gwshan>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447027806-4744-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447029127.8727.29.camel@kernel.crashing.org>
 <20151109073032.GA10235@gwshan>
 <1447100904.31884.26.camel@kernel.crashing.org>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:55044 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbbKJGNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 01:13:46 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 10 Nov 2015 16:13:44 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2319E2CE8050
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:13:42 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAA6DX3030670994
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:13:42 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAA6D8br020513
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:13:09 +1100
Content-Disposition: inline
In-Reply-To: <1447100904.31884.26.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015 at 07:28:24AM +1100, Benjamin Herrenschmidt wrote:
>On Mon, 2015-11-09 at 18:30 +1100, Gavin Shan wrote:
>> 
>> Yeah, It's something that I hilighed in the cover letter. I was
>> thinking we might need a better way to enable Tx/Rx before the
>> interrupt is up, but couldn't figure out one way. So I need some
>> advice here.
>
>No, that's not right. For Tx/Rx to work the interface must be opened,
>there is simply no way around that and that's perfectly fine. The
>situation with an MDIO PHY is the same, most drivers can't talk to
>their PHY until the interface has been opened because the chip is
>basically powered down otherwise.
>
>So we require the interface to be opened to talk, so far so good,
>the NC-SI stack doesn't even need to open it itself, it's acceptable
>to require userspace to do it. IE. Userspace will chose what interface
>to use, open it (for DHCP etc... or whatever other reason) and *that*
>will then trigger the NC-SI negociation.
>

Yes, NCSI is smiliar to PHY to some extent. However, PHY's negotiation
is purly electrical procedure, no packets received from MAC for it. We
have the same situation when the NCSI/PHY is going to be brought down.

At the beginning, the NCSI packets can be received and transmitted after
the interface is opened. Before NCSI negotiation is done, no other packets
can be received and transmitted. For the Rx path (for other packets), the
NCSI link isn't enabled when NCSI negotiation isn't finished. There might
have lots of egress packets whose IP addresses can't be resolved to MAC
address as ARP resolution doesn't work before NCSI negotiation is done.
So there is a weird window: interface is up, but no packets (except NCSI
packets) can be received or transmitted.

When the interface is brought down, for example by "ifconfig eth0 down",
The NCSI interface needs to be teared down by transmitting and receiving
NCSI commands and responses. Similiarly, it introduces another weird window:
interface is down, but NCSI packets still can be transmitted and received.

>Cheers,
>Ben.
>

Thanks,
Gavin

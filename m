From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: don't change gso data on clones
Date: Wed, 11 Feb 2015 12:35:09 -0500
Message-ID: <54DB92CD.1070309@oracle.com>
References: <54DB5711.3040705@oracle.com> <1423662993.4847.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26564 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbbBKRfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 12:35:16 -0500
In-Reply-To: <1423662993.4847.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/11/2015 08:56 AM, Eric Dumazet wrote:
> On Wed, 2015-02-11 at 08:20 -0500, David L Stevens wrote:
>> This patch unclones an skb for the case where the sunvnet driver needs to
>> change the segmentation size so that it doesn't interfere with TCP SACK's
>> use of them.
>>
>> Signed-off-by: David L Stevens <david.stevens@oracle.com>
>> ---
> 
> Hmm... this would point to a TCP bug ?
> 
> What happens if not GSO is needed, TCP corrupts data currently
> read/processed by NIC/driver ?

I don't think I understand your concern. This problem can result in a
panic using sunvnet because the sunvnet driver is changing the original
skb, which is always, or at least almost always, a clone. TCP uses gso_segs
to track packet counts, so changing it in the driver can result in bad math--
TCP assumes its copy of the clone's data shouldn't change (of course).

A driver that doesn't change the segmentation or original data doesn't
need to care whether it's a clone or not-- it'll free it and drop a
reference. Since sunvnet is changing the gso_size and gso_segs, it needs
to unclone first.

						+-DLS

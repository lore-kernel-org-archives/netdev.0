From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 12:51:49 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Tom Herbert (Partner - google)" <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:19731 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751044AbaI3Mvy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 08:51:54 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was pondering what it would take for a network device support
CHECKSUM_COMPLETE on its Rx path. And I simply failed to understand the
specifics when using the napi_gro_receive() interface.

Scenario 1 - TCP/IPv4 packet. This will eventually reach tcp4_gro_receive(), and from
there into skb_gro_checksum_validate().
Since this SKB is marked as COMPLETE, the pseudo TCP checksum will be computed
and skb_gro_checksum_validate_complete() be called.
Now, it seems to me as if the only way by which the flow won't actually try to
re-calculate the checksum over TCP header and payload is if NAPI_GRO_CB(skb)->csum
is actually the one's complement to the TCP pseudo header. But that sounds.... odd,
since that's the csum that should have been listed on the SKB - and it doesn't protect
any of the data, only the "metadata".

Scenario 2 - IP-GRE packet, with CSUM option on the GRE header.
This scenario will also eventually reach skb_gro_checksum_validate_complete(),
this time via gre_gro_receive().
This one is even odder, since in order for the flow not to re-calculate the checksum
The driver should have set the SKB's csum to 0xffffffff [as it's using the
null_compute_pseudo() which will return a pseudo_csum of 0].

>From the comment in skbuff.h regarding CHECKSUM_COMPLETE it looks as if all
the HW needs to do is calculate the checksum over the entire data, starting at the
network header.

So, to summarize my questions -
1. What should a driver set as the SKBs csum value when passing CHECKSUM_COMPLETE?
2. Does the GRO flow for non-encapsulated packets work for packets marked as
CHECKSUM_COMPLETE? And by work, I obviously mean 'doesn't re-calculate checksums'.
3. Same as question 2, but for encapsulated packets.

Thanks,
Yuval



________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

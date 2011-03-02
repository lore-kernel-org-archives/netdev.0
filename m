From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy and source mac selection mode
Date: Tue, 01 Mar 2011 18:56:18 -0800
Message-ID: <413.1299034578@death>
References: <20110301223458.GA24403@yandex-team.ru> <20110301152951.646451c6@nehalam>
Cc: "Oleg V. Ukhno" <olegu@yandex-team.ru>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36084 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755435Ab1CBC4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 21:56:22 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p222Vhgq007296
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 21:31:43 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id DD8EF38C8038
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 21:56:20 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p222uL3x2760816
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 21:56:21 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p222uKOK018718
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 21:56:20 -0500
In-reply-to: <20110301152951.646451c6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>On Wed, 2 Mar 2011 01:34:58 +0300
>"Oleg V. Ukhno" <olegu@yandex-team.ru> wrote:
>
>> Patch introduces two new (related) features to bonding module.
>> First feature is round-robin hashing policy, which is primarily
>> intended for use with 802.3ad mode, and puts every next IPv4 and
>> IPv6 packet into  next availables slave without taling into account
>> which layer3 and above protocol is used.
>> Second feature makes possible choosing which MAC-address will be set
>> in the transmitted packet - when set to src-mac it will force setting
>> slave's interface real MAC address as source MAC address in every
>> packet, sent via this slave interface.
>> Main goal of this patch is to make possible single TCP stream
>> equally striped for both transmitted and received packets over all
>> available slaves.
>> This operating mode is not fully 802.3ad compliant, and will cause
>> some packet reordering in TCP stream, to some kernel tuning may be
>> required.
>> For correct working enabling round-robin hashing policy plus using
>> real slave's MAC addresses as source MAC addresses in transmitted
>> packets requires specific switch setting)hashing mode for port-channel
>> ("etherchannel) should be set to src-mac or src-dst-mac to get
>> correct load-striping on the receiving host's etherchannel.
>> General requirements for using bonding in this operating mode are:
>> - even and preferrably equal number of slaves on sending and receiving
>> hosts;
>> - equal RTT between sending and receiving hosts on all slaves;
>> - switch capable of doing etherchannels and using src-mac or src-dst-mac
>> hashing policy for egress load striping
>> 
>> Signed-off-by: Oleg V. Ukhno <olegu@yandex-team.ru>
>
>It seems to me the whole bonding policy is getting so complex
>that the code is a mess. Perhaps it should be somehow linked into
>existing packet classification or firewall mechanisms.  This would
>increase the flexibility and reduce the amount of policy code
>in the bonding driver itself.

	Hmm.

	Yes, the number of special case knobs in bonding is getting
rather large, and there are one or two other proposals in the pipe
besides this one.

	It would be handy to be able to do things like run ebtables
style rules against traffic going in and out of the bond.  Right now
ebtables is pretty tightly coupled with the bridge, so we'd need to add
a whole new set of netfilter "bondtables" or something.  Or add hooks
for ebtables outside of the bridge.

	For this particular patch, the src-mac business could be handled
by a netfilter module.  The round-robin hash policy part would probably
have to stay in bonding.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

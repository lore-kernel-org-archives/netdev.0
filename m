From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next v2 2/2] vxlan: Remote checksum offload
Date: Tue, 13 Jan 2015 09:26:03 -0800
Message-ID: <CA+mtBx-AiU9RLNDMiWcfFsV0O7=S17o1ee5Qcihuf5-6XSG1zg@mail.gmail.com>
References: <1421110838-5146-1-git-send-email-therbert@google.com>
	<1421110838-5146-3-git-send-email-therbert@google.com>
	<20150113012626.GD20387@casper.infradead.org>
	<20150113114443.GK20387@casper.infradead.org>
	<20150113164011.GO20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:32799 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbbAMR0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:26:04 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so4383163igd.1
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 09:26:04 -0800 (PST)
In-Reply-To: <20150113164011.GO20387@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 8:40 AM, Thomas Graf <tgraf@suug.ch> wrote:
> [Moving this discussion to the thread of the respective patch]
>
> On 01/13/15 at 08:16am, Tom Herbert wrote:
>> On 01/13/15 at 11:44am, Thomas Graf wrote:
>> > The major difference here is that we have to consider backwards
>> > compatibility specifically for VXLAN. Your initial feedback on GPE
>> > actually led me to how I implemented GBP.
>> >
>> > I think the axioms we want to establish are as follows:
>> >  1. Extensions need to be explicitly enabled by the user. A previously
>> >     dropped frame should only be processed if the user explitly asks
>> >     for it.
>> >  2. As a consequence: only share a VLXAN UDP port if the enabled
>> >     extensions match (vxlan_sock_add), e.g. user A might want RCO
>> >     but user B might be unaware. They cannot share the same UDP port.
>> >
>> > The 2nd lead me to introduce the 'exts' member to vxlan_sock so we can
>> > compare it in vxlan_find_sock() and only share a UDP port if the
>> > enabled extensions match.
>> >
>> RCO is represented in the socket in VXLAN flags (VLXAN_F_*). My patch
>> also adds a flags to vxlan_sock which contains the VLXAN flags. For
>> shared port, I suspect all the receive features must match, including
>> receive checksum settings for instance, but we don't care about
>> transmit side. To facilitate this, I would suggest splitting flags
>> into o_flags and i_flags like ip_tunnel does, and then compare i_flags
>> in vxlan_find_sock.
>
> Not sure I understand why you want to omit the transmit side. If a
> VXLAN socket with RCO TX enabled is found and shared with a user
> who does not want RCO enabled, it will get RCO enabled frames which
> will get dropped by non RCO VXLAN receivers.

Yes, if the transmit parameters are shared between different users
then that is an issue and transmit features should be matched. Since
VLXAN is using the same same socket for TX and RX that would appear to
be the case. However, in other encaps like GRE, FOU, & GUE the receive
and transmit paths are separate where each tunnel can have their own
transmit parameters even if they share a common receive port or path.
This allows for useful asymmetric configurations (like defining two
tunnels that receive packets on same port, but one transmits non-zero
UDP checksums and one with zero checksums).

Tom

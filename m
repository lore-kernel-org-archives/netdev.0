From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Tue, 4 Mar 2014 23:49:33 +0100
Message-ID: <a23fcc368f1421286c1115c2365942ce.squirrel@webmail.itwm.fhg.de>
References: <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
    <20140304.170050.2058599034902221847.davem@davemloft.net>
    <cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
    <20140304.172025.2034977449200344617.davem@davemloft.net>
Reply-To: phoebe.buckheister@itwm.fraunhofer.de
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: phoebe.buckheister@itwm.fraunhofer.de, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:44233 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbaCDWtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 17:49:36 -0500
Received: from itwm1.itwm.fhg.de (itwm1.itwm.fhg.de [131.246.191.4])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s24MnYGc027324
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2014 23:49:35 +0100
In-Reply-To: <20140304.172025.2034977449200344617.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why have an intermediate copy when that's not necessary at all?  It
> seems like pure overhead to be.
>
> Furthermore, cpu's have byte-shifting load and store instructions
> which will be used if you make use of the 'p' versions of the endian
> swap functions, such as cpu_to_le16p().
>
> So it's going to cost basically nothing.

I didn't mean the runtime cost of any conversion that might happen, I was
thinking about how much these conversions would affect the code that uses
these header structs. While for the u16/u32 fields this might be not much,
it will be more for the hardware address fields since these are stored as
the little endian encoding of u64 field you get when reading the u8[8] as
a __be64. If I understand you correctly, these fields would also have to
be in network byte order in the header struct, introducing copy-and-swaps
in every upper layer that uses those addresses and making address matching
harder since memcmp won't work anymore.

What would be better here? Explicit endianness on all fields for
consistency and thus __le64 for EUI64 members with copy-swap functions to
convert those addresses into u8[8] where required, explicit endianness on
everything except addresses, or keeping it as is? I'm honestly not sure.

I want to note here that struct ieee802154_addr, which holds the address
information and is also used by BSD socket calls, has always used host
byte order for its own fields. This might itself be a huge mistake, but it
is relevant to this discussion.

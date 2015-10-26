From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension headers
 and recalc checksum during fragmentation
Date: Mon, 26 Oct 2015 19:44:03 +0100
Message-ID: <1445885043.985660.420718105.55D9DB7D@webmail.messagingengine.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
 <CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
 <1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
 <CALx6S35ttmhwMzbPRCkSApbgvJXcgC-kAzuiDQvOc=98mBQEnQ@mail.gmail.com>
 <1445706124.1823412.419177649.420E8888@webmail.messagingengine.com>
 <CALx6S37krurU1nFpC-9aT_EDhZfH7p=-wSrSjUSNKvm5+s_c2Q@mail.gmail.com>
 <1445852946.87102.420207505.5C1EF1DC@webmail.messagingengine.com>
 <CALx6S34WNYxQ4HOG0hg-jO_U-OYhGABS8xaqTD1v4Q0fx-6QtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:42947 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbbJZSoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 14:44:05 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id E95CA2073F
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 14:44:03 -0400 (EDT)
In-Reply-To: <CALx6S34WNYxQ4HOG0hg-jO_U-OYhGABS8xaqTD1v4Q0fx-6QtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, Oct 26, 2015, at 15:19, Tom Herbert wrote:
> > We already concluded that drivers do have this problem and not the stack
> > above ip6_fragment. The places I am aware of I fixed in this patch. Also
> > IPv4 to me seems unaffected, albeit one can certainly clean up the logic
> > in net-next.
> >
> I don't understand why checksum for IP fragments is a driver problem.
> When fragments are sent to driver they should never have
> CHECKSUM_PARTIAL set (or maybe that is what you are seeing?).

Because either the drivers or the hardware does not correctly iterate
over the extension headers to fetch the final nexthdr field which is
used to compute the checksum. This is different from IPv4.

I can only guess e.g. from the e1000e driver:

        case cpu_to_be16(ETH_P_IPV6):
                /* XXX not handling all IPV6 headers */
                if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
                        cmd_len |= E1000_TXD_CMD_TCP;
                break;

> > Do you want to move the skb_checksum_help() check to the front of
> > ip_fragment in ipv4 now too?
> >
> Yes, it seems to me we should never fragment a packets with
> CHECKSUM_PARTIAL. This seems to currently be possible in IP output (v4
> & v6). I would imagine that we don't see this bug trip (too often?)
> because most uses of UDP got through the user space fragmentation
> code, and UDP packets sent through kernel path probably don't have a
> frag_list so they go through slow path.

I agree.

> Also, as Eric suggested, it looks like your patch is doing two things
> (fixing csum/fragmentation and disabling csum_partial for any
> extension headers)-- these should be separate patches.

I will now split the patches as a consensus seems reached here (and
write a commit message :) ). I audit the IPv4 paths, too.

Thanks,
Hannes

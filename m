From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 06 Aug 2014 09:05:49 +0200
Message-ID: <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
	 <1407204710-21778-6-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:52708 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaHFHFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 03:05:53 -0400
Received: by mail-we0-f173.google.com with SMTP id q58so2125274wes.32
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 00:05:52 -0700 (PDT)
In-Reply-To: <1407204710-21778-6-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-04 at 22:11 -0400, Willem de Bruijn wrote:
> TCP timestamping extends SO_TIMESTAMPING to bytestreams.
> 
> Bytestreams do not have a 1:1 relationship between send() buffers and
> network packets. The feature interprets a send call on a bytestream as
> a request for a timestamp for the last byte in that send() buffer.
> 
> The choice corresponds to a request for a timestamp when all bytes in
> the buffer have been sent. That assumption depends on in-order kernel
> transmission. This is the common case. That said, it is possible to
> construct a traffic shaping tree that would result in reordering.
> The guarantee is strong, then, but not ironclad.
> 
> This implementation supports send and sendpages (splice). GSO replaces
> one large packet with multiple smaller packets. This patch also copies
> the option into the correct smaller packet.
> 
> This patch does not yet support timestamping on data in an initial TCP
> Fast Open SYN, because that takes a very different data path.
> 
> If ID generation in ee_data is enabled, bytestream timestamps return a
> byte offset, instead of the packet counter for datagrams.
> 
> The implementation supports a single timestamp per packet. It silenty
> replaces requests for previous timestamps. To avoid missing tstamps,
> flush the tcp queue by disabling Nagle, cork and autocork. Missing
> tstamps can be detected by offset when the ee_data ID is enabled.
> 
> Implementation details:
> 
> - On GSO, the timestamping code can be included in the main loop. I
> moved it into its own loop to reduce the impact on the common case
> to a single branch.
> 
> - To avoid leaking the absolute seqno to userspace, the offset
> returned in ee_data must always be relative. It is an offset between
> an skb and sk field. The first is always set (also for GSO & ACK).
> The second must also never be uninitialized. Only allow the ID
> option on sockets in the ESTABLISHED state, for which the seqno
> is available. Never reset it to zero (instead, move it to the
> current seqno when reenabling the option).
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> 


I believe you missed fact that a GSO packet can be split into 2 or many
skbs, when tcp_write_xmit() has to send a lower amount.

This is done in tso_fragment()

Also, I am a bit worried about retransmits ?

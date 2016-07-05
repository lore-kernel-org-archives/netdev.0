From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Tue, 5 Jul 2016 17:05:41 +0300
Message-ID: <20160705170541.3f210675@pixies>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
	<20160705130327.GA10737@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36688 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbcGEOFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 10:05:49 -0400
Received: by mail-wm0-f52.google.com with SMTP id f126so138905787wma.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 07:05:48 -0700 (PDT)
In-Reply-To: <20160705130327.GA10737@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Jul 2016 15:03:27 +0200, fw@strlen.de wrote:
> > The expected behavior in such a setup would be segmenting the skb first,
> > and then fragmenting each segment according to dst mtu, and finally
> > passing the resulting fragments to ip_finish_output2.
> > 
> > 'ip_finish_output_gso' already supports this "Slowpath" behavior,
> > but it is only considered if IPSKB_FORWARDED is set.
> > 
> > However in the bridged case, IPSKB_FORWARDED is off, and the "Slowpath"
> > behavior is not considered.
> 
> I placed this test there under the assumption that L2 bridges have
> the same MTU on all bridge ports, so we'd only need to consider routing
> case.

In our setups we have no control of VM mtu (which affects gso_size of
packets arriving from tap), and no control of vxlan's underlay mtu.

> How does work if e.g. 1460-sized udp packet arrives on tap0?
> Do we fragment (possibly ignoring DF?)

A *non* gso udp packet arriving on tap0 is bridged to vxlan0 (assuming
vxlan mtu is sufficient), and the original DF of the inner packet is
preserved.

The skb gets vxlan-udp encapsulated, with outer IP header having DF=0
(unless tun_flags & TUNNEL_DONT_FRAGMENT), and then, if skb->len > mtu,
fragmented normally at the ip_finish_output --> ip_fragment code path.

So on wire we have 2 frags of the vxlan datagram; they are reassembled
at recepient ip stack of vxlan termination. Inner packet preserved.
Not ideal, but works.

The issue is with GSO skbs arriving from tap, which eventually generates
segments larger then the mtu, which are not transmitted on eth0:

  tap0 rx:  super packet, gso_size from user's virtio_net_hdr
    ...
    vxlan0 tx:  encaps the super packet
      ...
      ip_finish_output
        ip_finish_output_gso
          *NO* skb_gso_validate_mtu()     <--- problem here
            ip_finish_output2:  tx the encapsulated super packet on eth0
              ...
              validate_xmit_skb
                netif_needs_gso
                  skb_gso_segment: segments inner payload according to
                                   original gso_size,
                                   leads to vxlan datagrams larger than mtu

> How does it work for non-ip protocols?

The specific problem is with vxlan (or any other udp based tunnel)
encapsulated GSOed packets.

> (Or did I misunderstand this setup...?)

tap0 bridged with vxlan0.
route to vxlan0's remote peer is via eth0, configured with small mtu.

Regards,
Shmulik

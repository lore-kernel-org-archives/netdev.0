From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/9][RFC] KVM virtio_net performance
Date: Mon, 11 Aug 2008 17:44:27 +1000
Message-ID: <200808111744.27915.rusty@rustcorp.com.au>
References: <1216899979-32532-1-git-send-email-markmc@redhat.com> <4888EC61.8050208@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58084 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbYHKHpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 03:45:38 -0400
In-Reply-To: <4888EC61.8050208@codemonkey.ws>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 July 2008 06:56:01 you wrote:
> I'm still seeing the same problem I saw with my patch series.  Namely,
> dhclient fails to get a DHCP address.

This is, from one point of view, a dhclient bug.  It opens a packet socket, 
and we'd tell it that the checksum is incomplete via auxdata, but it doesn't 
have auxdata.

On the other hand, perhaps we should copy the packet and checksum it in this 
case?  Not many devices input packets with partial csums, so dhclient doesn't 
normally hit this.  Xen might though?

ie, in net/packet/af_packet.c's packet_recvmsg():

	if (pkt_sk(sk)->auxdata) {
		struct tpacket_auxdata aux;

		aux.tp_status = TP_STATUS_USER;
		if (skb->ip_summed == CHECKSUM_PARTIAL)
			aux.tp_status |= TP_STATUS_CSUMNOTREADY;
		aux.tp_len = PACKET_SKB_CB(skb)->origlen;
		aux.tp_snaplen = skb->len;
		aux.tp_mac = 0;
		aux.tp_net = skb_network_offset(skb);
		aux.tp_vlan_tci = skb->vlan_tci;

		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
	}

add an "else if (skb->ip_summed == CHECKSUM_PARTIAL)" case...

Rusty.

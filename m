From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Tue, 02 Nov 2004 00:08:49 +0100
Message-ID: <4186C201.5030004@tpack.net>
References: <41797696.9070905@candelatech.com>	 <20041022214611.GA4948@electric-eye.fr.zoreil.com>	 <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>	 <4181838B.6040002@tpack.net>  <41818D99.9020300@candelatech.com> <1099038566.1813.99.camel@cyan.cph.tpack.net> <418281C1.9080707@candelatech.com> <4182D44E.7070507@tpack.net> <4182DABE.7000502@candelatech.com> <4182E0C6.6090205@tpack.net> <4186876E.5040204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4186876E.5040204@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> How does this look?  I think it should fix the problem with
> having a new skb created in the __vlan_put_tag() method.

Yes, this seems to be handled correctly now.

Two nitpickings:
  - veth should be reassigned after calling __vlan_put_tag
  - sample skb->len before calling dev_queue_xmit and use that to
    update stats->tx_bytes (it can be different from skb2->len)

And then there's the return values ...

This is a hard_start_xmit() method, so we should try to be
consistent with real device drivers. The only defined return
values are: NETDEV_TX_OK and NETDEV_TX_BUSY.
(There is also Andi's NETDEV_TX_LOCKED, which we can ignore here).

Furthermore transmission shouldn't be retried in case of failure,
only on congestion does this make sense.

So my suggestion for the last part of the function is:

	len = skb->len;
	rv = dev_queue_xmit(skb);
	if (rv < 0) {
		stats->tx_dropped++;
		kfree_skb(skb2);
		ret = NETDEV_TX_OK;
	} else if (rv == NET_XMIT_SUCCESS || rv == NET_XMIT_CN) {
		stats->tx_packets++;
		stats->tx_bytes += len;
		kfree_skb(skb2);
		ret = NETDEV_TX_OK;
	} else {
		/* The device below us is congested */
		ret = NETDEV_TX_BUSY;
	}

	return ret;


-Tommy

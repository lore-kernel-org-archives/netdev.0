From: David Howells <dhowells@redhat.com>
Subject: Fun splitting reassembled UDP skbuffs
Date: Sun, 04 Mar 2007 14:53:35 +0000
Message-ID: <14258.1173020015@redhat.com>
Cc: netdev@vger.kernel.org, dhowells@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932932AbXCDOxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2007 09:53:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hi Dave,

Is it possible to mix the likes of skb_clone(), pskb_pull() and pskb_trim()?
I've tried to do this and I seem to end up with skb refcounting errors amongst
other things.

As it happens, the UDP packet was fragmented, and so the skbuff I've got is
non-linear.

The problem I've got to deal with is that RxRPC permits you to glue packets
together into one UDP datagram (a jumbogram).  If the UDP datagram wasn't
fragmented, you'd end up with a single packet looking like this:

	+---------------+
	|  IP header	|
	+---------------+
	|  UDP header	|
	+---------------+
	|  RxRPC header	|	<--- has the RXRPC_JUMBO_PACKET flag set
	+---------------+
	:		:
	:  Data		:
	:		:
	+---------------+
	|  Jumbo header	|	<--- has the RXRPC_JUMBO_PACKET flag set
	+---------------+
	:		:
	:  Data		:
	:		:
	+---------------+
	|  Jumbo header	|	<--- has the RXRPC_JUMBO_PACKET flag set
	+---------------+
	:		:
	:  Data		:
	:		:
	+---------------+
	|  Jumbo header	|
	+---------------+
	:		:
	:  Data		:
	:		:
	+---------------+

This is equivalent to four lots of this:

	+---------------+
	|  IP header	|
	+---------------+
	|  UDP header	|
	+---------------+
	|  RxRPC header	|
	+---------------+
	:		:
	:  Data		:
	:		:
	+---------------+

With the sequence number and serial number advanced by 1 in each successive
packet and the flags and checksums set appropriately for each.

Theoretically, it is permissible for an intervening agency (such as a router)
to split a jumbo packet back into its constituent data packets and send them
on.  If that doesn't happen, then the intended receiver has to reconstitute
them.  For reference, the RxRPC header looks like this:

	struct rxrpc_header {
		__be32	epoch;
		__be32	cid;
		__be32	callNumber;
		__be32	seq;
		__be32	serial;
		u8	type;
		u8	flags;
		u8	userStatus;
		u8	securityIndex;
		__be16	_rsvd;		// security checksum
		__be16	serviceId;
	};

And the jumbo header looks like this:

	struct rxrpc_jumbo_header {
		u8	flags;
		u8	pad;
		__be16	_rsvd;		// security checksum
	};

The RxRPC headers are reconstituted by fixing the sequence and serial numbers
as previously mentioned, and then replacing the flags and checksum fields in
the RxRPC header with the replacements included in the Jumbo header for each
packet.

So, I have a function that looks like this:

	void rxrpc_process_jumbo_packet(struct rxrpc_call *call,
					struct sk_buff *jumbo)
	{
		struct rxrpc_jumbo_header jhdr;
		struct rxrpc_skb_priv *sp;
		struct sk_buff *part;

		kenter(",{%u}", jumbo->data_len);

		sp = rxrpc_skb(jumbo);

		do {
			sp->hdr.flags &= ~RXRPC_JUMBO_PACKET;

			/* make a clone to represent the first subpacket in
			 * what's left of the jumbo packet */
			part = skb_clone(jumbo, GFP_ATOMIC);
			if (!part) {
				/* simply ditch the tail in the event of
				 * ENOMEM */
				pskb_trim(jumbo, RXRPC_JUMBO_DATALEN);
				break;
			}

			pskb_trim(part, RXRPC_JUMBO_DATALEN);

			if (!pskb_pull(jumbo, RXRPC_JUMBO_DATALEN))
				goto protocol_error;

			if (skb_copy_bits(jumbo, 0, &jhdr, sizeof(jhdr)) < 0)
				goto protocol_error;
			if (!pskb_pull(jumbo, sizeof(jhdr)))
				BUG();

			sp->hdr.seq	= htonl(ntohl(sp->hdr.seq) + 1);
			sp->hdr.serial	= htonl(ntohl(sp->hdr.serial) + 1);
			sp->hdr.flags	= jhdr.flags;
			sp->hdr._rsvd	= jhdr._rsvd;

			kproto("Rx DATA Jumbo %%%u", ntohl(sp->hdr.serial) - 1);

			rxrpc_fast_process_packet(call, part);
			part = NULL;

		} while (sp->hdr.flags & RXRPC_JUMBO_PACKET);

		rxrpc_fast_process_packet(call, jumbo);
		kleave("");
		return;

	protocol_error:
	...
	}

This function is called with the UDP and RxRPC headers already pskb_pull()'d
from the packet.  The rxrpc_skb_priv struct is stored in jumbo->cb and
contains a copy of the RxRPC header placed there by the caller.  The packet
itself has been skb_orphan()'d.

I was wondering if I should use skb_split() instead of skb_clone()'ing the
packet and adjusting with pskb_pull() and pskb_trim(), but it's not obvious
what the base for the length argument to skb_split() is.  Also, from reading
the comments in and around these functions, it's not clear that using one of
them won't cause a clone to wind up in a bad state.

I'm seeing odd effects that seem to indicate that I may not be disassembling
the jumbogram correctly and that I've got refcounting errors:

	[0swappe] ==> rxrpc_process_jumbo_packet(,{1384})
	[0swappe] ### Rx DATA Jumbo %32
	[0swappe]     Rx serial %32 [DATA]
	[0swappe]     Rx DATA %32 { #32 }
	[0swappe]     Rx serial %33 [DATA]
	[0swappe]     ACK Requested on %33
	[0swappe]     Rx DATA %33 { #33 }
	[0swappe] <== rxrpc_process_jumbo_packet()
 bad-->	[0swappe]     Rx serial %1802201963 [UHAWHEAVAUATSH]
	...
	Slab corruption: start=ffff81003bed5618, len=216
	Redzone: 0x5a2cf071/0x5a2cf071.
	Last user: [<ffffffff803c4bfd>](kfree_skbmem+0x7a/0x7f)
	0b0: 6b 6b 6b 6b 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
	Single bit error detected. Probably bad RAM.
	Run memtest86+ or a similar memory test tool.
	Prev obj: start=ffff81003bed5528, len=216
	Redzone: 0x5a2cf071/0x5a2cf071.
	Last user: [<ffffffff803c4bfd>](kfree_skbmem+0x7a/0x7f)
	000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
	010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
	Next obj: start=ffff81003bed5708, len=216
	Redzone: 0x5a2cf071/0x5a2cf071.
	Last user: [<ffffffff803c4bfd>](kfree_skbmem+0x7a/0x7f)
	000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
	010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b

David

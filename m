From: Chuck Anderson <cra@WPI.EDU>
Subject: bridge should flood non-IPv4-multicast ethernet frames
Date: Tue, 13 Sep 2011 16:00:27 -0400
Message-ID: <20110913200027.GQ28007@angus.ind.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL1.WPI.EDU ([130.215.36.91]:49629 "EHLO MAIL1.WPI.EDU"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932506Ab1IMUbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 16:31:16 -0400
Received: from MAIL1.WPI.EDU (MAIL1.WPI.EDU [130.215.36.91])
	by MAIL1.WPI.EDU (8.14.5/8.14.5) with ESMTP id p8DK0U3a009555
	for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 16:00:30 -0400
Received: from SMTP.WPI.EDU (SMTP.WPI.EDU [130.215.36.186])
	by MAIL1.WPI.EDU (8.14.5/8.14.5) with ESMTP id p8DK0UXT009552
	for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 16:00:30 -0400
Received: from angus.ind.WPI.EDU (ANGUS.IND.WPI.EDU [130.215.130.21])
	by SMTP.WPI.EDU (8.14.4/8.14.4) with ESMTP id p8DK0RYM002677
	for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 16:00:28 -0400
	(envelope-from cra@WPI.EDU)
Received: from angus.ind.WPI.EDU (angus.ind.WPI.EDU [127.0.0.1])
	by angus.ind.WPI.EDU (8.14.2/8.14.2) with ESMTP id p8DK0R9P016864
	for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 16:00:27 -0400
Received: (from cra@localhost)
	by angus.ind.WPI.EDU (8.14.2/8.14.2/Submit) id p8DK0RW9016863
	for netdev@vger.kernel.org; Tue, 13 Sep 2011 16:00:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the bridge code grew multicast snooping capability (currently
IPv4/IGMPv2-only as I understand it), it stopped flooding non-IPv4
multicast ethernet frames.  This breaks the capability to bridge any
non-IPv4 protocols that also use multicast ethernet frames, such as
IPv6 and IS-IS, while the bridge snooping capability remains enabled
(it appears to be default enabled at least in the RHEL 6 vendor
kernel).  I noticed this when IPv6 neighbor discovery (ND) and router
advertisement (RA) packets weren't making it to a KVM guest via br0 on
the host, breaking IPv6 connectivity to the guest.  This type of thing
is a common bug with vendor's multicast snooping implementations, but
I was surprised to discover that Linux has this same bug.  See RFC
4541, section 1, last paragraph, and section 2.1.2, paragraph 4:

http://tools.ietf.org/html/rfc4541.html

I believe the relevent code is in br_device.c:

	if (is_broadcast_ether_addr(dest))
		br_flood_deliver(br, skb);
	else if (is_multicast_ether_addr(dest)) {
		if (unlikely(netpoll_tx_running(dev))) {
			br_flood_deliver(br, skb);
			goto out;
		}
		if (br_multicast_rcv(br, NULL, skb)) {
			kfree_skb(skb);
			goto out;
		}

		mdst = br_mdb_get(br, skb);
		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
			br_multicast_deliver(mdst, skb);
		else
			br_flood_deliver(br, skb);
	} else if ((dst = __br_fdb_get(br, dest)) != NULL)
		br_deliver(dst->dst, skb);
	else
		br_flood_deliver(br, skb);

is_multicast_ether_addr() only checks to see if the lowest bit is
1--i.e. any multicast ethernet address.  That check alone isn't
sufficient.  There also needs to be a check that the ethernet frame is
in one of the well-known formats for the particular protocol for which
snooping is supported, IPv4 being the only one supported by Linux
bridging so far.

I see a few ways to fix this:

1.  IPv4 Multicast always uses multicast ethernet addresses in the
format 01:00:5E:xx:xx:xx.  Insert a check that the dest address
matches 01:00:5E:xx:xx:xx, otherwise always flood the frame so we
don't break non-IPv4-multicast frames from being bridged.  Something
like this pseudocode:

	if (is_broadcast_ether_addr(dest))
		br_flood_deliver(br, skb);
	else if (is_ipv4_multicast_ether_addr(dest)) {

...

static inline int is_ipv4_multicast_ether_addr(const u8 *addr)
{
	return (addr[0] == 0x01 && addr[1] == 0x00 && addr[2] == 0x5e);
}


2. Check that the Ethertype is 0x800 (IPv4), and if it is not, always
flood the frame so we don't break non-IPv6-multicast frames being
bridged.

3. Do both of the above, the key point being that IPv6 multicast
frames (33:33:xx:xx:xx:xx), along with any other ethernet multicast
frames that aren't supported by the current bridge snooping code,
should always be flooded unconditionally.  IS-IS for example uses
01:80:C2:00:00:14 and 01:80:C2:00:00:15.

Thoughts?

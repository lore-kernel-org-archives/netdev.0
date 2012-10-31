From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Wed, 31 Oct 2012 15:20:30 -0700
Message-ID: <5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>,
	tcpdump-workers@lists.tcpdump.org
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mail.sonic.net ([64.142.16.245]:37127 "EHLO a.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550Ab2JaXLX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 19:11:23 -0400
In-Reply-To: <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 31, 2012, at 2:50 PM, Ani Sinha <ani@aristanetworks.com> wrote:

> pcap files that already have the tags reinsrted should work with
> current filter code. However for live traffic, one has to get the tags
> from CMSG() and then reinsert it back to the packet for the current
> filter to work.

*Somebody* has to do that, at least to packets that pass the filter, before they're handed to a libpcap-based application, for programs that expect to see packets as they arrived from/were transmitted to the wire to work.

I.e., the tags *should* be reinserted by libpcap, and, as I understand it, that's what the

	#if defined(HAVE_PACKET_AUXDATA) && defined(HAVE_LINUX_TPACKET_AUXDATA_TP_VLAN_TCI)
		...
	#endif

blocks of code in pcap-linux.c in libpcap are doing.

Now, if filtering is being done in the *kernel*, and the tags aren't being reinserted by the kernel, then filter code stuffed into the kernel would need to differ from filter code run in userland.  There's already precedent for that on Linux, with the "cooked mode" headers; those are synthesized by libpcap from the metadata returned for PF_PACKET sockets, and the code that attempts to hand the kernel a filter goes through the filter code, which was generated under the assumption that the packet begins with a "cooked mode" header, and modifies (a copy of) the code to, instead, use the special Linux-BPF-interpreter offsets to access the metadata.

The right thing to do here would be to, if possible, do the same, so that the kernel doesn't have to reinsert VLAN tags for packets that aren't going to be handed to userland.

And, yes, if that should be done for some interfaces with some kernel versions but not all interfaces for all kernel versions, there would need to be a way for libpcap to ask whether it's necessary.  Is it necessary on any interfaces *before* the kernel change in question?
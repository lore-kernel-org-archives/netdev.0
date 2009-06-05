From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 5 Jun 2009 10:18:15 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906050959380.23895@gentwo.org>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org> <20090603.224104.222901210.davem@davemloft.net> <alpine.DEB.1.10.0906041150590.3204@gentwo.org> <20090604.153057.178458221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:37720 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751226AbZFEOSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 10:18:22 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 83B1C82CDED
	for <netdev@vger.kernel.org>; Fri,  5 Jun 2009 10:33:24 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XM0i0uoBM1Ti for <netdev@vger.kernel.org>;
	Fri,  5 Jun 2009 10:33:24 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1B90C82CDEF
	for <netdev@vger.kernel.org>; Fri,  5 Jun 2009 10:33:18 -0400 (EDT)
In-Reply-To: <20090604.153057.178458221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Jun 2009, David Miller wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Thu, 4 Jun 2009 11:52:48 -0400 (EDT)
>
> > On Wed, 3 Jun 2009, David Miller wrote:
> >
> >> We don't do this for ARP, for example.  We have a 3 packet limit just
> >> like IPoIB implements for multicast here.
> >
> > ARP is a management protocol with specific semantics. Socket protocols are
> > dealing with streams of datagrams.
>
> Go look at what the ARP backlog queue actually does, then come back to
> this conversation (hint: it's not a backlog for ARP packets, it's
> a backlog for packets waiting for ARP to resolve).

ARP is tied to managing small chunks of information about the network
infrastructure. Buffering the first few and throwing the rest away is
appropriate there for what the ARP protocol intends to do.

UDP multicasting can be used for streaming information. And right now the
IPoIB layer is dropping thousands of packets whenever there was a pause of
a few minutes or when a new multicast group is used and there is some
delay that the network need to reestablish the multicast route.

On IPoIB the app can send without being throttled to the speed supported
by the hardware in these cases. The faster the cpu we get the more packets
will be dropped in these bursts. The socket layer has an option to not
wait using MSG_DONTWAIT but in these cases we are not honoring that the
flag is not set. We simply drop the packets.

If UDP multicasting is used for a purpose like ARP then this is
appropriate but UDP multicasting has a variety of uses. If you want ARP
style semantics then the buffer size can be limited in such a way that
only 3 packets are bufferd by setting SO_SNDBUF and using MSG_DONTWAIT.

But without the patch this method is forced upon all uses of UDP
multicast for IPoIB layer.

And strangely if you use a 1G NIC everything is fine and the socket layer
properly throttles for packet bursts.




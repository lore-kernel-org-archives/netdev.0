From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Fri, 09 Mar 2007 11:53:23 -0500
Message-ID: <45F19103.3010100@pobox.com>
References: <20070308231556.GE30703@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Norbert Eicker <n.eicker@fz-juelich.de>,
	Jens Osterkamp <jens@de.ibm.com>,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57858 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767402AbXCIQxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:53:45 -0500
In-Reply-To: <20070308231556.GE30703@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Jeff, 
> 
> Please apply. The rather long patch description is from the submitter,
> Norbert Eicker, I don't know if that's alright, or if I should ask to 
> have it trimmed.
> 
> Thanks, 
> --linas
> 
> From: Norbert Eicker <n.eicker@fz-juelich.de>
> 
> I found out that the spidernet-driver is unable to send fragmented IP 
> frames.
> 
> Let me just recall the basic structure of "normal" UDP/IP/Ethernet 
> frames (that actually work):
>  - It starts with the Ethernet header (dest MAC, src MAC, etc.)
>  - The next part is occupied by the IP header (version info, length of 
> packet, id=0, fragment offset=0, checksum, from / to address, etc.)
>  - Then comes the UDP header (src / dest port, length, checksum)
>  - Actual payload
>  - Ethernet checksum
> 
> Now what's different for IP fragment:
>  - The IP header has id set to some value (same for all fragments), 
> offset is set appropriately (i.e. 0 for first fragment, following 
> according to size of other fragments), size is the length of the frame.
>  - UDP header is unchanged. I.e. length is according to full UDP 
> datagram, not just the part within the actual frame! But this is only 
> true within the first frame: all following frames don't have a valid 
> UDP-header at all.
> 
> The spidernet silicon seems to be quite intelligent: It's able to 
> compute (IP / UDP / Ethernet) checksums on the fly and tests if frames 
> are conforming to RFC -- at least conforming to RFC on complete frames.
> 
> But IP fragments are different as explained above:
> I.e. for IP fragments containing part of a UDP datagram it sees 
> incompatible length in the headers for IP and UDP in the first frame 
> and, thus, skips this frame. But the content *is* correct for IP 
> fragments. For all following frames it finds (most probably) no valid 
> UDP header at all. But this *is* also correct for IP fragments.
> 
> The Linux IP-stack seems to be clever in this point. It expects the 
> spidernet to calculate the checksum (since the module claims to be able 
> to do so) and marks the skb's for "normal" frames accordingly 
> (ip_summed set to CHECKSUM_HW).
> But for the IP fragments it does not expect the driver to be capable to 
> handle the frames appropriately. Thus all checksums are allready 
> computed. This is also flaged within the skb (ip_summed set to 
> CHECKSUM_NONE).
> 
> Unfortunately the spidernet driver ignores that hints. It tries to send 
> the IP fragments of UDP datagrams as normal UDP/IP frames. Since they 
> have different structure the silicon detects them the be not 
> "well-formed" and skips them.
> 
> The following one-liner against 2.6.21-rc2 changes this behavior. If the 
> IP-stack claims to have done the checksumming, the driver should not 
> try to checksum (and analyze) the frame but send it as is.
> 
> Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

are you sure it can't send out fragmented IP frames?  what's really 
going on here?

patch was corrupted anyway, and could not be applied...



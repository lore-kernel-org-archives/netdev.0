From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [Qemu-devel] TCP performance problems - GSO/TSO, MSS, 8139cp
 related
Date: Mon, 14 Nov 2016 09:29:48 +0000
Message-ID: <20161114092947.GB2031@work-vm>
References: <20161111210500.GE1041@n2100.armlinux.org.uk>
 <1478899423.3892.7.camel@infradead.org>
 <20161111224427.GG1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>, netdev@vger.kernel.org,
        qemu-devel@nongnu.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        jasowang@redhat.com, vyasevic@redhat.com, stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932141AbcKNJ3y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 04:29:54 -0500
Content-Disposition: inline
In-Reply-To: <20161111224427.GG1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Russell King - ARM Linux (linux@armlinux.org.uk) wrote:
> On Fri, Nov 11, 2016 at 09:23:43PM +0000, David Woodhouse wrote:
> > It's also *fairly* unlikely that the kernel in the guest has developed
> > a bug and isn't setting gso_size sanely. I'm more inclined to suspect
> > that qemu isn't properly emulating those bits. But at first glance at
> > the code, it looks like *that's* been there for the last decade too...
> 
> I take issue with that, having looked at the qemu rtl8139 code:
> 
>                 if ((txdw0 & CP_TX_LGSEN) && ip_protocol == IP_PROTO_TCP)
>                 {
>                     int large_send_mss = (txdw0 >> 16) & CP_TC_LGSEN_MSS_MASK;
> 
>                     DPRINTF("+++ C+ mode offloaded task TSO MTU=%d IP data %d "
>                         "frame data %d specified MSS=%d\n", ETH_MTU,
>                         ip_data_len, saved_size - ETH_HLEN, large_send_mss);
> 
> That's the only reference to "large_send_mss" there, other than that,
> the MSS value that gets stuck into the field by 8139cp.c is completely
> unused.  Instead, qemu does this:
> 
>                 eth_payload_data = saved_buffer + ETH_HLEN;
>                 eth_payload_len  = saved_size   - ETH_HLEN;
> 
>                 ip = (ip_header*)eth_payload_data;
> 
>                     hlen = IP_HEADER_LENGTH(ip);
>                     ip_data_len = be16_to_cpu(ip->ip_len) - hlen;
> 
>                     tcp_header *p_tcp_hdr = (tcp_header*)(eth_payload_data + hlen);
>                     int tcp_hlen = TCP_HEADER_DATA_OFFSET(p_tcp_hdr);
> 
>                     /* ETH_MTU = ip header len + tcp header len + payload */
>                     int tcp_data_len = ip_data_len - tcp_hlen;
>                     int tcp_chunk_size = ETH_MTU - hlen - tcp_hlen;
> 
>                     for (tcp_send_offset = 0; tcp_send_offset < tcp_data_len; tcp_send_offset += tcp_chunk_size)
>                     {
> 
> It uses a fixed value of ETH_MTU to calculate the size of the TCP
> data chunks, and this is not surprisingly the well known:
> 
> #define ETH_MTU     1500
> 
> Qemu seems to be buggy - it ignores the MSS value, and always tries to
> send 1500 byte frames.

cc'ing in Stefan who last touched that code and Jason and Vlad who
know the net code.

Dave

> -- 
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
> 

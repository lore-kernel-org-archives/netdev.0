From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Tue, 17 Jan 2012 17:28:19 +0100
Message-ID: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tore@fud.no
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64306 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841Ab2AQQ2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 11:28:24 -0500
Received: by wgbdq11 with SMTP id dq11so2118989wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 08:28:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bugzilla reference :

https://bugzilla.kernel.org/show_bug.cgi?id=42572

> An IPv4 client behind a link with a MTU of 1259 downloading a file from an IPv6
> server
> 
> When RTAX_FEATURE_ALLFRAG is set on a route, the effective TCP segment
> size does not take into account the size of the IPv6 Fragmentation
> header that needs to be included in outbound packets, causing every
> transmitted TCP segment to be fragmented across two IPv6 packets, the
> latter of which will only contain 8 bytes of actual payload.
> 
> RTAX_FEATURE_ALLFRAG is typically set on a route in response to
> receving a ICMPv6 Packet Too Big message indicating a Path MTU of less
> than 1280 bytes. 1280 bytes is the minimum IPv6 MTU, however ICMPv6
> PTBs with MTU < 1280 are still valid, in particular when an IPv6
> packet is sent to an IPv4 destination through a stateless translator.
> Any ICMPv4 Need To Fragment packets originated from the IPv4 part of
> the path will be translated to ICMPv6 PTB which may then indicate an
> MTU of less than 1280.
> 
> RFC 2460 section 5 specifies what an IPv6 stack should do when this
> happens:
> 
> > In response to an IPv6 packet that is sent to an IPv4 destination
> > (i.e., a packet that undergoes translation from IPv6 to IPv4), the
> > originating IPv6 node may receive an ICMP Packet Too Big message
> > reporting a Next-Hop MTU less than 1280.  In that case, the IPv6 node
> > is not required to reduce the size of subsequent packets to less than
> > 1280, but must include a Fragment header in those packets so that the
> > IPv6-to-IPv4 translating router can obtain a suitable Identification
> > value to use in resulting IPv4 fragments.  Note that this means the
> > payload may have to be reduced to 1232 octets (1280 minus 40 for the
> > IPv6 header and 8 for the Fragment header), and smaller still if
> > additional extension headers are used.
> 
> The Linux kernel refuses to reduce the effective MTU to anything below
> 1280 bytes, instead it sets it to exactly 1280 bytes, and
> RTAX_FEATURE_ALLFRAG is also set. However, the TCP segment size appears
> to be set to 1240 bytes (1280 Path MTU - 40 bytes of IPv6 header),
> instead of 1232 (additionally taking into account the 8 bytes required
> by the IPv6 Fragmentation extension header).
> 
> This in turn results in rather inefficient transmission, as every 
> transmitted TCP segment now is split in two fragments containing
> 1232+8 bytes of payload.
> 
> I am attaching a tcpdump that shows this happening. In this case,
> 2a02:c0::46:0:57ee:3d82 is an IPv6-only server running Linux 3.2.0,
> while 2a02:c0::46:0:57ee:2a2a really is 87.238.42.42, a NAT device with
> an IPv4 node behind it. The link between the NAT device and the IPv4
> node has a MTU of 1259. Somewhere between the NAT device and the server
> there's a stateless IPv4/IPv6 translator. When the server sends its
> first full-sized (1500 bytes) packets, the NAT device responds with
> a ICMPv4 Need To Fragment (MTU=1259) which are then received by the
> server in its translated for (ICMPv6 PTB, MTU 1279). After that a
> large number of these mini-fragments containing only 8 bytes of 
> payload are transmitted. They should have been avoided.
> 
> Tore


It seems that dst_allfrag() will force us to use ip6_fragment() and
reduce effective MSS to :

MTU - sizeof(ipv6hdr) - sizeof(frag_hdr) - sizeof(tcphdr)

(not counting TCP options)

But tcp_mtu_to_mss() doesnt take into account dst_allfrag() and computed
TCP MSS might be 8 bytes too big ? (ie sizeof(struct frag_hdr))

For MTU = 1280, we endup with MSS=1240 instead of 1232

/* Calculate MSS. Not accounting for SACKs here.  */
int tcp_mtu_to_mss(const struct sock *sk, int pmtu)
{
        const struct tcp_sock *tp = tcp_sk(sk);
        const struct inet_connection_sock *icsk = inet_csk(sk);
        int mss_now;

        /* Calculate base mss without TCP options:
           It is MMS_S - sizeof(tcphdr) of rfc1122
         */
        mss_now = pmtu - icsk->icsk_af_ops->net_header_len - sizeof(struct tcphdr);

        /* Clamp it (mss_clamp does not include tcp options) */
        if (mss_now > tp->rx_opt.mss_clamp)
                mss_now = tp->rx_opt.mss_clamp;

        /* Now subtract optional transport overhead */
        mss_now -= icsk->icsk_ext_hdr_len;

        /* Then reserve room for full set of TCP options and 8 bytes of data */
        if (mss_now < 48)
                mss_now = 48;

        /* Now subtract TCP options size, not including SACKs */
        mss_now -= tp->tcp_header_len - sizeof(struct tcphdr);

        return mss_now;
}

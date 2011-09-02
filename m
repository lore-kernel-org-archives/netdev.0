From: chetan loke <loke.chetan@gmail.com>
Subject: Re: FW: [PATCH] af_packet: flush complete kernel cache in packet_sendmsg
Date: Fri, 2 Sep 2011 12:49:47 -0400
Message-ID: <CAAsGZS6Qiyc6nhgyVLrphSLW6vf16=hbGVWJ+CFw6rfZQsdiFQ@mail.gmail.com>
References: <20110505141107.GC30443@orbit.nwl.cc>
	<1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
	<D3F292ADF945FB49B35E96C94C2061B90A239361@nsmail.netscout.com>
	<CAAsGZS6Tt9FLXfanH1+DgKt_9gR_YPJ8kX_pryhnzWTQVkNkNw@mail.gmail.com>
	<20110902153147.GB29025@philter>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, davem@davemloft.net
To: Phil Sutter <phil.sutter@viprinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56752 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab1IBQts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 12:49:48 -0400
Received: by ywf7 with SMTP id 7so2316869ywf.19
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2011 09:49:48 -0700 (PDT)
In-Reply-To: <20110902153147.GB29025@philter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2011 at 11:31 AM, Phil Sutter <phil.sutter@viprinet.com> wrote:

> So far we haven't noticed problems in that direction. I just tried some
> explicit test: having tcpdump print local timestamps (not the pcap-ones)
> on every received packet, activating icmp_echo_ignore_all and pinging
> the host on a dedicated line. I expected to sometimes see a second
> difference between the two timestamps, as like with sending from time to
> time a packet should get "lost" in the cache, and then occur to
> userspace after the next one arrived. Maybe my test is broken, or RX is
> indeed unaffected.
>

You will need high traffic rate. If interested, you could try
pktgen(with varying packet-load). Keep the packet-payload under 1500
bytes (don't send jumbo frames) unless you have the following fix:
commit cc9f01b246ca8e4fa245991840b8076394f86707

Your Tx path is working because flush_cache_call gets triggered before
flush_dcache_page. On the Rx path, since you don't have that
workaround, you will eventually(it's just a matter of time) see this
problem.

Or, delete your patch and try this workaround (in
__packet_get/set_status) and you may be able to cover both Tx and Rx
paths.


diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2ea3d63..35d71dc 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -412,11 +412,19 @@ static void __packet_set_status(struct
packet_sock *po, void *frame, int status)
        switch (po->tp_version) {
        case TPACKET_V1:
                h.h1->tp_status = status;
-               flush_dcache_page(pgv_to_page(&h.h1->tp_status));
+               #ifndef ENABLE_CACHEPROB_WORKAROUND
+                       flush_dcache_page(pgv_to_page(&h.h1->tp_status));
+               #else
+                       kw_extra_cache_flush();
+               endif
                break;
        case TPACKET_V2:
                h.h2->tp_status = status;
-               flush_dcache_page(pgv_to_page(&h.h2->tp_status));
+               #ifndef ENABLE_CACHEPROB_WORKAROUND
+                       flush_dcache_page(pgv_to_page(&h.h2->tp_status));
+               #else
+                       kw_extra_cache_flush();
+               #endif
                break;
        case TPACKET_V3:
        default:
@@ -437,13 +445,19 @@ static int __packet_get_status(struct
packet_sock *po, void *frame)

        smp_rmb();

+       kw_extra_cache_flush();
+
        h.raw = frame;
        switch (po->tp_version) {
        case TPACKET_V1:
-               flush_dcache_page(pgv_to_page(&h.h1->tp_status));
+               #ifndef ENABLE_CACHEPROB_WORKAROUND
+                       flush_dcache_page(pgv_to_page(&h.h1->tp_status));
+               #endif
                return h.h1->tp_status;
        case TPACKET_V2:
-               flush_dcache_page(pgv_to_page(&h.h2->tp_status));
+               #ifndef ENABLE_CACHEPROB_WORKAROUND
+                       flush_dcache_page(pgv_to_page(&h.h2->tp_status));
+               #endif
                return h.h2->tp_status;
        case TPACKET_V3:
        default:


> Greetings and thanks for the hints, Phil

Chetan Loke

From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [RFC][PATCH 2/2] bgmac: pass received packet to the netif instead
 of copying it
Date: Thu, 15 Aug 2013 13:36:48 +0200
Message-ID: <CACna6rwtLw-Aiz3amMvTBwWsi0OWo5f2yMCF9e8DeCjKLOGDEA@mail.gmail.com>
References: <1376243355-5740-1-git-send-email-zajec5@gmail.com>
	<1376243355-5740-2-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Network Development <netdev@vger.kernel.org>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jonas Gorski <jogo@openwrt.org>,
	Robert Bradley <robert.bradley1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:42809 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab3HOLgt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 07:36:49 -0400
Received: by mail-ob0-f179.google.com with SMTP id fb19so670228obc.38
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 04:36:48 -0700 (PDT)
In-Reply-To: <1376243355-5740-2-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/11 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> It makes more sense to allocate new (empty) skb and pass it to the
> hardware. That way we avoid copying whole packet into new skb which
> should result in better performance.

I did some testing of this patch using "perf" tool and iperf -s
running on the OpenWrt machine (with bgmac supported hardware).

There are the results:
No network usage:
64.93% [kernel] [k] arch_cpu_idle
16.10% [kernel] [k] arch_local_irq_restore
11.52% [kernel] [k] cpu_startup_entry

Running iperf on PC: iperf -c 192.168.1.1
23.57% [kernel] [k] __copy_user_common
10.57% [kernel] [k] csum_partial
8.87% [kernel] [k] arch_cpu_idle
4.74% [kernel] [k] arch_local_irq_restore
4.30% [ip_tables] [k] ipt_do_table
2.91% [nf_conntrack] [k] nf_conntrack_in
2.44% [kernel] [k] __netif_receive_skb_core
2.36% [kernel] [k] r4k_dma_cache_inv
2.33% [nf_conntrack] [k] nf_conntrack_proto_fini

With 0002-bgmac-pass-received-packet-to-the-netif-instead-of-c.patch
14.83% [kernel] [k] __copy_user_common
14.81% [kernel] [k] csum_partial
4.24% [ip_tables] [k] ipt_do_table
3.69% [kernel] [k] arch_local_irq_restore
3.54% [kernel] [k] __netif_receive_skb_core
3.38% [kernel] [k] r4k_dma_cache_inv
3.24% [nf_conntrack] [k] nf_conntrack_in
2.95% [xt_conntrack] [k] 0x0000018c
2.88% [nf_conntrack] [k] nf_conntrack_proto_fini
2.58% [iptable_nat] [k] 0x00000008
2.32% [bgmac] [k] 0x00000d9c
2.18% [nf_conntrack_ipv4] [k] need_ipv4_conntrack

So you can see that __copy_user_common usage has really decreased with
this patch!

Unfortunately it didn't result in better performance... no idea why :(

--=20
Rafa=C5=82

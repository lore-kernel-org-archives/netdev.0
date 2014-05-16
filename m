From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 19:40:37 +0300
Message-ID: <20140516194037.4486cd63@vostro>
References: <20140516104014.607d2d0f@vostro>
	<1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516173443.0b40157e@vostro>
	<1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:34024 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaEPQkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 12:40:20 -0400
Received: by mail-la0-f47.google.com with SMTP id pn19so2148028lab.20
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 09:40:18 -0700 (PDT)
In-Reply-To: <1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2014 09:29:29 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2014-05-16 at 17:34 +0300, Timo Teras wrote:
> 
> > Ah, did not notice that one. So I'm adding Herbert as explicit cc.
> > 
> > $ git describe --contains 9d8506cc2d7ea1f911c72c100193a3677f6668c3
> > v3.13-rc1~7^2
> > 
> > But as you may have noticed, the attached oops is from 3.14.4 that
> > includes the fix commit. While bisecting, I tested multiple versions
> > between 3.12 and 3.14. Bisecting clearly points this is the commit
> > that introduces this oops, and it is not fixed in any version up
> > until 3.14.4.
> > 
> > Also the forward path from gre->ethX goes to eth that does not have
> > TSO/GSO support. So I'd assume that the fix commit is not that
> > relevant in my specific test case.
> > 
> > The faulty commit must be introducing additional bug, and the commit
> > you refer did not fix it.
> 
> Right. The commit could expose a dormant bug in a driver.
> 
> For example, some drivers might forget to use skb_put()
> 
> Please give us more details.
> 
> What is the driver receiving ethernet frames ?
> 
> Is it using GRO ?

Both the gre bound interface, and the inside interface are identical.

And you are right. It might be driver / hw / gro capability specific
issue. I had also report from a user using similar gre/ipsec/forwarding
setup, that 3.13-stable kernels works on his hardware.

dmesg tells:

[   23.946984] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[   23.978145] r8169 0000:00:09.0 (unregistered net_device): not PCI Express
[   23.997147] r8169 0000:00:09.0 eth0: RTL8169sc/8110sc at 0xf8358000, 00:30:18:a8:14:ac, XID 18000000 IRQ 18
[   24.007012] r8169 0000:00:09.0 eth0: jumbo features [frames: 7152 bytes, tx checksumming: ok]
[   24.032389] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[   24.039530] r8169 0000:00:0b.0 (unregistered net_device): not PCI Express
[   24.057092] r8169 0000:00:0b.0 eth1: RTL8169sc/8110sc at 0xf835a000, 00:30:18:ab:69:4b, XID 18000000 IRQ 19
[   24.066955] r8169 0000:00:0b.0 eth1: jumbo features [frames: 7152 bytes, tx checksumming: ok]
[   24.092330] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[   24.098745] r8169 0000:00:0c.0 (unregistered net_device): not PCI Express
[   24.117118] r8169 0000:00:0c.0 eth2: RTL8169sc/8110sc at 0xf835c000, 00:30:18:a8:14:ad, XID 18000000 IRQ 16
[   24.126983] r8169 0000:00:0c.0 eth2: jumbo features [frames: 7152 bytes, tx checksumming: ok]

And, ethtool -k eth0

Features for eth0:
rx-checksumming: on
tx-checksumming: off
	tx-checksum-ipv4: off
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: off
	tx-scatter-gather: off
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on [fixed]
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]

Using unmodified in-tree r8169 module.

Please let me know if additional information is needed.

Thanks.
Timo

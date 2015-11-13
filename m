From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next] net/core: ensure features get disabled on
 new lower devs
Date: Fri, 13 Nov 2015 11:29:03 +0100
Message-ID: <20151113102903.GB2143@nanopsycho.orion>
References: <1446583017-19021-1-git-send-email-jarod@redhat.com>
 <1446610172-21420-1-git-send-email-jarod@redhat.com>
 <20151104.215632.964832400121049446.davem@davemloft.net>
 <56452E2A.9050501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jarod@redhat.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	razor@blackwall.org, mkubecek@suse.cz, alexander.duyck@gmail.com,
	netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56452E2A.9050501@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Nov 13, 2015 at 01:26:18AM CET, f.fainelli@gmail.com wrote:
>On 04/11/15 18:56, David Miller wrote:
>>> Fixes: fd867d51f889 ("net/core: generic support for disabling netdev features down stack")
>>  ...
>>> Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>>> ---
>>> v2: Based on suggestions from Alex, and with not changing err to ret, this
>>> patch actually becomes quite minimal and doesn't ugly up the code much.
>> 
>> Applied, thanks.
>
>This causes some warnings to be displayed for DSA stacked devices:
>
>[    1.272297] brcm-sf2 f0b00000.ethernet_switch: Starfighter 2 top:
>4.00, core: 2.00 base: 0xf0c80000, IRQs: 68, 69
>[    1.283181] libphy: dsa slave smi: probed
>[    1.344088] f0b403c0.mdio:05: Broadcom BCM7445 PHY revision: 0xd0,
>patch: 3
>[    1.658917] brcm-sf2 f0b00000.ethernet_switch gphy (uninitialized):
>attached PHY at address 5 [Broadcom BCM7445]
>[    1.669414] brcm-sf2 f0b00000.ethernet_switch gphy: set_features()
>failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>[    1.734202] brcm-sf2 f0b00000.ethernet_switch rgmii_1
>(uninitialized): attached PHY at address 0 [Generic PHY]
>[    1.744486] brcm-sf2 f0b00000.ethernet_switch rgmii_1: set_features()
>failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>[    1.809091] brcm-sf2 f0b00000.ethernet_switch rgmii_2
>(uninitialized): attached PHY at address 1 [Generic PHY]
>[    1.819364] brcm-sf2 f0b00000.ethernet_switch rgmii_2: set_features()
>failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>[    1.884090] brcm-sf2 f0b00000.ethernet_switch moca (uninitialized):
>attached PHY at address 2 [Generic PHY]
>[    1.894109] brcm-sf2 f0b00000.ethernet_switch moca: set_features()
>failed (-1); wanted 0x0000000000004020, left 0x0000000000004820
>
>DSA slave network devices are not associated with their master network
>device using the typical lower/upper netdev helpers.
>
>I do not have a good fix to come up with yet, but if you see something
>obvious with net/dsa/slave.c, feel free to send patches for testing, I
>can boot net-next on this platform.

I'm having similar issues with bridge, with linus's git now:

<dmesg>
...
[   14.354362] br0: set_features() failed (-1); wanted 0x000000801fd978a9, left 0x000000801fff78e9
[   14.430480] br0: set_features() failed (-1); wanted 0x000000801fd978a9, left 0x000000801fff78e9
[   14.430550] IPv6: ADDRCONF(NETDEV_UP): br0: link is not ready
[   17.938637] tg3 0000:01:00.0 eno1: Link is up at 1000 Mbps, full duplex
[   17.938647] tg3 0000:01:00.0 eno1: Flow control is off for TX and off for RX
[   17.938651] tg3 0000:01:00.0 eno1: EEE is disabled
[   17.938669] IPv6: ADDRCONF(NETDEV_CHANGE): eno1: link becomes ready
[   17.938753] br0: port 1(eno1) entered forwarding state
[   17.938762] br0: port 1(eno1) entered forwarding state
[   17.938834] IPv6: ADDRCONF(NETDEV_CHANGE): br0: link becomes ready
[   29.763514] FS-Cache: Loaded
[   29.917680] FS-Cache: Netfs 'nfs' registered for caching
[   29.936739] Key type dns_resolver registered
[   30.637482] NFS: Registering the id_resolver key type
[   30.637502] Key type id_resolver registered
[   30.637504] Key type id_legacy registered
[   31.286444] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   31.403005] Ebtables v2.0 registered
[   31.630354] tun: Universal TUN/TAP device driver, 1.6
[   31.630358] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   31.630824] virbr0-nic: set_features() failed (-1); wanted 0x00000080000048c1, left 0x00000080001b48c9
[   31.677764] virbr0-nic: set_features() failed (-1); wanted 0x00000080000048c1, left 0x00000080001b48c9
[   31.677855] device virbr0-nic entered promiscuous mode
[   31.677898] virbr0: set_features() failed (-1); wanted 0x000000801fdb78c9, left 0x000000801fff78e9
[   31.904892] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
[   32.087094] virbr0: set_features() failed (-1); wanted 0x000000801fdb78c9, left 0x000000801fff78e9
[   32.087196] virbr0: port 1(virbr0-nic) entered listening state
[   32.087205] virbr0: port 1(virbr0-nic) entered listening state
[   32.093676] br0: set_features() failed (-1); wanted 0x000000801fd978a9, left 0x000000801fff78e9
[   32.093786] virbr0: set_features() failed (-1); wanted 0x000000801fdb78c9, left 0x000000801fff78e9
[   32.093872] virbr0-nic: set_features() failed (-1); wanted 0x00000080000048c1, left 0x00000080001b48c9
[   32.093966] virbr0: set_features() failed (-1); wanted 0x000000801fdb78c9, left 0x000000801fff78e9
[   32.094051] virbr0-nic: set_features() failed (-1); wanted 0x00000080000048c1, left 0x00000080001b48c9
[   32.094132] virbr0: set_features() failed (-1); wanted 0x000000801fdb78c9, left 0x000000801fff78e9
[   32.124341] virbr0: port 1(virbr0-nic) entered disabled state
</dmesg>

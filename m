From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [forcedeth bug] Re: [GIT] Networking
Date: Fri, 5 Aug 2011 13:44:12 +0200
Message-ID: <20110805114411.GE1928@minipsycho.orion>
References: <20110722.073339.1236244143490935644.davem@davemloft.net>
 <20110801151308.GA31256@elte.hu>
 <20110804215354.GA7056@elte.hu>
 <20110805102239.GB1928@minipsycho.orion>
 <20110805102903.GF2420@elte.hu>
 <20110805111231.GA29466@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110805111231.GA29466@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Aug 05, 2011 at 01:12:31PM CEST, nhorman@tuxdriver.com wrote:
>On Fri, Aug 05, 2011 at 12:29:03PM +0200, Ingo Molnar wrote:
>> 
>> * Jiri Pirko <jpirko@redhat.com> wrote:
>> 
>> > Thu, Aug 04, 2011 at 11:53:54PM CEST, mingo@elte.hu wrote:
>> > >
>> > >* Ingo Molnar <mingo@elte.hu> wrote:
>> > >
>> > >>  0891b0e08937: forcedeth: fix vlans
>> > >
>> > >Hm, forcedeth is still giving me trouble even on latest -git that has 
>> > >the above fix included.
>> > >
>> > >The symptom is a stuck interface, no packets in. There's a frame 
>> > >error RX packet:
>> > >
>> > > [root@mercury ~]# ifconfig eth0
>> > > eth0      Link encap:Ethernet  HWaddr 00:13:D4:DC:41:12  
>> > >           inet addr:10.0.1.13  Bcast:10.0.1.255  Mask:255.255.255.0
>> > >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>> > >           RX packets:0 errors:1 dropped:0 overruns:0 frame:1
>> > >           TX packets:531 errors:0 dropped:0 overruns:0 carrier:0
>> > >           collisions:0 txqueuelen:1000 
>> > >           RX bytes:0 (0.0 b)  TX bytes:34112 (33.3 KiB)
>> > >           Interrupt:35 
>> > >
>> > >Weirdly enough a defconfig x86 bootup works just fine - it's certain 
>> > >.config combinations that trigger the bug. I've attached such a 
>> > >config.
>> > >
>> > >Note that at least once i've observed a seemingly good kernel going 
>> > >'bad' after a couple of minutes uptime. I've also observed 
>> > >intermittent behavior - apparent lost packets and a laggy network.
>> > >
>> > >I have done 3 failed attempts to bisect it any further - i got to the 
>> > >commit that got fixed by:
>> > >
>> > >  0891b0e08937: forcedeth: fix vlans
>> > >
>> > >... but that's something we already knew.
>> > >
>> > >Let me know if there's any data i can provide to help debug this 
>> > >problem.
>> > >
>> > >Thanks,
>> > >
>> > >	Ingo
>> > 
>> > Interesting.
>> > 
>> > Is DEV_HAS_VLAN set in id->driver_data (L5344) ?
>> 
>Looks like you can match it to pci id.  Device ids 0x0372 and 0x0373 look to
>have the flag set
>
>> How do i tell that without hacking the driver?
>> 
>> > If so, would you try to disable both rx an tx vlan accel using 
>> > ethtool and see if it helps?
>> 
>> Should i do that when the device is in a stuck state and see whether 
>> it recovers?
>> 
>> Also, please provide the exact ethtool command sequences i should 
>> try, this makes it easier for me to test exactly what you want me to 
>> test.
>> 
>should be:
>ethtool -K ethX rxvlan off txvlan off
>
>I'm just poking about, but If I had to guess it looks like the card you have
>ingo is an older forcedeth and uses the older format ring descriptor (I base
>this on the fact that the rx error count noted above only gets incremented ni
>nv_rx_process, but not nv_rx_process_optimized.  Both paths should support hw
>vlan acceleration though and Jiris fixes for vlan hw rx acceleration were only
>applied to the optimized path.

Well hw accel was not implemented in nv_rx_process before so I did not
see any reason to do so during vlan conversion. Anyway, since this path
was touched, I do not see reason why regression might happen there. Only
change is that now hw accel is enabled by default (before, it got
enabled only when vid was added). So if turning off hw accel fixes the
problem for Ingo, I would tend fix this by simply disabling vlan hw
accel for non-optimized path, by patch like this:

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e55df30..3f1b24b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5341,7 +5341,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	}
 
 	np->vlanctl_bits = 0;
-	if (id->driver_data & DEV_HAS_VLAN) {
+	if (id->driver_data & DEV_HAS_VLAN && nv_optimized(np)) {
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
 		dev->hw_features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
 	}

Strange kind of hw this is ....

>
>Neil
>
>> Thanks,
>> 
>> 	Ingo
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 

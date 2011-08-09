From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [forcedeth bug] Re: [GIT] Networking
Date: Tue, 9 Aug 2011 15:13:31 +0200
Message-ID: <20110809131330.GA2020@minipsycho.brq.redhat.com>
References: <20110722.073339.1236244143490935644.davem@davemloft.net>
 <20110801151308.GA31256@elte.hu>
 <20110804215354.GA7056@elte.hu>
 <20110805102239.GB1928@minipsycho.orion>
 <20110805102903.GF2420@elte.hu>
 <20110805112557.GD1928@minipsycho.orion>
 <20110805121855.GC13055@elte.hu>
 <20110805123136.GF1928@minipsycho.orion>
 <20110805143732.GH1928@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110805143732.GH1928@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Aug 05, 2011 at 04:37:33PM CEST, jpirko@redhat.com wrote:
>Fri, Aug 05, 2011 at 02:31:37PM CEST, jpirko@redhat.com wrote:
>>Fri, Aug 05, 2011 at 02:18:55PM CEST, mingo@elte.hu wrote:
>>>
>>>* Jiri Pirko <jpirko@redhat.com> wrote:
>>>
>>>> >> Is DEV_HAS_VLAN set in id->driver_data (L5344) ?
>>>> >
>>>> >How do i tell that without hacking the driver?
>>>> 
>>>> look in dmesg for line like:
>>>> "forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt gbit lnktim msi
>>>> desc-v3"
>>>> 
>>>> if "vlan" is there, DEV_HAS_VLAN is set
>>>
>>>[    3.534489] forcedeth 0000:00:0a.0: highdma csum gbit lnktim desc-v3
>>>
>>>Note, this is a pretty old system with an old nvidia chipset and 
>>>on-board ethernet:
>>>
>>>00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
>>>        Subsystem: ASUSTeK Computer Inc. K8N4-E Mainboard
>>>        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>>>        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>>>        Latency: 0 (250ns min, 5000ns max)
>>>        Interrupt: pin A routed to IRQ 11
>>>        Region 0: Memory at da100000 (32-bit, non-prefetchable) [size=4K]
>>>        Region 1: I/O ports at d000 [size=8]
>>>        Capabilities: [44] Power Management version 2
>>>                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
>>>                Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
>>
>>Please do lspci -nn
>>
>>There are two CK804 chips:
>>0x10DE, 0x0056
>>0x10DE, 0x0057
>>
>>I have only the second one handy - Getting the machine as we speak.
>
>I'm unable to see problems you are referring to on my machine.
>
>Would you please try following patch if it fixes your issue? It's
>in fact returning everything back to the original state (for your card).


Ingo, any news with this?

Thanks.

Jirka

>
>diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
>index e55df30..d7d43d4 100644
>--- a/drivers/net/forcedeth.c
>+++ b/drivers/net/forcedeth.c
>@@ -2763,18 +2763,18 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
> 			skb->protocol = eth_type_trans(skb, dev);
> 			prefetch(skb->data);
> 
>-			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
>-
> 			/*
> 			 * There's need to check for NETIF_F_HW_VLAN_RX here.
> 			 * Even if vlan rx accel is disabled,
> 			 * NV_RX3_VLAN_TAG_PRESENT is pseudo randomly set.
> 			 */
>-			if (dev->features & NETIF_F_HW_VLAN_RX &&
>-			    vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
>-				u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
>+			if (dev->features & NETIF_F_HW_VLAN_RX) {
>+				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
>+				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
>+					u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
> 
>-				__vlan_hwaccel_put_tag(skb, vid);
>+					__vlan_hwaccel_put_tag(skb, vid);
>+				}
> 			}
> 			napi_gro_receive(&np->napi, skb);
> 
>@@ -5615,7 +5615,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
> 		goto out_error;
> 	}
> 
>-	nv_vlan_mode(dev, dev->features);
>+	//nv_vlan_mode(dev, dev->features);
> 
> 	netif_carrier_off(dev);
> 

From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v2] sfc: report supported link speeds on SFP
 connections
Date: Tue, 7 Jun 2016 17:20:16 -0400
Message-ID: <20160607212016.GH56933@redhat.com>
References: <1464917604-11596-1-git-send-email-jarod@redhat.com>
 <a354e801-dc3e-bae4-0dcb-f174df8b9161@solarflare.com>
 <20160606185529.GV56933@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bert Kenward <bkenward@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160606185529.GV56933@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 02:55:29PM -0400, Jarod Wilson wrote:
> On Mon, Jun 06, 2016 at 05:29:30PM +0100, Bert Kenward wrote:
> > 7000-series SFC NICs connected with an SFP+ module currently fail to
> > report any supported link speeds.
> > 
> > Reported-by: Jarod Wilson <jarod@redhat.com>
> > Signed-off-by: Bert Kenward <bkenward@solarflare.com>
> 
> Had a feeling my cut might not have been quite right. Looks good to me.
> 
> Reviewed-by: Jarod Wilson <jarod@redhat.com>

...however, upon testing, there's a gotcha. This results in my 10Gbps sfc
nic reporting that it supports 40Gbps:

$ ethtool ens4f0
Settings for ens4f0:
	Supported ports: [ FIBRE ]
	Supported link modes:   1000baseT/Full
	                        10000baseT/Full
	                        40000baseKR4/Full
	Supported pause frame use: Symmetric Receive-only
	Supports auto-negotiation: Yes
	Advertised link modes:  Not reported
	Advertised pause frame use: Symmetric
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10000baseT/Full
	Link partner advertised pause frame use: Symmetric
	Link partner advertised auto-negotiation: No
	Speed: 10000Mb/s
	Duplex: Full
	Port: FIBRE
	PHYAD: 255
	Transceiver: internal
	Auto-negotiation: on
Cannot get wake-on-lan settings: Operation not permitted
	Current message level: 0x000020f7 (8439)
			       drv probe link ifdown ifup rx_err tx_err hw
	Link detected: yes

$ ethtool -i ens4f0
driver: sfc
version: 4.0
firmware-version: 4.6.1.1001 rx1 tx1
expansion-rom-version:
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: no

$ lspci -v -s 0000:05:00.0
05:00.0 Ethernet controller: Solarflare Communications SFC9120 (rev 01)
	Subsystem: Solarflare Communications SFN7x22F-R2 Flareon Ultra 7000 Series 10G Adapter
	Physical Slot: 4
	Flags: bus master, fast devsel, latency 0, IRQ 16
	I/O ports at c100 [size=256]
	Memory at ef000000 (64-bit, non-prefetchable) [size=8M]
	Memory at ef884000 (64-bit, non-prefetchable) [size=16K]
	Expansion ROM at ef840000 [disabled] [size=256K]
	Capabilities: <access denied>
	Kernel driver in use: sfc

One solution would be to move the case MC_CMD_MEDIA_QSFP_PLUS above
XFP/SFP_PLUS, only check the 40Gbps cap, no break, fall through into the
XFP/SFP_PLUS chunk, continue processing there.

-- 
Jarod Wilson
jarod@redhat.com

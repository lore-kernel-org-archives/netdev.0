From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net v2] e1000e: keep vlan interfaces
	functional after rxvlan off
Date: Thu, 16 Jun 2016 01:08:56 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F1C2D7@ORSMSX101.amr.corp.intel.com>
References: <1463511831-13684-1-git-send-email-jarod@redhat.com>
 <1465516213-18176-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465516213-18176-1-git-send-email-jarod@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Jarod Wilson
> Sent: Thursday, June 9, 2016 4:50 PM
> To: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH net v2] e1000e: keep vlan interfaces
> functional after rxvlan off
> 
> I've got a bug report about an e1000e interface, where a vlan interface is
> set up on top of it:
> 
> $ ip link add link ens1f0 name ens1f0.99 type vlan id 99
> $ ip link set ens1f0 up
> $ ip link set ens1f0.99 up
> $ ip addr add 192.168.99.92 dev ens1f0.99
> 
> At this point, I can ping another host on vlan 99, ip 192.168.99.91.
> However, if I do the following:
> 
> $ ethtool -K ens1f0 rxvlan off
> 
> Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
> again. Upon discussion with folks here, and closer inspection, it appears
> that the software *receive* fallback is working correctly, but outbound
> traffic is broken. Upon glancing at the e1000 driver, I saw a note about
> having to keep RX and TX accel flags in sync, because there's no
> (hardware?) support for separate vlan accel toggle. Swipe the same hack
> from the e1000 driver, and things start to behave again with rxvlan off.
> 
> After patch:
> 
> $ ping 192.168.99.91
> PING 192.168.99.91 (192.168.99.91) 56(84) bytes of data.
> 64 bytes from 192.168.99.91: icmp_seq=1 ttl=64 time=0.591 ms
> 64 bytes from 192.168.99.91: icmp_seq=2 ttl=64 time=0.335 ms
> 64 bytes from 192.168.99.91: icmp_seq=3 ttl=64 time=0.417 ms
> ^C
> --- 192.168.99.91 ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 2000ms
> rtt min/avg/max/mdev = 0.335/0.447/0.591/0.109 ms
> 
> $ sudo ethtool -K ens1f0 rxvlan off
> Actual changes:
> rx-vlan-offload: off
> tx-vlan-offload: off [requested on]
> 
> $ ping 192.168.99.91
> PING 192.168.99.91 (192.168.99.91) 56(84) bytes of data.
> 64 bytes from 192.168.99.91: icmp_seq=1 ttl=64 time=0.327 ms
> 64 bytes from 192.168.99.91: icmp_seq=2 ttl=64 time=0.393 ms
> 64 bytes from 192.168.99.91: icmp_seq=3 ttl=64 time=0.424 ms
> ^C
> --- 192.168.99.91 ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 1999ms
> rtt min/avg/max/mdev = 0.327/0.381/0.424/0.043 ms
> 
> Also slipped a related-ish fix to the kerneldoc text for
> e1000e_vlan_strip_disable here...
> 
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 2 Feb 2012 20:38:29 +0000
Message-ID: <1328215109.2541.69.camel@bwh-desktop>
References: <1321575301.2749.51.camel@bwh-desktop>
	 <CAEE6B20.3A9F7%roprabhu@cisco.com> <20120202072448.GA25403@redhat.com>
	 <4F2A4D81.6070002@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Roopa Prabhu <roprabhu@cisco.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <chrisw@redhat.com>, <sri@us.ibm.com>,
	<dragos.tatulea@gmail.com>, <kvm@vger.kernel.org>, <arnd@arndb.de>,
	<gregory.v.rose@intel.com>, <mchan@broadcom.com>,
	<dwang2@cisco.com>, <shemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, <kaber@trash.net>, <benve@cisco.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F2A4D81.6070002@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-02 at 00:46 -0800, John Fastabend wrote:
[...]
> OK finally got to read through this. And its not clear to me why we need
> these per VF/PF filter netdevice ops and netlink extensions if we can
> get the stacking correct. (Adding filters to the macvlan seems reasonable
> to me)
> 
> In the cases I saw listed above I see a few enumerations:
> 
> PF <--> MACVLAN  <---> Guest <--- [...]
> 
> VF <--> MACVLAN  <---> Guest <--- [...]       
> 
>                     VF|Guest <--- [...]       direct assigned VF
> 
>                     PF|Guest <--- [...]       direct assigned PF
> 
> 
> I used '[...]' to represent whatever additional stacking is done in the
> guest unknown to the host. In the direct assign VF case (Greg Rose
> correct me if I am wrong) the normal uc and mc addr lists should suffice
> along with the netdev op ndo_set_rx_mode(). Here the guest adds MAC
> addresses and/or VLANS as normal and then the VF<->PF back channel
> should handle this if needed. This should work for Linux guests and other
> OS's should do something similar.
> 
> In the direct assign PF case the hardware is owned by the guest so
> no problems here.
> 
> This leaves the two MACVLAN cases which can be handled the same. If
> the MACVLAN driver and netlink interface is extended to add filters
> to the MACVLAN then the addresses can be pushed to the lower device
> using the normal dev_uc_{add|del}() and dev_mc_{add|del}() routines.
[...]

There is another case: hybrid acceleration.  Without a bridge in the
NIC, you need a software bridge for multicast/broadcast replication,
traffic between guests, and traffic between guest and host.  A guest
driver can then send and receive to remote addresses through a VF while
retaining fallback to the software bridge.

In order to do this, the guest driver needs to know which addresses are
local.  The net driver for the PF can tell it about the addresses
assigned to each function, but if there are other devices included in
the bridge then it will not know about them.

In Solarflare's current out-of-tree implementation this is dealt with in
an extension to libvirt that writes the additional 'local' MAC addresses
to a driver-specific sysfs file, but that is obviously not likely to be
acceptable in-tree!  So I was interested in this proposal to extend MAC
filtering, but wanted to get the semantics clear.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


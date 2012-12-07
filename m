From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [PATCH v3 1/4] net: Add support for hardware-offloaded
 encapsulation
Date: Fri, 7 Dec 2012 10:24:17 -0800 (PST)
Message-ID: <alpine.LFD.2.02.1212071013200.30243@morpheus.jf.intel.com>
References: <1354845419-22483-1-git-send-email-joseph.gasparakis@intel.com>   <1354845419-22483-2-git-send-email-joseph.gasparakis@intel.com>  <1354874847.20838.49.camel@deadeye.wl.decadent.org.uk>  <50C21D21.5040101@intel.com>
 <1354900385.2707.42.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dmitry@broadcom.com,
	saeed.bishara@gmail.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354900385.2707.42.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 7 Dec 2012, Ben Hutchings wrote:

> On Fri, 2012-12-07 at 08:45 -0800, Alexander Duyck wrote:
> > On 12/07/2012 02:07 AM, Ben Hutchings wrote:
> > > On Thu, 2012-12-06 at 17:56 -0800, Joseph Gasparakis wrote:
> > >> This patch adds support in the kernel for offloading in the NIC Tx and Rx
> > >> checksumming for encapsulated packets (such as VXLAN and IP GRE).
> > > [...]
> > >> --- a/include/linux/netdevice.h
> > >> +++ b/include/linux/netdevice.h
> > >> @@ -1063,6 +1063,8 @@ struct net_device {
> > >>  	netdev_features_t	wanted_features;
> > >>  	/* mask of features inheritable by VLAN devices */
> > >>  	netdev_features_t	vlan_features;
> > >> +	/* mask of features inherited by encapsulating devices */
> > >> +	netdev_features_t	hw_enc_features;
> > > [...]
> > > 
> > > How will the networking core know *which* encapsulations this applies
> > > to?  I notice that your implementation in ixgbe does not set
> > > NETIF_F_HW_CSUM here, so presumably the hardware will parse headers to
> > > find which ranges should be checksummed and it won't cover the next
> > > encapsulation protocol that comes along.
> > > 
> > > Ben.
> > > 
> > 
> > Actually the offload is generic to any encapsulation that does not
> > compute a checksum on the inner headers.  So as long as you can treat
> > the outer headers as one giant L2 header you can pretty much ignore what
> > is in there as long as the inner network and transport header values are
> > set.  There are a number of tunnels that fall into that category since
> > most just use IP as the L2 and the L3 usually doesn't contain any checksum.
> 
> Yes, that should work, but it requires that the driver/hardware uses the
> header offsets from the skb rather than parsing the packet.  This is not
> currently required for devices with the NETIF_F_IP_CSUM and
> NETIF_F_IPV6_CSUM features.
> 
> Please do state explicitly which feature flags are valid in
> hw_enc_features, any changes in semantics, and in particular in what
> cases the driver/hardware is supposed to use header offsets from the skb
> vs parsing the packet.
> 
> Ben.
> 
So the idea here is that the driver will use the headers for checksumming 
if the skb->encapsulation bit is on. The bit should be set in the protocol 
driver.

To answer the second comment, the flags that we use in this series of 
patches is NETIF_F_IP_CSUM, NETIF_F_IPV6_CSUM and NETIF_F_SG. These are 
the bits that we propose will be used for checksumming of encapsulation. 
As per a previous comment in v2, the hw_enc_features field should be used 
also in the future when NICs have more encap offloads, so one could
indicate these features there from the driver.

Furthermore, I submitted a patch for Rx checksumming, where NETIF_F_RXCSUM 
is used, again in conjunction with skb->encapsulation flag. As I mention 
in my logs, the driver is expected to set the ip_summed to UNNECESSARY and 
turn the skb->encapsulation on, to indicate that the inner headers are 
already HW checksummed.

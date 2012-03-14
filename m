From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net 2/2] net: fix a bug of dropping FCoE frames when disabling
 tx ip checksum
Date: Wed, 14 Mar 2012 12:32:47 -0700
Message-ID: <20120314123247.687be130@nehalam.linuxnetplumber.net>
References: <1331708518-28120-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120314082529.584a669f@nehalam.linuxnetplumber.net>
	<138EA028228D124A900F5E6746F3C2160F6B0F97@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Zou, Yi" <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43869 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753142Ab2CNTcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 15:32:51 -0400
In-Reply-To: <138EA028228D124A900F5E6746F3C2160F6B0F97@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Mar 2012 18:54:32 +0000
"Zou, Yi" <yi.zou@intel.com> wrote:

> > 
> > On Wed, 14 Mar 2012 00:01:58 -0700
> > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > 
> > > From: Yi Zou <yi.zou@intel.com>
> > >
> > > Fix a bug when using 'ethtool -K ethx tx off' to turn off tx ip
> > checksum,
> > > FCoE CRC offload should not be impacte. The skb_checksum_help() is
> > needed
> > > only if it's not FCoE traffic for ip checksum, regardless of ethtool
> > toggling
> > > the tx ip checksum on or off.
> > >
> > > Signed-off-by: Yi Zou <yi.zou@intel.com>
> > > Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > ---
> > >  net/core/dev.c |    3 +++
> > >  1 files changed, 3 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 6ca32f6..9e378009 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -1913,6 +1913,9 @@ int skb_checksum_help(struct sk_buff *skb)
> > >  	__wsum csum;
> > >  	int ret = 0, offset;
> > >
> > > +	if (skb->protocol == htons(ETH_P_FCOE))
> > > +		goto out;
> > > +
> > >  	if (skb->ip_summed == CHECKSUM_COMPLETE)
> > >  		goto out_set_summed;
> > >
> > 
> > Shouldn't this be done in the offending driver rather than the core?
> Well, yes and no, the driver is already using NETIF_F_FCOE_CRC to indicate
> the FCoE CRC offload capability, and can_checksum_protocol() indicates that.
> The fcoe protocol stack then uses CHECKSUM_PARTIAL and NETIF_F_FCOE_CRC to
> pass through netdev w/o doing skb_checksum(), which is not captured here
> in dev_hard_start_xmit() as it looks at NETIF_F_ALL_CSUM only before calling
> skb_checksum_help().

But your change would break any code (if there is any) generating this
kind of packet and going through firewall, etc. For example a bridge or
router for FCOE packets.

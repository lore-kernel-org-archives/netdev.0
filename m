From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [net 2/2] net: fix a bug of dropping FCoE frames when disabling
 tx ip checksum
Date: Wed, 14 Mar 2012 18:54:32 +0000
Message-ID: <138EA028228D124A900F5E6746F3C2160F6B0F97@ORSMSX102.amr.corp.intel.com>
References: <1331708518-28120-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120314082529.584a669f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60569 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753018Ab2CNSye convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 14:54:34 -0400
In-Reply-To: <20120314082529.584a669f@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> On Wed, 14 Mar 2012 00:01:58 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > From: Yi Zou <yi.zou@intel.com>
> >
> > Fix a bug when using 'ethtool -K ethx tx off' to turn off tx ip
> checksum,
> > FCoE CRC offload should not be impacte. The skb_checksum_help() is
> needed
> > only if it's not FCoE traffic for ip checksum, regardless of ethtool
> toggling
> > the tx ip checksum on or off.
> >
> > Signed-off-by: Yi Zou <yi.zou@intel.com>
> > Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  net/core/dev.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 6ca32f6..9e378009 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1913,6 +1913,9 @@ int skb_checksum_help(struct sk_buff *skb)
> >  	__wsum csum;
> >  	int ret = 0, offset;
> >
> > +	if (skb->protocol == htons(ETH_P_FCOE))
> > +		goto out;
> > +
> >  	if (skb->ip_summed == CHECKSUM_COMPLETE)
> >  		goto out_set_summed;
> >
> 
> Shouldn't this be done in the offending driver rather than the core?
Well, yes and no, the driver is already using NETIF_F_FCOE_CRC to indicate
the FCoE CRC offload capability, and can_checksum_protocol() indicates that.
The fcoe protocol stack then uses CHECKSUM_PARTIAL and NETIF_F_FCOE_CRC to
pass through netdev w/o doing skb_checksum(), which is not captured here
in dev_hard_start_xmit() as it looks at NETIF_F_ALL_CSUM only before calling
skb_checksum_help().

Yi

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

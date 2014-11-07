From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 6/9] ixgbe: fix X540 Completion timeout
Date: Fri, 7 Nov 2014 17:06:55 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664685E27B19@ORSMSX110.amr.corp.intel.com>
References: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1415350670-15333-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <545CD898.7060403@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3364 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714AbaKGRH6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 12:07:58 -0500
In-Reply-To: <545CD898.7060403@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Friday, November 07, 2014 6:35 AM
> To: Kirsher, Jeffrey T; davem@davemloft.net
> Cc: Skidmore, Donald C; netdev@vger.kernel.org; nhorman@redhat.com;
> sassmann@redhat.com; jogreene@redhat.com
> Subject: Re: [net-next 6/9] ixgbe: fix X540 Completion timeout
> 
> Hello.
> 
> On 11/7/2014 11:57 AM, Jeff Kirsher wrote:
> 
> > From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> > On topologies including few levels of PCIe switching X540 can run into
> > an unexpected completion error.  We get around this by waiting after
> > enabling loopback a sufficient amount of time until Tx Data Fetch is
> > sent.  We then poll the pending transaction bit to ensure we received
> > the completion.  Only then do we go on to clear the buffers.
> 
> > Signed-of-by: Don Skidmore <donald.c.skidmore@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> > ---
> >   drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 21
> ++++++++++++++++++++-
> >   1 file changed, 20 insertions(+), 1 deletion(-)
> 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> > index b5f484b..e314b53 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> [...]
> > @@ -3600,6 +3601,24 @@ void ixgbe_clear_tx_pending(struct ixgbe_hw
> *hw)
> >   	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
> >   	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0 |
> IXGBE_HLREG0_LPBK);
> >
> > +	/* wait for a last completion before clearing buffers */
> > +	IXGBE_WRITE_FLUSH(hw);
> > +	usleep_range(3000, 6000);
> > +
> > +	/* Before proceeding, make sure that the PCIe block does not have
> > +	 * transactions pending.
> > +	 */
> > +	poll = ixgbe_pcie_timeout_poll(hw);
> > +	for (i = 0; i < poll; i++) {
> > +		usleep_range(100, 200);
> > +		value = ixgbe_read_pci_cfg_word(hw,
> IXGBE_PCI_DEVICE_STATUS);
> > +		if (ixgbe_removed(hw->hw_addr))
> > +			goto out;
> 
>     Why not just *break*?
> 
> > +		if (!(value &
> IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING))
> > +			goto out;
> 
>     Likewise.
> 
> > +	}
> > +
> > +out:
> >   	/* initiate cleaning flow for buffers in the PCIe transaction layer */
> >   	gcr_ext = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
> >   	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT,
> 
> WBR, Sergei

Your right the breaks would be much cleaner, thanks for pointing it out. :)  I can resubmit the patch threw Jeff or send a new one, whatever is preferred.

- Don Skidmore <donald.c.skidmore@intel.com>

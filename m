From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 08/15] i40e: acknowledge VFLR when disabling SR-IOV
Date: Mon, 6 Jan 2014 18:10:48 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654EA3EF@FMSMSX113.amr.corp.intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1389011436-18424-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <52CADD2C.2090103@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17034 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755886AbaAFSKv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 13:10:51 -0500
In-Reply-To: <52CADD2C.2090103@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Monday, January 06, 2014 8:43 AM
> To: Kirsher, Jeffrey T; Williams, Mitch A
> Cc: davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com; Brandeburg, Jesse
> Subject: Re: [net-next 08/15] i40e: acknowledge VFLR when disabling SR-IOV
> 
> On 06.01.2014 16:30, Jeff Kirsher wrote:
> 
> > From: Mitch Williams <mitch.a.williams@intel.com>
> 
> > When SR-IOV is disabled, the (now nonexistent) virtual function
> > devices undergo a VFLR event. We don't need to handle this event
> > because the VFs are gone, but we do need to tell the HW that they are
> > complete. This fixes an issue with a phantom VFLR and broken VFs when
> > SR-IOV is re-enabled.
> 
> > Change-Id: I7580b49ded0158172a85b14661ec212af77000c8
> > Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Tested-by: Sibai Li <sibai.li@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 15 +++++++++++++--
> >   1 file changed, 13 insertions(+), 2 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> > index f92404c..e91f9d7 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> [...]
> > @@ -748,8 +750,17 @@ void i40e_free_vfs(struct i40e_pf *pf)
> >   	kfree(pf->vf);
> >   	pf->vf = NULL;
> >
> > -	if (!i40e_vfs_are_assigned(pf))
> > +	if (!i40e_vfs_are_assigned(pf)) {
> >   		pci_disable_sriov(pf->pdev);
> > +		/* Acknowledge VFLR for all VFS. Without this, VFs will fail to
> > +		 * work correctly when SR-IOV gets re-enabled.
> > +		 */
> > +		for (vf_id = 0; vf_id < tmp; vf_id++) {
> > +			reg_idx = (hw->func_caps.vf_base_id + vf_id) / 32;
> > +			bit_idx = (hw->func_caps.vf_base_id + vf_id) % 32;
> > +			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), (1 << bit_idx));
> > +		}
> > +	}
> >   	else
> 
>     } and *else* should be on the same line. And the *else* arm should also
> have {} now.
> 
> >   		dev_warn(&pf->pdev->dev,
> >   			 "unable to disable SR-IOV because VFs are assigned.\n");
> 
> WBR, Sergei

You are absolutely correct, Sergei, and I apologize for not seeing this before I submitted the patch.

There will be a patch coming from Greg Rose in the next few weeks that will fix this problem in the process of adding a bug fix. Since this is just cosmetic, would it be all right with you if we just wait for Greg's patch to come through?

-Mitch

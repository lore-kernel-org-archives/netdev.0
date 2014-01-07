From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 08/15] i40e: acknowledge VFLR when disabling SR-IOV
Date: Wed, 08 Jan 2014 01:55:40 +0400
Message-ID: <52CC77DC.5020801@cogentembedded.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com> <1389011436-18424-9-git-send-email-jeffrey.t.kirsher@intel.com> <52CADD2C.2090103@cogentembedded.com> <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654EA3EF@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:52378 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbaAGVzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:55:40 -0500
Received: by mail-lb0-f170.google.com with SMTP id c11so734110lbj.1
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 13:55:39 -0800 (PST)
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654EA3EF@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06-01-2014 22:10, Williams, Mitch A wrote:

>>> From: Mitch Williams <mitch.a.williams@intel.com>

>>> When SR-IOV is disabled, the (now nonexistent) virtual function
>>> devices undergo a VFLR event. We don't need to handle this event
>>> because the VFs are gone, but we do need to tell the HW that they are
>>> complete. This fixes an issue with a phantom VFLR and broken VFs when
>>> SR-IOV is re-enabled.

>>> Change-Id: I7580b49ded0158172a85b14661ec212af77000c8
>>> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> Tested-by: Sibai Li <sibai.li@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>    drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 15 +++++++++++++--
>>>    1 file changed, 13 insertions(+), 2 deletions(-)

>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>>> index f92404c..e91f9d7 100644
>>> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> [...]
>>> @@ -748,8 +750,17 @@ void i40e_free_vfs(struct i40e_pf *pf)
>>>    	kfree(pf->vf);
>>>    	pf->vf = NULL;
>>>
>>> -	if (!i40e_vfs_are_assigned(pf))
>>> +	if (!i40e_vfs_are_assigned(pf)) {
>>>    		pci_disable_sriov(pf->pdev);
>>> +		/* Acknowledge VFLR for all VFS. Without this, VFs will fail to
>>> +		 * work correctly when SR-IOV gets re-enabled.
>>> +		 */
>>> +		for (vf_id = 0; vf_id < tmp; vf_id++) {
>>> +			reg_idx = (hw->func_caps.vf_base_id + vf_id) / 32;
>>> +			bit_idx = (hw->func_caps.vf_base_id + vf_id) % 32;
>>> +			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), (1 << bit_idx));
>>> +		}
>>> +	}
>>>    	else

>>      } and *else* should be on the same line. And the *else* arm should also
>> have {} now.

>>>    		dev_warn(&pf->pdev->dev,
>>>    			 "unable to disable SR-IOV because VFs are assigned.\n");

>> WBR, Sergei

> You are absolutely correct, Sergei, and I apologize for not seeing this before I submitted the patch.

    I guess you haven't run scripts/checkpatch.pl, have you?

> There will be a patch coming from Greg Rose in the next few weeks that will fix this problem in the process of adding a bug fix. Since this is just cosmetic, would it be all right with you if we just wait for Greg's patch to come through?

    Looks like DaveM has decided for everybody and the patch with the fix has 
been already posted too.

> -Mitch

WBR, Sergei

From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [PATCH] i40e: handle setting administratively set MAC address
 back to zero
Date: Sun, 25 Jun 2017 13:10:53 +0200
Message-ID: <da4bf893-ae23-bd1d-c23f-45554e5964dd@kpanic.de>
References: <20170623074624.32405-1-sassmann@kpanic.de>
 <20170625062108.GQ1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:62865 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751050AbdFYLLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 07:11:16 -0400
In-Reply-To: <20170625062108.GQ1248@mtr-leonro.local>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.06.2017 08:21, Leon Romanovsky wrote:
> On Fri, Jun 23, 2017 at 09:46:24AM +0200, Stefan Assmann wrote:
>> When an administratively set MAC was previously set and should now be
>> switched back to 00:00:00:00:00:00 the pf_set_mac flag did not get
>> toggled back to false.
>> As a result VFs were still treated as if an administratively set MAC was
>> present.
>>
>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 ++++++++++--
>>  1 file changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> index ecbe40e..af0ff61 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
>> @@ -2764,7 +2764,6 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
>>
>>  	spin_unlock_bh(&vsi->mac_filter_hash_lock);
>>
>> -	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
>>  	/* program mac filter */
>>  	if (i40e_sync_vsi_filters(vsi)) {
>>  		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
>> @@ -2772,7 +2771,16 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
>>  		goto error_param;
>>  	}
>>  	ether_addr_copy(vf->default_lan_addr.addr, mac);
>> -	vf->pf_set_mac = true;
>> +
>> +	if (is_zero_ether_addr(mac)) {
>> +		vf->pf_set_mac = false;
>> +		dev_info(&pf->pdev->dev, "Removing MAC on VF %d\n", vf_id);
>> +	} else {
>> +		vf->pf_set_mac = true;
>> +		dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n",
>> +			 mac, vf_id);
>> +	}
>> +
> 
> It can be removed to be one line change, because I'm not sure that
> dev_info prints are necessary here.
> +	vf->pf_set_mac = is_zero_ether_addr(mac);
> 
> Thanks

This matches ixgbe behavior, so I'd prefer to keep it this way.
Thanks!

  Stefan

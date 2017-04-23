From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next 03/11] ixgbe: add support for XDP_TX action
Date: Sat, 22 Apr 2017 20:40:22 -0700
Message-ID: <58FC2226.3070207@gmail.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
 <20170421015029.18994-4-jeffrey.t.kirsher@intel.com>
 <20170422192411.1d85793a@cakuba.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, nhorman@redhat.com,
        sassmann@redhat.com, jogreene@redhat.com,
        John Fastabend <john.r.fastabend@intel.com>
To: Jakub Kicinski <kubakici@wp.pl>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34056 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1427472AbdDWDko (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 23:40:44 -0400
Received: by mail-it0-f65.google.com with SMTP id 193so7771813itm.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 20:40:44 -0700 (PDT)
In-Reply-To: <20170422192411.1d85793a@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-22 07:24 PM, Jakub Kicinski wrote:
> On Thu, 20 Apr 2017 18:50:21 -0700, Jeff Kirsher wrote:
>> +static int ixgbe_xdp_queues(struct ixgbe_adapter *adapter)
>> +{
>> +	if (nr_cpu_ids > MAX_XDP_QUEUES)
>> +		return 0;
>> +
>> +	return adapter->xdp_prog ? nr_cpu_ids : 0;
>> +}
> 
> Nit: AFAICT ixgbe_xdp_setup() will guarantee xdp_prog is not set if
> there are too many CPU ids.

Sure being a bit paranoid I guess.

> 
>> @@ -6120,10 +6193,21 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
>>  		e_err(probe, "Allocation for Tx Queue %u failed\n", i);
>>  		goto err_setup_tx;
>>  	}
>> +	for (j = 0; j < adapter->num_xdp_queues; j++) {
>> +		err = ixgbe_setup_tx_resources(adapter->xdp_ring[j]);
>> +		if (!err)
>> +			continue;
>> +
>> +		e_err(probe, "Allocation for Tx Queue %u failed\n", j);
>> +		goto err_setup_tx;
>> +	}
>> +
>>  
> 
> Nit: extra line here

OK well I guess we can fix this if we need a respin anyways.

> 
>> @@ -9557,7 +9739,21 @@ static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
>>  			return -EINVAL;
>>  	}
>>  
>> +	if (nr_cpu_ids > MAX_XDP_QUEUES)
>> +		return -ENOMEM;
>> +
>>  	old_prog = xchg(&adapter->xdp_prog, prog);
>> +
>> +	/* If transitioning XDP modes reconfigure rings */
>> +	if (!!prog != !!old_prog) {
>> +		int err = ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
>> +
>> +		if (err) {
>> +			rcu_assign_pointer(adapter->xdp_prog, old_prog);
>> +			return -EINVAL;
>> +		}
>> +	}
>> +
>>  	for (i = 0; i < adapter->num_rx_queues; i++)
>>  		xchg(&adapter->rx_ring[i]->xdp_prog, adapter->xdp_prog);
>>  
> 
> In case of disabling XDP I assume ixgbe_setup_tc() will free the rings
> before the xdp_prog on the rings is swapped to NULL.  Is there anything
> preventing TX in that time window?  I think usual ordering would be to
> install the prog after reconfig but uninstall before.
> 

Well in the ixgbe_setup_tc() case we set the rx_ring->xdp_prog in
ixgbe_setup_rx_resorources(), while the dma engine is disabled, so the for
loop is just doing another set on the rx_ring assigning it to the program
already set previously.

Its not really buggy its just extra useless work so I'll change it to this,

	if (!!prog != !!old_prog) {
		...
	} else {
		for ( ... )
			swap xdp prog
	}

Nice spot, thanks for reviewing. And I missed a build error so I'll roll these
fixes in a resend.

Thanks,
John

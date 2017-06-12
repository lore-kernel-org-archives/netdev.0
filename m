From: Jes Sorensen <jsorensen@fb.com>
Subject: Re: [PATCH RFC net-next 3/4] net/mlx5: Separate between eswitch and
 MPFS l2 table logic
Date: Mon, 12 Jun 2017 13:52:54 -0400
Message-ID: <d205ed47-0275-ade7-1fdc-d82001b1dda5@fb.com>
References: <20170607234214.24723-1-saeedm@mellanox.com>
 <20170607234214.24723-4-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56708 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752018AbdFLRxE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 13:53:04 -0400
In-Reply-To: <20170607234214.24723-4-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 07:42 PM, Saeed Mahameed wrote:
> Multi-Physical Function Switch (MPFs) is required for when multi-PF
> configuration is enabled to allow passing user configured unicast MAC
> addresses to the requesting PF.
> 
> Before this patch eswitch.c used to manage the HW MPFS l2 table,
> eswitch always enabled vport(0) (NIC PF) vport's contexts update on unicast
> mac address list changes, to populate the PF's MPFS L2 table accordingly,
> even if SRIOV was not enabled.
> 
> In downstream patch we would like to allow compiling the driver without
> eswitch functionalities, for that we move MPFS l2 table logic out
> of eswitch.c into its own file, and provide Kconfig flag (MLX5_MPFS) to
> allow compiling out MPFS for those who don't want Multi-PF support
> 
> NIC PF netdevice will now directly update MPFS l2 table via the new MPFS
> API. VF netdevice has no access to MPFS L2 table, so e-Switch will remain
> responsible of updating its PF MPFS l2 table on behalf of its VFs.
> 
> Due to this change we also don't require enabling vport(0) (PF vport)
> unicast mac changes events anymore, for when SRIOV is not enabled.
> Which means eswitch is now activated only on SRIOV activation, and not
> required otherwise.


On overall it looks good - one nit.

> +static int alloc_l2table_index(struct mlx5_mpfs *l2table, u32 *ix)
> +{
> +	int err = 0;
> +
> +	*ix = find_first_zero_bit(l2table->bitmap, l2table->size);
> +	if (*ix >= l2table->size)
> +		err = -ENOSPC;
> +	else
> +		__set_bit(*ix, l2table->bitmap);
> +
> +	return err;
> +}

You pass in a pointer for ix but you don't modify it, why not just pass 
in the value?.

> +static void free_l2table_index(struct mlx5_mpfs *l2table, u32 ix)
> +{
> +	__clear_bit(ix, l2table->bitmap);
> +}

Here you stick to the u32.

Jes

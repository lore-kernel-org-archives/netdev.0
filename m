From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/6] mlxsw: spectrum_router: Use FIB
 notifications instead of switchdev calls
Date: Thu, 22 Sep 2016 11:47:23 +0200
Message-ID: <20160922094723.GB1830@nanopsycho.orion>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
 <1474458794-5512-4-git-send-email-jiri@resnulli.us>
 <20160922065102.GA13287@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35991 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752165AbcIVJr0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 05:47:26 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so13056732wma.3
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 02:47:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160922065102.GA13287@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 22, 2016 at 08:51:02AM CEST, idosch@idosch.org wrote:
>On Wed, Sep 21, 2016 at 01:53:11PM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Until now, in order to offload a FIB entry to HW we use switchdev op.
>> However that has limits. Mainly in case we need to make the HW aware of
>> all route prefixes configured in kernel. HW needs to know those in order
>> to properly trap appropriate packets and pass the to kernel to do
>> the forwarding. Abort mechanism is now handled within the mlxsw driver.
>
>FWIW, I think it's smart to move abort into the driver instead of
>flushing all the routes from the namespace as before.
>
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>[...]
>
>> +static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
>> +{
>> +	char ralue_pl[MLXSW_REG_RALUE_LEN];
>> +	struct mlxsw_resources *resources;
>> +	struct mlxsw_sp_fib_entry *fib_entry;
>> +	struct mlxsw_sp_fib_entry *tmp;
>> +	struct mlxsw_sp_vr *vr;
>> +	int i;
>> +	int err;
>> +
>> +	resources = mlxsw_core_resources_get(mlxsw_sp->core);
>> +	for (i = 0; i < resources->max_virtual_routers; i++) {
>> +		vr = &mlxsw_sp->router.vrs[i];
>> +		if (!vr->used)
>> +			continue;
>> +
>> +		list_for_each_entry_safe(fib_entry, tmp,
>> +					 &vr->fib->entry_list, list) {
>> +			fib_info_offload_dec(fib_entry->fi);
>> +			mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
>> +			mlxsw_sp_fib_entry_remove(fib_entry->vr->fib,
>> +						  fib_entry);
>> +			mlxsw_sp_fib_entry_put_all(mlxsw_sp, fib_entry);
>
>If we now do the routing in slow path, then maybe it makes sense to also
>flush all the neighbour entries and prevent new neighbours from being
>programmed into the device?

Hmm, that makes sense. Since this patch does not change the existing
behaiour regarding this, I would like to address that in follow-up
patch.



>
>> +		}
>> +	}
>> +	mlxsw_sp->router.aborted = true;
>> +
>> +	mlxsw_reg_ralue_pack4(ralue_pl, MLXSW_SP_L3_PROTO_IPV4,
>> +			      MLXSW_REG_RALUE_OP_WRITE_WRITE, 0, 0, 0);
>
>I'm not sure about that, but the loop above removed all the tables from
>the device and now you are using table 0 again. Will this work w/o
>binding some tree to it (0?)?

You are right. Will fix.



>
>> +	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
>> +	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
>> +	if (err)
>> +		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
>> +}
>
>Thanks

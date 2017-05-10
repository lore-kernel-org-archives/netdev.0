From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-mellanox] question about potential null pointer
 dereference
Date: Wed, 10 May 2017 11:01:06 -0500
Message-ID: <20170510110106.Horde.JgxThF8mIQZAnkBm18hgMAi@gator4166.hostgator.com>
References: <20170510103659.Horde.a0uOuKuhfTuy1DbqQ378EHK@gator4166.hostgator.com>
 <20170510155131.GA11944@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway31.websitewelcome.com ([192.185.143.39]:34015 "EHLO
        gateway31.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753112AbdEJQBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 12:01:09 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway31.websitewelcome.com (Postfix) with ESMTP id 3B80961B75
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 11:01:07 -0500 (CDT)
In-Reply-To: <20170510155131.GA11944@splinter.mtl.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quoting Ido Schimmel <idosch@mellanox.com>:

> On Wed, May 10, 2017 at 10:36:59AM -0500, Gustavo A. R. Silva wrote:
>>
>> Hello everybody,
>>
>> While looking into Coverity ID 1350941 I ran into the following piece of
>> code at drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:1483:
>>
>> 1483static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
>> 1484                                            char *sfn_pl, int rec_index,
>> 1485                                            bool adding)
>> 1486{
>> 1487        struct mlxsw_sp_port *mlxsw_sp_port;
>> 1488        char mac[ETH_ALEN];
>> 1489        u8 local_port;
>> 1490        u16 vid, fid;
>> 1491        bool do_notification = true;
>> 1492        int err;
>> 1493
>> 1494        mlxsw_reg_sfn_mac_unpack(sfn_pl, rec_index, mac, &fid,
>> &local_port);
>> 1495        mlxsw_sp_port = mlxsw_sp->ports[local_port];
>> 1496        if (!mlxsw_sp_port) {
>> 1497                dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Incorrect
>> local port in FDB notification\n");
>> 1498                goto just_remove;
>> 1499        }
>> 1500
>> 1501        if (mlxsw_sp_fid_is_vfid(fid)) {
>> 1502                struct mlxsw_sp_port *mlxsw_sp_vport;
>> 1503
>> 1504                mlxsw_sp_vport =
>> mlxsw_sp_port_vport_find_by_fid(mlxsw_sp_port,
>> 1505                                                                 fid);
>> 1506                if (!mlxsw_sp_vport) {
>> 1507                        netdev_err(mlxsw_sp_port->dev, "Failed to find a
>> matching vPort following FDB notification\n");
>> 1508                        goto just_remove;
>> 1509                }
>> 1510                vid = 0;
>> 1511                /* Override the physical port with the vPort. */
>> 1512                mlxsw_sp_port = mlxsw_sp_vport;
>> 1513        } else {
>> 1514                vid = fid;
>> 1515        }
>> 1516
>> 1517do_fdb_op:
>> 1518        err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp, local_port, mac, fid,
>> 1519                                      adding, true);
>> 1520        if (err) {
>> 1521                if (net_ratelimit())
>> 1522                        netdev_err(mlxsw_sp_port->dev, "Failed to set
>> FDB entry\n");
>> 1523                return;
>> 1524        }
>> 1525
>> 1526        if (!do_notification)
>> 1527                return;
>> 1528        mlxsw_sp_fdb_call_notifiers(mlxsw_sp_port->learning_sync,
>> 1529                                    adding, mac, vid,  
>> mlxsw_sp_port->dev);
>> 1530        return;
>> 1531
>> 1532just_remove:
>> 1533        adding = false;
>> 1534        do_notification = false;
>> 1535        goto do_fdb_op;
>> 1536}
>>
>>
>> The issue here is that line 1496 implies that mlxsw_sp_port might be NULL.
>> If this is the case, the execution path jumps to line 1532 and then to line
>> 1517. All this could end up dereferencing a NULL pointer at line 1522.
>>
>> Is there any chance for mlxsw_sp_port to be NULL at line 1496 and, at the
>> same time, a NULL pointer dereference occurs at line 1522?
>>
>> I'm trying to figure out if this is a false positive or something that
>> actually needs to be fixed.
>
> In theory, yes, it can happen, but it didn't happen yet. I recently
> patched that and now it's in Jiri's queue. I guess he'll send it
> tomorrow.
>
> https://github.com/jpirko/linux_mlxsw/commit/4160fb9ad6eeacba7736cfdbf7f52248432c2e89
>

Great, glad to see it is fixed now.

> Thanks for looking into this!
>

Sure thing, thanks for clarifying. :)

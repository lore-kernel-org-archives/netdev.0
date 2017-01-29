From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Sun, 29 Jan 2017 11:11:40 +0200
Message-ID: <CALzJLG9OksXW5JAZiPoSfKtTF_z8Te9UDP9bm_XhXAp-FwmwEw@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
 <CAJ3xEMhaQ4zsBxkWzs8qCv5KT-gAmdD9dNkSS+KDwB+VGw5SEw@mail.gmail.com>
 <CALzJLG_v2HxsdPdX5H=T51RGmaMMnXVxzihuPN66a9RxDadEcw@mail.gmail.com>
 <CALx6S34K-N7TWtEG0cCgq-zAXqqfNp9zp1JtR8bLvD=F90A2pg@mail.gmail.com>
 <CALzJLG9YXBzXAOrtth7SX8n3S5cN3ZSmKax4FOGiTr7SY8gobg@mail.gmail.com>
 <CALx6S375OVvSi5QLLCpsGc84iE3cJ3VH5Rm6sg8OJgDR=nqXfA@mail.gmail.com>
 <CALzJLG_WCiTei7CDoUCzM241gt0bSKqjGJ61ke2XbbQTOjZBkQ@mail.gmail.com>
 <CALx6S35-ecvO0k6-yqdLpO6mXA4Y6mycMD3HqHPCaUtMZd8GYA@mail.gmail.com>
 <CALzJLG-U2uLB2uqeVT1viP87oxDEp1XUymu-zVRhe9yGrBEc+w@mail.gmail.com>
 <588BD66E.2050201@fb.com> <CALzJLG_abLhT7wcrtB97KzurJ2-=OZv11cELjoRW79cOeyjxgw@mail.gmail.com>
 <588CDA55.7030900@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:33003 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdA2NSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 08:18:00 -0500
Received: by mail-qt0-f181.google.com with SMTP id v23so183786952qtb.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 05:17:53 -0800 (PST)
In-Reply-To: <588CDA55.7030900@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 7:52 PM, Alexei Starovoitov <ast@fb.com> wrote:
> On 1/28/17 3:20 AM, Saeed Mahameed wrote:
>>
>> On Sat, Jan 28, 2017 at 1:23 AM, Alexei Starovoitov <ast@fb.com> wrote:
>>>
>>> On 1/27/17 1:15 PM, Saeed Mahameed wrote:
>>>>
>>>>
>>>> It is only mandatory for configurations that needs eswitch, where the
>>>> driver has no way to know about them, for a good old bare metal box,
>>>> eswitch is not needed.
>>>>
>>>> we can do some work to strip the l2 table logic - needed for PFs to
>>>> work on multi-host - out of eswitch but again that would further
>>>> complicate the driver code since eswitch will still need to update l2
>>>> tables for VFs.
>>>
>>>
>>>
>>> Saeed,
>>> for multi-host setups every host in that multi-host doesn't
>>> actually see the eswitch, no? Otherwise broken driver on one machine
>>> can affect the other hosts in the same bundle? Please double check,
>>
>>
>> each host (PF) has its own eswitch, and each eswitch lives in its own
>> "steering-space"
>>   and it can't affect others.
>>
>>> since this is absolutely critical HW requirement.
>>>
>>
>> The only shared HW resources between hosts (PFs) is the simple l2 table,
>> and the only thing a host can ask from the l2 talbe (FW) is: "forward
>> UC MAC to me", and it is the responsibility of the the driver eswitch
>> to do so.
>>
>> the l2 table is created and managed by FW, SW eswitch can only request
>> from FW, and the FW is trusted.
>
>
> ok. clear. thanks for explaining.
> Could you describe the sequence of function calls within mlx5
> that does the assignment of uc mac for PF ?
> since I'm missing where eswitch is involved.
> I can see:
> mlx5e_nic_enable | mlx5e_set_mac
>   queue_work(priv->wq, &priv->set_rx_mode_work);
>     mlx5e_set_rx_mode_work
>       mlx5e_apply_netdev_addr
>         mlx5e_add_l2_flow_rule
>

It is a  little bit more complicated than this :).

ConnectX4/5 and hopefully so on .. provide three different isolated
steering layers:

3. vport layer: avaialbe for any PF/VF vport nic driver instance
(netdevice), it allows vlan/mac filtering
 ,RSS hashing and n-tuple steering (for both encapsulated and
nonencapsulated traffic) and RFS steering. ( the code above only
writes flow entries of a PF/VF to its own vport flow tables, there is
another mechanism to propagate l2 steering rules down to eswitch from
the vport layer.

2. eswitch layer: Available for PFs only with
HCA_CAP.vport_group_manager capability set.
it allows steering between PF and different VFs on the same host (vlan
mac steering and ACL filters in sriov legacy mode, and fancy n-tuple
steering and offloads for switchdev mode - eswitch_offloads.c - )
if this table is not create the default is pass-throu traffic to PF

1. L2 table: Available for PFs only with HCA_CAP.vport_group_manager
capability set.
needed for MH configurations and only PF is allowed and should write
"request UC MAC - set_l2_table_entry" on behalf of the PF itself and
it's own VFs.

- On a bare metal machine only layer 3 is required (all traffic is
passed to the PF vport).
- On a MH configuration layer 3 and 1 are required.
- On a SRIOV configuration layer 3 and 2 are required.
- On MH with SRIOV all layers are required.

in the driver, eswitch and L2 layers are handled by PF@eswitch.c.

So for your question:

PF always init_eswitch ( no eswitch -sriov- tables are created), and
the eswitch will start listening for vport_change_events.

A PF/VF or netdev vport instance on any steering changes updates
should call  mlx5e_vport_context_update[1]

vport_context_update is A FW command that will store the current
UC/MC/VLAN list and promiscuity info of a vport.

The FW will generate an event to the PF driver eswitch manager (vport
manager) mlx5_eswitch_vport_event [2], and the PF eswitch will call
set_l2_table_entry for each UC mac on each vport change event of any
vport (including its own vport), in case of SRIOV is enabled it will
update eswitch tables as well.

To simplify my answer the function calls are:
Vport VF/PF netdevice:
mlx5e_set_rx_mode_work
    mlx5e_vport_context_update
       mlx5e_vport_context_update_addr_list  --> FW event will be
generated to the PF esiwtch manager

PF eswitch manager(eswitch.c) on a vport change FW event:
mlx5_eswitch_vport_event
      esw_vport_change_handler
           esw_vport_change_handle_locked
                   esw_apply_vport_addr_list
                              esw_add_uc_addr
                                     set_l2_table_entry --> this will
update the l2 table in case MH is enabled.

Sorry for the long answer :)
-Saeed

[1] http://lxr.free-electrons.com/source/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c#L440
[2] http://lxr.free-electrons.com/source/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c#L1675

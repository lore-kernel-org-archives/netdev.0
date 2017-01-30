From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Mon, 30 Jan 2017 08:45:59 -0800
Message-ID: <588F6DC7.70904@fb.com>
References: <20170126233241.2268449-1-tom@herbertland.com>
 <20170126233241.2268449-2-tom@herbertland.com>
 <CAJ3xEMhaQ4zsBxkWzs8qCv5KT-gAmdD9dNkSS+KDwB+VGw5SEw@mail.gmail.com>
 <CALzJLG_v2HxsdPdX5H=T51RGmaMMnXVxzihuPN66a9RxDadEcw@mail.gmail.com>
 <CALx6S34K-N7TWtEG0cCgq-zAXqqfNp9zp1JtR8bLvD=F90A2pg@mail.gmail.com>
 <CALzJLG9YXBzXAOrtth7SX8n3S5cN3ZSmKax4FOGiTr7SY8gobg@mail.gmail.com>
 <CALx6S375OVvSi5QLLCpsGc84iE3cJ3VH5Rm6sg8OJgDR=nqXfA@mail.gmail.com>
 <CALzJLG_WCiTei7CDoUCzM241gt0bSKqjGJ61ke2XbbQTOjZBkQ@mail.gmail.com>
 <CALx6S35-ecvO0k6-yqdLpO6mXA4Y6mycMD3HqHPCaUtMZd8GYA@mail.gmail.com>
 <CALzJLG-U2uLB2uqeVT1viP87oxDEp1XUymu-zVRhe9yGrBEc+w@mail.gmail.com>
 <588BD66E.2050201@fb.com>
 <CALzJLG_abLhT7wcrtB97KzurJ2-=OZv11cELjoRW79cOeyjxgw@mail.gmail.com>
 <588CDA55.7030900@fb.com>
 <CALzJLG9OksXW5JAZiPoSfKtTF_z8Te9UDP9bm_XhXAp-FwmwEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36300 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753769AbdA3Qq0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:46:26 -0500
In-Reply-To: <CALzJLG9OksXW5JAZiPoSfKtTF_z8Te9UDP9bm_XhXAp-FwmwEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/17 1:11 AM, Saeed Mahameed wrote:
>
> ConnectX4/5 and hopefully so on .. provide three different isolated
> steering layers:
>
> 3. vport layer: avaialbe for any PF/VF vport nic driver instance
> (netdevice), it allows vlan/mac filtering
>   ,RSS hashing and n-tuple steering (for both encapsulated and
> nonencapsulated traffic) and RFS steering. ( the code above only
> writes flow entries of a PF/VF to its own vport flow tables, there is
> another mechanism to propagate l2 steering rules down to eswitch from
> the vport layer.
>
> 2. eswitch layer: Available for PFs only with
> HCA_CAP.vport_group_manager capability set.
> it allows steering between PF and different VFs on the same host (vlan
> mac steering and ACL filters in sriov legacy mode, and fancy n-tuple
> steering and offloads for switchdev mode - eswitch_offloads.c - )
> if this table is not create the default is pass-throu traffic to PF
>
> 1. L2 table: Available for PFs only with HCA_CAP.vport_group_manager
> capability set.
> needed for MH configurations and only PF is allowed and should write
> "request UC MAC - set_l2_table_entry" on behalf of the PF itself and
> it's own VFs.
>
> - On a bare metal machine only layer 3 is required (all traffic is
> passed to the PF vport).
> - On a MH configuration layer 3 and 1 are required.
> - On a SRIOV configuration layer 3 and 2 are required.
> - On MH with SRIOV all layers are required.
>
> in the driver, eswitch and L2 layers are handled by PF@eswitch.c.
>
> So for your question:
>
> PF always init_eswitch ( no eswitch -sriov- tables are created), and
> the eswitch will start listening for vport_change_events.
>
> A PF/VF or netdev vport instance on any steering changes updates
> should call  mlx5e_vport_context_update[1]
>
> vport_context_update is A FW command that will store the current
> UC/MC/VLAN list and promiscuity info of a vport.
>
> The FW will generate an event to the PF driver eswitch manager (vport
> manager) mlx5_eswitch_vport_event [2], and the PF eswitch will call
> set_l2_table_entry for each UC mac on each vport change event of any
> vport (including its own vport), in case of SRIOV is enabled it will
> update eswitch tables as well.
>
> To simplify my answer the function calls are:
> Vport VF/PF netdevice:
> mlx5e_set_rx_mode_work
>      mlx5e_vport_context_update
>         mlx5e_vport_context_update_addr_list  --> FW event will be
> generated to the PF esiwtch manager
>
> PF eswitch manager(eswitch.c) on a vport change FW event:
> mlx5_eswitch_vport_event
>        esw_vport_change_handler
>             esw_vport_change_handle_locked
>                     esw_apply_vport_addr_list
>                                esw_add_uc_addr
>                                       set_l2_table_entry --> this will
> update the l2 table in case MH is enabled.

all makes sense. To test this logic I added printk-s
to above functions, but I only see:
# ip link set eth0 addr 24:8a:07:47:2b:6e
[  148.861914] mlx5e_vport_context_update_addr_list: is_uc 1 err 0
[  148.875152] mlx5e_vport_context_update_addr_list: is_uc 0 err 0

MLX5_EVENT_TYPE_NIC_VPORT_CHANGE doesn't come into mlx5_eq_int().
Yet nic seems to work fine. Packets come and go.

broken firmware or expected behavior?

# ethtool -i eth0
driver: mlx5_core
version: 3.0-1 (January 2015)
firmware-version: 14.16.2024

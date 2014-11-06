From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: mlx4+vxlan offload breaks gre tunnels
Date: Thu, 6 Nov 2014 09:03:42 +0200
Message-ID: <CAJ3xEMgpzY0U4g52P=FiPtHCT+bH1bKEjSj+1OfFAfKc44q2dg@mail.gmail.com>
References: <20141105150448.GA20776@breakpoint.cc>
	<545A4DB7.5010603@mellanox.com>
	<CA+mtBx_oxJxteeBnbyboGTSKn3JdBRx2Nb3a9EuCZzG+_U-8Zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>, Amir Vadai <amirv@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:48140 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbaKFHDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 02:03:43 -0500
Received: by mail-ob0-f169.google.com with SMTP id va2so390483obc.14
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 23:03:42 -0800 (PST)
In-Reply-To: <CA+mtBx_oxJxteeBnbyboGTSKn3JdBRx2Nb3a9EuCZzG+_U-8Zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014 at 11:59 PM, Tom Herbert <therbert@google.com> wrote:
> On Wed, Nov 5, 2014 at 8:17 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> On 11/5/2014 5:04 PM, Florian Westphal wrote:
>>>
>>> tl,dr: all tcp packets sent via gre tunnel have broken tcp csum if vxlan
>>> offload
>>> is enabled with mlx4 driver.
>>>
>>> Given following config on tx-side:
>>> dev=enp3s0
>>> ip addr add dev $dev 192.168.23.1/24
>>> ip link set $dev up
>>> ip link add mygre type gretap remote 192.168.23.2 local 192.168.23.1
>>> ip addr add dev mygre 192.168.42.1/24
>>> ip link set gre0 up
>>> ip link set mygre up
>>>
>>> and
>>>
>>> options mlx4_core log_num_mgm_entry_size=-1 debug_level=1
>>> port_type_array=2,2
>>>
>>> in
>>> /etc/modprobe.d/mlx4.conf
>>>
>>> all tcp packets sent to destinations over the gre tunnel have bogus tcp
>>> checksums (and are tossed on rx side when stack validates tcp checksum).
>>>
>>> net-next head is commit 30349bdbc4da5ecf0efa25556e3caff9c9b8c5f7 .
>>>
>>> What makes things work for me:
>>> either
>>>
>>> options mlx4_core 1 debug_level=1 port_type_array=2,2
>>>
>>> (ie. no MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
>>>
>>> or not setting NETIF_F_IP_CSUM in enc_features:
>>>
>>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> @@ -2579,10 +2579,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev,
>>> int port,
>>>                  dev->priv_flags |= IFF_UNICAST_FLT;
>>>            if (mdev->dev->caps.tunnel_offload_mode ==
>>> MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
>>> -               dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>>> +               dev->hw_enc_features |= NETIF_F_RXCSUM |
>>>                                          NETIF_F_TSO |
>>> NETIF_F_GSO_UDP_TUNNEL;
>>>
>>> I am not sure if its right fix, but to my eyes this basically looks like
>>> mlx4 is telling stack that it can handle tcp checksum offload within
>>> tunnels, and that doesn't seem to be the case for all types (e.g. gre).
>>>
>>> Could someone who understand the enc_features specifics better confirm
>>> that
>>> above patch is correct (or provide a better/proper fix)?
>>
>>
>> Yep, I can see now the problem. It comes into play with ConnectX3-pro NICs
>> that support VXLAN offloads (but not with ConnectX3 NIC which don't) when
>> you enable the offloads support on the CX3-pro.
>>
>> The problem originates from the fact that we can't advertize something like
>> "the HW can offload the inner checksum of UDP/VXLAN encapsulated (but not
>> for GRE)", e.g in a similar manner that exists in the GSO space, where you
>> have NETIF_F_GSO _YYY for each yyy in {UDP, SIT, GRE, etc} tunneling scheme.
>>
>> I think the best effort we can do now is
>>
>> 1. come up with something such as the below patch for 3.18 which is
>> back-ward portable for -stable kernels, it will only arm the hw offloads if
>> the OS tells us there's VXLAN in action
>>
>> 2. come  up with proper kernel APIs to let NICs advertize which encap
>> schemes they can actually offload the inner checksum, Tom... your work which
>> now runs over netdev.

> Possibly #3: add ndo_gso_check to detect nested tunneling. In this
> case it would see that gso_type has both SKB_GSO_GRE and
> SKB_GSO_UDP_TUNNEL set.

I am not with you, where do we have nested tunneling here? the below
setting is simple GRE tunnel
to host (say) TCP traffic

>> tested to work with the  following which is a bit different, tell me if it
>> works for you
>>
>> # node A - with mlx4_en address192.168.31.18
>> ip tunnel add gre1 mode gre local 192.168.31.18 remote 192.168.31.17 ttl 255
>> ifconfig gre1 10.10.10.18/24 up
>> ifconfig gre1 mtu 1450
>>
>> # node B - with mlx4_en address192.168.31.17
>> ip tunnel add gre1 mode gre local 192.168.31.17 remote 192.168.31.18 ttl 255
>> ifconfig gre1 10.10.10.17/24 up
>> ifconfig gre1 mtu 1450

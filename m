From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 08/14] ixgbe: Add support for generic Tx checksums
Date: Mon, 4 Apr 2016 15:54:10 -0700
Message-ID: <CAKgT0Uf1zT2uihC6e04nt_1MkwOBsnx4Yh-ZJ-1i2kEec_zJFQ@mail.gmail.com>
References: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1459808097-26409-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<5702EB85.5080307@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@redhat.com>, sassmann@redhat.com,
	John Greene <jogreene@redhat.com>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36789 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbcDDWyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 18:54:11 -0400
Received: by mail-io0-f177.google.com with SMTP id q128so164564713iof.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 15:54:11 -0700 (PDT)
In-Reply-To: <5702EB85.5080307@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 4, 2016 at 3:32 PM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 4/4/2016 3:14 PM, Jeff Kirsher wrote:
>>
>> From: Alexander Duyck <aduyck@mirantis.com>
>>
>> This patch adds support for generic Tx checksums to the ixgbe driver.  It
>> turns out this is actually pretty easy after going over the datasheet as
>> we
>> were doing a number of steps we didn't need to.
>>
>> In order to perform a Tx checksum for an L4 header we need to fill in the
>> following fields in the Tx descriptor:
>>    MACLEN (maximum of 127), retrieved from:
>>                 skb_network_offset()
>>    IPLEN  (maximum of 511), retrieved from:
>>                 skb_checksum_start_offset() - skb_network_offset()
>>    TUCMD.L4T indicates offset and if checksum or crc32c, based on:
>>                 skb->csum_offset
>>
>> The added advantage to doing this is that we can support inner checksum
>> offloads for tunnels and MPLS while still being able to transparently
>> insert VLAN tags.
>>
>> I also took the opportunity to clean-up many of the feature flag
>> configuration bits to make them a bit more consistent between drivers.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 164
>> +++++++++-----------------
>>   1 file changed, 59 insertions(+), 105 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index bce5737..8d248c8 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -7202,103 +7202,61 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
>>         return 1;
>>   }
>>
>
>
> <snip>
>
>
>
>> @@ -9190,41 +9148,37 @@ skip_sriov:
>>     #endif
>>         netdev->features = NETIF_F_SG |
>> -                          NETIF_F_IP_CSUM |
>> -                          NETIF_F_IPV6_CSUM |
>> -                          NETIF_F_HW_VLAN_CTAG_TX |
>> -                          NETIF_F_HW_VLAN_CTAG_RX |
>>                            NETIF_F_TSO |
>>                            NETIF_F_TSO6 |
>>                            NETIF_F_RXHASH |
>> -                          NETIF_F_RXCSUM;
>> -
>> -       netdev->hw_features = netdev->features | NETIF_F_HW_L2FW_DOFFLOAD;
>> +                          NETIF_F_RXCSUM |
>> +                          NETIF_F_HW_CSUM |
>> +                          NETIF_F_SCTP_CRC |
>> +                          NETIF_F_HW_VLAN_CTAG_TX |
>> +                          NETIF_F_HW_VLAN_CTAG_RX;
>>   -     switch (adapter->hw.mac.type) {
>> -       case ixgbe_mac_82599EB:
>> -       case ixgbe_mac_X540:
>> -       case ixgbe_mac_X550:
>> -       case ixgbe_mac_X550EM_x:
>> +       if (hw->mac.type >= ixgbe_mac_82599EB)
>>                 netdev->features |= NETIF_F_SCTP_CRC;
>> -               netdev->hw_features |= NETIF_F_SCTP_CRC |
>> -                                      NETIF_F_NTUPLE |
>> -                                      NETIF_F_HW_TC;
>> -               break;
>> -       default:
>> -               break;
>> -       }
>>   -     netdev->hw_features |= NETIF_F_RXALL;
>> +       /* copy netdev features into list of user selectable features */
>> +       netdev->hw_features |= netdev->features;
>> +       netdev->hw_features |= NETIF_F_RXALL |
>> +                              NETIF_F_HW_L2FW_DOFFLOAD;
>> +
>> +       if (hw->mac.type >= ixgbe_mac_82599EB)
>> +               netdev->hw_features |= NETIF_F_NTUPLE;
>
>
> looks like the cleanup missed moving NETIF_F_HW_TC flag here that enables
> cls_u32 offloads via TC.

Back when I submitted this patch the NETIF_F_HW_TC flag didn't exist.
I'm pretty sure this is probably a case of a patch getting mangled
after sitting in the tree for so long.

In addition I just noticed there is a bug in the setting of the
SCTP_CRC flag as well.  It is set twice when we should only be setting
it in the if statement.  It is just a quick 2 line fix that is needed.
I can either submit a follow-up or I can respin the original patch
real quick so that it applies on top of the current ixgbe queue.

- Alex

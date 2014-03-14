From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 01/16] ixgbe: add check for netif_carrier_ok in
 ixgbe_xmit_frame
Date: Fri, 14 Mar 2014 20:19:38 +0000
Message-ID: <87618083B2453E4A8714035B62D679924FF2B099@FMSMSX105.amr.corp.intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1394790446-31591-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <20140314.145735.289100032884651109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"asharma@fb.com" <asharma@fb.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140314.145735.289100032884651109.davem@davemloft.net>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, March 14, 2014 11:58 AM
>To: Kirsher, Jeffrey T
>Cc: Tantilov, Emil S; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com; asharma@fb.com;
>stable@vger.kernel.org
>Subject: Re: [net-next 01/16] ixgbe: add check for
>netif_carrier_ok in ixgbe_xmit_frame
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Fri, 14 Mar 2014 02:47:11 -0700
>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index 851c413..8bea6ca 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -7121,6 +7121,11 @@ static netdev_tx_t
>__ixgbe_xmit_frame(struct sk_buff *skb,
>>  	struct ixgbe_adapter *adapter = netdev_priv(netdev);
>>  	struct ixgbe_ring *tx_ring;
>>
>> +	if (!netif_carrier_ok(netdev)) {
>> +		dev_kfree_skb_any(skb);
>> +		return NETDEV_TX_OK;
>> +	}
>> +
>
>I would much prefer that this check moves into netpoll's
>direct invocation of
>->ndo_start_xmit().
>
>Otherwise every driver will start to add this check and that
>kind of duplication doesn't make any sense at all.

That would work, but what if there are other callers of ndo_start_xmit that don't have this check? Handling this in the driver takes care of all instances.

Specifically this issue was seen with netconsole, but we also had reports of the same issue where I'm not sure netconsole was the culprit (I just don't have enough info about the setup).

If the netif_carrier_ok() check in ixgbe_start_xmit() is not acceptable we'll still have to plug a possible issue in ixgbe_watchdog_flush_tx() where a call to ndo_start_xmit may fill the rings after the HW reset and cause the driver to go into a reset loop.

Thanks,
Emil

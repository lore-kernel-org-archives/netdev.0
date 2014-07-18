From: Neil Armstrong <superna9999@gmail.com>
Subject: Re: [PATCH 1/2] net: macb: Separate rx and tx ring init function
Date: Fri, 18 Jul 2014 12:13:33 +0200
Message-ID: <53C8F34D.9090503@gmail.com>
References: <53C8EE60.8020707@gmail.com> <53C8F280.9040507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Varka Bhadram <varkabhadram@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53C8F280.9040507@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/07/2014 12:10, Varka Bhadram a =E9crit :
> On 07/18/2014 03:22 PM, Neil Armstrong wrote:
>> A single method is called to initialize the TX and RX
>> rings. Separate the methods into distinct ones for
>> MACB and GEM context.
>>
>> Signed-off-by: Neil Armstrong <narmstrong@neotion.com>
>> ---
>>   drivers/net/ethernet/cadence/macb.c |   33 +++++++++++++++++++++++=
+---------
>>   drivers/net/ethernet/cadence/macb.h |    3 ++-
>>   2 files changed, 26 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
>> index e9daa07..20ad483 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -1219,7 +1219,14 @@ out_err:
>>   	return -ENOMEM;
>>   }
>>  =20
>> -static void gem_init_rings(struct macb *bp)
>> +static void gem_init_rx_rings(struct macb *bp)
>> +{
>> +	bp->rx_tail =3D bp->rx_prepared_head =3D 0;
>> +
>> +	gem_rx_refill(bp);
>> +}
>> +
>> +static void gem_init_tx_rings(struct macb *bp)
>>   {
>>   	int i;
>>  =20
>> @@ -1229,12 +1236,10 @@ static void gem_init_rings(struct macb *bp)
>>   	}
>>   	bp->tx_ring[TX_RING_SIZE - 1].ctrl |=3D MACB_BIT(TX_WRAP);
>>  =20
>> -	bp->rx_tail =3D bp->rx_prepared_head =3D bp->tx_head =3D bp->tx_ta=
il =3D 0;
>> -
>> -	gem_rx_refill(bp);
>> +	bp->tx_head =3D bp->tx_tail =3D 0;
>=20
> This is not the preferred way of doing it....
>=20
> multiple assignments should be avoided
Should I change it ? I only moved the lines, the logic hasn't changed.
>=20
>>   }
>>  =20
>> -static void macb_init_rings(struct macb *bp)
>> +static void macb_init_rx_rings(struct macb *bp)
>>   {
>>   	int i;
>>   	dma_addr_t addr;
>> @@ -1247,13 +1252,20 @@ static void macb_init_rings(struct macb *bp)
>>   	}
>>   	bp->rx_ring[RX_RING_SIZE - 1].addr |=3D MACB_BIT(RX_WRAP);
>>  =20
>> +	bp->rx_tail =3D 0;
>> +}
>> +
>> +static void macb_init_tx_rings(struct macb *bp)
>> +{
>> +	int i;
>> +
>>   	for (i =3D 0; i < TX_RING_SIZE; i++) {
>>   		bp->tx_ring[i].addr =3D 0;
>>   		bp->tx_ring[i].ctrl =3D MACB_BIT(TX_USED);
>>   	}
>>   	bp->tx_ring[TX_RING_SIZE - 1].ctrl |=3D MACB_BIT(TX_WRAP);
>>  =20
>> -	bp->rx_tail =3D bp->tx_head =3D bp->tx_tail =3D 0;
>> +	bp->tx_head =3D bp->tx_tail =3D 0;
>=20
> Dto...
Idem, it was like this before.
>=20
>>   }
>>  =20
>>   static void macb_reset_hw(struct macb *bp)
>> @@ -1554,7 +1566,8 @@ static int macb_open(struct net_device *dev)
>>  =20
>>   	napi_enable(&bp->napi);
>>  =20
>> -	bp->macbgem_ops.mog_init_rings(bp);
>> +	bp->macbgem_ops.mog_init_rx_rings(bp);
>> +	bp->macbgem_ops.mog_init_tx_rings(bp);
>>   	macb_init_hw(bp);
>>  =20
>>   	/* schedule a link state check */
>> @@ -1901,12 +1914,14 @@ static int __init macb_probe(struct platform=
_device *pdev)
>>   	if (macb_is_gem(bp)) {
>>   		bp->macbgem_ops.mog_alloc_rx_buffers =3D gem_alloc_rx_buffers;
>>   		bp->macbgem_ops.mog_free_rx_buffers =3D gem_free_rx_buffers;
>> -		bp->macbgem_ops.mog_init_rings =3D gem_init_rings;
>> +		bp->macbgem_ops.mog_init_rx_rings =3D gem_init_rx_rings;
>> +		bp->macbgem_ops.mog_init_tx_rings =3D gem_init_tx_rings;
>>   		bp->macbgem_ops.mog_rx =3D gem_rx;
>>   	} else {
>>   		bp->macbgem_ops.mog_alloc_rx_buffers =3D macb_alloc_rx_buffers;
>>   		bp->macbgem_ops.mog_free_rx_buffers =3D macb_free_rx_buffers;
>> -		bp->macbgem_ops.mog_init_rings =3D macb_init_rings;
>> +		bp->macbgem_ops.mog_init_rx_rings =3D macb_init_rx_rings;
>> +		bp->macbgem_ops.mog_init_tx_rings =3D macb_init_tx_rings;
>>   		bp->macbgem_ops.mog_rx =3D macb_rx;
>>   	}
>>  =20
>> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ether=
net/cadence/macb.h
>> index 51c0244..8016d08 100644
>> --- a/drivers/net/ethernet/cadence/macb.h
>> +++ b/drivers/net/ethernet/cadence/macb.h
>> @@ -550,7 +550,8 @@ struct macb;
>>   struct macb_or_gem_ops {
>>   	int	(*mog_alloc_rx_buffers)(struct macb *bp);
>>   	void	(*mog_free_rx_buffers)(struct macb *bp);
>> -	void	(*mog_init_rings)(struct macb *bp);
>> +	void	(*mog_init_rx_rings)(struct macb *bp);
>> +	void	(*mog_init_tx_rings)(struct macb *bp);
>>   	int	(*mog_rx)(struct macb *bp, int budget);
>>   };
>>  =20
>=20
>=20

Do I need to make a corrective patch for multiple assignments before ?

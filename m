From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v4] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Sat, 31 Oct 2015 16:03:26 +0000
Message-ID: <yw1xlhajauup.fsf@unicorn.mansr.com>
References: <1446137333-1822-1-git-send-email-mans@mansr.com>
	<20151030222841.GA24712@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151030222841.GA24712@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Fri, 30 Oct 2015 23:28:42 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu <romieu@fr.zoreil.com> writes:

>> +static int nb8800_poll(struct napi_struct *napi, int budget)
>> +{
>> +	struct net_device *dev =3D napi->dev;
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +	struct nb8800_dma_desc *rx;
>> +	int work =3D 0;
>> +	int last =3D priv->rx_eoc;
>> +	int next;
>> +
>> +	while (work < budget) {
>> +		struct rx_buf *rx_buf;
>> +		u32 report;
>> +		int len;
>> +
>> +		next =3D (last + 1) & (RX_DESC_COUNT - 1);
>> +
>> +		rx_buf =3D &priv->rx_bufs[next];
>> +		rx =3D &priv->rx_descs[next];
>> +		report =3D rx->report;
>> +
>> +		if (!report)
>> +			break;
>> +
>> +		if (IS_RX_ERROR(report)) {
>> +			nb8800_rx_error(dev, report);
>> +		} else if (likely(rx_buf->page)) {
>> +			len =3D RX_BYTES_TRANSFERRED(report);
>> +			nb8800_receive(dev, next, len);
>> +		}
>> +
>> +		rx->report =3D 0;
>> +		if (!rx_buf->page)
>> +			nb8800_alloc_rx(dev, next, true);
>
> It looks like it receives, then tries to allocate new resources. If s=
o
> it may deplete the ring and you should instead consider allocating ne=
w
> resources first, then receive data if alloc + map suceeded.

The hardware receives a frame and stores it in the provided DMA buffer,
then raises an interrupt and moves on to the next buffer.  When a buffe=
r
is handed over to the network stack, a new one has to take its place in
the DMA queue.  I'm not sure how you're suggesting this be done
differently.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com

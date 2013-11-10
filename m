From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: add Renesas R-Car CAN driver
Date: Sun, 10 Nov 2013 18:57:32 +0100
Message-ID: <527FC90C.6020604@pengutronix.de>
References: <201311020240.13354.sergei.shtylyov@cogentembedded.com> <5276ADF6.9050309@pengutronix.de> <527C28DE.7070402@cogentembedded.com> <527CAC38.6040800@pengutronix.de> <527D6B88.3010409@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="McUmQ30TTCgg37usshs32TvDN7tlWG844"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <527D6B88.3010409@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--McUmQ30TTCgg37usshs32TvDN7tlWG844
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/08/2013 11:54 PM, Sergei Shtylyov wrote:
[...]

>>>> Please use a common prefix for all defines.
>=20
>>>     OK, done now. Could you however explain why the file-local #defin=
e's
>>> should be prefixed? It's not quite obvious to me...
>=20
>> It's about readability and maintainability. If you don't know the
>> driver, but all driver local defines and functions have a common prefi=
x,
>> it's much easier to read if you are not the author of the driver IMHO.=

>=20
>    Well, actually I think the last changes somewhat impaired the
> readability. My idea was that you want to exclude name conflicts with
> #include'd headers this way...

IMHO this way it's clear to everyone, that certain defines are
driver/hardware specific.

>>> [...]
>>>>> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
>>>>> +                       struct net_device *ndev)
>>>>> +{
>>>>> +    struct rcar_can_priv *priv =3D netdev_priv(ndev);
>>>>> +    struct can_frame *cf =3D (struct can_frame *)skb->data;
>>>>> +    u32 data, mier1, mbxno, i;
>>>>> +    unsigned long flags;
>>>>> +    u8 mctl =3D 0;
>>>>> +
>>>>> +    if (can_dropped_invalid_skb(ndev, skb))
>>>>> +        return NETDEV_TX_OK;
>>>>> +
>>>>> +    spin_lock_irqsave(&priv->mier_lock, flags);
>>>>> +    mier1 =3D readl(&priv->regs->mier1);
>>>>> +    if (mier1) {
>>>>> +        i =3D __builtin_clz(mier1);
>>>>> +        mbxno =3D i ? N_MBX - i : FIRST_TX_MB;
>>>>> +    } else {
>>>>> +        mbxno =3D FIRST_TX_MB;
>>>>> +    }
>=20
>>>> Can you explain how the hardware arbitration works, and you do you
>>>> guarantee the CAN frames are send by the hardware in the same order =
you
>>>> put them into the hardware.
>=20
>>>     Tx mailbox with the smallest mailbox number has the highest
>>> priority.
>>> The other possible Tx mailbox selection rule (not used by the driver
>>> now) is ID priority transmit mode (as defined in the ISO 11898-1 spec=
s).
>>> The algorithm used guarantees the mailboxes are filled sequentially.
>=20
>    Well, not quite, unfortunately -- it wraps at the last mailbox...

Yes sure, that's the downside if there isn't a real FIFO in the
hardware. I suggest to have two pointers in your private struct:

    unsinged int tx_head;
    unsigned int tx_tail;

static inline unsigned int get_tx_head_mb(struct *priv)
{
       return priv->tx_head % RCAN_TX_QUEUE_SIZE;
}

static inline unsigned int get_tx_tail_mb(struct priv *priv)
{
       return priv->tx_tail % RCAN_TX_QUEUE_SIZE;
}

Put the next CAN frame into get_tx_head_mb(), increment priv->tx_head
and stop your queue if all buffers are used or wrap around.

       /* stop, if all buffers are used or wrap around */
       if ((priv->tx_head - priv->tx_tail =3D=3D RCAN_TX_QUEUE_SIZE) &&
	    get_tx_head_mb(priv) =3D=3D 0)
               netif_stop_queue(dev);

But I think, as you don't have any additional prio bits, it boils down to=
:

       /* stop, if wrap around */
       if (get_tx_head_mb(priv) =3D=3D 0)
               netif_stop_queue(dev);

In your tx-complete, use something like this:

   reg =3D read_tx_complete();
   for (/* nix */; priv->tx_head - priv->tx_tail > 0; priv->tx_tail++) {
       mb =3D get_tx_tail_mb(priv);

       if (!reg & (1 << mb))
            break;

       read_can_frame();
   }

   if ((get_tx_head_mb(priv) !=3D 0) || (get_tx_tail_mb(priv) =3D=3D 0))
           netif_wake_queue(dev);

>> I see. You are using mier1 to track the used mailboxes....correct?
>=20
>    Yes, the mailbox interrupts in MIER1 are enabled only for used
> mailboxes.
>=20
>>> +    if (unlikely(mier1 =3D=3D 0xffffffff))
>>> +        netif_stop_queue(ndev);
>=20
>> Then you have a race condition in your tx-complete handler
>> rcar_can_tx_done(), as you call netif_wake_queue() unconditionally. If=

>=20
>    Yes, I'm seeing it now...
>=20
>> mier1 =3D=3D 0xffffffff you must wait until _all_ mailboxes are transm=
itted
>=20
>    That 0xffffffff criterion seems wrong for me now, I changed the
> algorithm and moved the criterion but didn't update it. The correct one=

> seems to be:
>=20
>     if (unlikely(mier1 & 0x80000000))
>         netif_stop_queue(ndev);

Better handle it in software altogether as outlined above.

>> until you are allowed to reenable the mailboxes. Have a look at the
>> at91_can driver, it's using a similar scheme. The lowest mailbox is
>> transmitted first, but there are three additional bits that indicate t=
he
>> priority.
>=20
>    You mean 4 bits? Priorities are from 0 to 15...

Yes, 4 bits (0xf), but the algorithm isn't limited to 4 bits.

>>> I've used 'canfdtest' as suggested by Wolfgang Grandegger to verify, =
see
>>> the log below:
>=20
>>> root@am335x-evm:~# ./canfdtest -v -g can0
>>> interface =3D can0, family =3D 29, type =3D 3, proto =3D 1
>>> .....................................................................=
=2E.........C
>>>
>>>
>>> Test messages sent and received: 483203
>>> Exiting...
>>> root@am335x-evm:~#
>=20
>    As you can see, 'canfdtest' didn't detect any race, maybe you could
> recommend a test which would help to detect it?

It's better to think to detect a race condition, then to test for it. I
suggest to use the algorithm outlined above, as implemented in the
at91_can.c driver.

>>> [...]
>>>>> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
>>>>> +{
>>>>> +    struct rcar_can_priv *priv =3D container_of(napi,
>>>>> +                          struct rcar_can_priv, napi);
>>>>> +    int num_pkts =3D 0;
>>>>> +
>>>>> +    /* Find mailbox */
>>>>> +    while (num_pkts < quota) {
>>>>> +        u8 mctl, mbx;
>>>>> +
>>>>> +        mbx =3D readb(&priv->regs->mssr);
>=20
>>>> How does the RX work? Is it a hardware FIFO?
>=20
>>>     In short, the MSSR register provides the smallest Rx mailbox numb=
er
>>> that is looked up in the Rx search mode. We read MSSR until no search=

>>> results can be obtained, so it is some sort of FIFO.
>=20
>> This looks racy....
>=20
>    Could you please elaborate?

Consider the hardware fills mailboxes 0...8, then your rx_poll starts to
read mailbox 0, clear mailbox 0, read mb 1, clear mb 2, then another CAN
frame arrives. Which mailbox will be filled next? Which mailbox will be
read next by rx_poll?

>>>     And there is separate FIFO operation mode: some mailboxes can be
>>> configured as FIFO and serviced by special registers but this operati=
on
>>> mode is not supported by the driver.
>=20
>> if you hardware supports a real FIFO then I strongly suggest to make u=
se
>> of it.
>=20
>    Well, Tx/Rx FIFOs are only 4 frames deep (although I haven't seen
> more than 2 Rx mailboxes ready in a row, there are 32 Tx mailboxes);
> also FIFO mode is less documented than mailbox mode (hence some nasty
> surprises are possible). We still can use mailboxes when in FIFO mode,
> it's just 8 of them are reserved for Tx/Rx FIFOs.

Who will the current rx_poll behave in the above outlined situation?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--McUmQ30TTCgg37usshs32TvDN7tlWG844
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJ/yRAACgkQjTAFq1RaXHPnkwCeJPfyAVriadFw+Vb9AZHEbx5E
ukcAn0cxKCsQXIq/xTB7hf3o1D+nYksr
=XXq+
-----END PGP SIGNATURE-----

--McUmQ30TTCgg37usshs32TvDN7tlWG844--

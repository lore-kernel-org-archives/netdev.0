From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v4 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Wed, 12 Jan 2011 10:24:24 +0100
Message-ID: <4D2D7348.4020601@pengutronix.de>
References: <1294746592-12144-1-git-send-email-bhupesh.sharma@st.com>
	<4D2C4D68.3070705@pengutronix.de>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA31B6@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6531616052217679047=="
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEAFA31B6-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============6531616052217679047==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig558CC01B41DEA72CC00B6357"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig558CC01B41DEA72CC00B6357
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/12/2011 09:51 AM, Bhupesh SHARMA wrote:

[..]

>>> b/drivers/net/can/c_can/c_can.c new file mode 100644 index
>>> 0000000..06e1553
>>> --- /dev/null
>>> +++ b/drivers/net/can/c_can/c_can.c
>>> @@ -0,0 +1,953 @@
>>> +/*
>>> + * CAN bus driver for Bosch C_CAN controller
>>> + *
>>> + * Copyright (C) 2010 ST Microelectronics
>>> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>>> + *
>>> + * Borrowed heavily from the C_CAN driver originally written by:
>>> + * Copyright (C) 2007
>>> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
>>> +<s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
>>> + *
>>> + * TX and RX NAPI implementation has been borrowed from at91 CAN
>>> +driver
>>> + * written by:
>>
>> I've just cleaned up the RX implementation, have a look at [1] and [2]=
=2E
>=20
> I am not sure that C_CAN will be effected as per the at91 driver change=
s.
> In C_CAN, messages numbers are allowed only from 0x01 to 0x20. Message =
object
> number 0 is not allowed. Internally obj-put and obj-get routines increm=
ent the
> message number by 1.

Okay - I just wanted you to have a look at it.

[...]

>>> +/*
>>> + * theory of operation:
>>> + *
>>> + * c_can core saves a received CAN message into the first free
>>> +message
>>> + * object it finds free (starting with the lowest). Bits NEWDAT and
>>> + * INTPND are set for this message object indicating that a new
>>> +message
>>> + * has arrived. To work-around this issue, we keep two groups of
>>> +message
>>> + * objects whose partitioning is defined by C_CAN_MSG_OBJ_RX_SPLIT.
>>> + *
>>> + * To ensure in-order frame reception we use the following
>>> + * approach while re-activating a message object to receive further
>>> + * frames:
>>> + * - if the current message object number is lower than
>>> + *   C_CAN_MSG_RX_LOW_LAST, do not clear the NEWDAT bit while
>> clearing
>>> + *   the INTPND bit.
>>> + * - if the current message object number is equal to
>>> + *   C_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of all lower
>>> + *   receive message objects.
>>> + * - if the current message object number is greater than
>>> + *   C_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of
>>> + *   only this message object.
>>> + */
>>> +static int c_can_do_rx_poll(struct net_device *dev, int quota) {
>>> +   u32 num_rx_pkts =3D 0;
>>> +   unsigned int msg_obj, msg_ctrl_save;
>>> +   struct c_can_priv *priv =3D netdev_priv(dev);
>>> +   u32 val =3D c_can_read_reg32(priv, &priv->regs->intpnd1);
>>> +
>>> +   for (msg_obj =3D C_CAN_MSG_OBJ_RX_FIRST;
>>> +                   msg_obj <=3D C_CAN_MSG_OBJ_RX_LAST && quota > 0;
>>> +                   msg_obj++) {
>>> +           if (val & (1 << msg_obj)) {
>>
>> what about using find_next_bit here?
>=20
> I will explore the possibility of using the same.
> But, IMHO this logic seems much easier to understand than a
> *for* loop with bulky *find_next_bit* call.

:)

>>> +                   c_can_object_get(dev, 0, msg_obj, IF_COMM_ALL &
>>> +                                   ~IF_COMM_TXRQST);
>>> +                   msg_ctrl_save =3D priv->read_reg(priv,
>>> +                                   &priv->regs->intf[0].msg_cntrl);
>>> +
>>> +                   if (msg_ctrl_save & IF_MCONT_EOB)
>>> +                           return num_rx_pkts;
>>> +
>>> +                   if (msg_ctrl_save & IF_MCONT_MSGLST) {
>>> +                           c_can_handle_lost_msg_obj(dev, 0, msg_obj=
);
>>> +                           num_rx_pkts++;
>>> +                           quota--;
>>> +                           continue;
>>> +                   }
>>> +
>>> +                   if (!(msg_ctrl_save & IF_MCONT_NEWDAT))
>>> +                           continue;
>>> +
>>> +                   /* read the data from the message object */
>>> +                   c_can_read_msg_object(dev, 0, msg_ctrl_save,
>> msg_obj);
>>> +
>>> +                   if (msg_obj < C_CAN_MSG_RX_LOW_LAST)
>>> +                           c_can_mark_rx_msg_obj(dev, 0,
>>> +                                           msg_ctrl_save, msg_obj);
>>> +                   else if (msg_obj > C_CAN_MSG_RX_LOW_LAST)
>>> +                           /* activate this msg obj */
>>> +                           c_can_activate_rx_msg_obj(dev, 0,
>>> +                                           msg_ctrl_save, msg_obj);
>>> +                   else if (msg_obj =3D=3D C_CAN_MSG_RX_LOW_LAST)
>>> +                           /* activate all lower message objects */
>>> +                           c_can_activate_all_lower_rx_msg_obj(dev,
>>> +                                           0, msg_ctrl_save);
>>> +
>>> +                   num_rx_pkts++;
>>> +                   quota--;
>>> +           }
>>> +           val =3D c_can_read_reg32(priv, &priv->regs->intpnd1);
>>> +   }
>>> +
>>> +   return num_rx_pkts;
>>> +}
>>> +
>>> +static inline int c_can_has_and_handle_berr(struct c_can_priv *priv)=

>>> +{
>>> +   return (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING) &&
>>> +           (priv->current_status & STATUS_LEC_MASK); }
>>> +
>>> +static int c_can_err(struct net_device *dev,
>>> +                           enum c_can_bus_error_types error_type,
>>> +                           enum c_can_lec_type lec_type)
>>> +{
>>> +   unsigned int reg_err_counter;
>>> +   unsigned int rx_err_passive;
>>> +   struct c_can_priv *priv =3D netdev_priv(dev);
>>> +   struct net_device_stats *stats =3D &dev->stats;
>>> +   struct can_frame *cf;
>>> +   struct sk_buff *skb;
>>> +   struct can_berr_counter bec;
>>> +
>>> +   /* propogate the error condition to the CAN stack */
>>> +   skb =3D alloc_can_err_skb(dev, &cf);
>>> +   if (unlikely(!skb))
>>> +           return 0;
>>> +
>>> +   c_can_get_berr_counter(dev, &bec);
>>> +   reg_err_counter =3D priv->read_reg(priv, &priv->regs->err_cnt);
>>> +   rx_err_passive =3D (reg_err_counter & ERR_COUNTER_RP_MASK) >>
>>> +                           ERR_COUNTER_RP_SHIFT;
>>> +
>>> +   if (error_type & C_CAN_ERROR_WARNING) {
>>> +           /* error warning state */
>>> +           priv->can.can_stats.error_warning++;
>>> +           priv->can.state =3D CAN_STATE_ERROR_WARNING;
>>> +           cf->can_id |=3D CAN_ERR_CRTL;
>>> +           if (bec.rxerr > 96)
>>> +                   cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
>>> +           if (bec.txerr > 96)
>>> +                   cf->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
>>> +   }
>>> +   if (error_type & C_CAN_ERROR_PASSIVE) {
>>> +           /* error passive state */
>>> +           priv->can.can_stats.error_passive++;
>>> +           priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
>>> +           cf->can_id |=3D CAN_ERR_CRTL;
>>> +           if (rx_err_passive)
>>> +                   cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
>>> +           if (bec.txerr > 127)
>>> +                   cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
>>> +   }
>>> +   if (error_type & C_CAN_BUS_OFF) {
>>> +           /* bus-off state */
>>> +           priv->can.state =3D CAN_STATE_BUS_OFF;
>>> +           cf->can_id |=3D CAN_ERR_BUSOFF;
>>> +           /*
>>> +            * disable all interrupts in bus-off mode to ensure that
>>> +            * the CPU is not hogged down
>>> +            */
>>> +           c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS)=
;
>>> +           can_bus_off(dev);
>>> +   }
>>> +
>>> +   /*
>>> +    * check for 'last error code' which tells us the
>>> +    * type of the last error to occur on the CAN bus
>>> +    */
>>> +
>>> +   /* common for all type of bus errors */
>>> +   priv->can.can_stats.bus_error++;
>>> +   stats->rx_errors++;
>>> +   cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +   cf->data[2] |=3D CAN_ERR_PROT_UNSPEC;
>>> +
>>> +   switch (lec_type) {
>>> +   case LEC_STUFF_ERROR:
>>> +           dev_dbg(dev->dev.parent, "stuff error\n");
>>> +           cf->data[2] |=3D CAN_ERR_PROT_STUFF;
>>> +           break;
>>> +
>>> +   case LEC_FORM_ERROR:
>>> +           dev_dbg(dev->dev.parent, "form error\n");
>>> +           cf->data[2] |=3D CAN_ERR_PROT_FORM;
>>> +           break;
>>> +
>>> +   case LEC_ACK_ERROR:
>>> +           dev_dbg(dev->dev.parent, "ack error\n");
>>> +           cf->data[2] |=3D (CAN_ERR_PROT_LOC_ACK |
>>> +                           CAN_ERR_PROT_LOC_ACK_DEL);
>>> +           break;
>>> +
>>> +   case LEC_BIT1_ERROR:
>>> +           dev_dbg(dev->dev.parent, "bit1 error\n");
>>> +           cf->data[2] |=3D CAN_ERR_PROT_BIT1;
>>> +           break;
>>> +
>>> +   case LEC_BIT0_ERROR:
>>> +           dev_dbg(dev->dev.parent, "bit0 error\n");
>>> +           cf->data[2] |=3D CAN_ERR_PROT_BIT0;
>>> +           break;
>>> +
>>> +   case LEC_CRC_ERROR:
>>> +           dev_dbg(dev->dev.parent, "CRC error\n");
>>> +           cf->data[2] |=3D (CAN_ERR_PROT_LOC_CRC_SEQ |
>>> +                           CAN_ERR_PROT_LOC_CRC_DEL);
>>> +           break;
>>> +   }
>>> +
>>> +   netif_receive_skb(skb);
>>> +   stats->rx_packets++;
>>> +   stats->rx_bytes +=3D cf->can_dlc;
>>> +
>>> +   return 1;
>>> +}
>>> +
>>> +static int c_can_poll(struct napi_struct *napi, int quota) {
>>> +   u16 irqstatus;
>>> +   int lec_type =3D 0;
>>> +   int work_done =3D 0;
>>> +   struct net_device *dev =3D napi->dev;
>>> +   struct c_can_priv *priv =3D netdev_priv(dev);
>>> +   enum c_can_bus_error_types error_type =3D C_CAN_NO_ERROR;
>>> +
>>> +   irqstatus =3D priv->read_reg(priv, &priv->regs->interrupt);
>>> +
>>> +   /* status events have the highest priority */
>>> +   if (irqstatus =3D=3D STATUS_INTERRUPT) {
>>> +           priv->current_status =3D priv->read_reg(priv,
>>> +                                   &priv->regs->status);
>>> +
>>> +           /* handle Tx/Rx events */
>>> +           if (priv->current_status & STATUS_TXOK)
>>> +                   priv->write_reg(priv, &priv->regs->status,
>>> +                                   priv->current_status & ~STATUS_TX=
OK);
>>> +
>>> +           if (priv->current_status & STATUS_RXOK)
>>> +                   priv->write_reg(priv, &priv->regs->status,
>>> +                                   priv->current_status & ~STATUS_RX=
OK);
>>> +
>>> +           /* handle bus error events */
>>> +           if (priv->current_status & STATUS_EWARN) {
>>> +                   dev_dbg(dev->dev.parent,
>>> +                                   "entered error warning state\n");=

>>> +                   error_type =3D C_CAN_ERROR_WARNING;
>>> +           }
>>> +           if ((priv->current_status & STATUS_EPASS) &&
>>> +                           (!(priv->last_status & STATUS_EPASS))) {
>>> +                   dev_dbg(dev->dev.parent,
>>> +                                   "entered error passive state\n");=

>>> +                   error_type =3D C_CAN_ERROR_PASSIVE;
>>> +           }
>>> +           if ((priv->current_status & STATUS_BOFF) &&
>>> +                           (!(priv->last_status & STATUS_BOFF))) {
>>> +                   dev_dbg(dev->dev.parent,
>>> +                                   "entered bus off state\n");
>>> +                   error_type =3D C_CAN_BUS_OFF;
>>> +           }
>>> +
>>> +           /* handle bus recovery events */
>>> +           if ((!(priv->current_status & STATUS_EPASS)) &&
>>> +                           (priv->last_status & STATUS_EPASS)) {
>>> +                   dev_dbg(dev->dev.parent,
>>> +                                   "left error passive state\n");
>>> +                   priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>> +           }
>>> +           if ((!(priv->current_status & STATUS_BOFF)) &&
>>> +                           (priv->last_status & STATUS_BOFF)) {
>>> +                   dev_dbg(dev->dev.parent,
>>> +                                   "left bus off state\n");
>>> +                   priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>> +           }
>>> +
>>> +           priv->last_status =3D priv->current_status;
>>> +
>>> +           /* handle error on the bus */
>>> +           lec_type =3D c_can_has_and_handle_berr(priv);
>>> +           if (lec_type && (error_type !=3D C_CAN_NO_ERROR))
>>> +                   work_done +=3D c_can_err(dev, error_type, lec_typ=
e);
>>> +   } else if ((irqstatus > C_CAN_MSG_OBJ_RX_FIRST) &&
>>> +                   (irqstatus <=3D C_CAN_MSG_OBJ_RX_LAST)) {
>>> +           /* handle events corresponding to receive message objects=

>> */
>>> +           work_done +=3D c_can_do_rx_poll(dev, (quota - work_done))=
;
>>> +   } else if ((irqstatus > C_CAN_MSG_OBJ_TX_FIRST) &&
>>> +                   (irqstatus <=3D C_CAN_MSG_OBJ_TX_LAST)) {
>>> +           /* handle events corresponding to transmit message object=
s
>> */
>>> +           c_can_do_tx(dev);
>>> +   }
>>> +
>>> +   if (work_done < quota) {
>>> +           napi_complete(napi);
>>> +           /* enable all IRQs */
>>> +           c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);=

>>> +   }
>>> +
>>> +   return work_done;
>>> +}
>>> +
>>> +static irqreturn_t c_can_isr(int irq, void *dev_id) {
>>> +   struct net_device *dev =3D (struct net_device *)dev_id;
>>> +   struct c_can_priv *priv =3D netdev_priv(dev);
>>> +
>>> +   /* disable all interrupts and schedule the NAPI */
>>> +   c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
>>> +   napi_schedule(&priv->napi);
>>> +
>>> +   return IRQ_HANDLED;
>>> +}
>>
>> Have a look at the pch_can interrupt handler, it supports shared irqs.=

>=20
> Could you please send me a reference URL for the same.
> As the pch_can driver code in David's net-next and net tree has almost
> similar implementation to the c_can driver.
> Or, am I missing something here?

Your interrupt handler unconditionally thinks it's a c_can interrupt...

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3Dbl=
ob;f=3Ddrivers/net/can/pch_can.c;h=3Dc42e97268248889acdb007a16cb9bf815241=
3bd2;hb=3D0c21e3aaf6ae85bee804a325aa29c325209180fd#l581

=2E..but the pch_can checks if it's really a interrupt from the c_can cor=
e.

If you implement your interrupt handler properly, you can register the
interrupt handler as SHARED:

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3Dbl=
ob;f=3Ddrivers/net/can/pch_can.c;h=3Dc42e97268248889acdb007a16cb9bf815241=
3bd2;hb=3D0c21e3aaf6ae85bee804a325aa29c325209180fd#l850

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig558CC01B41DEA72CC00B6357
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0tc0sACgkQjTAFq1RaXHOP+gCeNkDz5+fQuRipQ95DkODKVXFY
1ekAoIlisQtBVewzwA7n24N346PB0c8J
=ZNqw
-----END PGP SIGNATURE-----

--------------enig558CC01B41DEA72CC00B6357--

--===============6531616052217679047==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6531616052217679047==--

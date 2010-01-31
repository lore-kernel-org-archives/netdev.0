From: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: mcp251x: Move to threaded interrupts
	instead of workqueues.
Date: Sun, 31 Jan 2010 18:39:35 +0100
Message-ID: <cabda6421001310939g4acd22d2ua8dab4de3322f90e@mail.gmail.com>
References: <1264857564-3917-1-git-send-email-chripell@fsfe.org>
	<4B648D3F.30909@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B648D3F.30909-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 30, 2010 at 8:49 PM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wr=
ote:
> Hi Christian,
>

Hi,

>
> Could you please truncate the lines to the usual 72 (or 80) characters
> per line?
>

ack, just reconfigured nano!

>> +static irqreturn_t mcp251x_can_ist(int irq, void *dev_id);
>> +static void mcp251x_restart_work_handler(struct work_struct *ws);
>> +static void mcp251x_tx_work_handler(struct work_struct *ws);
>
> Any chance to get rid of these forward declarations (by reordering them)?
>

ack, I was trying to minimize patch size so the reason for not moving
code. I fixed it.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* This message is worrisome (because it poi=
nts out
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* something wrong with locking logic) if se=
en when
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* there is no bus-off recovery going on.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>
> Before it calls netif_carrier_on, it calls the drivers "do_set_mode"
> callback. See:
>
> http://lxr.linux.no/#linux+v2.6.32/drivers/net/can/dev.c#L383
>
> Is there a way to clear the TX logic in the "do_set_mode" callback?
>

ack, sorry saw this just now

>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&net->dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"cannot allocate error skb\=
n");
>
> dev_err?
>

ack

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->can.state =3D=3D CAN_STATE_BUS_OFF=
) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_clean(net);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(net);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto restart_work_unlock;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else { ? To get rid of the label.
>

ack. I realized that netif_wake_queue here is wrong too or at least
meaningless: the carrier of the can network interface is declared down
so we shouldn't reschedule the tx queue anyway. I took it out and
retested without it.

-- =

Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."

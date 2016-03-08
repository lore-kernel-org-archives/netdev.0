From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Tue, 8 Mar 2016 08:46:13 +0100
Message-ID: <56DE8345.50901@hartkopp.net>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56DC1561.9060306@hartkopp.net>
 <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DD36F5.2000308@pengutronix.de>
 <SG2PR06MB1038DD47FAFF354C99AF2E4FC3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB1038DD47FAFF354C99AF2E4FC3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/07/2016 09:32 AM, Ramesh Shanmugasundaram wrote:

>>>>> +	/* Ensure channel starts in FD mode */
>>>>> +	if (!(priv->can.ctrlmode & CAN_CTRLMODE_FD)) {
>>>>> +		netdev_err(ndev, "enable can fd mode for channel %d\n", ch);
>>>>> +		goto fail_mode;
>>>>> +	}
>>>>
>>>> What's the reason behind this check?
>>>>
>>>> A CAN FD capable CAN controller can be either configured to run as
>>>> CAN 2.0 (Classic CAN) or as CAN FD controller.
>>>>
>>>> So why are to throwing an error here and produce an initialization
>>>> failure?
>>>
>>> When this controller is configured in FD mode and used only with CAN
>>> 2.0 nodes, it still expects a DTSEG (data bitrate) configuration same
>>> as NTSEG (nominal bitrate). This check, specifically in ndo_open,
>>> ensures both are configured and will work fine with CAN 2.0 nodes
>>> (e.g.)
>>>
>>> "ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on"
>>>
>>> If I don't have this check, a configuration like this
>>>
>>> "ip link set can0 up type can bitrate 1000000"
>>>
>>> will bring up the controller without DTSEG configured.

What about spending some status flag or setting the data bitrate equal to the
nominal bitrate unless a data bitrate is provided?

>>
>> That should bring up the controller in CAN 2.0 mode.
> 
> Yes, that's the user's intention but the manual states DTSEG still need to be configured. In the above configuration, it will not be.
> Besides, this will not be a "pure" CAN 2.0 node (i.e.) if a frame with length > 8 bytes is received the controller will "ACK" because in FD mode it can receive up to 64 bytes frame.

Oh. We probably mix something up here (CAN frame formats & bitrates).

A CAN2.0 frame and a CAN FD frame have very different representations on the
wire! So if you see a FDF (former EDL) bit this is a CAN FD frame, which
requires two bitrates (nominal/data bitrate) where the data bitrate has to be
greater or equal the nominal bitrate.

The fact that the data bitrate is equal the nominal/arbitration bitrate has
nothing to do with CAN2.0 then. Regarding your answer this is not even "a pure
CAN2.0" node - it still looks like a CAN FD node with equal data/nominal bitrates.

The fact that a CAN FD frame has a size of 8 bytes doesn't make it a CAN2.0
frame :-)

> 
> The controller does support a "pure" classical CAN mode with a different set of register map itself.

Is this a can_rcar controller register mapping then?

> Do you think a pure CAN 2.0 mode support would be beneficial? I can submit this in coming days on top of current submission.
> 
> The current submission status is:
>  - Controller operates in CAN FD mode only.
>  - If needed to interoperate with CAN 2.0 nodes, data bitrate still need to be configured and it will work perfectly. However, it is not a "pure" CAN 2.0 node as mentioned above.

When you have a CAN FD /capable/ controller the idea is:

"ip link set can0 up type can bitrate 1000000"

The controller is in CAN2.0 mode:

1. It can send and receive CAN2.0 frames @1MBit/s.
2. The MTU is set to 16 (sizeof(struct can_frame)) ; CAN_CTRLMODE_FD is unset.
3. The CAN controller is not CAN FD tolerant (will produce error frames)

"ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on"

1. It can send and receive CAN2.0 frames @1MBit/s.
2. It can send and receive CAN FD frames @1MBit/s (arbitration&data bitrate).
3. The MTU is set to 72 (sizeof(struct canfd_frame)) ; CAN_CTRLMODE_FD is set.

For CAN FD frames the data bitrate can be increased like:
"ip link set can0 up type can bitrate 1000000 dbitrate 4000000 fd on"

So when CAN_CTRLMODE_FD is unset the controller should act like a "pure
CAN2.0" node. When people configure a CAN FD controller with "fd on" and use
CAN2.0 frames all the time this is ok either - but the controller is able to
process CAN FD frames with the correct bitrate too.

Regards,
Oliver


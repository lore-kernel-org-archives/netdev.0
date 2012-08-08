From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Wed, 08 Aug 2012 17:02:04 +0200
Message-ID: <50227F6C.8010501@grandegger.com>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <1344230489-16595-1-git-send-email-olivier@sobrie.be> <5020B51E.8060600@grandegger.com> <20120808061419.GA16678@hposo> <5022227F.60800@grandegger.com> <20120808133005.GA14300@hposo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120808133005.GA14300@hposo>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/08/2012 03:30 PM, Olivier Sobrie wrote:
> On Wed, Aug 08, 2012 at 10:25:35AM +0200, Wolfgang Grandegger wrote:
>> Hi Oliver,
>>
>> On 08/08/2012 08:14 AM, Olivier Sobrie wrote:
>>> Hi Wolfgang,
>>>
>>> On Tue, Aug 07, 2012 at 08:26:38AM +0200, Wolfgang Grandegger wrote:
>>>> On 08/06/2012 07:21 AM, Olivier Sobrie wrote:
>>>>> This driver provides support for several Kvaser CAN/USB devices.
>>>>> Such kind of devices supports up to three can network interfaces.
>>>>
>>>> s/can/CAN/
>>>>
>>>>> It has been tested with a Kvaser USB Leaf Light (one network interface)
>>>>> connected to a pch_can interface.
>>>>> The firmware version of the Kvaser device was 2.5.205.
>>>>>
>>>>> List of Kvaser devices supported by the driver:
>>>>>   - Kvaser Leaf prototype (P010v2 and v3)
>>>>>   - Kvaser Leaf Light (P010v3)
>>>>>   - Kvaser Leaf Professional HS
>>>>>   - Kvaser Leaf SemiPro HS
>>>>>   - Kvaser Leaf Professional LS
>>>>>   - Kvaser Leaf Professional SWC
>>>>>   - Kvaser Leaf Professional LIN
>>>>>   - Kvaser Leaf SemiPro LS
>>>>>   - Kvaser Leaf SemiPro SWC
>>>>>   - Kvaser Memorator II, Prototype
>>>>>   - Kvaser Memorator II HS/HS
>>>>>   - Kvaser USBcan Professional HS/HS
>>>>>   - Kvaser Leaf Light GI
>>>>>   - Kvaser Leaf Professional HS (OBD-II connector)
>>>>>   - Kvaser Memorator Professional HS/LS
>>>>>   - Kvaser Leaf Light "China"
>>>>>   - Kvaser BlackBird SemiPro
>>>>>   - Kvaser OEM Mercury
>>>>>   - Kvaser OEM Leaf
>>>>>   - Kvaser USBcan R
>>>>
>>>> Impressive list! What CAN controllers are used inside the devices? SJA1000?
>>>
>>> I took this list from the Kvaser driver. However I only have a Kvaser
>>> Leaf Light device thus I'm not sure it will work with other ones.
>>> If you prefer I can only let Kvaser Leaf Light instead of the full list.
>>> In my device it looks to be a Renesas M16C controller.
>>
>> OK. Checking the manual, if available, could help to understand how the
>> firmware handles bus errors and state changes.
> 
> Ok I'll try to find it.
> 
>>
>>>>> Signed-off-by: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
>>>>> ---
>>>>> Changes since v1:
>>>>>   - added copyrights
>>>>>   - kvaser_usb.h merged into kvaser.c
>>>>>   - added kvaser_usb_get_endpoints to find eindpoints instead of
>>>>>     hardcoding their address
>>>>>   - some cleanup and comestic changes
>>>>>   - fixed issues with errors handling
>>>>>   - fixed restart-ms == 0 case
>>>>>   - removed do_get_berr_counter method since the hardware doens't return
>>>>>     good values for txerr and rxerr.
>>>>>
>>>>> If someone in the linux-usb mailing can review it, it would be nice.
>>>>>
>>>>> Concerning the errors, it behaves like that now:
>>>>>
>>>>> 1) Short-circuit CAN-H and CAN-L and restart-ms = 0
>>>>>
>>>>> t0: short-circuit + 'cansend can1 123#112233'
>>>>>
>>>>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-warning,tx-error-warning}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-passive,tx-error-passive}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-off
>>>>> 	bus-error
>>>>>
>>>>> t1: remove short-circuit + 'ip link set can1 type can restart'
>>>>>
>>>>>   can1  20000100  [8] 00 00 00 00 00 00 00 00   ERRORFRAME
>>>>> 	restarted-after-bus-off
>>>>>   can1  20000004  [8] 00 0C 00 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-warning,tx-error-warning}
>>>>
>>>> Why do we get the last error message? Maybe the firmware does it that
>>>> way (going down passive->warning->active).
>>>
>>> It goes in that order: warning -> passive -> bus off -> warning
>>> -> passive -> ...
>>
>> Just for curiosity? You don't see back to "error active"?
> 
> No but that's maybe because of my misunderstanding of the
> M16C_STATE_BUS_ERROR flag.
> What I see is:
> t1: M16C_STATE_BUS_ERROR
> t2: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_PASSIVE
> t3: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_OFF
> and then again
> t4: M16C_STATE_BUS_ERROR
> t2: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_PASSIVE
> t3: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_OFF
> 
> Thus as you suggested below, the flag M16C_STATE_BUS_ERROR might not mean
> CAN_STATE_ERROR_WARNING...

Do you see bus error bits set? If not, I could mean "error active",
otherwise "error warning". Meaning the device sends such messages
containing bus error information plus the current state.

>>>>> 2) Short-circuit CAN-H and CAN-L and restart-ms = 100
>>>>>
>>>>> t0: short-circuit + cansend can1 123#112233
>>>>>
>>>>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-warning,tx-error-warning}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-passive,tx-error-passive}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-off
>>>>> 	bus-error
>>>>>   can1  2000018C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-warning,tx-error-warning}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>> 	restarted-after-bus-off
>>>>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-warning,tx-error-warning}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-passive,tx-error-passive}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-off
>>>>> 	bus-error
>>>>>   ...
>>>>>
>>>>>   can1  2000018C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-warning,tx-error-warning}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>> 	restarted-after-bus-off
>>>>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-warning,tx-error-warning}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
>>>>> 	controller-problem{rx-error-passive,tx-error-passive}
>>>>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
>>>>> 	bus-error
>>>>>
>>>>> t1: remove short-circuit
>>>>>
>>>>>   can1  123  [3] 11 22 33
>>>>>   can1  20000008  [8] 00 00 40 00 00 00 00 00   ERRORFRAME
>>>>> 	protocol-violation{{back-to-error-active}{}}
>>>>
>>>> The order is still inverted but likely the firmware is doing it that way.
>>>
>>> Indeed the firmware does it that way: it sends the acknwledge of the
>>> frame beofre the state change. I can avoid that behavior by checking the
>>> state in the acknowledge frame and send the restart frame if the bus was
>>> off.
>>
>> Well, if the firmware does it wrong, I would not really care. Also,
>> could you use timestamping to see if they come close together.
> 
> candump can1,0:0,#FFFFFFFF -td -e:
>  (001.369850)  can1  123  [3] 11 22 33
>  (004.716034)  can1  20000008  [8] 00 00 40 00 00 00 00 00   ERRORFRAME
> 	protocol-violation{{back-to-error-active}{}}
> 
> Not so close... I'll add something in the tx acknowledge.

More than three seconds, wired. I would add netdev_dbg() to the state
change and error handling code to better understand what's going on.
....

>>> What error should I report in case of M16C_STATE_BUS_ERROR?
>>
>> To make that clear, I have added an (old) output from the SJA1000, which
>> is the defacto reference. Bus error reporting is enabled and no cable is
>> connected. Watch the TX error count increasing and how the state changes:
> 
> With my hardware I do not get txerr and rxerr... I only get
> M16C_STATE_BUS_ERROR. Thus in fact I can only pass from ACTIVE to PASSIVE
> without reaching the WARNING state.

No problem, I just wanted to illustrate how the hardware does usually do
error and state change reporting.

Wolfgang.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

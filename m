From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: flexcan: fix irq flooding by clearing all interrupt
 sources
Date: Wed, 14 Dec 2011 14:21:18 +0100
Message-ID: <4EE8A2CE.6030805@grandegger.com>
References: <4EE61928.10608@grandegger.com> <4EE61E3D.2090303@pengutronix.de> <4EE62141.8010305@grandegger.com> <4EE7416E.8070203@grandegger.com> <4EE74AC5.9050404@grandegger.com> <4EE74C2A.9040908@pengutronix.de> <4EE77BAE.5040702@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben Dowle <Reuben.Dowle@navico.com>,
	=?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE77BAE.5040702@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On 12/13/2011 05:22 PM, Wolfgang Grandegger wrote:
> On 12/13/2011 01:59 PM, Marc Kleine-Budde wrote:
>> On 12/13/2011 01:53 PM, Wolfgang Grandegger wrote:
>>>> I got my MX35PDK board working and can confirm, that the patch works on
>>>> a i.mx35 as well. My testing also confirms, that the ESR TWRN_INT,
>>>> RWRN_INT, FLEXCAN_ESR_BOFF_INT do not function as documented. These
>>>> flags do show up once, together with ERR_INT, and then, after clearing,
>>>> never again. Obviously a bug in the Flexcan logic. From the feedback we
>>>> can say, that only the i.MX28 does behave differently (==correctly). All
>>>> other seem to work with the current code:
>>>>
>>>>  Flexcan on
>>>>  - i.mx25
>>>>  - i.mx35
>>>>  - i.mx53
>>>>  - P1010/P1020
>>>
>>> But unfortunately, state change reporting looks different with this patch :)
>>
>> Hmm - so not schedule for stable. What about your buf-off-handling, will
>> this change the reporting again?
> 
> Well, as it is a serious problem on i.MX28, I would schedule this patch
> for stable as well. The error and state change reporting is bogus on the
> Flexcan anyhow. Without this patch, I get "active->warning->passive" if
> I send a message with cable disconnect (no ack). With patch just
> "active->warning". That's the same behaviour
> as on the i.MX28, also with my new state and bus-off handling. See:

I now understand the difference. I "flexcan_irq" we have:

	/*
	 * schedule NAPI in case of:
	 * - rx IRQ
	 * - state change IRQ
	 * - bus error IRQ and bus error reporting is activated
	 */
	if ((reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE) ||
	    (reg_esr & FLEXCAN_ESR_ERR_STATE) ||
	    flexcan_has_and_handle_berr(priv, reg_esr)) {

Without this patch, "reg_esr & FLEXCAN_ESR_ERR_STATE" is *always* true
because the RWRN_INT is never cleared. This means, *any* message is
scheduled. As a nice side effect, this patch fixes this bug a well.

Only because any message is scheduled, the state change to error passive
is recognized in flexcan_poll(). The state change to error passive is
not signaled by an extra interrupt and is therefore only visible
together with RX, TX done or bus-error events.

Wolfgang.


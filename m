From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v3 3/3] ptp: Added a clock that uses the eTSEC found on
 the MPC85xx.
Date: Mon, 17 May 2010 13:05:54 -0500
Message-ID: <4BF18582.6000500@freescale.com>
References: <cover.1273855016.git.richard.cochran@omicron.at> <ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at> <4BED8C91.8020107@freescale.com> <20100517082757.GA9703@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:55746 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab0EQSGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 14:06:01 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o4HI5uOL000808
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 11:05:56 -0700 (MST)
Received: from az33exm25.fsl.freescale.net (az33exm25.am.freescale.net [10.64.32.16])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id o4HIGjcS006435
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 13:16:45 -0500 (CDT)
In-Reply-To: <20100517082757.GA9703@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2010 03:27 AM, Richard Cochran wrote:
> On Fri, May 14, 2010 at 12:46:57PM -0500, Scott Wood wrote:
>> On 05/14/2010 11:46 AM, Richard Cochran wrote:
>>> diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
>>
>> Get rid of both device_type and model, and specify a compatible
>> string instead (e.g. "fsl,etsec-ptp").
>
> Okay, will do. I really am at a loss at understanding all the rules in
> the whole device tree world. I just tried to follow
> Documentation/powerpc and what is already present in the kernel.

There's some stuff in there that isn't how we'd do it now, but is slow 
to change for compatibility reasons.

>> Or perhaps this should just be some additional properties on the
>> existing gianfar nodes, rather than presenting it as a separate
>> device?  How do you associate a given ptp block with the
>> corresponding gianfar node?
>
> There only one PTP clock. Its registers repeat in each port's memory
> space, but you are only supposed to touch the first set of PTP
> registers.

OK.  I'm not too familiar with PTP itself, was looking more at the 
device tree and similar structural bits.

> There are no differences (that I know of) in how the PTP clocks
> work. I have in house the mpc8313, the mpc8572, and the p2020. The
> mpc8572 appears to lack some of the TMR_CTRL bits, but this is
> probably a documentation bug. I will check it.

If there's any possibility of needing to make a distinction (which 
probably can't be ruled out with future chips), the chip name could be 
made part of the compatible string, with a secondary compatible showing 
a canonical part name for that version of the PTP block.  E.g. p2020 
might have:

compatble = "fsl,p2020-etsec-ptp", "fsl,mpc8313-etsec-ptp";

The driver would bind only on the mpc8313 version.

There are several examples of this, such as the Freescale i2c driver and 
binding (ignore the legacy "fsl-i2c").

>> > >+  - tmr_fiper1   Fixed interval period pulse generator.
>> > >+  - tmr_fiper2   Fixed interval period pulse generator.
>>

MPC8572 and P2020 have fiper3 as well.

>> They should probably have an "fsl,ptp-" prefix as well.
>
> Okay, but must I then change the following code in order to find them?
> Does adding the prefix just mean that I also add it to my search
> strings, or is it preprocessed (stripped) somehow?

It is not stripped; you have to change the code as well.

>> You've got two IRQs, with the same handler, and the same dev_id?
>>  From the manual it looks like there's one PTP interrupt per eTSEC
>> (which would explain 3 interrupts on p2020).
>
> Will reduce to just one IRQ.

The device tree should still contain all of the interrupts, in case 
they're needed later -- and put a comment in the driver saying why the 
first interrupt seems sufficient.

>>> +static struct of_device_id match_table[] = {
>>> +	{ .type = "ptp_clock" },
>>> +	{},
>>> +};
>>
>> This driver controls every possible PTP implementation?
>
> No, I only want to match with the eTSEC clock device. Given the
> compatible string above ("fsl,etsec-ptp"), what is the correct way to
> do this? (pointer to an existing driver to emulate would be enough)

Put .compatible = "fsl,etsec-ptp" (or "fsl,mpc8313-etsec-ptp") where you 
have .type = "ptp_clock".

-Scott

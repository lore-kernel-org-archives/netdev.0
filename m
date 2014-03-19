From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH] cxgb4: fix probe when already with invalid parameters
Date: Wed, 19 Mar 2014 15:41:27 -0700
Message-ID: <532A1D17.4010701@chelsio.com>
References: <1395254994-12011-1-git-send-email-cascardo@linux.vnet.ibm.com> <CBA48B605613B640864883107238931C10D383@nice.asicdesigners.com> <20140319215714.GA19326@oc0268524204.ibm.com> <532A1676.4010306@chelsio.com> <532A1966.3070207@chelsio.com> <20140319223010.GB19326@oc0268524204.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:49384
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753964AbaCSWlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 18:41:31 -0400
In-Reply-To: <20140319223010.GB19326@oc0268524204.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   The biggest problem is that just because a PF is MASTER it doesn't 
mean that it can do anything it wants to the adapter.  There may be 
other already registered users (PFs) which are happily going about their 
business.  Being MASTER implies responsibilities:

  1. Initialization if the adapter isn't already initialized.

  2. Handling adapter errors and error interrupts.

Casey

On 03/19/14 15:30, Thadeu Lima de Souza Cascardo wrote:
> On Wed, Mar 19, 2014 at 03:25:42PM -0700, Casey Leedom wrote:
>>    I think I know what's happening.  You mentioned that you're doing
>> a "netboot" so it's probably using PF0..3 for the network boot
>> (depending on the port being booted from) and is failing to issue a
>> BYE command.  When cxgb4 comes along it gets MASTER (because
>> presumably the "netboot" said it didn't want to be MASTER) and the
>> chip/firmware is reported as being Already Initialized.  The
>> "netboot" here seems to be pretty crazy though since the above
>> scenario would require it to explicitly refuse to be MASTER and fail
>> to issue a BYE command.
>>
>>    Which "netboot" are you using and what's the version number, etc.?
>>
> That will take me a while to get answered. I'll see if I can find who
> wrote that code, but it's a driver for Open Firmware on IBM Power
> Systems. I am not really sure this is the cause, but that's what was
> reported to me.
>
> By the way, what exactly are the tons of problems with my patch,
> considering the change I proposed, ie, checking that it's the MASTER?
> What scenarios could it get wrong? Do you suggest any further checking?
>
> Cascardo.
>
>> Casey
>>
>>
>> On 03/19/14 15:13, Casey Leedom wrote:
>>> Okay, that firmware is recent enough but Dimitris is right, the
>>> patch has a ton of problems.  This section of code is very tricky
>>> and we've worked hard to get it right.  The firmware also has
>>> special code in it to ~try to catch~ cases where a previous driver
>>> on the same PF failed to issue a BYE command.  When the firmware
>>> sees a new HELLO command come in from a PF and that PF is already
>>> "registered" (via a previous HELLO command), if it's the _only_ PF
>>> "registered" and the new HELLO command provides the Clear
>>> Initialized flag, then the firmware will assume a missing BYE and
>>> automatically "de-initialize" the firmware/chip.  So it's Very
>>> Weird that you're getting a PF is MASTER and Chip/Firmware is
>>> Initialized return.
>>>
>>> Casey
>>>
>>> On 03/19/14 14:57, Thadeu Lima de Souza Cascardo wrote:
>>>> On Wed, Mar 19, 2014 at 09:38:49PM +0000, Dimitrios Michailidis wrote:
>>>>> Thadeu Lima de Souza Cascardo wrote:
>>>>>> Since commit 636f9d371f70f22961fd598fe18380057518ca31 ("cxgb4: Add
>>>>>> support for T4 configuration file"), we have problems when probing the
>>>>>> device, and finding out it's already initialized, but does not have
>>>>>> valid buffer sizes setup.
>>>>>>
>>>>>> This may happen with kexec without shutdown, or bad firmware or
>>>>>> bootloader.
>>>>>>
>>>>>> The usual symptom is that probe fails:
>>>>>>
>>>>>> [    2.605494] cxgb4 0000:50:00.4: Coming up as MASTER:
>>>>>> Adapter already
>>>>>> initialized
>>>>>> [    2.605511] cxgb4 0000:50:00.4: bad SGE FL page buffer sizes [0, 0]
>>>>>> [    2.625629] cxgb4: probe of 0000:50:00.4 failed with error -22
>>>>>>
>>>>>> The solution is to treat the adapter as not initialized in case the
>>>>>> parameters are invalid.
>>>>> The patch doesn't look right to me.  Besides reinitializing
>>>>> the device when it finds
>>>>> disagreeable settings it disregards that this PF may not be in
>>>>> charge of the device.
>>>>> If the controlling PF (what the code calls master) selects
>>>>> values this PF doesn't like
>>>>> with the patch it will elevate itself to master and install
>>>>> its own preferences.
>>>>>
>>>>> Also not right of course is that FW is claiming the device is
>>>>> initialized when clearly it isn't.
>>>>> Can you tell me which FW version is involved here and what
>>>>> steps got the device in this state?
>>>>>
>>>> We are trying to netboot, so it's possibly a problem on the Open
>>>> Firmware driver that makes it not send FW BYE before handling the CPU to
>>>> the bootloader. I could easily reproduce a similar situation by removing
>>>> the call to t4_fw_bye during the driver remove path, and reloading the
>>>> driver without commit 940d9d34a5467c2e2574866eb009d4cb61e27299 ("cxgb4:
>>>> allow large buffer size to have page size").
>>>>
>>>> The firmware I am using is:
>>>> firmware-version: 1.9.23.0, TP 0.1.9.1
>>>>
>>>> How about the change below?
>>>>
>>>> If that's OK, I'll send a v2.
>>>>
>>>> Cascardo.
>>>>
>>>>
>>>>>> Signed-off-by: Thadeu Lima de Souza Cascardo
>>>>>> <cascardo@linux.vnet.ibm.com>
>>>>>> ---
>>>>>>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   34
>>>>>> +++++++++++++---------
>>>>>>   1 files changed, 20 insertions(+), 14 deletions(-)
>>>>>>
>>>>>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>>>>>> b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>>>>>> index 34e2488..d0638f9 100644
>>>>>> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>>>>>> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>>>>>> @@ -5237,13 +5237,27 @@ static int adap_init0(struct adapter *adap)
>>>>>>        * master initialization), note that we're living with existing
>>>>>>        * adapter parameters.  Otherwise, it's time to try
>>>>>> initializing the
>>>>>>        * adapter ...
>>>>>> +     *
>>>>>> +     * If we're living with non-hard-coded parameters (either from a
>>>>>> +     * Firmware Configuration File or values programmed by
>>>>>> a different PF
>>>>>> +     * Driver), give the SGE code a chance to pull in
>>>>>> anything that it
>>>>>> +     * needs ...  Note that this must be called after we
>>>>>> retrieve our VPD
>>>>>> +     * parameters in order to know how to convert core
>>>>>> ticks to seconds.
>>>>>>        */
>>>>>>       if (state == DEV_STATE_INIT) {
>>>>>>           dev_info(adap->pdev_dev, "Coming up as %s: "\
>>>>>>                "Adapter already initialized\n",
>>>>>>                adap->flags & MASTER_PF ? "MASTER" : "SLAVE");
>>>>>>           adap->flags |= USING_SOFT_PARAMS;
>>>>>> -    } else {
>>>>>> +        ret = t4_sge_init(adap);
>>>>>> +        if (ret == -EINVAL) {
>>>> -        if (ret == -EINVAL) {
>>>> +        if (ret == -EINVAL && adap->flags & MASTER_PF) {
>>>>
>>>>>> +            adap->flags &= ~USING_SOFT_PARAMS;
>>>>>> +            state = DEV_STATE_UNINIT;
>>>>>> +        } else if (ret < 0) {
>>>>>> +            goto bye;
>>>>>> +        }
>>>>>> +    }
>>>>>> +    if (state != DEV_STATE_INIT) {
>>>>>>           dev_info(adap->pdev_dev, "Coming up as MASTER: "\
>>>>>>                "Initializing adapter\n");
>>>>>>
>>>>>> @@ -5300,19 +5314,11 @@ static int adap_init0(struct adapter *adap)
>>>>>>                   -ret);
>>>>>>               goto bye;
>>>>>>           }
>>>>>> -    }
>>>>>> -
>>>>>> -    /*
>>>>>> -     * If we're living with non-hard-coded parameters (either from a
>>>>>> -     * Firmware Configuration File or values programmed by
>>>>>> a different PF
>>>>>> -     * Driver), give the SGE code a chance to pull in
>>>>>> anything that it
>>>>>> -     * needs ...  Note that this must be called after we
>>>>>> retrieve our VPD
>>>>>> -     * parameters in order to know how to convert core
>>>>>> ticks to seconds.
>>>>>> -     */
>>>>>> -    if (adap->flags & USING_SOFT_PARAMS) {
>>>>>> -        ret = t4_sge_init(adap);
>>>>>> -        if (ret < 0)
>>>>>> -            goto bye;
>>>>>> +        if (adap->flags & USING_SOFT_PARAMS) {
>>>>>> +            ret = t4_sge_init(adap);
>>>>>> +            if (ret < 0)
>>>>>> +                goto bye;
>>>>>> +        }
>>>>>>       }
>>>>>>
>>>>>>       if (is_bypass_device(adap->pdev->device))
>>>>>> -- 
>>>>>> 1.7.1

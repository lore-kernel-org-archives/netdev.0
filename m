From: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [GIT] Networking
Date: Tue, 19 Jan 2016 09:51:37 +0000
Message-ID: <569E0729.9020603@arm.com>
References: <20160112.215136.850414372508130298.davem@davemloft.net>
 <56978094.4050302@arm.com> <87k2n97n5e.fsf@kamboji.qca.qualcomm.com>
 <569CCCD2.4040105@arm.com> <569D61BA.8020701@broadcom.com>
 <569DFA0A.6070900@arm.com> <569E0387.1070601@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <569E0387.1070601-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 19/01/16 09:36, Arend van Spriel wrote:
> On 19-1-2016 9:55, Marc Zyngier wrote:
>> On 18/01/16 22:05, Arend van Spriel wrote:
>>> On 18-1-2016 12:30, Marc Zyngier wrote:
>>>> Hi Kalle,
>>>>
>>>> On 16/01/16 11:57, Kalle Valo wrote:
>>>>> Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org> writes:
>>>>>
>>>>>> David, Hante,
>>>>>>
>>>>>> On 13/01/16 02:51, David Miller wrote:
>>>>>>
>>>>>> [...]
>>>>>>
>>>>>>> Hante Meuleman (33):
>>>>>> [...]
>>>>>>>       brcmfmac: Move all module parameters to one place
>>>>>
>>>>> As a reminder to myself this is the commit id:
>>>>>
>>>>> 7d34b0560567 brcmfmac: Move all module parameters to one place
>>>>>
>>>>>> This particular patch breaks one of my boxes in a spectacular way:
>>>>>>
>>>>>> [    3.602155] Unable to handle kernel paging request at virtual address 000027e4
>>>>>> [    3.602160] pgd = c0003000
>>>>>> [    3.602169] [000027e4] *pgd=80000040004003, *pmd=00000000
>>>>>> [    3.602181] Internal error: Oops: 206 [#1] PREEMPT SMP ARM
>>>>>
>>>>> [...]
>>>>>
>>>>>> This is caused by this hunk:
>>>>>>
>>>>>> @@ -890,7 +887,8 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
>>>>>>  	if (!sdiodev->sg_support)
>>>>>>  		return;
>>>>>>  
>>>>>> -	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE, brcmf_sdiod_txglomsz);
>>>>>> +	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE,
>>>>>> +		      sdiodev->bus_if->drvr->settings->sdiod_txglomsz);
>>>>>>  	nents += (nents >> 4) + 1;
>>>>>>  
>>>>>>  	WARN_ON(nents > sdiodev->max_segment_count);
>>>>>>
>>>>>> were drvr->settings is NULL (as the settings allocation seems to be done
>>>>>> much later). The fix is not completely obvious to me (probably requires
>>>>>> pushing the call to brcmf_mp_device_attach() down into the various bus
>>>>>> specific functions). An alternative would be to restore the txglomsz
>>>>>> parameter as it was before and not rely on settings being allocated.
>>>>>
>>>>> Should we revert the patch or can you Hante fix this? The revert doesn't
>>>>> seem to be trivial so I would appreciate if someone could send a patch.
>>>>
>>>> I've worked out a partial revert (see below) that allows my system to
>>>> boot, but I'd rather see a proper fix from the maintainer of this code.
>>>
>>> Hi Marc,
>>>
>>> Thanks for the patch, but Hante has created a different patch basically
>>> deferring the allocation of the sgtable. Feel free to give it a spin on
>>> your box and share the results.
>>
>> Hi Arend,
>>
>> This patch fixes indeed the problem, thanks (I had to undo the mangling
>> your mailer had done, though). So feel free to add my:
> 
> Thanks, Marc
> 
> I started using thunderbird on windows 7. Probably better revert to the
> one on Citrix.
> 
>> Reported-by: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
>> Tested-by: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
>>
>> It would be good if this could make it in -rc1.
> 
> Will try to submit a clean patch to Kalle.
> 
>>> I am looking for a arm64 platform to add to my test machines so if
>>> you can recommend one (with PCIe).
>>
>> Note that this crash happened with 32bit ARM, without PCIe (the box is a
>> "Cubietruck").
>>
>> As for arm64, there is now quite a few machines out there (ARM sells a
>> dev board called Juno, but there is also various offerings with AMD
>> Opteron A1100, Cavium ThunderX, APM X-Gene, and maybe even some Broadcom
>> based systems, who knows! ;-).
> 
> Thanks. Actually found something in our corporate spam:
> 
> http://www.broadcom.com/press/release.php?id=s948493

Ah, quality marketroid blurb! :-) Yeah, this looks promising, assuming
it is available in the not too distant future (I think I reviewed some
of the PCIe code for that platform...).

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

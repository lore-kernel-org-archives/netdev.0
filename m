From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: Re: [PATCH net-next 4/7] sfc: Add support for IEEE-1588 PTP
Date: Fri, 20 Jul 2012 10:15:46 +0100
Message-ID: <500921C2.1080001@solarflare.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com> <1342635693.2617.56.camel@bwh-desktop.uk.solarflarecom.com> <20120719142558.GB24484@localhost.localdomain> <500827EF.208@solarflare.com> <20120720063102.GB2330@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Andrew Jackson <ajackson@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39000 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752939Ab2GTJPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 05:15:50 -0400
In-Reply-To: <20120720063102.GB2330@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> This code looks like it is trying to find the offset between two
>>> clocks. Is there some reason why you cannot use <linux/timecompare.h>
>>> to accomplish this?
>>
>> This is what the code is doing. <linux/timecompare.h> states
>>
>> "the assumption is that reading the source
>> time is slow and involves equal time for sending the request and
>> receiving the reply"
>>
>> While in our case event though it is slow we cannot guarantee the second
>> assumption. The code above takes into account some of the particulars of the sfc
>> hardware and gives us good results. 
> 
> Fair enough, but then maybe a comment mentioning how timecompare is
> unsuitable would be nice to have.
> 

This can be added

>>> I am trying to purge the whole SYS thing (only blackfin is left)
>>> because there is a much better way to go about this, namely
>>> synchronizing the system time to the PHC time via an internal PPS
>>> signal.
>>

Do you mean using the PPS kernel consumer to govern the system time?

> I don't understand what the issue is here. Can't you just call
> ptp_clock_event, like you already have...
> 
>>>> +static void efx_ptp_pps_worker(struct work_struct *work)
>>>> +{
>>>> +	struct efx_ptp_data *ptp =
>>>> +		container_of(work, struct efx_ptp_data, pps_work);
>>>> +	struct efx_nic *efx = ptp->channel->efx;
>>>> +	struct timespec event_gen_time;
>>>> +	struct ptp_clock_event ptp_pps_evt;
>>>> +	ktime_t gen_time_host;
>>>> +
>>>> +	if (efx_ptp_synchronize(efx, PTP_SYNC_ATTEMPTS))
>>>> +		return;
>>>> +
>>>> +	gen_time_host = ktime_sub(ptp->mc_base_time,
>>>> +				  ptp->host_base_time);
>>>> +	event_gen_time = ktime_to_timespec(gen_time_host);
>>>> +
>>>> +	ptp_pps_evt.type = PTP_CLOCK_EXTTS;
>>>> +	ptp_pps_evt.timestamp = ktime_to_ns(gen_time_host);
>>>> +	ptp_clock_event(ptp->phc_clock, &ptp_pps_evt);
>>>> +}
> 
> ... here?
> 

In order for a PPS to arrive at the kernel consumer ptp_clock_event
needs to be called with PTP_CLOCK_PPS. This then calls pps_get_ts
and stamps the event with the current system time, not the time
that was put into the event.

Using PTP_CLOCK_EXTTS the PPS is visible to userspace via a read
on the phc device and can then be used in our modified ptpd2.

>>>> +static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
>>>> +{
> 
> You can set the time here somehow by doing, T' = T + offset, and so...
> 
>>>> +}
> 
>>>> +static int efx_phc_settime(struct ptp_clock_info *ptp,
>>>> +			   const struct timespec *e_ts)
>>>> +{
>>>> +	/* We must provide this function, but we cannot actually set the time */
>>>
>>> Huh? You can adjtime, so must be able to settime, too, right?
>>>
>>> If you have enough range in the RAW timestamp in the MC firmware (like
>>> 64 bits of nanoseconds), and you allow settime, then you can spare the
>>> system time synchronization code altogether.
>>>
>>
>> You will have to elaborate further on this point.
> 
> ... why can't you also just set the time?

Our hardware can only have an offset applied to the clock. In order to set time
we need to know the time now, then work out and offset to get to the target time.
At the point that we apply this offset the clock will have moved on and not be
set to the target time. We can apply some measured average times to the offset
to get closer but with this hardware settime will not leave the NIC clock at the
desired time. 

> 
> Thanks,
> Richard

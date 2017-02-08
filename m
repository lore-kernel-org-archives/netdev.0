From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH v2 net-next 6/9] sunvnet: straighten up message event
 handling logic
Date: Wed, 8 Feb 2017 08:28:25 -0800
Message-ID: <792566dd-8f05-ed1b-50ad-d40f958aa2c7@oracle.com>
References: <1486505582-76823-1-git-send-email-shannon.nelson@oracle.com>
 <1486505582-76823-7-git-send-email-shannon.nelson@oracle.com>
 <20170208155947.GE30741@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208155947.GE30741@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/8/2017 7:59 AM, Sowmini Varadhan wrote:
> On (02/07/17 14:12), Shannon Nelson wrote:
>> +
>> +	/* we don't expect any other bits */
>> +	BUG_ON(port->rx_event & ~(LDC_EVENT_DATA_READY |
>> +				  LDC_EVENT_RESET |
>> +				  LDC_EVENT_UP));
>> +
>> +	/* RESET takes precedent over any other event */
>> +	if (port->rx_event & LDC_EVENT_RESET) {
>                   :
>>  		port->rx_event = 0;
>>  		return 0;
>>  	}
>> +	if (port->rx_event & LDC_EVENT_UP) {
>> +		vio_link_state_change(vio, LDC_EVENT_UP);
>> +		port->rx_event = 0;
>> +		return 0;
>> +	}
>>
>>  	err = 0;
>>  	tx_wakeup = 0;
>
> IIRC there were timing-related situations where you can get woken up with
> both UP and DATA_READY, and if my reading of your patch is
> correct, we would ignore the DATA_READY, and return, right?
>
> --Sowmini

The existing code does this as well - if it first finds a RESET, it 
handles it then hits the return 0.  Next if it finds the UP, it does the 
goto back to the ldc_ctrl: to process, and hits the same return 0.  Only 
if neither of these bits have been seen does the code move on to process 
the DATA_READY event.

If we're seeing cases of both UP and DATA_READY, then yes we'll wnat to 
look at changing this logic.  I think that should be a separate patch.

sln

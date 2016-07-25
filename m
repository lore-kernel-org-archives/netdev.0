From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 1/2] be2net: set temperature value for all
 adapter's functions
Date: Mon, 25 Jul 2016 09:53:03 -0300
Message-ID: <57960BAF.20004@linux.vnet.ibm.com>
References: <1469237395-11501-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <a231dccbdf9d054819aca387db6533c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ajit Kumar Khaparde <ajit.khaparde@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>,
	netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42581 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648AbcGYMxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 08:53:12 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6PCj0Ud118820
	for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 08:53:12 -0400
Received: from e24smtp05.br.ibm.com (e24smtp05.br.ibm.com [32.104.18.26])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24c4nr1dg2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 08:53:11 -0400
Received: from localhost
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Mon, 25 Jul 2016 09:53:08 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 3FC8F1DC006E
	for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 08:52:57 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6PCr4Vp13566462
	for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 09:53:04 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6PCr3Qd027099
	for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 09:53:04 -0300
In-Reply-To: <a231dccbdf9d054819aca387db6533c4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2016 07:48 AM, Sathya Perla wrote:
>> -----Original Message-----
>> From: Guilherme G. Piccoli [mailto:gpiccoli@linux.vnet.ibm.com]
>>
>> Temperature values on be2net driver are made available to userspace via
> hwmon abstraction, so tools like lm-
>> sensors can present them to the user.
>> The driver provides hwmon structures for each adapter's function.
>> Nevertheless, the temperature information come from fw queries performed
> by
>> be_worker() with some frequency, and this procedure is called with a
> single function as argument; this means
>> that the temperature value is updated only in the specific function that
> was passed to be_worker().
>>
>> This can lead to incongruency in reported temperature by a function, or
> in a worse scenario, some functions
>> might be unable to provide temperature info to userspace, if they
> weren't fed with this information from fw in
>> be_worker() run.
>
> Hi, I'm wondering if you are OK with the temperature value being 128s old
> (2/2 patch), then why is it a problem
> if two different functions report a temperature value that is queried a
> few seconds apart?
> Also, you'll not have a scenario where the FW cmd succeeds for one
> function and fails for other functions.
> It's a common FW for the entire adapter.
>
>>
>> This patch changes the way temperature is set in be2net driver. At
> anytime the fw query is performed, it will set
>> the temperature value for all functions of the adapter, instead of only
> setting the temperature of the function
>> passed to be_worker().
> If the possible inconsistency across functions is indeed a problem, then a
> simpler solution would be to
> issue the FW cmd synchronously when the sysfs attr is read, i.e., in
> be_hwmon_show_temp() routine itself.
>

Hi Sathya, thanks very much for your quick reply. I agree with you that 
an 1 or 2 sec inconsistency wouldn't harm, but the main problem we're 
seeing is that be_worker() is being called with a single function as a 
parameter - in our case, the last function is being passed as argument 
to be_worker() multiple times in a row, and then we have its temperature 
updated but the other functions' temperature set as invalid.

Regarding the temperature update run on be_hwmon_show_temp(), it was an 
idea too, but I was afraid in delay this output too much - imagine some 
userspace tool reads hwmon attributes for all functions almost at "same 
time", supposing the fw command can't run in parallel, the "last" read 
would need to wait 4 fw commands to complete before showing it's output.
Besides, in a worse scenario, some "not-friendly" tool might issue lots 
of reads to hwmon per second then issuing lots of fw commands, which 
does not seem a good idea. Of course this last case we can avoid by 
implementing a counter or timer on be_hwmon_show_temp() to allow maximum 
number of fw cmds in a time frame.

I appreciate your advice on how do you prefer to address this issue.
Thanks,


Guilherme


> thanks!
> -Sathya
>

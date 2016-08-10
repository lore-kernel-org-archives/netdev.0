From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Fwd: Re: [PATCH RESEND net-next 13/15] smc: receive data from RMBE
Date: Wed, 10 Aug 2016 17:15:01 +0200
Message-ID: <40f250c2-d865-5bd3-8d20-a2dc2fd7d257@linux.vnet.ibm.com>
References: <653f839a-8098-da62-3437-8b002d929a50@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Utz Bacher <utz.bacher@de.ibm.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39247 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932616AbcHJTp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:45:59 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7AFEDBv057969
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 11:15:12 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24qm9sup4a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 11:15:12 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 16:15:09 +0100
In-Reply-To: <653f839a-8098-da62-3437-8b002d929a50@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

sorry, forget my previous mail from today. I now realize that xchg() 
does not help on 32-bit architectures. I have to think about 
alternatives here.

-------- Forwarded Message --------
Subject: Re: [PATCH RESEND net-next 13/15] smc: receive data from RMBE
Date: Wed, 10 Aug 2016 15:44:00 +0200
From: Ursula Braun <ubraun@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org, linux-s390@vger.kernel.org, 
schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com



On 08/09/2016 11:32 PM, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Tue,  9 Aug 2016 12:12:58 +0200
>
>> +		xchg(&conn->rx_curs_confirmed.acurs,
>> +		     smc_curs_read(conn->local_tx_ctrl.cons.acurs));
>
> Why in the world do you need to use xchg() in all of these places?
>
> It makes no sense whatsoever, especially since you don't even check
> the return value.
> 98e906b2
> If you need the operation to be atomic, then you have to check the
> return value and do something to recover if something else beat
> you to the xchg() and put something else into the location.
>
> Otherwise, you therefore don't need it be atomic and can avoid
> this expensive operation and just store the value normally.
>
Reviewing my xchg() usages, I really detected some paranoid usages, that 
I am going to remove. But there are still usages (and 
conn->rx_curs_confirmed is one of them), where I need an 8-byte cursor 
field to be read and written atomicaly, even though I do not care 
whether the write operation has been beaten or not. But I do care that 
reading the cursor does not return a partially updated cursor. Isn't 
xchg() a possible solution in this case?

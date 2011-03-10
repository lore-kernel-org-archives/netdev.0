From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Stale entries in RT_TABLE_LOCAL
Date: Thu, 10 Mar 2011 03:50:27 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103100222080.2550@ja.ssi.bg>
References: <201102231243.23579.alexandre.sidorenko@hp.com> <20110309.135308.102544831.davem@davemloft.net> <alpine.LFD.2.00.1103100139510.2372@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: alexandre.sidorenko@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49731 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751026Ab1CJBpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 20:45:49 -0500
In-Reply-To: <alpine.LFD.2.00.1103100139510.2372@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Thu, 10 Mar 2011, Julian Anastasov wrote:

> On Wed, 9 Mar 2011, David Miller wrote:
>
>> From: Alex Sidorenko <alexandre.sidorenko@hp.com>
>> Date: Wed, 23 Feb 2011 12:43:23 -0500
>> 
>>> I am not sure what is the best way to fix this, I can think of several
>>> approaches:
>>>
>>>   (a) change the sources so that it would be impossible to add the same IP
>>>       multiple times, even with different masks. I cannot think of any
>>>       situation where adding the same IP (but with different mask) to the 
>>> same
>>>       interface could be useful. But maybe I am wrong?
>> 
>> I'm leaning towards this solution if it's viable.  But I'm not so sure that
>> nobody uses this feature, maybe Julian knows?
>> 
>> Julian, the issue is that if you add the same IP address multiple times 
>> using
>> different subnet masks, we allow it.
>> 
>> But removal doesn't work correctly, we clear the IFA list on the device but 
>> we
>> leave stale entries in the local routing table.
>> 
>> The test case is:
>> 
>> ip addr add 192.168.142.109/23 dev dummy0
>> ip addr add 192.168.142.109/22 dev dummy0
>
> 	Here I have just one local route.

 	Aha, it seems the problem happens when the
both lines are executed while there is another address on
device and the last added address becomes secondary
for the 1st, eg:

IP1: 192.168.140.31/22, primary
IP2: 192.168.142.109/23, primary
IP3: 192.168.142.109/22, secondary for primary IP1

 	It is the route for IP3 that is leaked, with prefsrc=IP1.
We create local route for secondary IPs with prefsrc=ItsPrimaryIP.
Both local routes for 109 differ in prefsrc (fa_info). But on
deletion only one route is deleted due to last_ip check - the first
because on deletion prefsrc is not matched, fib_table_delete
does not work in symmetric way. So, the local route created
for IP3 remains no matter the deletion order.
If we decide to create one unique local route for this case,
there is a risk device unregistration to remove
it (fib_sync_down_dev with force > 0). I have to think more
on this issue...

Regards

--
Julian Anastasov <ja@ssi.bg>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix packets_per_slave showing
Date: Thu, 05 Dec 2013 13:42:08 +0100
Message-ID: <52A074A0.7050807@redhat.com>
References: <1386239818-7408-1-git-send-email-nikolay@redhat.com>	 <20131205110843.GD23210@redhat.com> <1386246835.30495.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755709Ab3LEMqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 07:46:32 -0500
In-Reply-To: <1386246835.30495.175.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2013 01:33 PM, Eric Dumazet wrote:
> On Thu, 2013-12-05 at 12:08 +0100, Veaceslav Falico wrote:
>> On Thu, Dec 05, 2013 at 11:36:58AM +0100, Nikolay Aleksandrov wrote:
>>> There's an issue when showing the value of packets_per_slave due to
>>> using signed integer. The value may be < 0 and thus not put through
>>> reciprocal_value() before showing. This patch makes it use unsigned
>>> integer when showing it.
>>
>> I was already checking my basic algebra knowledge here,
>> reciprocal_value(reciprocal_value(0..USHRT_MAX)) can become negative?!? :)
>>
>> If anyone's also wondering...
>>
>> packets_per_slave is reciprocal_value(0..USHRT_MAX), and thus can indeed be
>> negative, and then the code
>>
>> 	if (packets_per_slave > 1)
>> 		packets_per_slave = reciprocal_value(packets_per_slave);
>>
>> would fail to recognise that it's a reciprocal_divide() value, and not a
>> standard 0/1 option (in bond_rr_gen_slave_id() we verify it via a switch,
>> so we're safe there) - and thus output nonsense.
>>
>> Acked-by: Veaceslav Falico <vfalico@redhat.com>
> 
> This code is very confusing.
> 
> Please rename bond->params.packets_per_slave
> to bond->params.reciprocal_packets_per_slave 
> 
> To make clear that its the reciprocal value.
> 
> Also the module parameter is named packets_per_slave, it would be nice
> if same name was not reused as local variable in bond_rr_gen_slave_id()
> 
> bond_check_params() reads the sys value several times.
> 
> This is racy with /sys access.
> 
IIRC bond_check_params() runs before sysfs is initialized for the bond device.

> You should use ACCESS_ONCE() to make sure nothing bad happens.
> 
Actually I think ACCESS_ONCE() should be added to bond_show_packets_per_slave
and to bond_rr_gen_slave_id() just as a precaution. It'll also serve the purpose
to show what's intended.
What do you think ?
> 
> 
Thanks for the feedback, I'll address the ACCESS_ONCE() in a separate patch for
net and leave the renaming to my net-next patch which will take care of the
types as well.

Cheers,
 Nik

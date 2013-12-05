From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net] bonding: fix packets_per_slave showing
Date: Thu, 5 Dec 2013 13:42:59 +0100
Message-ID: <20131205124259.GE23210@redhat.com>
References: <1386239818-7408-1-git-send-email-nikolay@redhat.com>
 <20131205110843.GD23210@redhat.com>
 <1386246835.30495.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756646Ab3LEMpf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 07:45:35 -0500
Content-Disposition: inline
In-Reply-To: <1386246835.30495.175.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 04:33:55AM -0800, Eric Dumazet wrote:
>On Thu, 2013-12-05 at 12:08 +0100, Veaceslav Falico wrote:
>> On Thu, Dec 05, 2013 at 11:36:58AM +0100, Nikolay Aleksandrov wrote:
>> >There's an issue when showing the value of packets_per_slave due to
>> >using signed integer. The value may be < 0 and thus not put through
>> >reciprocal_value() before showing. This patch makes it use unsigned
>> >integer when showing it.
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
>This code is very confusing.
>
>Please rename bond->params.packets_per_slave
>to bond->params.reciprocal_packets_per_slave
>
>To make clear that its the reciprocal value.
>
>Also the module parameter is named packets_per_slave, it would be nice
>if same name was not reused as local variable in bond_rr_gen_slave_id()

Agreed, but I think it'd be rather net-next material. Here we have a clear
bug...

>
>bond_check_params() reads the sys value several times.
>
>This is racy with /sys access.
>
>You should use ACCESS_ONCE() to make sure nothing bad happens.

Hrm? bond_check_params() isn't involved in sysfs at all :-/, it's called
only via bonding_init(). And bond->params.packets_per_slave isn't read
there at all, only assigned.

Or, given the naming confusions, I'm again missing something?

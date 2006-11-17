From: "Wei Yongjun" <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Fri, 17 Nov 2006 13:45:40 +0800
Message-ID: <009301c70a0b$9d6fdb20$6004a8c0@weiyongjun>
References: <1163739471.2802.7.camel@LINE> <20061116195122.144bc37f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:64215 "EHLO proxy.fnst.com.cn")
	by vger.kernel.org with ESMTP id S1162036AbWKQFsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 00:48:24 -0500
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"Li Yewang" <lyw@nanjing-fnst.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, November 17, 2006 11:51 AM
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Thu, 16 Nov 2006 23:57:50 -0500
> Li Yewang <lyw@nanjing-fnst.com> wrote:
>
>> [1]Summary of the problem:
>> On IA32 system, If jiffies - b > 0x7fffffff, router can not send
>> redirect packet.unsigned long b = rt->u.dst.rate_last
>> +(ip_rt_redirect_load << rt->u.dst.rate_tokens)
>>
>> [2]Full description of the problem:
>> In linux kernel, if time_after(jiffies, (rt->u.dst.rate_last
>> +(ip_rt_redirect_load << rt->u.dst.rate_tokens)) == false,
>> router will not send redirect packet. Here define b = rt-
>> >u.dst.rate_last +(ip_rt_redirect_load << rt->u.dst.rate_tokens):
>>
>> 1. If (jiffies - b <= 0x7fffffff), time_after(jiffies, b) == true,
>> router will send redirect packet.
>>
>> 2. If (jiffies - b > 0x7fffffff), time_after(jiffies, b) == false,
>> router will not send redirect packet. For example: when I add a router
>> after system boot, jiffies = (unsigned long)(-300000),
>> rt->u.dst.rate_last = 0, rt->u.dst.rate_tokens = 0, b = 20,
>> time_after((unsigned long)(-300000), 20) == false, send redirect packet
>> can not be send even if router is used in the first time.
>>
>> When router send a  redirect packet in time b, and before jiffies
>> increased to 0x7fffffff + b, router can send redirect packet.
>> But if a redirect packet must be send in 0x80000000+ b,
>> time_after(jiffies, b) == false, redirect packet will not be send also.
>> So between time (0x80000000+ b) to time b, router do not send redirect
>> packet. That is to say, in a circle of jiffies, router has 24.9 days can
>> not send redirect packet (0x80000000/1000/60/60/24=24.9).
>
> Wouldn't making ip_rt_redirect_load and other unsigned long instead of int fix 
> the problem?
>
> Remember time_after() works correctly for values that wraparound.

Yes, time_after() works correctly for values that wraparound. For examples: if 
time a = (unsigned long)(-1), and time b = 1; time_after(b, a) = true.
But if a is increaseing, after a circle of jiffies, a' = a + (unsigned long)(-1) 
+ 1 = (unsigned long)(-1) = a,
this time a' is after b, but time_after(b, a') still equal to true,because 
values that wraparound can not be making in time_after().

Regards 



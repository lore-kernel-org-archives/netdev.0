From: Patrick McHardy <kaber@trash.net>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Mon, 14 May 2007 21:19:50 +0200
Message-ID: <4648B656.6030800@trash.net>
References: <Line.LNX.4.64.0705141430120.8521@d.namei> <4648AE85.6020608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, Curtis Doty <Curtis@GreenKey.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47450 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbXENTUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:20:42 -0400
In-Reply-To: <4648AE85.6020608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> James Morris wrote:
> 
>>---------- Forwarded message ----------
>>Date: Mon, 14 May 2007 08:15:50 -0700 (PDT)
>>From: Curtis Doty <Curtis@GreenKey.net>
>>To: Linux Kernel <linux-kernel@vger.kernel.org>
>>Subject: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
>>
>>BUG: unable to handle kernel NULL pointer dereference at virtual address
>>000000a8
>>[...]
>>EIP is at inet_select_addr+0x4/0x9f
>>eax: 00000000   ebx: f8b97046   ecx: 000000fd   edx: 00000000
>>esi: 000000fd   edi: 00000001   ebp: f71cd0ac   esp: c078bc9c
>>ds: 007b   es: 007b   ss: 0068
>>Process swapper (pid: 0, ti=c078b000 task=c06fc480 task.ti=c0746000)
>>Stack: f8b97046 f601b130 c05fd0b6 f728b980 f728b980 f8b5adbb c05bcb6e c078bd74
>>       00000003 00000003 00000246 00000246 00000000 f887e014 f8a611a6 f7c1ea80
>>       f728b9a8 00000000 f727d220 f887e000 00000001 00000072 f7383800 f728b980
>>Call Trace:
>> [<f8b97046>] reject+0x0/0x4ae [ipt_REJECT]
>> [<c05fd0b6>] icmp_send+0x14d/0x39b
> 
> 
> 
> A REJECT target in the output chain will trigger this in combination
> with icmp_errors_use_inbound_ifaddr because skb->dev is still NULL
> at this point and its passed to inet_select_addr.
> 
> I'll look into this.


saddr = iph->daddr;
if (!(rt->rt_flags & RTCF_LOCAL)) {
        if (sysctl_icmp_errors_use_inbound_ifaddr)


                saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
        else
                saddr = 0;
}

Fixing the crash is easy, the right thing to do when skb->dev
is not set is to let routing choose the address because the
packet was locally generated and icmp_errors_use_inbound_ifaddr
shouldn't apply (the crash can also happen with IPsec tunnels
by the way).

This leaves the question what to do in the path after ip_output,
when skb->dev points to the output device. We don't know the
input device anymore, so there doesn't seem to be a way to make
it do what the sysctl promises.

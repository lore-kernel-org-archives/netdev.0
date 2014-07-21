From: Mihail Dakov <mihail.dakov@ng4t.com>
Subject: Re: AF_PACKET: tx_ring mirrored in rx_ring?
Date: Mon, 21 Jul 2014 16:40:33 +0200
Message-ID: <53CD2661.8070707@ng4t.com>
References: <53CD1326.5090006@ng4t.com> <53CD1AE5.10408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud15.udmedia.de ([194.117.254.55]:46099 "EHLO
	mail.ud15.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242AbaGUOkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 10:40:35 -0400
In-Reply-To: <53CD1AE5.10408@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for fast reply.

On 07/21/2014 03:51 PM, Daniel Borkmann wrote:
> On 07/21/2014 03:18 PM, Mihail Dakov wrote:
>> Hello guys,
>>
>> I am having a trouble using the RX/TX ring buffer for AF_PACKET 
>> sockets. I create two sockets (one for rx, one for tx). I bind those 
>> sockets to the same interface. According the docs you can create a 
>> socket per direction or single socket for both directions (allocating 
>> double the memory needed for a ring buffer, and then mapping first rx 
>> and then tx buffer). In this case I opted for creating two sockets, 
>> one per direction. The problem is that when I use the tx_ring to send 
>> over the pf_socket I see those message "mirrored" in the rx_ring 
>> buffer which is not an expected behavior for my application. In other 
>> to reproduce the issue I simplified my application into a smaller 
>> one. Then I send a manually created ping message with adjusted mac 
>> and ip address so that a remote machine in my local network answers 
>> it. I successfully see the ping request double (once in the tx_ring 
>> and once in the rx_ring). Which I think is not expected behavior. 
>> This application was tested on kernel
>> 3.14.12-1 and was compiled with gcc (Debian 4.8.3-5) and on kernel 
>> 3.2.0-52-lowlatency with compiler gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 
>> 4.6.3.
>>
>> So some questions have arised:
>>
>> 1. Is this normal behavior? If it is, why? I mean, if I use a socket 
>> per direction I expect to see only packets for that direction on the 
>> correspondent socket, right?
>> 2. Could you provide some more insights about why this "problem" is 
>> happening? Am I doing it wrong? Did I get it wrong (the whole ring 
>> buffer in af_packets)? Am I using wrong settings?
>>
>> I have attached the simple program which should reproduce the issue.
>
> It's expected behaviour (and actually also RX/TX ring independant).
> Currently, when calling dev_hard_start_xmit() the kernel tries to push
> local traffic back via dev_queue_xmit_nit() iff a packet socket is
> present for that protocol, or for any kind of traffic for monitoring
> purposes. 
What'd you mean by local traffic? The packets which are replicated are 
destined to remote machine(s).
> skbs are not particularly marked for differentiating outgoing
> traffic from normal protocols and from packet sockets. Even having 1
> socket for RX/TX wouldn't work with your scenario as at some point in
> time you need to bind to a protocol as well and we install dev_add_pack()
> there, too. BPF might help in some situations, but still with a
> performance penalty. You could use PACKET_QDISC_BYPASS to solve that
This works on kernel 3.14.12 which isn't suitable for the program as 
target machine(s) provide 3.2 kernel (where no PACKET_QDISC_BYPASS flag 
exists). So I guess I have to adjust my app for the
replicated packets in the rx_ring.
> issue if your scenario allows for that, as here dev_queue_xmit_nit()
> won't be called, and thus you won't mirror back.

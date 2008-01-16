From: John Heffner <jheffner@psc.edu>
Subject: Re: SO_RCVBUF doesn't change receiver advertised window
Date: Wed, 16 Jan 2008 14:42:31 -0500
Message-ID: <478E5E27.3050307@psc.edu>
References: <f47983b00801151236l3b06f6dci35898fee71f6a942@mail.gmail.com>	 <20080116045026.eb62287a.billfink@mindspring.com> <f47983b00801161127u5fa4de0bgf53bb3b8fc57a3c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org
To: Ritesh Kumar <ritesh@cs.unc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:56820 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbYAPTmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 14:42:44 -0500
In-Reply-To: <f47983b00801161127u5fa4de0bgf53bb3b8fc57a3c7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ritesh Kumar wrote:
> On 1/16/08, Bill Fink <billfink@mindspring.com> wrote:
>> On Tue, 15 Jan 2008, Ritesh Kumar wrote:
>>
>>> Hi,
>>>     I am using linux 2.6.20 and am trying to limit the receiver window
>>> size for a TCP connection. However, it seems that auto tuning is not
>>> turning itself off even after I use the syscall
>>>
>>> rwin=65536
>>> setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &rwin, sizeof(rwin));
>>>
>>> and verify using
>>>
>>> getsockopt(sock, SOL_SOCKET, SO_RCVBUF, &rwin, &rwin_size);
>>>
>>> that RCVBUF indeed is getting set (the value returned from getsockopt
>>> is double that, 131072).
>> Linux doubles what you requested, and then uses (by default) 1/4
>> of the socket space for overhead, so you effectively get 1.5 times
>> what you requested as an actual advertised receiver window, which
>> means since you specified 64 KB, you actually get 96 KB.
>>
>>> The above calls are made before connect() on the client side and
>>> before bind(), accept() on the server side. Bulk data is being sent
>>> from the client to the server. The client and the server machines also
>>> have tcp_moderate_rcvbuf set to 0 (though I don't think that's really
>>> needed; setting a value to SO_RCVBUF should automatically turnoff auto
>>> tuning.).
>>>
>>> However the tcp trace shows the SYN, SYN/ACK and the first few packets as:
>>> 14:34:18.831703 IP 192.168.1.153.45038 > 192.168.2.204.9999: S
>>> 3947298186:3947298186(0) win 5840 <mss 1460,sackOK,timestamp 2842625
>>> 0,nop,wscale 5>
>>> 14:34:18.836000 IP 192.168.2.204.9999 > 192.168.1.153.45038: S
>>> 3955381015:3955381015(0) ack 3947298187 win 5792 <mss
>>> 1460,sackOK,timestamp 2843649 2842625,nop,wscale 2>
>>> 14:34:18.837654 IP 192.168.1.153.45038 > 192.168.2.204.9999: . ack 1
>>> win 183 <nop,nop,timestamp 2842634 2843649>
>>> 14:34:18.837849 IP 192.168.1.153.45038 > 192.168.2.204.9999: .
>>> 1:1449(1448) ack 1 win 183 <nop,nop,timestamp 2842634 2843649>
>>> 14:34:18.837851 IP 192.168.1.153.45038 > 192.168.2.204.9999: P
>>> 1449:1461(12) ack 1 win 183 <nop,nop,timestamp 2842634 2843649>
>>> 14:34:18.839001 IP 192.168.2.204.9999 > 192.168.1.153.45038: . ack
>>> 1449 win 2172 <nop,nop,timestamp 2843652 2842634>
>>> 14:34:18.839011 IP 192.168.2.204.9999 > 192.168.1.153.45038: . ack
>>> 1461 win 2172 <nop,nop,timestamp 2843652 2842634>
>>> 14:34:18.840875 IP 192.168.1.153.45038 > 192.168.2.204.9999: .
>>> 1461:2909(1448) ack 1 win 183 <nop,nop,timestamp 2842637 2843652>
>>> 14:34:18.840997 IP 192.168.1.153.45038 > 192.168.2.204.9999: .
>>> 2909:4357(1448) ack 1 win 183 <nop,nop,timestamp 2842637 2843652>
>>> 14:34:18.841120 IP 192.168.1.153.45038 > 192.168.2.204.9999: .
>>> 4357:5805(1448) ack 1 win 183 <nop,nop,timestamp 2842637 2843652>
>>> 14:34:18.841244 IP 192.168.1.153.45038 > 192.168.2.204.9999: .
>>> 5805:7253(1448) ack 1 win 183 <nop,nop,timestamp 2842637 2843652>
>>> 14:34:18.841388 IP 192.168.2.204.9999 > 192.168.1.153.45038: . ack
>>> 2909 win 2896 <nop,nop,timestamp 2843655 2842637>
>>> 14:34:18.841399 IP 192.168.2.204.9999 > 192.168.1.153.45038: . ack
>>> 4357 win 3620 <nop,nop,timestamp 2843655 2842637>
>>> 14:34:18.841413 IP 192.168.2.204.9999 > 192.168.1.153.45038: . ack
>>> 5805 win 4344 <nop,nop,timestamp 2843655 2842637>
>>>
>>> As you can see, the syn and syn ack show rcv windows to be 5840 and
>>> 5792 and it automatically increases for the receiver to values 2172
>>> till 4344 and more in the later part of the trace till 24214.
>> Since the window scale was 2, the final advertised receiver window
>> you indicate of 24214 gives 2^2*24214 or right around 96 KB, which
>> is what is expected given the way Linux works.
>>
>>                                                 -Bill
> 
> Thanks for the explanation Bill. That surely clears part of my doubt.
> However, why doesn't linux advertise 24214 in the SYN packets? I was
> hoping that the moment I setup a RCVBUF, linux would pre-allocate
> buffers and drop any autotuning. Doesn't the above behavior count as
> autotuning?


Linux also starts all connections with a small advertised window.  It 
only grows the window after observing the ratio of data to overhead in 
received packets.  If it receives only small packets from the sender 
with a high overhead ratio, it will only open the window just far enough 
that it doesn't overflow the receive buffer.  This algorithm (look for 
rcv_ssthresh in the code) controls the advertised window given a receive 
buffer size.  This is separate from autotuning, which adjusts the buffer 
size.  You're correct that autotuning is disabled when SO_RCVBUF is set, 
but the "receive slow-start" is always used.

   -John

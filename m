From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of
 timestamps?
Date: Tue, 04 Mar 2014 10:50:59 -0800
Message-ID: <53162093.1040208@hp.com>
References: <53151E55.9000503@hp.com> <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:2839 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbaCDSvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:51:01 -0500
In-Reply-To: <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 07:22 PM, John Heffner wrote:
> Running with such a large window scale and no timestamps (PAWS
> protection) is generally not a great idea, but I don't think is part
> of the issue here.

OK.  I'll look for other, additional sticks with which to beat the 
provider of the system that doesn't do timestamping :)

> If you look where things really go wrong, the receiver is sending
> anomalous SACK blocks that will trigger the SACK renege handling path.
>   Reneging triggers go-back-n behavior, so we see the spurious
> retransmits from there on.

Should those subsequent ACKs be clocking-out additional retransmissions 
like they appear to do? (Assuming I'm not projecting into the trace) Or 
is that an unavoidable consequence of there being no timestamps with 
which to tell which send was being ACKed?

> The most notable bad segment is this one:
> 18:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.],
> ack 3171368, win 32716, options [nop,nop,sack 1 {3171368:3177208}],
> length 0
> It contains a SACK block contiguous with the acked seqno.

I've gone back through one of the other traces and found the same thing 
therein.

> There is some other strangeness just before that, where the SACK
> block shrinks then grows again.

That would be this yes?

15:20:46.798816 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq 
3660468:3661928, ack 4262, win 297, length 1460
15:20:46.799027 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack 
3168256, win 32081, options [nop,nop,sack 1 {3171368:3172828}], length 0
15:20:46.799042 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq 
3661928:3664848, ack 4262, win 297, length 2920
15:20:46.799465 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack 
3169716, win 32241, options [nop,nop,sack 1 {3171368:3172828}], length 0
15:20:46.799479 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq 
3664848:3666308, ack 4262, win 297, length 1460
15:20:46.799497 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack 
3169716, win 32241, options [nop,nop,sack 1 {3171368:3174288}], length 0
15:20:46.799504 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack 
3169716, win 32241, options [nop,nop,sack 1 {3171368:3175748}], length 0
15:20:46.799509 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq 
3666308:3667768, ack 4262, win 297, length 1460
15:20:46.799773 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack 
3171176, win 32491, options [nop,nop,sack 1 {3171368:3172828}], length 0
15:20:46.799787 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq 
3667768:3669228, ack 4262, win 297, length 1460
15:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack 
3171368, win 32716, options [nop,nop,sack 1 {3171368:3177208}], length 0
15:20:46.800081 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq 
3171368:3172828, ack 4262, win 297, length 1460

Might that be packet-reordering in the other direction?  Sadly, I don't 
have good "both sides" traces as the receiving system doesn't seem to 
capture traffic terribly well.  I suppose TCP timestamps might have 
helped answer that question.

> One other thing that jumped out at me is there is no actual loss, just
> reordering.

That was interesting wasn't it - calling it the "Big Bad Internet (tm)" 
I was expecting to see *some* actual packet loss.   Though in this case 
the traffic, while going across the continental US, may not have been 
crossing Internet providers.

thanks muchly,

rick jones

>
>    -John
>
> On Mon, Mar 3, 2014 at 7:29 PM, Rick Jones <rick.jones2@hp.com> wrote:
>> I've been looking at some packet traces of an application looking to upload
>> a Large Quantity (tm) of data to a server across the Big Bad Internet (tm).
>> They've been Linux senders, and the destination while supporting SACK and
>> window scaling does not support TCP timestamps. (TCP timestamp support was
>> requested of the supplier of said server many many months ago now.)
>>
>> This destination system has been issuing RSTs at seemingly random points in
>> the middle of a large fraction of the attempted transfers.  In looking at
>> the traces, they all seem to be variations on the theme of what is shown by:
>>
>> ftp://netperf.org/retrans_question/for_netdev.png
>>
>> which is a passing of ftp://netperf.org/retrans_question/for_netdev.pcap
>> through tcptrace -nG and zoomed-in to the end.  I've seen this with a 3.2.0
>> kernel as the sender, have reports of it happening with whatever is in
>> Fedora Core 20, and the traces above are from a 3.11.0 kernel as the sender.
>>
>> The large quantity of (likely) unnecessary retransmissions shouldn't be
>> triggering a RST by the receiver, but the failures consistently show that
>> and I was wondering if the (spurious) retransmissions were perhaps
>> "encouraged" (so to speak) by the lack of TCP Timestamps.
>>
>> happy benchmarking,
>>
>> rick jones
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

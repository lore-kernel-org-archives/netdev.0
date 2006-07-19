From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Wed, 19 Jul 2006 12:00:40 +0200
Message-ID: <44BE02C8.5030709@kom.aau.dk>
References: <44BD38B1.1080807@kom.aau.dk> <7335583a0607190238x782a5c37pd4f62830e52ec65a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:65180 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S964781AbWGSKAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 06:00:43 -0400
To: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
In-Reply-To: <7335583a0607190238x782a5c37pd4f62830e52ec65a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I am using an emualtor that I developed using netfilter (see 
http://kom.aau.dk/~oumer/publications/VTC05.pdf for a description of the 
emulator).. and I emualte a UMTS network with RTT of 150ms, and I use a 
384kbps connection. There is UMTS frame erasure rate of 10%, but I have 
persistant link layer retransmission, which means nothing is actually 
lost. So due to this link layer errors, some packets arrive out of order 
and the effect of that on tcp performance is what I am after. I am using 
linux 2.4.

I have put more detailed traces  at
www.kom.auc.dk/~oumer/sackstuff.tar.gz
I have run the different cases 10 times each,

NT_NSACK[1-10].dat---no timestamp, no SACK 
NT_SACK[1-10].dat----no timestamp, SACK
T_NSACK[1-10].dat---timestamp, no SACK
T_SACK[1-10].dat----timestamp. SACK

(by no SACK I mean only SACK, DSACK and FACK disabled, I also have 
results when they are enabled, see below for curves illustrating the 
different cases...)

the files without extension are just two column files that summarize the 
ten runs for the four different cases, the first column in the # 
retransmission, and second column is the download time, the values are 
gathered from tcptrace

the two eps files are just the plot summarizing  the above average 
download time and average retransmission # for each case...

one more thing in the trace files, you will find 3 tcp connections, the 
first one is not modified by my emulator that causes the reordering 
(actually, that is the connection through which I reset the destination 
catch that stores some metrics from previous runs using some commands 
via ssh), the second one is the ftp control channel and the third one is 
the ftp data channel....the emulator affects the last two channels
and causes reordering once in a while.....
please dont hesistate to ask me if anything is not clear...

Also, I have put the final curves of all my emulations showing the 
download times and percentage of retransmissions (#retransmission 
/total  packets sent)
at
www.kom.auc.dk/~oumer/384_100Kbyte_Timestamps_SACK_FACK_DSACK_10FER_DT.pdf
www.kom.auc.dk/~oumer/384_100Kbyte_Timestamps_SACK_FACK_DSACK_10FER_ret.pdf

There are a lot of other things that I dont understand from these two 
curve. However the most bizzare one (apart from the SACK issue that 
started this discussion) is why DSACK leads to increased retransmissions 
when used without timestamps? (the behaviour is ok interms of download 
time as it is reducing it, showing that DSACK base spurious 
retransmission is at work)

Thanks a lot for taking the time

Regards,
Oumer







Xiaoliang (David) Wei wrote:

> Hi Oumer,
>
>    Your result is interesting. Just a few questions (along with your 
> texts):
>
>> So I looked further into the results, and what I found was that when
>> SACK (when I refer to SACK here, I mean SACK only without FACK and
>> DSACK)  is used, the retransmissions seem to happen earlier .
>> at www.kom.auc.dk/~oumer/first_transmission_times.pdf
>> you can find the pic of cdf of the time when the first TCP
>> retransmission occured for the four combinations of SACK and timestamps
>> after hundrends of downloads of a 100K file for the different conditions
>> under network reordering...
>
>
> Could you give a little bit more details on the scenarios. For example:
> What is your RTT, capacity and etc? Linux versions? Packetsize is
> 1.5K? Then 100K is about 66 packets. Do flows finish slow start or
> not? Also, what is the reordering level? Are you using Dummynet or
> real network?
>
>
>> ...but I couldnt figure out why the retransmissions occur earlier for
>> SACK than no SACK TCP. As far as I know, for both SACK and non SACK
>> cases, we need three (or more according to the setting) duplicate ACKs
>> to enter the fast retransmission /recovery state.... which would have
>> resulted in the same behaviour to the first occurance of a
>> retransmission..... or is there some undocumented enhancment in Linux
>> TCP when using SACK that makes it enter fast retransmit earlier... the
>> ony explanation I could imagine is something like this
>
>
> Are you sure FACK is turned OFF? FACK might retransmit earlier if you
> have packet reordering, I think.
>
>
>> non SACK case
>> =============
>> 1 2 3 4 5 6 7 8 9 10..... were sent and 2 was reorderd....and assume we
>> are using delayed ACKs...and we get a triple duplicate ACK after pkt#8
>> is received. (i.e 3&4--first duplicate ACK, 5&6..second duplicate ACK
>> and 7&8...third duplicate ACK.....)...
>>
>> so if SACK behaved like this...
>>
>> 3&4 SACKEd.... 2 packets out of order received
>> 5&6 SACKEd....4 packets out of order received.... start fast
>> retransmission....as reorderd is greater than 3.... (this is true when
>> it comes to marking packets as lost during fast recovery, but is it true
>> als for the first retransmission?)
>
>
> I guess delayed ACK is turned off when there is packet reordering. The
> receiver will send one ack for each data packet whenever there is out
> of order packets in its queue. So we will get duplicate ack ealier
> than what you explain above...
>
>
>> One more thing, say I have FRTO, DSACK and timestamps enabled, which
>> algorithm takes precedence ? if FRTO is enabled, then all spurious
>> timeout detection are done through FRTO or a combination?..
>
>
> They are compatible, I think?
>
> When retransmission timer times out, it first tries to go through
> FRTO. If FRTO found it's a real loss, then it goes to traditional
> timeout process as specified in FRTO algorithm.
>
> -David
>


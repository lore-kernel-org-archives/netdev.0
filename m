From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Wed, 19 Jul 2006 18:32:09 +0200
Message-ID: <44BE5E89.1020002@kom.aau.dk>
References: <44BD38B1.1080807@kom.aau.dk> <20060719132719.GA22143@ms2.inr.ac.ru> <44BE498F.9070001@kom.aau.dk> <20060719154934.GA29877@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:41210 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S1030203AbWGSQc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 12:32:29 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060719154934.GA29877@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Alexey Kuznetsov wrote:

>Condition triggering start of fast retransmit is the same.
>The behaviour while retransmit is different. FACKless code
>behaves more like NewReno.
>  
>
Ok, that is a good point!!  Now at least I can convince myself the CDFs 
for the first retransmissions showing that SACK leads to earlier 
retransmissions than no SACK are not wrong....and I can even convince 
myself that this is the real reason behind sack/fack's performance 
degredation for the case of no timestamps,:-)... ...

>>and it is disabled only when reordering is detected (and this is done 
>>either through timestamps or DSACK, right?)...
>>so if neither DSACK and timestamps are enabled we are unable to detect 
>>disorder, so basically there should be no difference between SACK and 
>>FACK, cause it is always FACK used... and that seems to make sense  from 
>>the results I have 
>>    
>>
>
>Yes. But FACKless tcp still retransmits less aggressively.
>
>  
>
>>the # of retransmissions increases as shown in the second figure? isnt 
>>that odd? shouldnt it be the other way around?
>>    
>>
>
>The most odd is that I see no correlation between #of retransmits
>and download time in you graphs. Actually, the correlation is negative. :-)
>
>  
>
yeah, that was what confuses me the most... in
www.kom.auc.dk/~oumer/ret_vs_download.pdf
I have a plot of the summary of runs of two hundrend runs for the four 
combinations of SACK(ON/OFF), timestamps(ON/OFF)
I just collected the retransmission from each run, and averaged the 
download time for each retransmission count..... I see no clear 
pattern...so that was why I was focusing more on when retransmissions 
are triggered rather than how many of them are they...because first, the 
earlier you are in the fast recovery phase (if you dont revert it ) the 
more time you spend on congestion avoidance, and it hurts the throughput 
quite a lot, also, the number of times you enter fast retransmit is more 
harmful than that of the number of retransmissions because more 
unncessary retransmissions during a fast recovery costs some bandwidth, 
but it doesnt damage the "future" of the connection as much as a 
retransmission that drives tcp into fast recovery....

>>Also why does the # retransmissions in the timestamp case increases when 
>>we use SACK/FACK as compared with no SACK case?
>>    
>>
>
>Excessive retransmissions still happen. Undoing just restores cwnd
>and tries to increase reordering metric to avoid false retransmits.
>
>  
>
Hmmm... I dont understand this....so if reording can be detected, (i.e 
we use timestamps, DSACK), the dupthreshold is increased temporarily? Ok 
this adds to the explanation of  why the retransmissions are
less in the timestamp case than in the non timestamp case (in addition 
to the fact that with timestamps, we get out of fast recovery earlier 
than non timestamps case, and hence also less retransmissions)...but 
what I was referring to was if you use timestamps then why the increase 
in the number of retransmissions when we use FACK, SACK or DSACK as 
compared to the no SACK case...Is this dupthreshold increase documented 
somewhere properly? in the linux congestion paper by you and Pasi , you 
mention it briefly in section 5 "linux fast recovery does not fully 
follow RFC 2582.. the sender adjusts the threshold for triggering fast 
retransmit dynamically, based on the observerd reordering in the 
network..." but it doesnt exactly say how this dynamic adjustment is 
done ....

>1. Suppose, some segments, but not all, were delayed.
>2. Senders sees dupack with a SACK. It is the first, SACK allows to open
>   window for one segment, you send one segment with snd.nxt.
>3. Receivers receives it before delayed segments arrived.
>4. When senders sees this SACK, it assumes that all the delayed
>   segments are lost.
>  
>
Thanks! it is very clear now.! but it is basically the same effect (for 
the explanation that I am seeking)...as the trace you quoted, right, two 
duplicate acks leading to retransmission....

>>OK ...but if timestamps are enabled, then I just couldnt figure out the 
>>use of  DSACK, can it tell us something more than we can find using 
>>timestamps??
>>    
>>
>
>It depends. Normally, no. If the network is fast, timestamps are just
>too coarse to detect redundant retransmissions.
>
>Plus, the heuristcs based on timestamps essentially relies on a bug
>in our timestamps processing code. Another side could have it fixed. :-)
>  
>
Ok, for my studies it shouldnt matter because I am using the buggy code 
on both the sender and receiver.. :-) (though I dont understand what 
this bug you are referring to is about :-)....

>Alexey
>  
>



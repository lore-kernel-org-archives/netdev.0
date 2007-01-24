From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH	REPOST	1/2]	NET:	Accurate	packet	scheduling	for	ATM/ADSL
 (kernel)
Date: Wed, 24 Jan 2007 17:38:39 +0100
Message-ID: <45B78B8F.9090106@trash.net>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>	 <1161602527.5502.155.camel@ras.pc.stuart.local>	 <453CB801.4010902@trash.net>	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>	 <456ED79E.2070707@trash.net> <1169075223.7560.15.camel@ras>	 <45AEF219.2060304@trash.net> <1169100970.21535.18.camel@ras>	 <45AF5C02.1010005@trash.net> <1169176280.1118.8.camel@ras>	 <45B0B744.7070800@trash.net> <1169263517.11507.14.camel@ras>	 <45B1D715.8010609@trash.net> <1169365528.3866.71.camel@ras.pc.stuart.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Russell Stuart <russell-tcatm@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57991 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbXAXQin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 11:38:43 -0500
In-Reply-To: <1169365528.3866.71.camel@ras.pc.stuart.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Sat, 2007-01-20 at 09:47 +0100, Patrick McHardy wrote:
> 
>>Russell Stuart wrote:
>>
>>>b.  There is no compatibility problem.
>>
>>Again, (b). You seem to have something in mind, it would be
>>easier if you would just explain exactly where you think there
>>is a problem.
> 
> 
> I though I had :(.
> 
> Consider:
>   Line speed is 256 K bits/sec.
>   Protocol: ADSL/ATM (PPPoE VC/LLC) (Overhead is 42 bytes + cell pad).
>   Kernel HZ is 1000.
>   cell_log = 8.
> 
> Below is a table which shows the RTAB that would be sent
> to a pre-STAB kernel:
> 
>               IP Datagram   Packet Size       Packet Size   Ticks to
>               Packet Size   Seen by Kernel    On the Wire   Send packet
>   RTAB[0]=2    -14..-7          0..7             53..53       1.656
>   RTAB[1]=2     -6..1           8..15            53..53       1.656
>   RTAB[2]=3      2..9          16..23            53..106      3.313
>   RTAB[3]=3     10..17         24..31           106..106      3.313
>    ...  
>   RTAB[9]=5     58..63         72..79           106..159      4.968
>   RTAB[10]=5    64..71         80..87           159..159      4.968
> 
> Below is the same thing for a post-STAB kernel:
> 
>               IP Datagram   Packet Size       Packet Size   Ticks to
>               Packet Size   Seen by Kernel    On the Wire   Send packet
>   RTAB[0]=0 - Undefined as no STAB entry is 0.
>   RTAB[1]=0 - Undefined as no STAB entry is 0.
>    ...
>   RTAB[5]=0 - Undefined as no STAB entry is 0.
>   RTAB[6]=2    -14..-7          0..7             53..53       1.656
>   RTAB[7]=2     -6..1           8..15            53..53       1.656
>   RTAB[8]=3      2..9          16..23            53..106      3.313
>   RTAB[9]=3     10..17         24..31           106..106      3.313
>    ...  
>   RTAB[15]=5    58..63         72..79           106..159      4.968
>   RTAB[16]=5    64..71         80..87           159..159      4.968
> 
> The two RTAB's are different.  Thus you must send 
> different RTAB's to pre-STAB and post-STAB kernels.  
> How is "tc" to decide which one to send?  I did add 
> code that checked uname once to solve a very 
> similar problem in "tc", but that got my wrist 
> slapped.

If the users asks to use STABs, send the modified RTAB.
If the kernel doesn't support STABs it will return an error,
which is good enough.

> Replacing RTAB with STAB would solve the problem, BTW,
> as the post-STAB kernel would ignore the RTAB.
> 
> It would also solve another problem.  The granularity
> of RTAB sucks for VOIP (my area of interest).  Eg on
> a 2 M bit link, one ATM cell takes 0.0848 ticks to 
> send, two cells 0.170 ticks, three cells 0.2544 ticks.  
> RTP voice packets are typically two or three cells.  
> RTAB only holds an integral number of ticks of course, 
> making the current traffic control engine useless for 
> VOIP links with speeds of around 2.5M bit or above.
> This could be fixed in an STAB implementation.

I think this is a different problem. If you replace RTABs
by STABs you again can't use it for anything that is only
interested in the size, not the transmission time (HFSC,
SFQ, ...).

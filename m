From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: why are there messages like assertion ((int)tcp_packets_in_flight(tp)...
Date: Wed, 26 Mar 2008 23:30:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803262246460.14579@kivilampi-30.cs.helsinki.fi>
References: <18406.49168.311576.570515@fisica.ufpr.br>
 <Pine.LNX.4.64.0803261353100.24534@kivilampi-30.cs.helsinki.fi>
 <18410.25779.32254.261486@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-797132128-1206564814=:14579"
Cc: Netdev <netdev@vger.kernel.org>
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58873 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbYCZVas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 17:30:48 -0400
In-Reply-To: <18410.25779.32254.261486@fisica.ufpr.br>
Content-ID: <Pine.LNX.4.64.0803262318380.11089@svm-3.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-797132128-1206564814=:14579
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803262318381.11089@svm-3.cs.Helsinki.FI>

On Wed, 26 Mar 2008, Carlos Carvalho wrote:

> Ilpo Järvinen (ilpo.jarvinen@helsinki.fi) wrote on 26 March 2008 14:57:
>  >On Sun, 23 Mar 2008, Carlos Carvalho wrote:
>  >
>  >> We get these messages in the log from time to time:
>  >> 
>  >> assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at net/ipv4/tcp_input.c (1274)
>  >> 
>  >> What do they mean? Is there a way to get rid of them?
>  >
>  >> They usually appear at high net traffic periods.
>  >
>  >Your mail is lacking key bit of information:
>  >- What kernel version you're using?
> 
> 2.6.22.18.
>  >- Is this only message?
> 
> Yes.
> 
>  >Especially I'm interested in if Leak printouts show up, but more
>  >complete snippet of the log wouldn't hurt (I don't need all those
>  >boot up details though :-)).
> 
> I don't know what you mean by leak but there aren't any other
> messages.

Since there aren't any other messages, it very likely equals to the case 
I already debugged enough to analyze its effect...

>  >It may mean a number of things. Basically packet counting is not that 
>  >accurate as it should, whether that's causing bad things or not, it 
>  >depends...
>  >
>  >...In case it's something before 2.6.24, there's one potential patch 
>  >available in archives adding one clearly missing left_out adjustment. 
> 
> Could you point it to me? I cannot upgrade now because I also use the
> vserver patch. I cannot test without it because this message only
> appears when net traffic is high enough, and this is our only machine
> in this condition.

http://marc.info/?l=linux-netdev&m=119910263911111&w=2

...I think it should apply cleanly to 2.6.22 as well.

>  >Nobody has confirmed that it actually silences the message nor I've a 
>  >clear theory how it could cause this. In the case that was debugged 
>  >(either 2.6.22 or 2.6.23, I don't remember anymore in which), this message 
>  >was found to occur in a rather harmless situation, ie., when no packets 
>  >are outstanding. Unless they occur in sheer number spamming your logs, 
>  >it's not that big problem.
> 
> In the last 3 days it appeared 6 times, so it's rare.
> 
> I'm reporting because I don't know what it means and it could be a bug.

This gets reported when TCP's packets_out (outstanding packets) was 
already zero, when ACK arrived with some SACK info. The left_out, for some 
not verified reason, is left to a value which is different from zero, ie., 
it "claims" that TCP has some packets whose state is known (either sacked 
or decided lost) which obviously is inconsistent. However, the left_out 
gets resynchronized early enough for this to not be a problem.

But yes, the cause for left_out inconsistency is caused by some unknown 
bug (which has very likely existed for ages), probably some odd 
tcp_fragment corner case I wasn't able to figure out by reading the code 
(some old ACK or ACK reordering). The reason this message started to 
appear was that I added some skipping to sack processing which synched it, 
and that syncing there was meant to update sack processing changes, not to 
fix some previous ACK inconstency. So that syncing was just hiding the 
inconsistency. But as it seems to only occur when packets_out is zero and 
due to drop of left_out in the later kernels, I haven't put too much 
effort into it, esp. because of the existance of the unconfirmed left_out 
patch I pointed out above.


-- 
 i.
---696243703-797132128-1206564814=:14579--

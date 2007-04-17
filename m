From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: + ppp_generic-fix-lockdep-warning.patch added to -mm tree
Date: Tue, 17 Apr 2007 08:26:32 -0500
Message-ID: <4624CB08.2070005@earthlink.net>
References: <20070411000932.1f00f395.akpm@linux-foundation.org> <028701c77c16$bcd68a90$0202fea9@Jura> <20070417073744.GA1976@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Yuriy N. Shkandybin" <jura@netams.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	Michal Ostrowski <mostrows@speakeasy.net>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:43237 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327AbXDQN0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 09:26:53 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HDRjI9018536
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 09:27:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HDQqeE551376
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 09:26:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HDQZ0T010553
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 09:26:36 -0400
In-Reply-To: <20070417073744.GA1976@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "xmit" function of a PPP channel is a synchronous operation.  If the 
transmission fails, we must notify the caller and let them re-submit the 
skb later.  The return status of dev_queue_xmit is needed to determine 
the return code passed back to the caller and thus the call is made 
synchronously and not in a tasklet.

Looking at the stack traces earlier in this thread, it seems to me that 
even if the PPPoE call was made in a tasklet, this same warning could be 
generated.

--
Michal Ostrowski
mostrows@earthlink.net



Jarek Poplawski wrote:
> On Wed, Apr 11, 2007 at 12:52:28PM +0400, Yuriy N. Shkandybin wrote:
> ...
>>> On Wed, 11 Apr 2007 09:57:33 +0400 "Yuriy N. Shkandybin" <jura@netams.com> 
>>> wrote:
>>>
>>>> I've tested  2.6.21-rc6-mm1
>>>> Linux vpn1 2.6.21-rc6-mm1 #4 SMP Wed Apr 11 03:34:26 MSD 2007 x86_64
>>>> Intel(R) Pentium(R) D CPU 2.80GHz GenuineIntel GNU/Linux
>>>>
>>>> warn appeares upon first pppoe connection to rp-pppoe server in kernel 
>>>> mode
>>>>
>>> Thanks.  So you're saying that
>>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.21-rc6/2.6.21-rc6-mm1/broken-out/ppp_generic-fix-lockdep-warning.patch
>>> did not fix anything?
>> As i understand this patch already in -mm tree, so I've booted into last mm 
>> kernel and received this locked warning.
>> Or i've mistaked and should apply this patch manually?
> 
> Hi!
> 
> Yuriy - thanks for testing my patch ...(pause) Not!
> 
> It seems this patch is not visible in this version - probably
> is overpatched by something else. But your new log shows there
> is another connection between these locks (ppp_xmit_process
> and ppp_push instead of ppp_channel_push in "-> #0"), so the
> patch is not sufficient (and could be dumped).
> 
> I don't know your vlans configuration, but it seems the real
> lockup isn't very probable here - it's rather lockdep question.
> I think vlan's too broad lockdep class is the main "guilty"
> here, but probably pppoe also could be enhanced: it's making
> the things unnecessarily complicated by calling dev_queue_xmit
> under ppp_generic's xmit locks. I wonder if there is any reason
> against using a tasklet here.
> 
> I'll try to find more time to untie this yet - or maybe some
> maintainer will find this interesting, too...
> 
> Regards,
> Jarek P.
> 
> PS: sorry for late responding (vacations).
> 
> 

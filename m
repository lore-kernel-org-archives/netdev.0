From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Fri, 08 Jan 2010 11:40:25 -0500
Message-ID: <4B475FF9.7000702@majjas.com>
References: <4B458B36.6050509@majjas.com> <20100107074756.GB6258@ff.dom.local>
 <4B459368.2000503@majjas.com> <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local> <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local> <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local> <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Berck E. Nash" <flyboy@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753963Ab0AHQlA@vger.kernel.org>
In-reply-to: <20100108074539.GA6205@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/8/2010 2:45 AM, Jarek Poplawski wrote:
> On Thu, Jan 07, 2010 at 06:11:34PM -0500, Michael Breuer wrote:
>    
>> Results:
>> ...
>> Jan  7 15:44:44 mail kernel: Pid: 0, comm: swapper Tainted: G        W
>>      
> BTW, was there any other oops saved before this one?
>
> ...
>    
Nope - just the one.
>> --- adapter dead after this --- rebooted.
>> * no MMAP; alternative 1 patch, mtu=1500; no errors; sustained transfer
>> rates about 25% lower than what I saw with mmap enabled...(before MMAP
>> enabled crashed).
>>      
> ?? Read below...
>
>    
>> * no MMAP mtu=9000; ran ok at low transfer rates - when high rates
>> kicked in, got the sky2 interrupt error&  things went south:
>> Jan  7 15:09:28 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x40000008
>> Jan  7 15:09:28 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x40000008
>> After this, remote connections broke and I rebooted... decided to rerun
>> w/o MMAP again before going back to MMAP and trying those other sky2
>> options...
>> * Retest of no MMAP + Alternative 1 - just to confirm consistency.
>> Worked - no errors. Only version so far that allows the win7 backup to
>> complete.
>>      
> ??? Hmm... Alternative 1 or 2 doesn't even compile into when no MMAP,
> so it definitely needs re-retesting ;-)
>    
I see your point. I'm pretty sure that run failed miserably. Perhaps 
something else is going on - some sort if intermittent thing that just 
got caught there... have one thought - see below.
>    
>> * MMAP + NO DMAR + disable_msi=1... also works w/o errors... leaving
>> this one running for a while - also completed a backup successfully.
>> Fastest of the lot... about 3x faster than any other version, working or
>> not.
>>      
> Very interesting. It would be nice to give it a really long try, and
> if still true, try MMAP + NO DMAR only.
>    
Still up - no kernel errors reported. There was a large dropped packet 
rate  (RX) which seems to actually correlate with DNS format error 
messages (ipv6 only). I spent some time tracking those down. 
Interestingly, most pointed back to one netblock & one ISP (0qf.ru). I 
blocked that domain and the errors expectedly dropped - as did the RX 
dropped packet rate.  Since booting this version yesterday eth0 shows 
1752944 dropped packets. 1752939 of those happened before I blocked the 
domain about 8 hours ago. I have run load tests since as well.

I think this dns activity is sendmail attempting to validate spam - but 
not 100% sure yet as I can't correlate the .ru domain with anything 
sendmail has reported. I'm running a sniffer now hoping to catch the 
next one. I *think* but can't prove, that these are coming in via 
sendmail - i.e., bad email, not even spam really - just enough to get a 
system configured to do dns lookups as part of spam filtering to connect 
to the server in question. What comes back would seem to be corrupt ipv6 
packets.

This gets us back somewhat to Berck Nash's reported problem. His report 
of sky2 failure was due to external attack. Could this be related? Is it 
possible that absent some set of the patches & config settings in this 
version that ipv6 bind activity involving corrupt (perhaps 
intentionally) packets is breaking something?

Will try rerunning without disable_msi later (after I catch the dns 
thing in the sniffer).
>    
>> I'm leaving this one running for now. Not retesting jumbo for now. Be
>> happy to help dig further.
>>
>> Tentative recommendations:
>>
>> 1) The af alternative patch seems rather necessary. First alternative
>> seems to be working, I'd suggest that be submitted and backported to
>> 2.6.32.
>> 2) Steven's pskb_may_pull patch also ought to be included and backported.
>> 3) Jumbo frame support for yukon2 should probably be disabled until/if
>> fixed.
>> 4) When possible I'll test dmar and disable_msi, and no dmar and no
>> disable_msi. When I first hit issues, I was running without DMAR, but
>> also without the above patches. I suppose the non-working permutations
>> need to be either fixed or invalidated (or well documented).
>> 5) It would be nice if someone with comparable hardware could reproduce
>> these issues. FWIW, I can only recreate the crash running windows backup
>> to a cifs share. Copying large files doesn't seem to do it.  Could also
>> be some other interaction going on here that perhaps others aren't
>> running - would be happy to compare notes.
>>
>> Notes:
>> This *could* be coincidental, but maybe not...
>> With MMAP+NO DMAR + disable_msi there are far fewer ... actually almost
>> no... bind error reports... and no bind format error messages. With
>> NOMMAP and alternative one there are a few more bind error messages and
>> one format error message during the several hours that version was up.
>> All other configurations going back perhaps for two weeks have
>> significantly more bind error reports - and all versions show increasing
>> frequency of bind format errors (IPV6 only) in the roughly 10-15 minutes
>> preceding the lockup/crash/interrupt error messages. There are none
>> immediately preceding any crash, but perhaps there is some correlation
>> between the network errors and bind ipv6 packets.
>>      
> OK, for now let's make sure this MMAP + NO DMAR + disable_msi is
> really really working.
>    
Still running :)
> Thanks,
> Jarek P.
>    

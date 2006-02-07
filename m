From: Horms <horms@verge.net.au>
Subject: Re: [PATCH][RFC] Shrink ip_vs_*.c includes
Date: Tue, 7 Feb 2006 04:00:49 +0000 (UTC)
Message-ID: <ds961g$t85$1@sea.gmane.org>
References: <43E69CE1.2030204@drugphish.ch>
	<20060206091319.GH27206@verge.net.au> <43E7163D.7080506@tac.ch>
	<ds7787$lnr$1@sea.gmane.org> <43E725E5.7080400@tac.ch>
Reply-To: "LinuxVirtualServer.org users mailing list." <lvs-users@LinuxVirtualServer.org>
Cc: netdev@vger.kernel.org
Return-path: <lvs-users-bounces@LinuxVirtualServer.org>
To: lvs-users@LinuxVirtualServer.org
List-Unsubscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=unsubscribe>
List-Archive: <http://www.in-addr.de/pipermail/lvs-users>
List-Post: <mailto:lvs-users@LinuxVirtualServer.org>
List-Help: <mailto:lvs-users-request@LinuxVirtualServer.org?subject=help>
List-Subscribe: <http://www.in-addr.de/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@LinuxVirtualServer.org?subject=subscribe>
Sender: lvs-users-bounces@LinuxVirtualServer.org
Errors-To: lvs-users-bounces@LinuxVirtualServer.org
List-Id: netdev.vger.kernel.org

In gmane.comp.linux.lvs.user Roberto Nibali <ratz@tac.ch> wrote:
>>>> CONFIG_IP_VS=m
>>>> # CONFIG_IP_VS_DEBUG is not set
>>>> CONFIG_IP_VS_TAB_BITS=12
>>>> CONFIG_IP_VS_PROTO_TCP=y
>>>> CONFIG_IP_VS_PROTO_UDP=y
>>>> CONFIG_IP_VS_PROTO_ESP=y
>>>> CONFIG_IP_VS_PROTO_AH=y
> 
> These 'y' caused me to think that it wasn't modular.

Me too :)

>>>> CONFIG_IP_VS_RR=m
>>>> CONFIG_IP_VS_WRR=m
>>>> CONFIG_IP_VS_LC=m
>>>> CONFIG_IP_VS_WLC=m
>>>> CONFIG_IP_VS_LBLC=m
>>>> CONFIG_IP_VS_LBLCR=m
>>>> CONFIG_IP_VS_DH=m
>>>> CONFIG_IP_VS_SH=m
>>>> CONFIG_IP_VS_SED=m
>>>> CONFIG_IP_VS_NQ=m
>>>> CONFIG_IP_VS_FTP=m
>>> Ok, this is m/y mixed. Haven't tried it yet.
>> 
>> Actually, I think that its completely modular.
> 
> So why the heck didn't it trigger on my system? Is it because the
> include/net/* headers are not always included on ia64? Well, tant pis!

I can reproduce the problem on x86 too.

>>> I'll reproduce it with your config. I didn't think of trying it with
>>> mixed y/m settings. Following include is missing then:
>>>
>>> #include <linux/seq_file.h>
>> 
>> Thanks, I found that linux/module.h was also needed.
> 
> Ok. I thought this would get included by any of the other headers. Well,
> so long as it also compiles fine on your system, I'm good.
> 
>> After putting those two back into ip_vs_conn.c the build went 
>> find. I also tried a few other combinations, all on ia64, without issue.
>> My diff is below. Could you recheck it?
> 
> Seems fine to me, thanks for testing this. I would have felt really bad
> if I broke IPVS in mainline because of such changes.
> 
>>> Or do you think we could put all the needed includes into ip_vs.h and
>>> simply be done with it?
>> 
>> I spoke breifly with Dave about this, and he isn't very keen on it.
> 
> Fair enough.
> 
>> The problem with that approach, is that while its less work to
>> maintain the headers by hand, it will likely result in uneeded
>> includes in some cases.
> 
> How so? All includes nota bene have the prevailing:
> 
> #ifndef _FOOBAR_H
> #define _FOOBAR_H
> [...]
> #endif  /* _FOOBAR_H */
> 
> framework. So would this speak slightely against that? 

I dare say that they do. However thats actually not the issue at hand.
The problem is, lets say that a.h is listed in ip_vs.h because
some of ipvs/*.c need it. Well, a.h is going to end up inclded in
all of ipvs/*.c, even the ones that don't need it, and thus would
otherwise not have it (assuming that we prune things by hand,
as you have done). So if a.h gets touched, for some reason,
then all of ipvs/*.c will be recompiled, some of which is not
neccessary.

This of course assumes that there is some variance in the includes
needed by the ipvs/*.c files. I think that is a fair assumption, though
I haven't done any analysis on it. Its also a reasonable expectation
that this could be the case in the future, even if it is not the case
now.

> Also, from the
> includes we take today, I reckon that in the end we half of the
> include/{net,linux}/*.h is in our objects :). But you guys decide. I
> could maybe run a call-graph.

Thats a slightly different issue. Perhaps the headers should be cleaned
up a little. But at least by taking the approach that your current patch
does, IPVS can get the benifit of any subsequent cleanups, rather than
partially annuling them.

>> So all of LVS will get built when
>> a given header is touched, where perhaps only half of it needed
>> to be built.
> 
> Well, it does not happen so ofter that a core network related header is
> touched to my avail.

That I would tend to agree with. But Dave seemed to think it is worth
the effort to break the headers out in IPVS, as they currently are.
And I think its reasonable enough.

>> So with that in mind, could you continue in the vein of
>> your original patch?
> 
> Sure thing. Your attached patch is fine; if you feel confident with our
> changes, submit it.

Will do. I'll drop the lvs-users CC as its a closed list whereas
netdev isn't. For the benifit of people who are on lvs-users and not
netdev, the patch will be the same as what I posted yesterday.

-- 
Horms

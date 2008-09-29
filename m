From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 29 Sep 2008 16:27:31 -0400
Message-ID: <20080929202731.GC20074@hmsreliant.think-freely.org>
References: <20080929191254.GA20074@hmsreliant.think-freely.org> <48E138EB.1080001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40096 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbYI2U3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 16:29:35 -0400
Content-Disposition: inline
In-Reply-To: <48E138EB.1080001@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 10:22:03PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>> Hey all-
>> 	We currently have the ability to disable our route cache secret int=
erval
>> rebuild timer (by setting it to zero), but if we do that its possibl=
e for an
>> attacker (if they guess our route cache hash secret, to fill our sys=
tem with
>> routes that all hash to the same bucket, destroying our performance.=
  This patch
>> provides a backstop for that issues.  In the event that our rebuild =
interval is
>> disabled (or very large), if any hash chain exceeds ip_rt_gc_elastic=
ity, we do
>> an emergency hash rebuild.  During the hash rebuild we:
>> 1) warn the user of the emergency
>> 2) disable the rebuild timer
>> 3) invalidate the route caches
>> 4) re-enable the rebuild timer with its old value
>>
>> Regards
>> Neil
>
> This sounds not good at all to me.
>
> 1) Dont set ip_rt_secret_interval to zero, this is plain silly, since
>   you give attackers infinite time to break your machine.
>
> To quote Herbert (who allowed to set this interval to 0)
>
>    "Let me first state that disabling the route cache hash rebuild
>     should not be done without extensive analysis on the risk profile
>     and careful deliberation.
>
>     However, there are times when this can be done safely or for
>     testing.  For example, when you have mechanisms for ensuring
>     that offending parties do not exist in your network."
>
Thats really rather the motivation behind this.  The patch that Herbert
submitted with that commit explicitly lets one disable their rebuild ti=
mer.  I
agree its stupid to do that, but we added code to allow it.  This provi=
des a
patch to help people who are victimized because they've done exactly th=
is
(additionaly providing them a warning to stop doing it).


>
> 2) Many machines have ip_rt_gc_elasticity set to 2,
>   because they have a huge hash table, but low chain depths.
Ok, that seem reasonable, and this isn't going to disallow that.  By th=
e same
resoning, people who have huge hash tables, and low chain depths won't
want their low chain length being violated, would they?  This patch wil=
l warn
them if their assumptions are being violated.

Neil


--=20
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 0/3] Gianfar byte queue limits
Date: Sun, 18 Mar 2012 16:50:06 -0400
Message-ID: <CAP=VYLog_HLBETu=t9NmgAB90LJWON14XbXnEroa6d=0Rwg63w@mail.gmail.com>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
	<1332102634.3647.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:62984 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab2CRUuI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 16:50:08 -0400
Received: by lbbgm6 with SMTP id gm6so2906119lbb.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 13:50:06 -0700 (PDT)
In-Reply-To: <1332102634.3647.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 18, 2012 at 4:30 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le dimanche 18 mars 2012 =E0 12:56 -0400, Paul Gortmaker a =E9crit :
>> The BQL support here is unchanged from what I posted earlier as an
>> RFC[1] -- with the exception of the fact that I'm now happier with
>> the runtime testing vs. the simple "hey it boots" that I'd done
>> for the RFC. =A0Plus I added a couple trivial cleanup patches.
>>
>> For testing, I made a couple spiders homeless by reviving an ancient
>> 10baseT hub. =A0I connected an sbc8349 into that, and connected the
>> yellowing hub into a GigE 16port, which was also connected to the
>> recipient x86 box.
>>
>> Gianfar saw the interface as follows:
>>
>> fsl-gianfar e0024000.ethernet: eth0: mac: 00:a0:1e:a0:26:5a
>> fsl-gianfar e0024000.ethernet: eth0: Running with NAPI enabled
>> fsl-gianfar e0024000.ethernet: eth0: RX BD ring size for Q[0]: 256
>> fsl-gianfar e0024000.ethernet: eth0: TX BD ring size for Q[0]: 256
>> PHY: mdio@e0024520:19 - Link is Up - 10/Half
>>
>> With the sbc8349 being diskless, I simply used an scp of /proc/kcore
>> to the connected x86 box as a rudimentary Tx heavy workload.
>>
>> BQL data was collected by changing into the dir:
>>
>> =A0 /sys/devices/e0000000.soc8349/e0024000.ethernet/net/eth0/queues/=
tx-0/byte_queue_limits
>>
>> and running the following:
>>
>> =A0 for i in * ; do echo -n $i": " ; cat $i ; done
>>
>> Running with the defaults, data like below was typical:
>>
>> hold_time: 1000
>> inflight: 4542
>> limit: 3456
>> limit_max: 1879048192
>> limit_min: 0
>>
>> hold_time: 1000
>> inflight: 4542
>> limit: 3378
>> limit_max: 1879048192
>> limit_min: 0
>>
>> i.e. 2 or 3 MTU sized packets in flight and the limit value lying
>> somewhere between those two values.
>>
>> The interesting thing is that the interactive speed reported by scp
>> seemed somewhat erratic, ranging from ~450 to ~700kB/s. (This was
>> the only traffic on the old junk - perhaps expected oscillations suc=
h
>> as those seen in isolated ARED tests?) =A0Average speed for 100M was=
:
>>
>> 104857600 bytes (105 MB) copied, 172.616 s, 607 kB/s
>>
>
> Still half duplex, or full duplex ?
>
> Limiting to one packet on half duplex might avoid collisions :)

Ah yes.  It was even in the text I'd had above!

  PHY: mdio@e0024520:19 - Link is Up - 10/Half

Now the slowdown makes sense to me.

Thanks for the review as well.

Paul.

>
>> Anyway, back to BQL testing; setting the values as follows:
>>
>> hold_time: 1000
>> inflight: 1514
>> limit: 1400
>> limit_max: 1400
>> limit_min: 1000
>>
>> had the effect of serializing the interface to a single packet, and
>> the crusty old hub seemed much happier with this arrangement, keepin=
g
>> a constant speed and achieving the following on a 100MB Tx block:
>>
>> 104857600 bytes (105 MB) copied, 112.52 s, 932 kB/s
>>
>> It might be interesting to know more about why the defaults suffer
>> the slowdown, but the hub could possibly be ancient spec violating
>> trash. =A0Definitely something that nobody would ever use for anythi=
ng
>> today. (aside from contrived tests like this)
>>
>> But it did give me an example of where I could see the effects of
>> changing the BQL settings, and I'm reasonably confident they are
>> working as expected.
>>
>
> Seems pretty good to me !
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

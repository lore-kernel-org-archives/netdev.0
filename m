From: Bhaskar Dutta <bhaskie@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Thu, 6 May 2010 17:25:32 +0530
Message-ID: <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:56740 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354Ab0EFLzc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 07:55:32 -0400
Received: by pwi5 with SMTP id 5so1232050pwi.19
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 04:55:32 -0700 (PDT)
In-Reply-To: <1273085598.2367.233.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 6, 2010 at 12:23 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 05 mai 2010 =E0 23:33 +0530, Bhaskar Dutta a =E9crit :
>
>> Hi,
>>
>> TSO, GSO and SG are already turned off.
>> rx/tx checksumming is on, but that shouldn't matter, right?
>>
>> # ethtool -k eth0
>> Offload parameters for eth0:
>> rx-checksumming: on
>> tx-checksumming: on
>> scatter-gather: off
>> tcp segmentation offload: off
>> udp fragmentation offload: off
>> generic segmentation offload: off
>>
>> The bad packets are very small in size, most have no data at all (<3=
00 bytes).
>>
>> After adding some logs to kernel 2.6.31-12, it seems that
>> tcp_v4_md5_hash_skb (function that calculates the md5 hash) is
>> (might?) getting corrupt.
>>
>> The tcp4_pseudohdr (bp =3D &hp->md5_blk.ip4) structure's saddr, dadd=
r
>> and len fields get modified to different values towards the end of t=
he
>> tcp_v4_md5_hash_skb function whenever there is a checksum error.
>>
>> The tcp4_pseudohdr (bp) is within the tcp_md5sig_pool (hp), which is
>> filled up by tcp_get_md5sig_pool (which calls per_cpu_ptr).
>>
>> Using a local copy of the tcp4_pseudohdr in the same function
>> tcp_v4_md5_hash_skb (copied all fields from the original
>> tcp4_pseudohdr within the tcp_md5sig_pool) and calculating the md5
>> checksum with the local =A0tcp4_pseudohdr seems to solve the issue
>> (don't see bad packets for a hours in load tests, and without the
>> change I can see them instantaneously in the load tests).
>>
>> I am still unable to figure out how this is happening. Please let me
>> know if you have any pointers.
>
> I am not familiar with this code, but I suspect same per_cpu data can=
 be
> used at both time by a sender (process context) and by a receiver
> (softirq context).
>
> To trigger this, you need at least two active md5 sockets.
>
> tcp_get_md5sig_pool() should probably disable bh to make sure current
> cpu wont be preempted by softirq processing
>
>
> Something like :
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index fb5c66b..e232123 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1221,12 +1221,15 @@ struct tcp_md5sig_pool =A0 =A0 =A0 =A0 =A0*tc=
p_get_md5sig_pool(void)
> =A0 =A0 =A0 =A0struct tcp_md5sig_pool *ret =3D __tcp_get_md5sig_pool(=
cpu);
> =A0 =A0 =A0 =A0if (!ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_cpu();
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_disable();
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> =A0static inline void =A0 =A0 =A0 =A0 =A0 =A0 tcp_put_md5sig_pool(voi=
d)
> =A0{
> =A0 =A0 =A0 =A0__tcp_put_md5sig_pool();
> + =A0 =A0 =A0 local_bh_enable();
> =A0 =A0 =A0 =A0put_cpu();
> =A0}
>
>
>

I put in the above change and ran some load tests with around 50
active TCP connections doing MD5.
I could see only 1 bad packet in 30 min (earlier the problem used to
occur instantaneously and repeatedly).

I think there is another possibility of being preempted when calling
tcp_alloc_md5sig_pool()
this function releases the spinlock when calling __tcp_alloc_md5sig_poo=
l().

I will run some more tests after changing the  tcp_alloc_md5sig_pool
and see if the problem is completely resolved.

Thanks a lot for your help!
Bhaskar

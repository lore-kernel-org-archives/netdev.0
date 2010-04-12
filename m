From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] rps: add flow director support
Date: Mon, 12 Apr 2010 10:13:03 -0700
Message-ID: <h2m65634d661004121013uf2c86b81ndded3bb138dee7a9@mail.gmail.com>
References: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
	 <z2o65634d661004120634h8336409er33af1fb75c2a9d1b@mail.gmail.com>
	 <u2m412e6f7f1004120727ga219ab9dr75ee522fba6f63c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:56343 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414Ab0DLRNJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 13:13:09 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o3CHD6uK019648
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 19:13:07 +0200
Received: from pvc22 (pvc22.prod.google.com [10.241.209.150])
	by kpbe15.cbf.corp.google.com with ESMTP id o3CHD4GK011108
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 10:13:05 -0700
Received: by pvc22 with SMTP id 22so3313760pvc.25
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 10:13:04 -0700 (PDT)
In-Reply-To: <u2m412e6f7f1004120727ga219ab9dr75ee522fba6f63c6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 12, 2010 at 7:27 AM, Changli Gao <xiaosuo@gmail.com> wrote:
> On Mon, Apr 12, 2010 at 9:34 PM, Tom Herbert <therbert@google.com> wr=
ote:
>> On Sun, Apr 11, 2010 at 2:42 PM, Changli Gao <xiaosuo@gmail.com> wro=
te:
>>> add rps flow director support
>>>
>>> with rps flow director, users can do weighted packet dispatching am=
ong CPUs.
>>> For example, CPU0:CPU1 is 1:3 for eth0's rx-0:
>>>
>> "Flow director" is a misnomer here in that it has no per flow
>> awareness, that is what RFS provides. =C2=A0Please use a different n=
ame.
>
> Flow here is a bundle of flow, not the original meaning. How about
> "rps_buckets" and "rps_bucket_x"?
>

Ideally, this should replace rps_cpus if it's a better interface....
right now these would be conflicting interfaces.

>>
>>> =C2=A0localhost linux # echo 4 > /sys/class/net/eth0/queues/rx-0/rp=
s_flows
>>> =C2=A0localhost linux # echo 0 > /sys/class/net/eth0/queues/rx-0/rp=
s_flow_0
>>> =C2=A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rp=
s_flow_1
>>> =C2=A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rp=
s_flow_2
>>> =C2=A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rp=
s_flow_3
>>>
>> It might be better to put this in its own directory
>
> I have thought that before, but since they control the same data in
> kernel as rps_cpus does, I put them in the same directory.
>
>> and also do it per
>> CPU instead of hash entry. =C2=A0This should result in a lot fewer e=
ntries
>> and I'm not sure how you would deal with holes in the hash table for
>> unspecified entries. =C2=A0Also, it would be nice not to have to spe=
cify a
>> number of entries. =C2=A0Maybe something like:
>>
>> localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_cpu_m=
ap/0
>> localhost linux # echo 3 > /sys/class/net/eth0/queues/rx-0/rps_cpu_m=
ap/1
>>
>> To specify CPU 0 with weight 1, CPU 1 with weight 3.
>>
>
> Your way is more simple and straightforward. My idea has it own advan=
tage:
> 1. control the rate precision through rps_flows.
> 2. do dynamic weighted packet dispatching by migrating some flows fro=
m
> some CPUs to other CPUs. During this operations, only the flows
> migrated are affected, and OOO only occurs in these flows.

It's probably a little more work, but the CPU->weight mappings could
be implemented to cause minimal disruption in the rps_map.  Also, if
OOO is an issue, then the mitigation technique in RFS could be applied
(this will work best when hash table is larger I believe).

Tom

>
> --
> Regards=EF=BC=8C
> Changli Gao(xiaosuo@gmail.com)
>

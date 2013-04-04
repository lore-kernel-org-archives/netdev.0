From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Enable open-lldp DCB support
Date: Thu, 04 Apr 2013 16:54:05 -0700
Message-ID: <515E129D.2020009@gmail.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com> <1365085574-12057-4-git-send-email-ogerlitz@mellanox.com> <515DA342.5020503@intel.com> <515DA579.3050006@mellanox.com> <515DCDF2.8070304@intel.com> <CAJZOPZKms=25WUR5WL0DEZ7yAi=zOKjZEGdO1BQsyJ+tvPMe+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Sagi Grimberg <sagig@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	netdev@vger.kernel.org, amirv@mellanox.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33326 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765000Ab3DDXye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 19:54:34 -0400
Received: by mail-ie0-f181.google.com with SMTP id 17so3683453iea.26
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 16:54:34 -0700 (PDT)
In-Reply-To: <CAJZOPZKms=25WUR5WL0DEZ7yAi=zOKjZEGdO1BQsyJ+tvPMe+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2013 02:18 PM, Or Gerlitz wrote:
>   John Fastabend <john.r.fastabend@intel.com> wrote:
>> On 4/4/2013 9:08 AM, Sagi Grimberg wrote:
>>> On 4/4/2013 6:58 PM, John Fastabend wrote:
>>>> On 4/4/2013 7:26 AM, Or Gerlitz wrote:
>
>>>> Does lldpad work now with the mlx4_en driver?
>>>> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
>
>>> Yes.
>>> -Sagi
>
>> So I looked at your code and lldpad a bit closer. I think this
>> just works around a bug in lldpad. Also with this patch lldpad
>> would try to xmit lldp pkts which would conflict with your firmware agent right?
>
> We don't use firmware agent
>

Ah OK. Your mlx4_en_dcbnl_getdcbx() routine should also return
DCB_CAP_DCBX_HOST then just to be clear. I should write a patch
to clarify those defines I guess.

>
>> For IEEE DCBX modes lldpad should check the return values from
>> the getdcbx dcbnl_rtnl_ops which you already have filled out. I
>> would expect your driver to return DCB_CAP_DCBX_LLD_MANAGED to
>> indicate it is being managed by firmware.
>
>
>> See bnx2x_dcbnl_get_dcbx() for an example of an implementation
>> which I believe is correct. I'll fix the user space lldpad bug.
>
> can you be more specific what's the user space bug?
>

Sure.

In lldpad before the IEEE DCBx (802.1Qaz) TLVs are initialized and the
hardware is managed with the 802.1Qaz module there is a check to verify
the hardware actually supports 802.1Qaz because we don't have a SW
fall back.

Today in lldpad this check is done via a DCB_CMD_GCAP netlink msg. But
this message is really built for the older CEE version of DCBX. In
./include/net/dcbnl.h it is listed in the CEE ops section and it uses
the CEE defines such as *_PG_* instead of including the more precise
*_ETS_* attributes. It also does not give any indication of the
firmware status.

A better check for IEEE support would be to use the getdcbx op via
DCB_CMD_GDCBX which has an explicit define for IEEE/CEE and fw
or host managed.

	#define DCB_CAP_DCBX_HOST               0x01
	#define DCB_CAP_DCBX_LLD_MANAGED        0x02
	#define DCB_CAP_DCBX_VER_CEE            0x04
	#define DCB_CAP_DCBX_VER_IEEE           0x08
	#define DCB_CAP_DCBX_STATIC             0x10

If this check is used your driver would work as is and lldpad would be
able to learn in a single call if (a) the hardware supports DCB (b)
which version CEE or IEEE or both and (c) if the firmware is already
managing DCBX. This reduces driver code somewhat which is a nice thing
and is more precise.

So as a heads up I am planning to fix/improve lldpad to use these bits
and it looks like every driver implementing the IEEE dcbnl ops does in
fact implement the getdcbx op so it should not break any drivers and
be backwards compatible. Meaning running a new lldpad version on an old
kernel will still work.

>> Looks like I added my reveiwed-by line too quickly.
>
> With this patch I can get the following
>
> # lldptool -i eth3 -T -V ETS-CFG
> tsa=0:ets,1:ets,2:ets,3:ets,4:ets,5:ets,6:ets,7:ets
> up2tc=0:0,1:1,2:2,3:3,4:4,5:5,6:6,7:7 tcbw=12,12,12,12,13,13,13,13
> TSA = 0:ets 1:ets 2:ets 3:ets 4:ets 5:ets 6:ets 7:ets
> up2tc = 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7
> tcbw = 12% 12% 12% 12% 13% 13% 13% 13%
>
> # lldptool -i eth3 -t -V ETS-CFG
> IEEE 8021QAZ ETS Configuration TLV
>           Willing: yes
>           CBS: not supported
>           MAX_TCS: 8
>           PRIO_MAP: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7
>           TC Bandwidth: 12% 12% 12% 12% 13% 13% 13% 13%
>           TSA_MAP: 0:ets 1:ets 2:ets 3:ets 4:ets 5:ets 6:ets 7:ets
>
> where without it, an error is returned, so basically, the patch allows
> 1st and most to do gets/sets where without it, it doesn't work,
> anything wrong with that?

Agree it doesn't work without this patch but we can fix it in user
space. This has the nice benefit of letting lldpad work with mlx4 on
older kernels. In general I think its easier to update user space then
the kernel for most users. I'll send you a lldpad patch in a few
moments.

Thanks,
John

>
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation

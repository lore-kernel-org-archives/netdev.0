From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit
 methods
Date: Wed, 20 Jul 2011 09:37:10 -0700
Message-ID: <4E270436.2090303@candelatech.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com> <1311105738.3113.11.camel@edumazet-laptop> <20110719202922.GA2352@minipsycho> <1311108107.3113.22.camel@edumazet-laptop> <20110720001904.GA1992@neilslaptop.think-freely.org> <1311122593.3113.46.camel@edumazet-laptop> <4E2626E1.6030005@candelatech.com> <20110720020737.GB2692@neilslaptop.think-freely.org> <1311135855.3113.66.camel@edumazet-laptop> <20110720151827.GD12349@hmsreliant.think-freely.org> <CAHXqBFKD1bD8uMYOwbhsutT0ZuEiw=7pUDM1hVGpCgrdnV6zAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46009 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab1GTQhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 12:37:31 -0400
In-Reply-To: <CAHXqBFKD1bD8uMYOwbhsutT0ZuEiw=7pUDM1hVGpCgrdnV6zAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2011 08:35 AM, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/7/20 Neil Horman<nhorman@tuxdriver.com>:
>> On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
>>> Le mardi 19 juillet 2011 =C3=A0 22:07 -0400, Neil Horman a =C3=A9cr=
it :
>>>>>
>>>> I think this is a good idea.  It lets pktgen dynamically make the =
clone/share
>>>> decision dynamically and only impacts performance for those system=
s.
>>>>
>>>
>>> Just let pktgen refuse to use clone_skb command for these devices.
>>>
>> copy that, This is by no means final, but what do you think of this?=
  If its
>> agreeable to you, Ben, et al. I can add this to my local tree and st=
art auditing
>> all the drivers that may need to have the flag set.
>>
>> Regards
>> Neil
>>
>>
>> diff --git a/include/linux/if.h b/include/linux/if.h
>> index 3bc63e6..ae904fe 100644
>> --- a/include/linux/if.h
>> +++ b/include/linux/if.h
>> @@ -76,6 +76,7 @@
>>   #define IFF_BRIDGE_PORT        0x4000          /* device used as b=
ridge port */
>>   #define IFF_OVS_DATAPATH       0x8000  /* device used as Open vSwi=
tch
>>                                          * datapath port */
>> +#define IFF_CANT_SHARE_SKB     0x10000 /* Device can't share skbs i=
n tx path */
>>
>>   #define IF_GET_IFACE   0x0001          /* for querying only */
>>   #define IF_GET_PROTO   0x0002
>> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>> index f76079c..bf6d88d 100644
>> --- a/net/core/pktgen.c
>> +++ b/net/core/pktgen.c
>> @@ -1071,6 +1071,9 @@ static ssize_t pktgen_if_write(struct file *fi=
le,
>>                 if (len<  0)
>>                         return len;
>>
>> +               if (pkt_dev->priv_flags&  IFF_CANT_SHARE_SKB)
>> +                       return -EOPNOTSUPP;
>> +
>>                 i +=3D len;
>>                 pkt_dev->clone_skb =3D value;
>>
>
> I would prefer that the flag be inclusive, i.e. it should mark driver=
s
> which can use shared skbs. And it might be better to clone the skb in
> case the flag is disabled to keep functionality working.

The whole point of clone-skb is for speedup due to not allocating
new memory..so if the netdev can't support it, lets just fail instead
of giving user false sense of it working...

User can just use clone-skb value of 0 in that case...

Thanks,
Ben

>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v2 1/2] ip_tunnel: fix ip tunnel lookup in collect_md mode
Date: Wed, 21 Jun 2017 18:40:15 +0800
Message-ID: <3663A9F6-0862-4580-BE82-15C502EA3D25@cmss.chinamobile.com>
References: <1497670031-2971-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAOrHB_AFrCiYGyLdYpeYf7UJPgWuA-VFObGt13tAqoC56+x4=g@mail.gmail.com>
 <B544BC96-63E4-4998-A5EA-36C37DBAA2F6@cmss.chinamobile.com>
 <CAOrHB_Dxha=GY8aUzy2Cg_Js0r3_Z+891uLsi7zSyd5SJ=7JFA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOrHB_Dxha=GY8aUzy2Cg_Js0r3_Z+891uLsi7zSyd5SJ=7JFA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 20 Jun 2017, at 2:08 AM, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Mon, Jun 19, 2017 at 6:13 AM, 严海双 <yanhaishuang@cmss.chinamobile.com> wrote:
>> 
>> 
>>> On 19 Jun 2017, at 1:43 PM, Pravin Shelar <pshelar@ovn.org> wrote:
>>> 
>>> On Fri, Jun 16, 2017 at 8:27 PM, Haishuang Yan
>>> <yanhaishuang@cmss.chinamobile.com> wrote:
>>>> In collect_md mode, if the tun dev is down, it still can call
>>>> ip_tunnel_rcv to receive on packets, and the rx statistics increase
>>>> improperly.
>>>> 
>>>> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
>>>> Cc: Pravin B Shelar <pshelar@nicira.com>
>>>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>>>> 
>>>> ---
>>>> Change since v2:
>>>> * Fix wrong recipient addresss
>>>> ---
>>>> net/ipv4/ip_tunnel.c | 2 +-
>>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>> 
>>>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>>>> index 0f1d876..a3caba1 100644
>>>> --- a/net/ipv4/ip_tunnel.c
>>>> +++ b/net/ipv4/ip_tunnel.c
>>>> @@ -176,7 +176,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
>>>>               return cand;
>>>> 
>>>>       t = rcu_dereference(itn->collect_md_tun);
>>>> -       if (t)
>>>> +       if (t && (t->dev->flags & IFF_UP))
>>>>               return t;
>>>> 
>>> It would be nice if we could increment drop count if tunnel device is not up.
>>> 
>> Hi Pravin
>> 
>> I think it’s not necessary, for example as gre tunnel, if ipgre_rcv fails, it would trigger send an icmp unreachable
>> message:
>> 
>>        if (ipgre_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
>>                return 0;
>> 
>>        icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
>> 
>> Since the tunnel device didn’t touch the packets, so increase drop statistics is not necessary.
>> 
> icmp err packets are not reliable on all networks. device stats are
> much more convenient during debugging connectivity issues.
> 

Okay, if the tunnel device is not up, packets will transfer to fallback tunnel, and if 
the fallback device is up, the RX drops will be increased as expected:

gre0: flags=193<UP,RUNNING,NOARP>  mtu 1476
        inet 172.16.20.1  netmask 255.255.255.0
        unspec 00-00-00-00-00-00-F0-00-00-00-00-00-00-00-00-00  txqueuelen 1000  (UNSPEC)
        RX packets 105  bytes 4522 (4.4 KiB)
        RX errors 0  dropped 105  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

My question is  whether we should increase the drops of original tunnel device 
instead of fallback device?

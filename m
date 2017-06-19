From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v2 1/2] ip_tunnel: fix ip tunnel lookup in collect_md mode
Date: Mon, 19 Jun 2017 21:13:52 +0800
Message-ID: <B544BC96-63E4-4998-A5EA-36C37DBAA2F6@cmss.chinamobile.com>
References: <1497670031-2971-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAOrHB_AFrCiYGyLdYpeYf7UJPgWuA-VFObGt13tAqoC56+x4=g@mail.gmail.com>
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
In-Reply-To: <CAOrHB_AFrCiYGyLdYpeYf7UJPgWuA-VFObGt13tAqoC56+x4=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 19 Jun 2017, at 1:43 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Fri, Jun 16, 2017 at 8:27 PM, Haishuang Yan
> <yanhaishuang@cmss.chinamobile.com> wrote:
>> In collect_md mode, if the tun dev is down, it still can call
>> ip_tunnel_rcv to receive on packets, and the rx statistics increase
>> improperly.
>> 
>> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
>> Cc: Pravin B Shelar <pshelar@nicira.com>
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>> 
>> ---
>> Change since v2:
>>  * Fix wrong recipient addresss
>> ---
>> net/ipv4/ip_tunnel.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>> index 0f1d876..a3caba1 100644
>> --- a/net/ipv4/ip_tunnel.c
>> +++ b/net/ipv4/ip_tunnel.c
>> @@ -176,7 +176,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
>>                return cand;
>> 
>>        t = rcu_dereference(itn->collect_md_tun);
>> -       if (t)
>> +       if (t && (t->dev->flags & IFF_UP))
>>                return t;
>> 
> It would be nice if we could increment drop count if tunnel device is not up.
> 
Hi Pravin

I think it’s not necessary, for example as gre tunnel, if ipgre_rcv fails, it would trigger send an icmp unreachable
message:

	if (ipgre_rcv(skb, &tpi, hdr_len) == PACKET_RCVD)
		return 0;

	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);

Since the tunnel device didn’t touch the packets, so increase drop statistics is not necessary.

Thanks

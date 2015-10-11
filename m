From: Ben Cox <ben@benjojo.co.uk>
Subject: Re: [PATCH] icmp: Fixed bug in raw sockets causing incorrect ICMP
 SNMP counter values
Date: Sun, 11 Oct 2015 23:17:02 +0100
Message-ID: <CAL=9YSVgnCDzZkDM4JujD89V3GpUnDGXyMk7qMnWg7LtmT5G7w@mail.gmail.com>
References: <20151011205528.GA4322@benjojo.co.uk>
	<1444601448.27760.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Cartwright-Cox <ben@benjojo.co.uk>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben+patches@benjojo.co.uk, David L Stevens <dlstevens@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444601448.27760.143.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forgive me for possibly being a little stupid here (This is my first
patch to Linux so I am slightly over my head)

Is this issue not addressed above the file where the following check is done?

if (iphlen > length)
    goto error_free;



On Sun, Oct 11, 2015 at 11:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2015-10-11 at 20:55 +0000, Ben Cartwright-Cox wrote:
>> Sending ICMP packets with raw sockets ends up in the SNMP counters
>> logging the type as the first byte of the IPv4 header rather than
>> the ICMP header (in nearly all cases this is seen as "OutType69".
>> This is fixed by adding the IP Header Length to the casting into
>> a icmphdr struct.
>>
>> Signed-off-by: Ben Cartwright-Cox <ben@benjojo.co.uk>
>> ---
>>  net/ipv4/raw.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
>> index 561cd4b..1ad8bae 100644
>> --- a/net/ipv4/raw.c
>> +++ b/net/ipv4/raw.c
>> @@ -409,7 +409,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
>>       }
>>       if (iph->protocol == IPPROTO_ICMP)
>>               icmp_out_count(net, ((struct icmphdr *)
>> -                     skb_transport_header(skb))->type);
>> +                     skb_transport_header(skb) + iphlen)->type);
>>
>>       err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
>>                     NULL, rt->dst.dev, dst_output_sk);
>
>
> Hmm... This seems to lack checks against a malicious user ?
>
> The only guarantee you have here is that iphlen < length.
>
> It is not enough.
>
> Make sure you do not access not initialized memory or even non existent
> one.
>
>
>

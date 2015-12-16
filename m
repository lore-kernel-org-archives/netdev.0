From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] hv_netvsc: Use simple parser for IPv4 and v6
 headers
Date: Wed, 16 Dec 2015 21:45:25 +0300
Message-ID: <5671B145.2080908@cogentembedded.com>
References: <1450289022-9958-1-git-send-email-haiyangz@microsoft.com>
 <5671AEAE.9080803@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, olaf@aepfle.de, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5671AEAE.9080803@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/16/2015 09:34 PM, Sergei Shtylyov wrote:

>> To avoid performance overhead when using skb_flow_dissect_flow_keys(),
>> we switch to the simple parsers to get the IP and port numbers.
>>
>> Performance comparison: throughput (Gbps):
>> Number of connections, before patch, after patch
>> 1            8.56        10.18
>> 4            11.17        14.07
>> 16            12.21        21.78
>> 64            18.71        32.08
>> 256            15.92        26.32
>> 1024            8.41        15.49
>> 3000            7.82        11.58
>>
>> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
>> Tested-by: Simon Xiao <sixiao@microsoft.com>
>> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
>> ---
>>   drivers/net/hyperv/netvsc_drv.c |   38 +++++++++++++++++++++++++++++---------
>>   1 files changed, 29 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
>> index 1c8db9a..e28951f 100644
>> --- a/drivers/net/hyperv/netvsc_drv.c
>> +++ b/drivers/net/hyperv/netvsc_drv.c
>> @@ -237,20 +237,40 @@ static u32 comp_hash(u8 *key, int klen, void *data,
>> int dlen)
> [...]
>> +    if (iphdr->version == 4) {
>> +        dbuf[0] = iphdr->saddr;
>> +        dbuf[1] = iphdr->daddr;
>> +        if (iphdr->protocol == IPPROTO_TCP) {
>> +            dbuf[2] = *(__be32 *)&tcp_hdr(skb)->source;
>> +            data_len = 12;
>> +        } else {
>> +            data_len = 8;
>> +        }
>> +    } else if (ipv6hdr->version == 6) {
>> +        memcpy(dbuf, &ipv6hdr->saddr, 32);
>> +        if (ipv6hdr->nexthdr == IPPROTO_TCP) {
>> +            dbuf[8] = *(__be32 *)&tcp_hdr(skb)->source;
>> +            data_len = 36;
>> +        } else {
>> +            data_len = 32;
>> +        }
>> +    } else {
>> +        return false;
>> +    }
>
>     This is asking to be a *switch* statement.

    Oops, nevermind. I'd misread the code.

> [...]

MBR, Sergei

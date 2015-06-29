From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC] tun, macvtap: higher order allocations for skbs
Date: Mon, 29 Jun 2015 18:30:27 +0800
Message-ID: <55911E43.6040406@redhat.com>
References: <1434622758-16549-1-git-send-email-mst@redhat.com> <5590CE8D.7030105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbbF2Kaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 06:30:30 -0400
In-Reply-To: <5590CE8D.7030105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/29/2015 12:50 PM, Jason Wang wrote:
>
> On 06/18/2015 06:20 PM, Michael S. Tsirkin wrote:
>> Needs more testing. Anyone see anything wrong with this?
>>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>  drivers/net/macvtap.c | 2 +-
>>  drivers/net/tun.c     | 2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 928f3f4..80e87e4 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -610,7 +610,7 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
>>  		linear = len;
>>  
>>  	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
>> -				   err, 0);
>> +				   err, 1);
>>  	if (!skb)
>>  		return NULL;
>>  
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index cb376b2d..8f2f1e5 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1069,7 +1069,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
>>  		linear = len;
>>  
>>  	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
>> -				   &err, 0);
>> +				   &err, 1);
>>  	if (!skb)
>>  		return ERR_PTR(err);
>>  
> Have a round of netperf testing in tun and ixgbe, can see improvement on
> packet size 512 and 2048.
>
> TX:
> size/session/+thu%/+normalize%
>    64/     1/    0%/    0%
>    64/     4/    0%/    0%
>   512/     1/   +6%/   +7%
>   512/     4/   +2%/   +2%
>  2048/     1/  +24%/  +50%
>  2048/     4/    0%/   +6%
> 16384/     1/    0%/   -6%
> 16384/     4/    0%/   -5%
> 65535/     1/    0%/   -4%
> 65535/     4/    0%/   -1%
> RX:
> size/session/+thu%/+normalize%
>    64/     1/   -5%/   -4%
>    64/     4/   -2%/   -1%
>   512/     1/   -7%/   -8%
>   512/     4/    0%/    0%
>  2048/     1/   +4%/   +7%
>  2048/     4/    0%/   +2%
> 16384/     1/    0%/   +2%
> 16384/     4/    0%/  +13%
> 65535/     1/    0%/    0%
> 65535/     4/    0%/   -1%
> TCP_RR:
> size/session/+thu%/+normalize%
>     1/    25/    0%/    0%
>     1/    50/    0%/    0%
>    64/    25/    0%/   -1%
>    64/    50/    0%/    0%
>   256/    25/    0%/    0%
>   256/    50/    0%/    0%
>

Done another test through pktgen in guest with my tx interrupt patches,
see little regression with this patch:

size/before(pps)/after(pps)
64/578689/573004
8192/332698/322733
16384/241497/237326

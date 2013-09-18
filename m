From: Ansis Atteka <aatteka@nicira.com>
Subject: Re: [PATCH net] ip: generate unique IP identificator if local
 fragmentation is allowed
Date: Wed, 18 Sep 2013 09:50:31 -0700
Message-ID: <CAA=3Oq=Kxfe8KKnWV7QjLnT1Art3UEMJBTE=tXBLZPa6diug6g@mail.gmail.com>
References: <1379456700-8033-1-git-send-email-aatteka@nicira.com>
	<20130918.122018.1088822749792394509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:53912 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752937Ab3IRQuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:50:32 -0400
Received: by mail-ie0-f169.google.com with SMTP id tp5so13675159ieb.0
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 09:50:31 -0700 (PDT)
In-Reply-To: <20130918.122018.1088822749792394509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 18, 2013 at 9:20 AM, David Miller <davem@davemloft.net> wrote:
> From: Ansis Atteka <aatteka@nicira.com>
> Date: Tue, 17 Sep 2013 15:25:00 -0700
>
>> @@ -1317,6 +1317,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
>>               ttl = ip_select_ttl(inet, &rt->dst);
>>
>>       iph = (struct iphdr *)skb->data;
>> +
>>       iph->version = 4;
>>       iph->ihl = 5;
>>       iph->tos = inet->tos;
>> @@ -1324,7 +1325,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
>>       iph->ttl = ttl;
>>       iph->protocol = sk->sk_protocol;
>>       ip_copy_addrs(iph, fl4);
>> -     ip_select_ident(iph, &rt->dst, sk);
>> +     ip_select_ident(skb, &rt->dst, sk);
>>
>>       if (opt) {
>>               iph->ihl += opt->optlen>>2;
>
> This transformation is not equivalent.
>
> ip_select_ident() is going to use ip_hdr() which obtains the header
> pointer via skb_network_header().
>
> But here, the code is using skb->data for this, which is different.

I dared to do that because three lines below ip_options_build() seems
to be already doing the same thing, if IP options are present:

struct sk_buff *__ip_make_skb() {
    ...
    ip_select_ident(skb, &rt->dst, sk);
    if (opt) {
        iph->ihl += opt->optlen>>2;
        ip_options_build(skb, opt, cork->addr, rt, 0);
    }

and

void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
__be32 daddr, struct rtable *rt, int is_frag) {
    unsigned char *iph = skb_network_header(skb);
    ....


Another solution would be to pass local fragmentation flag as fourth
argument to ip_select_ident(). If you think that would be cleaner,
then I can reimplement it that way?

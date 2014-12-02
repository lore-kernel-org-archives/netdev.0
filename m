From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification until
 after ndo_uninit()
Date: Tue, 2 Dec 2014 11:53:32 -0800
Message-ID: <CAADnVQKLCWa3tZu2akkJzF6nUPoS4m-mmetQYbtWiuPEN1vFGg@mail.gmail.com>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>
	<20141202100746.GA13717@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:54413 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933179AbaLBTxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 14:53:33 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so9866059qge.32
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 11:53:32 -0800 (PST)
In-Reply-To: <20141202100746.GA13717@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 2, 2014 at 2:07 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/01/14 at 09:54pm, Mahesh Bandewar wrote:
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2220,8 +2220,16 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
>>       return skb->len;
>>  }
>>
>> -void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
>> -               gfp_t flags)
>> +void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
>> +{
>> +     struct net *net = dev_net(dev);
>> +
>> +     rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
>> +}
>> +EXPORT_SYMBOL(rtmsg_ifinfo_send);
>> +
>> +struct sk_buff *rtmsg_ifinfo(int type, struct net_device *dev,
>> +                          unsigned int change, gfp_t flags, bool fill_only)
>>  {
>>       struct net *net = dev_net(dev);
>>       struct sk_buff *skb;
>> @@ -2239,11 +2247,15 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
>>               kfree_skb(skb);
>>               goto errout;
>>       }
>> +     if (fill_only)
>> +         return skb;
>> +
>>       rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
>> -     return;
>> +     return NULL;
>>  errout:
>>       if (err < 0)
>>               rtnl_set_sk_err(net, RTNLGRP_LINK, err);
>> +     return NULL;
>>  }
>
> I think it would be cleaner to introduce a new function, for example
> rtmsg_ifinfo_build_skb() which is called from rtmsg_ifinfo(). The
> single caller that requires delayed sending can use the build skb
> function directly and then send it off.

+1
that would make patch much smaller.

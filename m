From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] vxlan: insert ipv6 macro
Date: Wed, 12 Oct 2016 21:01:54 +0800
Message-ID: <CAD=hENc0pQPKDvq_HJ14BhNzAWQndZ4GMo_-_D4EtQMgs9tv2g@mail.gmail.com>
References: <1476174211-9358-1-git-send-email-zyjzyj2000@gmail.com> <20161011160615.7f7f7746@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pabeni@redhat.com,
        daniel@iogearbox.net, Pravin B Shelar <pshelar@nicira.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        hannes@stressinduktion.org, "David S. Miller" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:35102 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933345AbcJLNBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 09:01:55 -0400
Received: by mail-ua0-f193.google.com with SMTP id 38so297720uaj.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:01:55 -0700 (PDT)
In-Reply-To: <20161011160615.7f7f7746@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jiri

How to explain the following source code? As you mentioned,  are the
#ifdefs in the following source pointless?
As to the previous patch, I will compile and analyze it. But now I am
busy with something else. After I draw a conclusion, I will let you
know.

Thanks for your reply.

 static void vxlan_sock_release(struct vxlan_dev *vxlan)
{
        bool ipv4 = __vxlan_sock_release_prep(vxlan->vn4_sock);
#if IS_ENABLED(CONFIG_IPV6)
        bool ipv6 = __vxlan_sock_release_prep(vxlan->vn6_sock);
#endif
        synchronize_net();
        if (ipv4) {
                udp_tunnel_sock_release(vxlan->vn4_sock->sock);
                kfree(vxlan->vn4_sock);
        }
#if IS_ENABLED(CONFIG_IPV6)
        if (ipv6) {
                udp_tunnel_sock_release(vxlan->vn6_sock->sock);
                kfree(vxlan->vn6_sock);
        }
#endif
}

On Tue, Oct 11, 2016 at 10:06 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 11 Oct 2016 16:23:31 +0800, zyjzyj2000@gmail.com wrote:
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -2647,15 +2647,15 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
>>       int err;
>>
>>       memset(&udp_conf, 0, sizeof(udp_conf));
>> -
>> +#if IS_ENABLED(CONFIG_IPV6)
>>       if (ipv6) {
>>               udp_conf.family = AF_INET6;
>>               udp_conf.use_udp6_rx_checksums =
>>                   !(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
>>               udp_conf.ipv6_v6only = 1;
>> -     } else {
>> +     } else
>> +#endif
>>               udp_conf.family = AF_INET;
>> -     }
>
> Zhu Yanjun, before posting patches such as the previous ones or
> this one, please test whether they make any difference. In this case,
> try to compile the code with IPv6 disabled before and after this patch,
> disassemble and compare the results. You'll see that this patch is
> pointless.
>
> It's pretty obvious from the code but to be really sure, I've just
> quickly built the vxlan module with IPv6 disabled. And indeed, as
> expected, the compiler just inlined everything into vxlan_open. The
> whole chain vxlan_open -> vxlan_sock_add -> __vxlan_sock_add (note that
> there's only a single caller of __vxlan_sock_add with IPv6 disabled) ->
> vxlan_socket_create -> vxlan_create_sock is inlined.
>
> It also means the code in the "if (ipv6)" branch is completely
> eliminated by the compiler even without ugly #ifdefs.
>
>  Jiri

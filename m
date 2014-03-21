From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Fri, 21 Mar 2014 07:06:06 +0200
Message-ID: <CAF1J0HMVJWMNHd30rD=2tqwVtPtUeMYZ4P-qP7bMnVVdr_=+Ng@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20140320.160229.857536522237793124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:43776 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaCUFGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 01:06:07 -0400
Received: by mail-ob0-f176.google.com with SMTP id wp18so1992378obc.35
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 22:06:07 -0700 (PDT)
In-Reply-To: <20140320.160229.857536522237793124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 10:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
> Date: Mon, 17 Mar 2014 13:17:30 +0200
>
>> If the vxlan interface is created without group definition, there is a
>> panic on the first packet reception:
>  ...
>> The crash occurs because vxlan_rcv decides on protocol version of outer
>> packed using vxlan->default_dst.remote_ip.sa.sa_family field which is
>> not initialized if no multicast group was specified at interface
>> creation time. This causes vxlan driver to always assume that outer
>> packet is IPv6.
>>
>> Using IP protocol version from skb instead of default destination
>> address family fixes the problem.
>>
>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>
> Thinking some more, I'd like to propose an alternate version of this fix.
>
> Any objections to this?  I think it maintains the pre-ipv6-support
> behavior.  I know there may be some concerns about supporting multiple
> families on the same socket, but I'm not so sure the code is able to
> support that right now anyways.

No objections from my side either.

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index a7eb3f2..3a23623 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1206,7 +1206,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
>                 goto drop;
>
>         /* Re-examine inner Ethernet packet */
> -       if (remote_ip->sa.sa_family == AF_INET) {
> +       if (vs->family == AF_INET) {
>                 oip = ip_hdr(skb);
>                 saddr.sin.sin_addr.s_addr = oip->saddr;
>                 saddr.sa.sa_family = AF_INET;
> @@ -2409,10 +2409,13 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
>
>         INIT_WORK(&vs->del_work, vxlan_del_work);
>
> -       if (ipv6)
> +       if (ipv6) {
> +               vs->family = AF_INET6;
>                 sock = create_v6_sock(net, port);
> -       else
> +       } else {
> +               vs->family = AF_INET;
>                 sock = create_v4_sock(net, port);
> +       }
>         if (IS_ERR(sock)) {
>                 kfree(vs);
>                 return ERR_CAST(sock);
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index 5deef1a..6f00731 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -16,6 +16,7 @@ struct vxlan_sock {
>         struct hlist_node hlist;
>         vxlan_rcv_t      *rcv;
>         void             *data;
> +       __u16             family;
>         struct work_struct del_work;
>         struct socket    *sock;
>         struct rcu_head   rcu;



-- 
Sincerely yours,
Mike.

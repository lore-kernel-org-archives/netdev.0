From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] vxlan: Do not reuse sockets for a different address
 family
Date: Tue, 04 Nov 2014 19:25:48 +0300
Message-ID: <5458FE0C.1080607@cogentembedded.com>
References: <b2c5c4c68f0ae715802b4b4fd35fd1031c65aac0.1415108561.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35646 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbaKDQZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:25:47 -0500
Received: by mail-lb0-f175.google.com with SMTP id n15so3439724lbi.6
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 08:25:45 -0800 (PST)
In-Reply-To: <b2c5c4c68f0ae715802b4b4fd35fd1031c65aac0.1415108561.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/4/2014 4:46 PM, Marcelo Ricardo Leitner wrote:

> Currently, we only match against local port number in order to reuse
> socket. But if this new vxlan wants an IPv6 socket and a IPv4 one bound
> to that port, vxlan will reuse an IPv4 socket as IPv6 and a panic will
> follow. The following steps reproduce it:

>     # ip link add vxlan6 type vxlan id 42 group 229.10.10.10 \
>         srcport 5000 6000 dev eth0
>     # ip link add vxlan7 type vxlan id 43 group ff0e::110 \
>         srcport 5000 6000 dev eth0
>     # ip link set vxlan6 up
>     # ip link set vxlan7 up
>     <panic>

> [    4.187481] BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
> [    4.187509] IP: [<ffffffff81667c98>] ipv6_sock_mc_join+0x88/0x630
> ...
> [    4.188076] Call Trace:
> [    4.188085]  [<ffffffff81667c4a>] ? ipv6_sock_mc_join+0x3a/0x630
> [    4.188098]  [<ffffffffa05a6ad6>] vxlan_igmp_join+0x66/0xd0 [vxlan]
> [    4.188113]  [<ffffffff810a3430>] process_one_work+0x220/0x710
> [    4.188125]  [<ffffffff810a33c4>] ? process_one_work+0x1b4/0x710
> [    4.188138]  [<ffffffff810a3a3b>] worker_thread+0x11b/0x3a0
> [    4.188149]  [<ffffffff810a3920>] ? process_one_work+0x710/0x710

> So address family must also match in order to reuse a socket.

> Reported-by: Jean-Tsung Hsiao <jhsiao@redhat.com>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> ---
>   drivers/net/vxlan.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index ca309820d39e1ba7995f38d3a2f9bacbd1c1f857..c0fa76d55ae3cc07fb14b70656d6b13b5bab091c 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -281,7 +281,8 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
>   	struct vxlan_sock *vs;
>
>   	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
> -		if (inet_sk(vs->sock->sk)->inet_sport == port)
> +		if ((inet_sk(vs->sock->sk)->inet_sport == port) &&
> +			(inet_sk(vs->sock->sk)->sk.sk_family == family))

   The continuation line should start below the next character after ( of the 
*if* statement, according to the networking coding style. And inner () are not 
necessary.

WBR, Sergei

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/6 net-next] inet: reset tb->fastreuseport when adding
 a reuseport sk
Date: Thu, 22 Dec 2016 14:43:40 -0800
Message-ID: <1482446620.8944.83.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1482441998-28359-1-git-send-email-jbacik@fb.com>
         <1482441998-28359-7-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
        kraigatgoog@gmail.com, tom@herbertland.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34933 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758273AbcLVWnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 17:43:42 -0500
Received: by mail-pg0-f66.google.com with SMTP id i5so11912153pgh.2
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 14:43:42 -0800 (PST)
In-Reply-To: <1482441998-28359-7-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-22 at 16:26 -0500, Josef Bacik wrote:
> If we have non reuseport sockets on a tb we will set tb->fastreuseport to 0 and
> never set it again.  Which means that in the future if we end up adding a bunch
> of reuseport sk's to that tb we'll have to do the expensive scan every time.
> Instead add a sock_common to the tb so we know what reuseport sk succeeded last.
> Once one sk has made it onto the list we know that there are no potential bind
> conflicts on the owners list that match that sk's rcv_addr.  So copy the sk's
> common into our tb->fastsock and set tb->fastruseport to FASTREUSESOCK_STRICT so
> we know we have to do an extra check for subsequent reuseport sockets and skip
> the expensive bind conflict check.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  include/net/inet_hashtables.h   |  4 ++++
>  net/ipv4/inet_connection_sock.c | 53 +++++++++++++++++++++++++++++++++++++----
>  2 files changed, 53 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 756ed16..4ccc18f 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -74,12 +74,16 @@ struct inet_ehash_bucket {
>   * users logged onto your box, isn't it nice to know that new data
>   * ports are created in O(1) time?  I thought so. ;-)	-DaveM
>   */
> +#define FASTREUSEPORT_ANY	1
> +#define FASTREUSEPORT_STRICT	2
> +
>  struct inet_bind_bucket {
>  	possible_net_t		ib_net;
>  	unsigned short		port;
>  	signed char		fastreuse;
>  	signed char		fastreuseport;
>  	kuid_t			fastuid;
> +	struct sock_common	fastsock;
>  	int			num_owners;
>  	struct hlist_node	node;
>  	struct hlist_head	owners;

Please place this fat field at the end of inet_bind_bucket

Many sockets do not use SO_REUSEPORT and should not use this field,
while tb->owners need to be touched.

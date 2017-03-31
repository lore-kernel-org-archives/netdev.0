From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: use sk_protocol instead of pcflag to
 detect udplite sockets
Date: Fri, 31 Mar 2017 06:25:09 -0700
Message-ID: <1490966709.8750.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35697 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933289AbdCaNZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 09:25:12 -0400
Received: by mail-pg0-f67.google.com with SMTP id g2so17349130pge.2
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 06:25:11 -0700 (PDT)
In-Reply-To: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-31 at 11:47 +0200, Paolo Abeni wrote:
> In the udp_sock struct, the 'forward_deficit' and 'pcflag' fields
> share the same cacheline. While the first is dirtied by
> udp_recvmsg, the latter is read, possibly several times, by the
> bottom half processing to discriminate between udp and udplite
> sockets.
> 
> With this patch, sk->sk_protocol is used to check is the socket is
> really an udplite one, avoiding some cache misses per
> packet and improving the performance under udp_flood with
> small packet up to 10%.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  include/linux/udp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/udp.h b/include/linux/udp.h
> index c0f5308..6cb4061 100644
> --- a/include/linux/udp.h
> +++ b/include/linux/udp.h
> @@ -115,6 +115,6 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
>  #define udp_portaddr_for_each_entry_rcu(__sk, list) \
>  	hlist_for_each_entry_rcu(__sk, list, __sk_common.skc_portaddr_node)
>  
> -#define IS_UDPLITE(__sk) (udp_sk(__sk)->pcflag)
> +#define IS_UDPLITE(__sk) (__sk->sk_protocol == IPPROTO_UDPLITE)
>  
>  #endif	/* _LINUX_UDP_H */



I am pretty sure we agreed in the past that forward_deficit would need
to be placed on a cache line of its own. Somehow we manage to not
implement this properly.

What about other fields like encap_rcv, encap_destroy, gro_receive,
gro_complete. They really should have the same false sharing issue.

Proper fix is :

 include/linux/udp.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index c0f530809d1f3db7323e51a52224eb49d8f97da0..bdfd11823c12f6c08dc6b2adb247b8e0a7f2e5d5 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -80,8 +80,10 @@ struct udp_sock {
 						struct sk_buff *skb,
 						int nhoff);
 
-	/* This field is dirtied by udp_recvmsg() */
-	int		forward_deficit;
+	/* This field is dirtied by udp_recvmsg().
+	 * Make sure it wont share a cache line with prior fields.
+	 */
+	int		forward_deficit ____cacheline_aligned_in_smp;
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)

From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next] net: synack packets can be attached to request sockets
Date: Thu, 8 Oct 2015 11:56:32 -0400
Message-ID: <CAHC9VhT7AY8wgeYbFE-U2ykF0S7YNkQo8i9-+dbsUV8Ry9xcVg@mail.gmail.com>
References: <1444305715.27760.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35332 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934141AbbJHP4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 11:56:33 -0400
Received: by oigi138 with SMTP id i138so7314676oig.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 08:56:33 -0700 (PDT)
In-Reply-To: <1444305715.27760.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 8:01 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> selinux needs few changes to accommodate fact that SYNACK messages
> can be attached to a request socket, lacking sk_security pointer
>
> (Only syncookies are still attached to a TCP_LISTEN socket)
>
> Adds a new sk_listener() helper, and use it in selinux and sch_fq
>
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported by: kernel test robot <ying.huang@linux.intel.com>
> Cc: Paul Moore <paul@paul-moore.com>
> Cc: Stephen Smalley <sds@tycho.nsa.gov>
> Cc: Eric Paris <eparis@parisplace.org>
> ---
>  include/net/sock.h       |    8 ++++++++
>  net/sched/sch_fq.c       |    3 ++-
>  security/selinux/hooks.c |   12 ++++++++----
>  3 files changed, 18 insertions(+), 5 deletions(-)

Acked-by: Paul Moore <paul@paul-moore.com>

> diff --git a/include/net/sock.h b/include/net/sock.h
> index dfe2eb8e1132..771ca1996442 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2201,6 +2201,14 @@ static inline bool sk_fullsock(const struct sock *sk)
>         return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
>  }
>
> +/* This helper checks if a socket is a LISTEN or NEW_SYN_RECV
> + * SYNACK messages can be attached to either ones (depending on SYNCOOKIE)
> + */
> +static inline bool sk_listener(const struct sock *sk)
> +{
> +       return (1 << sk->sk_state) & (TCPF_LISTEN | TCPF_NEW_SYN_RECV);
> +}
> +
>  void sock_enable_timestamp(struct sock *sk, int flag);
>  int sock_get_timestamp(struct sock *, struct timeval __user *);
>  int sock_get_timestampns(struct sock *, struct timespec __user *);
> diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
> index 3386cce4751e..109b2322778f 100644
> --- a/net/sched/sch_fq.c
> +++ b/net/sched/sch_fq.c
> @@ -225,6 +225,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
>                 return &q->internal;
>
>         /* SYNACK messages are attached to a TCP_NEW_SYN_RECV request socket
> +        * or a listener (SYNCOOKIE mode)
>          * 1) request sockets are not full blown,
>          *    they do not contain sk_pacing_rate
>          * 2) They are not part of a 'flow' yet
> @@ -232,7 +233,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
>          *    especially if the listener set SO_MAX_PACING_RATE
>          * 4) We pretend they are orphaned
>          */
> -       if (!sk || sk->sk_state == TCP_NEW_SYN_RECV) {
> +       if (!sk || sk_listener(sk)) {
>                 unsigned long hash = skb_get_hash(skb) & q->orphan_mask;
>
>                 /* By forcing low order bit to 1, we make sure to not
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 64340160f4ac..6e50841ef1f6 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4898,7 +4898,7 @@ static unsigned int selinux_ip_output(struct sk_buff *skb,
>         if (sk) {
>                 struct sk_security_struct *sksec;
>
> -               if (sk->sk_state == TCP_LISTEN)
> +               if (sk_listener(sk))
>                         /* if the socket is the listening state then this
>                          * packet is a SYN-ACK packet which means it needs to
>                          * be labeled based on the connection/request_sock and
> @@ -5005,7 +5005,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
>          *       unfortunately, this means more work, but it is only once per
>          *       connection. */
>         if (skb_dst(skb) != NULL && skb_dst(skb)->xfrm != NULL &&
> -           !(sk != NULL && sk->sk_state == TCP_LISTEN))
> +           !(sk && sk_listener(sk)))
>                 return NF_ACCEPT;
>  #endif
>
> @@ -5022,7 +5022,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
>                         secmark_perm = PACKET__SEND;
>                         peer_sid = SECINITSID_KERNEL;
>                 }
> -       } else if (sk->sk_state == TCP_LISTEN) {
> +       } else if (sk_listener(sk)) {
>                 /* Locally generated packet but the associated socket is in the
>                  * listening state which means this is a SYN-ACK packet.  In
>                  * this particular case the correct security label is assigned
> @@ -5033,7 +5033,11 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
>                  * selinux_inet_conn_request().  See also selinux_ip_output()
>                  * for similar problems. */
>                 u32 skb_sid;
> -               struct sk_security_struct *sksec = sk->sk_security;
> +               struct sk_security_struct *sksec;
> +
> +               if (sk->sk_state == TCP_NEW_SYN_RECV)
> +                       sk = inet_reqsk(sk)->rsk_listener;
> +               sksec = sk->sk_security;
>                 if (selinux_skb_peerlbl_sid(skb, family, &skb_sid))
>                         return NF_DROP;
>                 /* At this point, if the returned skb peerlbl is SECSID_NULL
>
>



-- 
paul moore
www.paul-moore.com

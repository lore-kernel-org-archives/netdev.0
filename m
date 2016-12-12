From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2] audit: use proper refcount locking on audit_sock
Date: Mon, 12 Dec 2016 15:58:23 -0800
Message-ID: <CAM_iQpXAZOOn7G-EbEy1T11w6uoqwx5M8jVt=iHfOj4TJYsqpA@mail.gmail.com>
References: <20161212100215.GA1305@madcap2.tricolour.ca> <5714bd7468cfec225407a6c367e658478d590495.1481534171.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-audit@redhat.com,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Paris <eparis@redhat.com>, Paul Moore <pmoore@redhat.com>,
        sgrubb@redhat.com
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5714bd7468cfec225407a6c367e658478d590495.1481534171.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2016 at 2:03 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> Resetting audit_sock appears to be racy.
>
> audit_sock was being copied and dereferenced without using a refcount on
> the source sock.
>
> Bump the refcount on the underlying sock when we store a refrence in
> audit_sock and release it when we reset audit_sock.  audit_sock
> modification needs the audit_cmd_mutex.
>
> See: https://lkml.org/lkml/2016/11/26/232
>
> Thanks to Eric Dumazet <edumazet@google.com> and Cong Wang
> <xiyou.wangcong@gmail.com> on ideas how to fix it.
>
> Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> ---
> There has been a lot of change in the audit code that is about to go
> upstream to address audit queue issues.  This patch is based on the
> source tree: git://git.infradead.org/users/pcmoore/audit#next
> ---
>  kernel/audit.c |   34 ++++++++++++++++++++++++++++------
>  1 files changed, 28 insertions(+), 6 deletions(-)
>
> diff --git a/kernel/audit.c b/kernel/audit.c
> index f20eee0..439f7f3 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -452,7 +452,9 @@ static void auditd_reset(void)
>         struct sk_buff *skb;
>
>         /* break the connection */
> +       sock_put(audit_sock);


Why audit_sock can't be NULL here?


>         audit_pid = 0;
> +       audit_nlk_portid = 0;
>         audit_sock = NULL;
>
>         /* flush all of the retry queue to the hold queue */
> @@ -478,6 +480,12 @@ static int kauditd_send_unicast_skb(struct sk_buff *skb)
>         if (rc >= 0) {
>                 consume_skb(skb);
>                 rc = 0;
> +       } else {
> +               if (rc & (-ENOMEM|-EPERM|-ECONNREFUSED)) {


Are these errno's bits??


> +                       mutex_lock(&audit_cmd_mutex);
> +                       auditd_reset();
> +                       mutex_unlock(&audit_cmd_mutex);
> +               }
>         }
>
>         return rc;
> @@ -579,7 +587,9 @@ static int kauditd_thread(void *dummy)
>
>                                 auditd = 0;
>                                 if (AUDITD_BAD(rc, reschedule)) {
> +                                       mutex_lock(&audit_cmd_mutex);
>                                         auditd_reset();
> +                                       mutex_unlock(&audit_cmd_mutex);
>                                         reschedule = 0;
>                                 }
>                         } else
> @@ -594,7 +604,9 @@ static int kauditd_thread(void *dummy)
>                                 auditd = 0;
>                                 if (AUDITD_BAD(rc, reschedule)) {
>                                         kauditd_hold_skb(skb);
> +                                       mutex_lock(&audit_cmd_mutex);
>                                         auditd_reset();
> +                                       mutex_unlock(&audit_cmd_mutex);
>                                         reschedule = 0;
>                                 } else
>                                         /* temporary problem (we hope), queue
> @@ -623,7 +635,9 @@ quick_loop:
>                                 if (rc) {
>                                         auditd = 0;
>                                         if (AUDITD_BAD(rc, reschedule)) {
> +                                               mutex_lock(&audit_cmd_mutex);
>                                                 auditd_reset();
> +                                               mutex_unlock(&audit_cmd_mutex);
>                                                 reschedule = 0;
>                                         }
>
> @@ -1004,17 +1018,22 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>                                 return -EACCES;
>                         }
>                         if (audit_pid && new_pid &&
> -                           audit_replace(requesting_pid) != -ECONNREFUSED) {
> +                           (audit_replace(requesting_pid) & (-ECONNREFUSED|-EPERM|-ENOMEM))) {
>                                 audit_log_config_change("audit_pid", new_pid, audit_pid, 0);
>                                 return -EEXIST;
>                         }
>                         if (audit_enabled != AUDIT_OFF)
>                                 audit_log_config_change("audit_pid", new_pid, audit_pid, 1);
> -                       audit_pid = new_pid;
> -                       audit_nlk_portid = NETLINK_CB(skb).portid;
> -                       audit_sock = skb->sk;
> -                       if (!new_pid)
> +                       if (new_pid) {
> +                               if (audit_sock)
> +                                       sock_put(audit_sock);
> +                               audit_pid = new_pid;
> +                               audit_nlk_portid = NETLINK_CB(skb).portid;
> +                               sock_hold(skb->sk);

Why refcnt is still needed here? I need it because I removed the code
in net exit code path.


> +                               audit_sock = skb->sk;
> +                       } else {
>                                 auditd_reset();
> +                       }
>                         wake_up_interruptible(&kauditd_wait);
>                 }
>                 if (s.mask & AUDIT_STATUS_RATE_LIMIT) {
> @@ -1283,8 +1302,11 @@ static void __net_exit audit_net_exit(struct net *net)
>  {
>         struct audit_net *aunet = net_generic(net, audit_net_id);
>         struct sock *sock = aunet->nlsk;
> -       if (sock == audit_sock)
> +       if (sock == audit_sock) {
> +               mutex_lock(&audit_cmd_mutex);


You need to put the if check inside the mutex too. Again, this could be
removed if you use refcnt.


>                 auditd_reset();
> +               mutex_unlock(&audit_cmd_mutex);
> +       }
>
>         RCU_INIT_POINTER(aunet->nlsk, NULL);
>         synchronize_net();
> --
> 1.7.1
>

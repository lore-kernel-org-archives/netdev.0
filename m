From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH 2/6] audit: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Fri, 12 Apr 2013 09:35:37 -0400
Message-ID: <CACLa4pu5OVK64NLe2y+Msd5suSAdVGgfw1A4G5RVwUezm5HHSA@mail.gmail.com>
References: <1364402946-32715-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1364402946-32715-1-git-send-email-honkiko@gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 27, 2013 at 12:49 PM, Hong Zhiguo <honkiko@gmail.com> wrote:
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  kernel/audit.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/kernel/audit.c b/kernel/audit.c
> index d596e53..4dbb047 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -58,7 +58,7 @@
>  #ifdef CONFIG_SECURITY
>  #include <linux/security.h>
>  #endif
> -#include <linux/netlink.h>
> +#include <net/netlink.h>

This is a duplicate include.  We already included net/netlink.h a
couple of lines above.  We use netlink_unicast, which comes from
linux/netlink.h.  I recognize that it comes in from net/netlink.h, but
I thought it good practice to pull it in ourselves.  Should I send a
separate patch to revert back to linux/netlink.h or a patch to just
remove the include altogether?

-Eric

>  #include <linux/freezer.h>
>  #include <linux/tty.h>
>  #include <linux/pid_namespace.h>
> @@ -910,7 +910,7 @@ static void audit_receive_skb(struct sk_buff *skb)
>  {
>         struct nlmsghdr *nlh;
>         /*
> -        * len MUST be signed for NLMSG_NEXT to be able to dec it below 0
> +        * len MUST be signed for nlmsg_next to be able to dec it below 0
>          * if the nlmsg_len was not aligned
>          */
>         int len;
> @@ -919,13 +919,13 @@ static void audit_receive_skb(struct sk_buff *skb)
>         nlh = nlmsg_hdr(skb);
>         len = skb->len;
>
> -       while (NLMSG_OK(nlh, len)) {
> +       while (nlmsg_ok(nlh, len)) {
>                 err = audit_receive_msg(skb, nlh);
>                 /* if err or if this message says it wants a response */
>                 if (err || (nlh->nlmsg_flags & NLM_F_ACK))
>                         netlink_ack(skb, nlh, err);
>
> -               nlh = NLMSG_NEXT(nlh, len);
> +               nlh = nlmsg_next(nlh, len);
>         }
>  }
>
> @@ -1483,7 +1483,7 @@ void audit_log_end(struct audit_buffer *ab)
>                 audit_log_lost("rate limit exceeded");
>         } else {
>                 struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
> -               nlh->nlmsg_len = ab->skb->len - NLMSG_SPACE(0);
> +               nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
>
>                 if (audit_pid) {
>                         skb_queue_tail(&audit_skb_queue, ab->skb);
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

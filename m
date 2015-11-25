From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net] isdn: Partially revert debug format string usage
 clean up
Date: Wed, 25 Nov 2015 10:35:59 -0800
Message-ID: <CAGXu5jJkNQ4vX3++oXCrb5xeVjxEvUa8Lyyzxe-9Q2kwNWQHmA@mail.gmail.com>
References: <1448433910@msgid.manchmal.in-ulm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34288 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbKYSgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 13:36:00 -0500
Received: by ioir85 with SMTP id r85so62371235ioi.1
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 10:36:00 -0800 (PST)
In-Reply-To: <1448433910@msgid.manchmal.in-ulm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 10:47 PM, Christoph Biedl
<linux-kernel.bfrz@manchmal.in-ulm.de> wrote:
> Commit 35a4a57 ("isdn: clean up debug format string usage") introduced
> a safeguard to avoid accidential format string interpolation of data
> when calling debugl1 or HiSax_putstatus. This did however not take into
> account VHiSax_putstatus (called by HiSax_putstatus) does *not* call
> vsprintf if the head parameter is NULL - the format string is treated
> as plain text then instead. As a result, the string "%s" is processed
> literally, and the actual information is lost. This affects the isdnlog
> userspace program which stopped logging information since that commit.

Oh, that's weird, but yeah, these calls aren't expanding format
strings, so I'm fine with this change.

Acked-by: Kees Cook <keescook@chromium.org>

On the other hand, VHiSax_putstatus contains an unchecked data buffer
overflow, since it uses tmpbuf without checking lengths at all:

        p = tmpbuf;
        if (head) {
                p += jiftime(p, jiffies);
                p += sprintf(p, " %s", head);
                p += vsprintf(p, fmt, args);
                *p++ = '\n';
                *p = 0;
                len = p - tmpbuf;
                p = tmpbuf;
        } else {
                p = fmt;
                len = strlen(fmt);
        }
        if (len > HISAX_STATUS_BUFSIZE) {
                spin_unlock_irqrestore(&cs->statlock, flags);
                printk(KERN_WARNING "HiSax: status overflow %d/%d\n",
                       len, HISAX_STATUS_BUFSIZE);
                return;
        }

It helpfully detects the overflow, but at this point it's too late:
the buffer (and things past it) have already been clobbered. Seems
reachable through capi_debug, callc_debug, but nothing jumps out at me
as passing taking too-long arguments, though there are some long call
chains that touch ioctls and tty stuff, which seems scary. :)

Also, though mitigated by needing DEB_DLOG_VERBOSE, there seems to be
and overflow in dlogframe too: it doesn't validate against
MAX_DLOG_SPACE. For example path:
    GROUP_TEI
    CTRL_SAPI
    ftyp == 3
    while ... adds to dp for length of skb
    ... heap buffer overflow

-Kees

>
> Fixes: 35a4a5733b0a ("isdn: clean up debug format string usage")
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
> ---
>  drivers/isdn/hisax/config.c  | 2 +-
>  drivers/isdn/hisax/hfc_pci.c | 2 +-
>  drivers/isdn/hisax/hfc_sx.c  | 2 +-
>  drivers/isdn/hisax/q931.c    | 6 +++---
>  4 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
> index b33f53b..bf04d2a 100644
> --- a/drivers/isdn/hisax/config.c
> +++ b/drivers/isdn/hisax/config.c
> @@ -1896,7 +1896,7 @@ static void EChannel_proc_rcv(struct hisax_d_if *d_if)
>                                 ptr--;
>                                 *ptr++ = '\n';
>                                 *ptr = 0;
> -                               HiSax_putstatus(cs, NULL, "%s", cs->dlog);
> +                               HiSax_putstatus(cs, NULL, cs->dlog);
>                         } else
>                                 HiSax_putstatus(cs, "LogEcho: ",
>                                                 "warning Frame too big (%d)",
> diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
> index 4a48255..90449e1 100644
> --- a/drivers/isdn/hisax/hfc_pci.c
> +++ b/drivers/isdn/hisax/hfc_pci.c
> @@ -901,7 +901,7 @@ Begin:
>                                         ptr--;
>                                         *ptr++ = '\n';
>                                         *ptr = 0;
> -                                       HiSax_putstatus(cs, NULL, "%s", cs->dlog);
> +                                       HiSax_putstatus(cs, NULL, cs->dlog);
>                                 } else
>                                         HiSax_putstatus(cs, "LogEcho: ", "warning Frame too big (%d)", total - 3);
>                         }
> diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
> index b1fad81..13b2151 100644
> --- a/drivers/isdn/hisax/hfc_sx.c
> +++ b/drivers/isdn/hisax/hfc_sx.c
> @@ -674,7 +674,7 @@ receive_emsg(struct IsdnCardState *cs)
>                                         ptr--;
>                                         *ptr++ = '\n';
>                                         *ptr = 0;
> -                                       HiSax_putstatus(cs, NULL, "%s", cs->dlog);
> +                                       HiSax_putstatus(cs, NULL, cs->dlog);
>                                 } else
>                                         HiSax_putstatus(cs, "LogEcho: ", "warning Frame too big (%d)", skb->len);
>                         }
> diff --git a/drivers/isdn/hisax/q931.c b/drivers/isdn/hisax/q931.c
> index b420f8b..ba4beb2 100644
> --- a/drivers/isdn/hisax/q931.c
> +++ b/drivers/isdn/hisax/q931.c
> @@ -1179,7 +1179,7 @@ LogFrame(struct IsdnCardState *cs, u_char *buf, int size)
>                 dp--;
>                 *dp++ = '\n';
>                 *dp = 0;
> -               HiSax_putstatus(cs, NULL, "%s", cs->dlog);
> +               HiSax_putstatus(cs, NULL, cs->dlog);
>         } else
>                 HiSax_putstatus(cs, "LogFrame: ", "warning Frame too big (%d)", size);
>  }
> @@ -1246,7 +1246,7 @@ dlogframe(struct IsdnCardState *cs, struct sk_buff *skb, int dir)
>         }
>         if (finish) {
>                 *dp = 0;
> -               HiSax_putstatus(cs, NULL, "%s", cs->dlog);
> +               HiSax_putstatus(cs, NULL, cs->dlog);
>                 return;
>         }
>         if ((0xfe & buf[0]) == PROTO_DIS_N0) {  /* 1TR6 */
> @@ -1509,5 +1509,5 @@ dlogframe(struct IsdnCardState *cs, struct sk_buff *skb, int dir)
>                 dp += sprintf(dp, "Unknown protocol %x!", buf[0]);
>         }
>         *dp = 0;
> -       HiSax_putstatus(cs, NULL, "%s", cs->dlog);
> +       HiSax_putstatus(cs, NULL, cs->dlog);
>  }
> --
> 2.1.4
>



-- 
Kees Cook
Chrome OS & Brillo Security

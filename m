From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH PKT_SCHED 4/17]: Check TCA_ACT_KIND payload size _before_ copying it
Date: Thu, 30 Dec 2004 14:34:01 +0100
Message-ID: <20041230133401.GW32419@postel.suug.ch>
References: <41D37875.5020103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41D37875.5020103@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41D37875.5020103@trash.net> 2004-12-30 04:39
> -			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
> -			if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {
> -				printk("Action %s bad\n", (char*)RTA_DATA(kind));
> +			if (RTA_PAYLOAD(kind) >= IFNAMSIZ)

The check should be RTA_PAYLOAD(kind) > IFNAMSIZ, == is ok
if the terminating NUL is provided.

>  				goto err_out;
> -			}
> +			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
>  		} else {

This will cause horrible crashes if no NUL is provided to terminate
the name.

So I think this should be:

if (RTA_PAYLOAD(kind) > IFNAMSIZ)
	goto err_out;
memset(act_name, ...);
memcpy(act_name, RTA_DATA(kind), RTA_PAYLOAD(kind));
act_name[IFNAMSIZ - 1] = '\0';

The memset is required to ensure 0 termination if kind is not and
shorter than IFNAMSIZ. memcpy instead of str* to avoid using
any form of str(n)len on a possibly not terminated string
and setting IFNAMSIZ - 1 to NUL to ensure proper handling of
a IFNAMSIZ long not terminated string.

I know it's unlikely but this might just save us some troubles later.

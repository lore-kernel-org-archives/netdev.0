From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Mon, 20 Dec 2004 09:27:27 +0100
Message-ID: <41C68CEF.3030803@trash.net>
References: <20041219203050.GK17998@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041219203050.GK17998@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Dave,
> 
> This patch is actually part of a patchset for 2.6.11 inclusion
> but the memory corruption possibility might make it worth
> for 2.6.10. It's not really dangerous since it requires
> admin capabilities though.

There are lots of places where this is possible, just look
at all the silly checks in the action code:

    sprintf(act_name, "%s", (char*)RTA_DATA(kind));
    if (RTA_PAYLOAD(kind) >= IFNAMSIZ) {

> Puts the indev validation into its own function to allow
> parameter validation before any changes are made. Changes
> the sanity check from >= IFNAMSIZ to > IFNAMSIZ to correctly
> handle 0 terminated strings and replaces the dangerous sprintf
> with a memcpy bound to the TLV size. Providing a indev TLV
> for kernels without CONFIG_NET_CLS_IND support will now lead
> to EOPPNOTSUPP.

Why special-case indev ? Neither u32 nor fw make any attempt
to clean up after errors in their init functions, so instead
of fixing a single attribute they need to do proper cleanup,
than we can just continue to validate indev when changing it.
Returning EOPNOTSUPP makes sense, of course.

I'm also against keeping all those printks when touching the
code. Its ok when writing new code, but I don't see why this
code, unlike everything else, needs to report errors in the
ringbuffer instead of returning meaningful error codes.

> +static inline void
> +tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *id_tlv)
> +{
> +	memset(indev, 0, IFNAMSIZ);
> +	memcpy(indev, RTA_DATA(id_tlv), RTA_PAYLOAD(id_tlv));
> +	indev[IFNAMSIZ - 1] = '\0';
> +}

And this should just use strlcpy.

Regards
Patrick

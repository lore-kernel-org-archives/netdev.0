From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH 03/12] man: Add a man page for the mirred action
Date: Mon, 7 Mar 2016 07:06:54 -0500
Message-ID: <56DD6EDE.8030403@mojatatu.com>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
 <1457093507-25601-4-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34950 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbcCGMG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 07:06:56 -0500
Received: by mail-io0-f177.google.com with SMTP id g203so128515075iof.2
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 04:06:56 -0800 (PST)
In-Reply-To: <1457093507-25601-4-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BTW, thanks for putting in this effort.

On 16-03-04 07:11 AM, Phil Sutter wrote:
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>   man/man8/tc-mirred.8 | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 89 insertions(+)
>   create mode 100644 man/man8/tc-mirred.8
>
> diff --git a/man/man8/tc-mirred.8 b/man/man8/tc-mirred.8
> new file mode 100644
> index 0000000000000..52d98bc416563
> --- /dev/null
> +++ b/man/man8/tc-mirred.8
> @@ -0,0 +1,89 @@
> +.TH "Mirror/redirect action in tc" 8 "11 Jan 2015" "iproute2" "Linux"
> +
> +.SH NAME
> +mirred - mirror/redirect action
> +.SH SYNOPSIS
> +.in +8
> +.ti -8
> +.BR tc " ... " "action mirred"
> +.I DIRECTION ACTION
> +.RB "[ " index
> +.IR INDEX " ] "
> +.BI dev " DEVICENAME"
> +
> +.ti -8
> +.IR DIRECTION " := { "
> +.BR ingress " | " egress " }"
> +
> +.ti -8
> +.IR ACTION " := { "
> +.BR mirror " | " redirect " }"
> +.SH DESCRIPTION
> +The
> +.B mirred
> +action allows to redirect or mirror packets to another network interface on the
> +same system. It is typically used in combination with the
> +.B ifb
> +pseudo device to create a shrared instance where QoS happens, but serves well
> +for debugging or monitoring purposes, too.

The ifb use case is definetely the most propagandized one; but certainly
the terms "mirror" and "redirect" are industry nouns for describing
what this action does. The only i raise this concern is because once it
writ it becomes dogma to some people (and if there is one thing i
learned over the years is that the google-cut-n-pasters are hard to
change). So i would reword as:
"This action allows packet mirroring(copying) or redirecting (stealing)
the packet it receives. Mirroring is what is sometimes referred as
R/SPAN an is commonly used to analyze and/or debug flows.

I would then use the ifb example as a very specific to linux use case;
and add the common use case of mirroring, example:
mirror icmp packets to dummy0 device and run tcpdump on that port..

sudo $TC filter add dev $SRCPORT parent ffff: protocol ip \
u32 match ip protocol 1 0xff \
action mirred egress mirror dev dummy0 \

For redirect, one use case is to redirect packets to a remote machine
based on policy intent. A sample policy is to add a default rule
to redirect packets that dont match any filter to a quarantine
machine. etc.

cheers,
jamal

> +.SH OPTIONS
> +.TP
> +.B ingress
> +.TQ
> +.B egress
> +Specify the direction in which the packet shall appear on the destination
> +interface. Currently only
> +.B egress
> +is implemented.
> +.TP
> +.B mirror

> +.TQ
> +.B redirect
> +Define whether the packet should be copied
> +.RB ( mirror )
> +or moved
> +.RB ( redirect )
> +to the destination interface.
> +.TP
> +.BI index " INDEX"
> +Assign a unique ID to this action instead of letting the kernel choose one
> +automatically.
> +.I INDEX
> +is a 32bit unsigned integer greater than zero.
> +.TP
> +.BI dev " DEVICENAME"
> +Specify the network interface to redirect or mirror to.
> +.SH EXAMPLES
> +Limit ingress bandwidth on eth0 to 1mbit/s, redirect exceeding traffic to lo for
> +debugging purposes:
> +
> +.RS
> +.EX
> +# tc qdisc add dev eth0 handle ffff: ingress
> +# tc filter add dev eth0 parent ffff: u32 \\
> +	match u32 0 0 \\
> +	action police rate 1mbit burst 100k conform-exceed pipe \\
> +	action mirred egress redirect dev lo
> +.EE
> +.RE
> +
> +Use an
> +.B ifb
> +interface to send ingress traffic on eth0 through an instance of
> +.BR sfq :
> +
> +.RS
> +.EX
> +# modprobe ifb
> +# ip link set ifb0 up
> +# tc qdisc add dev ifb0 root sfq
> +# tc qdisc add dev eth0 handle ffff: ingress
> +# tc filter add dev eth0 parent ffff: u32 \\
> +	match u32 0 0 \\
> +	action mirred egress redirect dev ifb0
> +.EE
> +.RE
> +
> +.SH SEE ALSO
> +.BR tc (8),
> +.BR tc-u32 (8)
>

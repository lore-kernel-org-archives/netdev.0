From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH] crash in 2.6.22-git2 sysctl_set_parent()
Date: Sat, 14 Jul 2007 06:19:41 +0530
Message-ID: <a781481a0707131749l55671ccdyb315072aec1423cb@mail.gmail.com>
References: <20070713200515.GS5549@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
To: "Linas Vepstas" <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:52946 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759161AbXGNAtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 20:49:43 -0400
Received: by nz-out-0506.google.com with SMTP id s18so583971nze
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 17:49:42 -0700 (PDT)
In-Reply-To: <20070713200515.GS5549@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm totally confuzed by this patch ...

On 7/14/07, Linas Vepstas <linas@austin.ibm.com> wrote:
>
> This is a patch (& bug report) for a crash in sysctl_set_parent()
> in 2.6.22-git2.

Are you sure you saw this crash on 22-git2 (Linus' tree) ???

> Problem: 2.6.22-git2 crashes with a stack trace
> [c000000001d0fb00] c000000000067b4c .sysctl_set_parent+0x48/0x7c
> [c000000001d0fb90] c000000000069b40 .register_sysctl_table+0x7c/0xf4
> [c000000001d0fc30] c00000000065e710 .devinet_init+0x88/0xb0
> [c000000001d0fcc0] c00000000065db74 .ip_rt_init+0x17c/0x32c
> [c000000001d0fd70] c00000000065deec .ip_init+0x10/0x34
> [c000000001d0fdf0] c00000000065e898 .inet_init+0x160/0x3dc
> [c000000001d0fea0] c000000000630bc4 .kernel_init+0x204/0x3c8

Please post the full dmesg output, if possible.

> A bit of poking around makes it clear what the problem is:
> In sysctl_set_parent(), the for loop
>
>    for (; table->ctl_name || table->procname; table++) {

Yup, but note that the "table" there is a struct ctl_table * ...

> walks off the end of the table, and into garbage.  Basically,
> this for-loop iterator expects all table arrays to be
> "null terminated".  However, net/ipv4/devinet.c statically
> declares an array that is not null-terminated.

Whereas the "not null-terminated" array you're talking about
in devinet.c is a struct devinet_sysctl_table, whose *members*
are ctl_table structs.

Also note that all those members have already been declared
as arrays: struct ctl_table xxx[2]; *precisely* because the
second element (which is left un-initialized, hence will get
zeroed-out being static) is what will protect us from running
out into garbage in sysctl_set_parent().

> The patch
> below fixes that; it works for me.

Now I'm even more confuzed ...

> Its somewhat conservative;
> if one wishes to assume that the compiler will always zero out
> the empty parts of the structure,

You can always safely assume that.

Off-topic, but note that unintialized static variables being automagically
initialized to zero / NULL is guaranteed by C (the language) itself, so
nothing left in the hands of compiler implementations here. [6.7.8:10]

> then this pach can be shrunk
> to one line: +  ctl_table               devinet_root_dir[3];

But that's pointless. It was already [2] for the reason I mentioned.

> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> [...]
>  net/core/neighbour.c |    4 ++++
>  net/ipv4/devinet.c   |    7 ++++++-
>  2 files changed, 10 insertions(+), 1 deletion(-)

Weirder. diffstat does not match the patch ...

> Index: linux-2.6.22-git2/net/ipv4/devinet.c
> ===================================================================
> --- linux-2.6.22-git2.orig/net/ipv4/devinet.c   2007-07-13 14:23:21.000000000 -0500
> +++ linux-2.6.22-git2/net/ipv4/devinet.c        2007-07-13 14:24:15.000000000 -0500
> @@ -1424,7 +1424,7 @@ static struct devinet_sysctl_table {
>         ctl_table               devinet_dev[2];
>         ctl_table               devinet_conf_dir[2];
>         ctl_table               devinet_proto_dir[2];
> -       ctl_table               devinet_root_dir[2];
> +       ctl_table               devinet_root_dir[3];
>  } devinet_sysctl = {
>         .devinet_vars = {
>                 DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
> @@ -1493,8 +1493,13 @@ static struct devinet_sysctl_table {

And Linus' latest -git doesn't even have this stuff at line 1493.

>                         .data           = &ipv4_devconf.loop,
>                         .maxlen         = sizeof(int),
>                         .mode           = 0644,
> +                       .child  = 0x0,
>                         .proc_handler   = &proc_dointvec,
>                 },
> +               {
> +                       .ctl_name       = 0,
> +                       .procname       = 0,
> +               },
>         },
>  };

Well, as I said, I'm totally confuzed ...

Satyam

From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: fix sw_flow_key alignment
Date: Fri, 30 Aug 2013 11:22:11 -0700
Message-ID: <CAEP_g=9y-HeG0vHS2v-dk7eDp=T0denddykDO3TJtk4UJ062Mg@mail.gmail.com>
References: <1377883940-8995-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:34507 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755203Ab3H3SWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:22:32 -0400
Received: by mail-la0-f48.google.com with SMTP id er20so1802779lab.21
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 11:22:31 -0700 (PDT)
In-Reply-To: <1377883940-8995-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 30, 2013 at 10:32 AM, Andy Zhou <azhou@nicira.com> wrote:
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index ad1aeeb..fe7524c4 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
>  int ovs_flow_init(void)
>  {
>         BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
> +       BUILD_BUG_ON(sizeof(struct sw_flow_key) % __alignof__(long));

Should this be checking alignof struct sw_flow_key instead of the size?

>         flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
>                                         0, NULL);
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index b65f885..202c4c4 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -125,7 +125,7 @@ struct sw_flow_key {
>                         } nd;
>                 } ipv6;
>         };
> -} __aligned(__alignof__(long));
> +} __aligned(sizeof(long));

This is going to result in the alignment issue discussed yesterday
where on 32-bit machines the 64 bit members potentially become
misaligned. The suggestion that Geert made was to just drop this
entirely and rely on the natural alignment from these values.

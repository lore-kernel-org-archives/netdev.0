From: tingwei liu <tingw.liu@gmail.com>
Subject: Re: [PATCH net-next] sctp: add a checking for sctp_sysctl_net_register
Date: Thu, 8 May 2014 17:40:57 +0800
Message-ID: <CA+qZnSQHfvO9HysmrsgVs0TSMz6j-kvAYNsHA+z38PWN621u2g@mail.gmail.com>
References: <536B3859.2050908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Tony <liutingwei@hisense.com>
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:39739 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbaEHJk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 05:40:58 -0400
In-Reply-To: <536B3859.2050908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014 at 3:55 PM, Wang Weidong <wangweidong1@huawei.com> wrote:
> When register_net_sysctl failed, we should free the
> sysctl_table while the net_namespace is not init_net.
>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/sysctl.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 844d2b0..4c17694 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -450,6 +450,11 @@ int sctp_sysctl_net_register(struct net *net)
>         }
>
>         net->sctp.sysctl_header = register_net_sysctl(net, "net/sctp", table);
> +       if (net->sctp.sysctl_header == NULL) {
> +               if (!net_eq(net, &init_net))
> +                       kfree(table);
> +               return -ENOMEM;
> +       }
>         return 0;
>  }
>
Hope to resolve the problem of sctp_sysctl_net_unregister() in one patch!
kfree(table) should check net namesapce.
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index c82fdc1..844d2b0 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -459,7 +459,8 @@ void sctp_sysctl_net_unregister(struct net *net)

        table = net->sctp.sysctl_header->ctl_table_arg;
        unregister_net_sysctl_table(net->sctp.sysctl_header);
-       kfree(table);
+       if (!net_eq(net, &init_net))
+               kfree(table);
 }

 static struct ctl_table_header *sctp_sysctl_header;

Thanks
Tingwei Liu
> --
> 1.7.12
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

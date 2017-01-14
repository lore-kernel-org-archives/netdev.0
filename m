From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] can: Fix kernel panic at security_sock_rcv_skb
Date: Sat, 14 Jan 2017 09:30:35 -0800
Message-ID: <1484415035.13165.57.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484202799-7287-1-git-send-email-shuo.a.liu@intel.com>
         <0e458012-e97b-298d-296e-ed25e35689a0@hartkopp.net>
         <1484226099.15816.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <9e6817a0-65b3-ed16-4616-f8e55aee09c4@hartkopp.net>
         <20170114034330.GA30070@shuo-desktop.sh.intel.com>
         <6dc1d111-9aa4-5771-0283-6408567e47c2@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Liu Shuo <shuo.a.liu@intel.com>, linux-kernel@vger.kernel.org,
        yanmin_zhang@linux.intel.com, shuox.liu@gmail.com,
        Zhang Yanmin <yanmin.zhang@intel.com>,
        "He, Bo" <bo.he@intel.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:CAN NETWORK LAYER" <linux-can@vger.kernel.org>,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <6dc1d111-9aa4-5771-0283-6408567e47c2@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-01-14 at 14:53 +0100, Oliver Hartkopp wrote:
> Hello Eric,
> 
> On 01/14/2017 04:43 AM, Liu Shuo wrote:
> > On Thu 12.Jan'17 at 17:33:38 +0100, Oliver Hartkopp wrote:
> >> On 01/12/2017 02:01 PM, Eric Dumazet wrote:
> 
> >>> The main problem seems that the sockets themselves are not RCU
> >>> protected.
> >>>
> >>> If CAN uses RCU for delivery, then sockets should be freed only after
> >>> one RCU grace period.
> >>>
> >>> On recent kernels, following patch could help :
> >>>
> >>
> >> Thanks Eric!
> >>
> >> @Liu ShuoX: Can you check if Eric's suggestion fixes the issue in your
> >> setup?
> > Sorry for late reply. I was OOO yesterday.
> > With Eric's hint, i just found his patch that "net: add SOCK_RCU_FREE
> > socket flag" in the latest kernel. With backporting this one plus Eric's
> > following patch, it fixs my failure.
> 
> what would be the best approach to fix this issue - even in stable kernels?
> 
> E.g. would this change be ok for a stable as a quick fix?
> 
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index 1108079d934f..6b974c2b66ef 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -112,6 +112,7 @@ EXPORT_SYMBOL(can_ioctl);
> 
>   static void can_sock_destruct(struct sock *sk)
>   {
> +       synchronize_rcu();
>          skb_queue_purge(&sk->sk_receive_queue);
>   }

Adding a synchronize_rcu() at socket close time might have side effects,
if say an application had 1000 such sockets and dies.

This might add 20 seconds of exit time and have serious implications.

I will submit the second patch : It is working for all linux versions.

> 
> And once this arrived in the mainline tree your suggested patch could be 
> applied?
> 
> In any case we should not forget to give Reported-by credits to Liu.

Sure



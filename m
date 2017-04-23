From: Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH 1/1] openvswitch: check return value of
	nla_nest_start
Date: Sun, 23 Apr 2017 13:22:53 -0700
Message-ID: <CAOrHB_CVPKymgbKb-aNS5fqK9Mhe15FtGy0EhkNgSmJ_TSq2PA@mail.gmail.com>
References: <1492929782-1112-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1492929782-1112-1-git-send-email-bianpan2016-9Onoh4P/yGk@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 22, 2017 at 11:43 PM, Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org> wrote:
> Function nla_nest_start() will return a NULL pointer on error, and its
> return value should be validated before it is used. However, in function
> queue_userspace_packet(), its return value is ignored. This may result
> in NULL dereference when calling nla_nest_end(). This patch fixes the
> bug.
>
> Signed-off-by: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
> ---
>  net/openvswitch/datapath.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 9c62b63..34c0fbd 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -489,7 +489,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>                 err = ovs_nla_put_tunnel_info(user_skb,
>                                               upcall_info->egress_tun_info);
>                 BUG_ON(err);
> -               nla_nest_end(user_skb, nla);
> +               if (nla)
> +                       nla_nest_end(user_skb, nla);
There is enough memory allocated for the netlink message accounting
for all attributes beforehand. So it is not required to check retuned
'nla' after each attributes addition to the msg.


>         }
>
>         if (upcall_info->actions_len) {
> @@ -497,7 +498,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>                 err = ovs_nla_put_actions(upcall_info->actions,
>                                           upcall_info->actions_len,
>                                           user_skb);
> -               if (!err)
> +               if (!err && nla)
>                         nla_nest_end(user_skb, nla);
>                 else
>                         nla_nest_cancel(user_skb, nla);
> --
> 1.9.1
>
>
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> https://mail.openvswitch.org/mailman/listinfo/ovs-dev

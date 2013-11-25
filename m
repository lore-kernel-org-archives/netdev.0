From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 6/8] openvswitch: Allow update of dp
 with OVS_DP_CMD_NEW if NLM_F_REPLACE is set
Date: Mon, 25 Nov 2013 13:23:50 -0800
Message-ID: <CAEP_g=8=dzm7NS5zx4-+wY+AXZLpym7JGQO9YTAgdTPm9v1mpQ@mail.gmail.com>
References: <cover.1385137618.git.tgraf@suug.ch>
	<2b77b94f043dbed36a08dcc0a876830d6ad1a97a.1385137618.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <2b77b94f043dbed36a08dcc0a876830d6ad1a97a.1385137618.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 22, 2013 at 8:56 AM, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 95d4424..3f1fb87 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c

I'm a little worried that this introduces some quirks to the interface. Such as:

> @@ -1190,6 +1185,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
>         struct vport *vport;
>         struct ovs_net *ovs_net;
>         int err, i;
> +       bool allocated = false;
>
>         err = -EINVAL;
>         if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])

This requires that DP_CMD_SET supply an OVS_DP_ATTR_UPCALL_PID
although I don't think that it's really necessary. In fact, we used to
completely ignore that field on SET since it's really only useful on
datapath creation and can otherwise be done more naturally through the
vport interface.

> @@ -1197,11 +1193,26 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
>
>         ovs_lock();
>
> +       dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
> +       if (!IS_ERR(dp)) {
> +               if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
> +                       goto update;

Conversely, this won't respect the UPCALL_PID field, which I would
expect it to since I think NLM_F_REPLACE should be roughly equivalent
to a delete and create. I believe that's the only field that is
missing although it seems easy to have the same problem as others are
added in the future.

From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to
	kernel
Date: Mon, 16 Sep 2013 15:38:21 -0500
Message-ID: <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
	<1378711207-29890-8-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1378711207-29890-8-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index 6741d81..2335014 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> +/* Push MPLS after the ethernet header. */
> +static int push_mpls(struct sk_buff *skb,
> +                    const struct ovs_action_push_mpls *mpls)
[...]
> +       /* update mac_len for subsequent pop_mpls actions. */
> +       skb->mac_len += VLAN_HLEN;

Is this supposed to be part of put_vlan()?

[...]

> +       if (skb->ip_summed == CHECKSUM_COMPLETE)
> +               skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> +                                                            MPLS_HLEN, 0));
> +
> +       hdr = (struct ethhdr *)(skb_mac_header(skb));

I think you could simplify this by using eth_hdr().

> @@ -616,6 +736,13 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
>                 goto out_loop;
>         }
>
> +       /* Needed to initialise inner protocol on kernels older
> +        * than v3.11 where skb->inner_protocol is not present
> +        * and compatibility code uses the OVS_CB(skb) to store
> +        * the inner protocol.
> +        */
> +       ovs_skb_set_inner_protocol(skb, skb->protocol);

The comment makes it sound like this code should just be deleted when
upstreaming. However, I believe that we still need to initialize this
field, right? Is this the best place do it or should it be conditional
on adding a first MPLS header? (i.e. what happens if inner_protocol is
already set and the packet simply passes through OVS?)

> diff --git a/datapath/vport-netdev.c b/datapath/vport-netdev.c
> index 215a47e..69f24d1 100644
> --- a/datapath/vport-netdev.c
> +++ b/datapath/vport-netdev.c
> @@ -287,8 +291,17 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> +       inner_protocol = ovs_skb_get_inner_protocol(skb);
> +       if (eth_p_mpls(skb->protocol) && !eth_p_mpls(inner_protocol))
> +               mpls = true;
> +
> +       if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev))
> +               vlan = true;

A couple of thoughts on this:
 - I'm not sure that the check on inner_protocol is right since I
don't think it will be set to an MPLS EtherType in any real situation.
I think you can just drop it.
 - Can we simplify the loop by just inserting the vlan tag (if
necessary), calling skb_gso_segment(), and sending the packet? I think
it should be possible now that our skb_gso_segment() backport is more
robust and it would make things easier to read.
 - Can we have some kind of version check for MPLS, similar to what we
do for VLAN, so that we don't call into this on kernels >= 3.11?

These are all pretty targeted comments though, as was the one in the
previous kernel patch so I am basically happy with this overall.

To move forward with this:
 - Pravin, would you mind double checking the GSO compat code?
 - Ben, do you want to take over for the userspace portions of the
series on the assumption that the above comments can be fixed fairly
easily?

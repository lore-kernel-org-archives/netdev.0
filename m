From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [RFC] [net]openvswitch: Clear the ct flow key for the
 recirculated packet
Date: Thu, 16 Mar 2017 17:12:40 -0700
Message-ID: <CAPWQB7GAJYjHBY1EP+Xyq_9nigSAcKMHb-4eTfvBNf_LQ-NuGA@mail.gmail.com>
References: <af0d1942-726b-b637-e8e3-2f4857bb00a2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Numan Siddique <nusiddiq-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <af0d1942-726b-b637-e8e3-2f4857bb00a2-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On 16 March 2017 at 05:25, Numan Siddique <nusiddiq-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> It is possible that the ct flow key information would have
> gone stale for the packets received from the userspace due to
> clone or ct_clear actions.
>
> In the case of OVN, it adds ping responder flows, which modifies
> the original icmp4 request packet to a reply packet. It uses the
> OVS actions - clone and ct_clear. When the reply packet hits the
> "ovs_ct_execute" function, and since the ct flow key info is not
> cleared, the connection tracker doesn't set the state to
> ESTABLISHED state.
>
> Note: This patch is marked as RFC, as I am not sure if this is the correct
> place to address this issue or it should be addressed in ovs-vswitchd
> to set the OVS_KEY_ATTR_CT_STATE and other related attributes
> properly for ct_clear action.

Hmm. I see a couple of options.

At the moment the ct_clear at the higher layer is not backed by any
action in the datapath layer. Basically we just clear the fields in
the flow metadata then from the OpenFlow point of view there is no
such state, so we can match on it as though it hasn't been through the
connection tracker, and for instance, try to send it through the
connection tracker again. If we were to introduce an openvswitch
kernel API to actually clear the 'skb->nfct' and perhaps the related
ct flow key fields in the kernel, then subsequent ct lookups would not
assume that the skb is already cached, and it should run through the
connection tracker and establish the state.

Alternatively, without changing the OVS API, we could make the actions
a bit smarter. If you change fields related to CT lookup (ie, the
5tuple) via set actions, then the conntrack entry associated with the
skb is no longer valid for the current packet. Clear the skb->nfct
when manipulating those fields, then when the CT action gets executed,
it can treat this packet as completely new and run it through the
connection tracker to establish the state.

I tend to like the latter because it doesn't involve extending the
API, but I can't help but wonder if the fact we've now got a ct_clear
action at the layer above means that eventually we're going to need
the equivalent functionality in the datapath API. Ie, we could solve
this problem but maybe something more detailed and obscure comes up
later where we're not really satisfying the expectations of the
OpenFlow 'ct_clear' action.

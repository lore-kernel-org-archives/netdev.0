From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: add ct_clear action
Date: Tue, 10 Oct 2017 10:24:20 -0700
Message-ID: <CAPWQB7FFNB1vghe+y_Y7B3buYmANjMTaEOgAKVHsmbOsDZxh6g@mail.gmail.com>
References: <20171006164426.9752-1-e@erig.me>
	<CAOrHB_BUVwWqYQcbWiQ69EhnQpY8epqu55pRBGA6g7xG21zSqQ@mail.gmail.com>
	<CAPWQB7FgKYe4Ax08NzW97-WGmriC7j9YhxQF9QtuQZwMjA00bQ@mail.gmail.com>
	<20171010150949.GG26353@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Garver <e@erig.me>, Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>,
	Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20171010150949.GG26353@dev-rhel7>
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

On 10 October 2017 at 08:09, Eric Garver <e@erig.me> wrote:
> On Tue, Oct 10, 2017 at 05:33:48AM -0700, Joe Stringer wrote:
>> On 9 October 2017 at 21:41, Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org> wrote:
>> > On Fri, Oct 6, 2017 at 9:44 AM, Eric Garver <e@erig.me> wrote:
>> >> This adds a ct_clear action for clearing conntrack state. ct_clear is
>> >> currently implemented in OVS userspace, but is not backed by an action
>> >> in the kernel datapath. This is useful for flows that may modify a
>> >> packet tuple after a ct lookup has already occurred.
>> >>
>> >> Signed-off-by: Eric Garver <e@erig.me>
>> > Patch mostly looks good. I have following comments.
>> >
>> >> ---
>> >>  include/uapi/linux/openvswitch.h |  2 ++
>> >>  net/openvswitch/actions.c        |  5 +++++
>> >>  net/openvswitch/conntrack.c      | 12 ++++++++++++
>> >>  net/openvswitch/conntrack.h      |  7 +++++++
>> >>  net/openvswitch/flow_netlink.c   |  5 +++++
>> >>  5 files changed, 31 insertions(+)
>> >>
>> >> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
>> >> index 156ee4cab82e..1b6e510e2cc6 100644
>> >> --- a/include/uapi/linux/openvswitch.h
>> >> +++ b/include/uapi/linux/openvswitch.h
>> >> @@ -806,6 +806,7 @@ struct ovs_action_push_eth {
>> >>   * packet.
>> >>   * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
>> >>   * packet.
>> >> + * @OVS_ACTION_ATTR_CT_CLEAR: Clear conntrack state from the packet.
>> >>   *
>> >>   * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
>> >>   * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
>> >> @@ -835,6 +836,7 @@ enum ovs_action_attr {
>> >>         OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
>> >>         OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
>> >>         OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
>> >> +       OVS_ACTION_ATTR_CT_CLEAR,     /* No argument. */
>> >>
>> >>         __OVS_ACTION_ATTR_MAX,        /* Nothing past this will be accepted
>> >>                                        * from userspace. */
>> >> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> >> index a54a556fcdb5..db9c7f2e662b 100644
>> >> --- a/net/openvswitch/actions.c
>> >> +++ b/net/openvswitch/actions.c
>> >> @@ -1203,6 +1203,10 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>> >>                                 return err == -EINPROGRESS ? 0 : err;
>> >>                         break;
>> >>
>> >> +               case OVS_ACTION_ATTR_CT_CLEAR:
>> >> +                       err = ovs_ct_clear(skb, key);
>> >> +                       break;
>> >> +
>> >>                 case OVS_ACTION_ATTR_PUSH_ETH:
>> >>                         err = push_eth(skb, key, nla_data(a));
>> >>                         break;
>> >> @@ -1210,6 +1214,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>> >>                 case OVS_ACTION_ATTR_POP_ETH:
>> >>                         err = pop_eth(skb, key);
>> >>                         break;
>> >> +
>> >>                 }
>> > Unrelated change.
>> >
>> >>
>> >>                 if (unlikely(err)) {
>> >> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> >> index d558e882ca0c..f9b73c726ad7 100644
>> >> --- a/net/openvswitch/conntrack.c
>> >> +++ b/net/openvswitch/conntrack.c
>> >> @@ -1129,6 +1129,18 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
>> >>         return err;
>> >>  }
>> >>
>> >> +int ovs_ct_clear(struct sk_buff *skb, struct sw_flow_key *key)
>> >> +{
>> >> +       if (skb_nfct(skb)) {
>> >> +               nf_conntrack_put(skb_nfct(skb));
>> >> +               nf_ct_set(skb, NULL, 0);
>> > Can the new conntract state be appropriate? may be IP_CT_UNTRACKED?
>> >
>> >> +       }
>> >> +
>> >> +       ovs_ct_fill_key(skb, key);
>> >> +
>> > I do not see need to refill the key if there is no skb-nf-ct.
>>
>> Really this is trying to just zero the CT key fields, but reuses
>> existing functions, right? This means that subsequent upcalls, for
>
> Right.
>
>> instance, won't have the outdated view of the CT state from the
>> previous lookup (that was prior to the ct_clear). I'd expect these key
>> fields to be cleared.
>
> I assumed Pravin was saying that we don't need to clear them if there is
> no conntrack state. They should already be zero.

The conntrack calls aren't going to clear it, so I don't see what else
would clear it?

If you execute ct(),ct_clear(), then the first ct will set the
values.. what will zero them?

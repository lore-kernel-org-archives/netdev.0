From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 net-next] MPLS: Use mpls_features to
 activate software MPLS GSO segmentation
Date: Mon, 2 Jun 2014 17:45:22 -0700
Message-ID: <CAEP_g=8T6kzvQrxQ8f9B9QKiTJq0t3-Eu26c2hycfHTfZNyJbg@mail.gmail.com>
References: <1401684215-14713-1-git-send-email-horms@verge.net.au>
 <20140602162145.GA3836@casper.infradead.org>
 <20140603001640.GA31821@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140603001640.GA31821-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Mon, Jun 2, 2014 at 5:16 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> On Mon, Jun 02, 2014 at 05:21:45PM +0100, Thomas Graf wrote:
>> On 06/02/14 at 01:43pm, Simon Horman wrote:
>> > +#ifdef CONFIG_NET_MPLS_GSO
>> > +static netdev_features_t net_mpls_features(struct sk_buff *skb,
>> > +                                      struct net_device *dev,
>> > +                                      netdev_features_t features)
>> > +{
>> > +   /* There is no support for MPLS LRO. So the only way that
>> > +    * an MPLS skb could require GSO segmentation is if it
>> > +    * was received as a non-MPLS skb and then became an MPLS skb.
>> > +    * This may be effected by Open vSwitch in which case the
>> > +    * mac_len will non-zero and not equal to skb_network_offset
>> > +    * as the former indicates the end of L2 while the latter indicates
>> > +    * the beginning of L3 and there is a gap between them occupied
>> > +    * by the MPLS label stack.
>> > +    *
>> > +    * Thus it is possible to avoid traversing any VLAN tags that are
>> > +    * present to determine if the ethtype is MPLS. Instead the
>> > +    * inequality of mac_len and skb_network_offset are used to
>> > +    * determine if a packet is MPLS for the purpose of determining
>> > +    * offload features.
>> > +    */
>> > +   if (skb->mac_len && skb->mac_len != skb_network_offset(skb))
>> > +           features &= dev->mpls_features;
>> > +   return features;
>> > +}
>>
>> Could you elaborate a bit on the safety of this? What about
>> GRE GSO which sets mac_len to the inner network offset?
>
> Hi Thomas,
>
> thanks for pointing that out.
>
> It seems to me that I made an error in extending an assumption
> that is true inside the (unmerged MPLS patch for) the Open vSwitch
> datapath to code outside of the datapath. I had thought this
> would be safe as the check should only trigger for packets
> manipulated by the datapath.
>
> I now think that its possible that the GRE GSO code could kick in: if the
> datapath outputs to GRE. And even if that is not the case it seems to me
> that adding an assumption in code in net/core/dev.c to the way mac_len is
> set which has not been universally adopted throughout net/ is asking for
> trouble.
>
> My _untested_ alternate approach as illustrated below is to check the
> ethernet type for MPLS, using skb_network_protocol to account for TEB and
> VLANs.
>
> I am slightly concerned about the performance implications of this
> approach.  I notice harmonize_features() already makes a call to
> skb_network_protocol(). So if performance is a problem perhaps that call
> could be leveraged somehow.

To be honest, I think this actually really belongs as part of
netif_skb_features()/harmonize_features(). The point of those
functions is to return the offloading features that are available for
a given packet, so it's not clear why they wouldn't take MPLS into
account. If we merged them then it would both be cleaner and should
avoid any performance issues.

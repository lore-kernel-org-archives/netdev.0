From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to
	kernel
Date: Fri, 16 May 2014 15:17:18 -0700
Message-ID: <CAEP_g=9JQAqm0oMpVAK-6V-0wtqPw=cRMasJhCG1T5n-AdaLVg@mail.gmail.com>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
 <20140516084809.GA18920@verge.net.au>
 <CAEP_g=-BQJTthV3JbgiiMtCEwM+-YX_sN5VpGkiPQLUVOKP0cg@mail.gmail.com>
 <20140516214806.GH8346@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140516214806.GH8346-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On Fri, May 16, 2014 at 2:48 PM, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
> On 05/16/14 at 02:29pm, Jesse Gross wrote:
>> On Fri, May 16, 2014 at 1:48 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> > On Fri, May 16, 2014 at 08:07:07AM +0900, Simon Horman wrote:
>> >> Allow datapath to recognize and extract MPLS labels into flow keys
>> >> and execute actions which push, pop, and set labels on packets.
>> >
>> > [snip]
>> >
>> >> diff --git a/datapath/linux/compat/gso.h b/datapath/linux/compat/gso.h
>> >> index b83a4c3..98b2aba 100644
>> >> --- a/datapath/linux/compat/gso.h
>> >> +++ b/datapath/linux/compat/gso.h
>> >> @@ -4,6 +4,7 @@
>> >>  #include <linux/version.h>
>> >>  #if LINUX_VERSION_CODE < KERNEL_VERSION(3,12,0)
>> >>
>> >> +#include <linux/netdevice.h>
>> >>  #include <linux/skbuff.h>
>> >>  #include <net/protocol.h>
>> >>
>> >> @@ -14,6 +15,9 @@ struct ovs_gso_cb {
>> >>       sk_buff_data_t  inner_network_header;
>> >>       sk_buff_data_t  inner_mac_header;
>> >>       void (*fix_segment)(struct sk_buff *);
>> >> +#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
>> >> +     __be16                  inner_protocol;
>> >> +#endif
>> >>  };
>> >>  #define OVS_GSO_CB(skb) ((struct ovs_gso_cb *)(skb)->cb)
>> >
>> > Unfortunately it seems that at least for v3.11 on x86_64 the above now
>> > results in struct ovs_gso_cb being larger than the cb field of struct
>> > skb_buff.
>> >
>> > (It also seems that the call to ovs_skb_set_inner_protocol() is
>> >  missing from push_mpls() so it is likely that GSO segmentation
>> >  is broken.)
>> >
>> > I apologise for not noticing this earlier.
>> >
>> > One idea I had is so make inner_protocol union of some other member of
>> > either struct ovs_gso_cb or struct ovs_skb_cb. But its not clear to me that
>> > would fly.
>> >
>> > Another possibility is to simply drop compatibility for segmentation of GSO
>> > packets that become MPLS.  But I gather that is not the preferred way for
>> > datapath features.
>> >
>> > Any suggestions would be much appreciated.
>>
>> Argh, I didn't realize that we were completely at the limit here...
>>
>> This is a little nasty but for the compatibility code maybe we could
>> make the inner offsets be 16 bits. I think this is unlikely to ever
>> cause a problem in practice and so it might be OK for the compat code.
>
> We actually hit the 16bit overflow issue with collapsed TCP frames
> on IB when the headroom grew beyond 64K. See commit 50bceae9bd
> ''tcp: Reallocate headroom if it would overflow csum_start''
> for additional details.

Good point, thanks.

> What about keeping the mac offset 32bit and basing a 16bit net offset
> on the mac offset. That would give 16 spare bits.

I think that could work since we always set both at the same time.

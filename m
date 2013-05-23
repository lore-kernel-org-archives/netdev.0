From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.29] datapath: Add basic MPLS support to kernel
Date: Thu, 23 May 2013 09:46:25 -0700
Message-ID: <CAEP_g=8DmRM7C6OtVjQXS5t7ofOZANWTu_h4xfZSP9RNga97BQ@mail.gmail.com>
References: <1368774397-10700-1-git-send-email-horms@verge.net.au>
 <CAEP_g=8GefFzMPSE0EkaLSTNtPJYtgoOKMaV_hN1ckE-Qxhsog@mail.gmail.com>
 <20130521005519.GA14817@verge.net.au> <CAEP_g=-PDNYWPk+yi4czHw7V822GPRdgNX+csHMByF151Jb5oA@mail.gmail.com>
 <20130523013856.GA22608@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:53107 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759707Ab3EWQqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 12:46:46 -0400
Received: by mail-ie0-f176.google.com with SMTP id at1so9370689iec.35
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 09:46:46 -0700 (PDT)
In-Reply-To: <20130523013856.GA22608@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 6:38 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, May 21, 2013 at 09:07:06AM -0700, Jesse Gross wrote:
>> On Mon, May 20, 2013 at 5:55 PM, Simon Horman <horms@verge.net.au> wrote:
>> > On Fri, May 17, 2013 at 04:14:56PM -0700, Jesse Gross wrote:
>> >> On Fri, May 17, 2013 at 12:06 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> > +static int push_mpls(struct sk_buff *skb,
>> >> > +                    const struct ovs_action_push_mpls *mpls)
>> >> > +{
>> >> > +       __be32 *new_mpls_lse;
>> >> > +       int err;
>> >> > +
>> >> > +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
>> >> > +       if (unlikely(err))
>> >> > +               return err;
>> >> > +
>> >> > +       skb_push(skb, MPLS_HLEN);
>> >>
>> >> What happens if there isn't enough headroom?
>> >
>> > Good point. How about this?
>> >
>> >         if (unlikely(skb->data<skb->head))
>> >                 return -EINVAL;
>> >         skb_push(skb, MPLS_HLEN);
>>
>> The amount of headroom is an internal kernel property so we can't
>> reject actions on the basis of it. We need to expand the headroom,
>> similar to __vlan_put_tag().
>
> Thanks. I have changed the code around and it is now as follows.
> I am a little unsure if the combination of make_writable() and
> skb_cow_head() is sensible.
>
>         err = make_writable(skb, skb->mac_len + MPLS_HLEN);
>         if (unlikely(err))
>                 return err;
>
>         if (skb_cow_head(skb, MPLS_HLEN) < 0)
>                 return -ENOMEM;
>
>         skb_push(skb, MPLS_HLEN);

I would reverse the order of make_writable() and skb_cow_head() to
avoid possibly having to reallocate twice. I think you also don't need
to add MPLS_HLEN to the length in make_writable() because that
function is ensuring that existing packet data can be modified and the
MPLS label isn't there yet.

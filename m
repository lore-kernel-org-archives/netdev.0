From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Thu, 19 Sep 2013 12:21:33 -0500
Message-ID: <CAEP_g=_Eds_XvPLUOhAAMZbxkzmBJEtSR9vVG2kkuRLehrfbDg@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au> <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
 <20130919155732.GC24919@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Pfaff <blp@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:60951 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752323Ab3ISRWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 13:22:08 -0400
Received: by mail-ie0-f178.google.com with SMTP id to1so15335764ieb.23
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 10:21:57 -0700 (PDT)
In-Reply-To: <20130919155732.GC24919@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 19, 2013 at 10:57 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 16, 2013 at 03:38:21PM -0500, Jesse Gross wrote:
>> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
>> > @@ -616,6 +736,13 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
>> >                 goto out_loop;
>> >         }
>> >
>> > +       /* Needed to initialise inner protocol on kernels older
>> > +        * than v3.11 where skb->inner_protocol is not present
>> > +        * and compatibility code uses the OVS_CB(skb) to store
>> > +        * the inner protocol.
>> > +        */
>> > +       ovs_skb_set_inner_protocol(skb, skb->protocol);
>>
>> The comment makes it sound like this code should just be deleted when
>> upstreaming. However, I believe that we still need to initialize this
>> field, right? Is this the best place do it or should it be conditional
>> on adding a first MPLS header? (i.e. what happens if inner_protocol is
>> already set and the packet simply passes through OVS?)
>
> I believe there are several problems here.
>
> The first one, which my comment was written around is that I think that if
> inner_protocol is a field of struct sk_buff then we can rely on it already
> being initialised.  However, if we are using compatibility code, where
> inner_protcol is called in the callback field of struct sk_buff then I
> think that OVS needs to initialise it.

I'm not sure that it's true that inner_protocol is already initialized
- I grepped the tree and the only assignment that I found is in
skbuff.c in __copy_skb_header().

> A second problem is one that you raise which I had not considered
> which is how to handle things if inner_protocol is already set.
>
> I believe this should only occur in the case where inner_protocol
> is a field of struct sk_buff and I think it would be most convenient
> to set it conditionally in ovs_skb_reset_inner_protocol().
> I think that if it is not set it should be zero but it should be
> safe to check for values less than ETH_P_802_3_MIN.

It's probably OK to check for values less than ETH_P_802_3_MIN but I'm
not sure that it's the most correct thing to do since skb->protocol
could contain these values (such as ETH_P_802_2). It's unlikely that
they will be GSO packets but it seems better to use the more strict
check against zero.

One other consideration in the OVS case - with recirculation we may
hit this code multiple times and the difference in behavior could be
surprising. However, on the other hand, we need to be careful because
skb->cb is not guaranteed to be initialized to zero.

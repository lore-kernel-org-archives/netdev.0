From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to kernel
Date: Mon, 23 Sep 2013 18:38:23 -0700
Message-ID: <CAEP_g=8i9djcOWhNEKweg8Qx8LhQ4jD142af2PgfR59yo=SsAA@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au> <CAEP_g=8FBQPZ=C6G39YdHRzG57m5MqfXSZFAX2S_KLHRwfzc2w@mail.gmail.com>
 <20130919155732.GC24919@verge.net.au> <CAEP_g=_Eds_XvPLUOhAAMZbxkzmBJEtSR9vVG2kkuRLehrfbDg@mail.gmail.com>
 <20130922053156.GA4849@verge.net.au> <CAEP_g=969qq6EAmo3mkaJP+tzqHQ9AUHje9j31CpzfD3RoRPaA@mail.gmail.com>
 <20130924013222.GL25601@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Pfaff <blp@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:52969 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751650Ab3IXBir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 21:38:47 -0400
Received: by mail-lb0-f175.google.com with SMTP id y6so3244538lbh.20
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 18:38:44 -0700 (PDT)
In-Reply-To: <20130924013222.GL25601@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 6:32 PM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Sep 23, 2013 at 02:17:50PM -0700, Jesse Gross wrote:
>> On Sat, Sep 21, 2013 at 10:34 PM, Simon Horman <horms@verge.net.au> wrote:
>> > On Thu, Sep 19, 2013 at 12:21:33PM -0500, Jesse Gross wrote:
>> >> On Thu, Sep 19, 2013 at 10:57 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> > On Mon, Sep 16, 2013 at 03:38:21PM -0500, Jesse Gross wrote:
>> >> >> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
>> >> One other consideration in the OVS case - with recirculation we may
>> >> hit this code multiple times and the difference in behavior could be
>> >> surprising. However, on the other hand, we need to be careful because
>> >> skb->cb is not guaranteed to be initialized to zero.
>> >
>> > Thanks, that is also not something that I had considered.
>> >
>> > I'm not sure, but I think that we can rely on skb->cb
>> > not being clobbered between rounds of recirculation.
>> > Or at the very least I think we could save and restore it
>> > as necessary.
>>
>> Yes, it should be safe to assume this.
>>
>> > So I think if we could be careful to make sure that inner_protocol
>> > is in a sane state the first time we see the skb but not
>> > each time it is recirculated then I think things should work out.
>> >
>> > In my current implementation of recirculation the datapath
>> > side is driven ovs_dp_process_received_packet(). So by my reasoning
>> > above I think it would make sense to reset the inner_protocol there
>> > and in ovs_packet_cmd_execute() rather than in ovs_execute_actions()
>> > which each of those functions call.
>>
>> I think that would work, however, I wonder if it's the right place in
>> general, independent of this compatibility issue. I guess it still
>> seems like the ideal thing to do is to move this as close to where it
>> is necessary as possible, specifically in mpls_push(). Is there a
>> reason to not put it there (again, other than the out-of-tree
>> compatibility issues)?
>
> I agree that should work, out-of-tree compatibility issues aside.
>
> Perhaps a solution is to have a conditional set_inner_protocol call inside
> push_mpls, where the condition is that inner_protocol is zero.
> And a reset_inner_protocol call earlier on, a call that sets inner_protocol
> to zero only if the compatibility code is in use and thus it resides in
> struct ovs_gso_cb. This call could be remove once the compatibility
> code is no longer needed, that is once kernels older than 3.11 are no
> longer supported.

I agree that's probably the right solution.

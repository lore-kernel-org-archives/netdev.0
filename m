From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: compute needed headroom for internal vports
Date: Tue, 12 Jan 2016 21:27:12 -0800
Message-ID: <CAOrHB_C0pt9=84t8Jzr1YL5n=Ap2frSy1rBipUqs84mGpg+o3g@mail.gmail.com>
References: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
	<CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
	<CAEh+42hN8wL7bbALB8SGCKvum2pzT3R0kXUtMfQPg-XP-QZ7Dg@mail.gmail.com>
	<CAOrHB_Bo2iqp2xGaZpOb2AvriGTTruC_O72hQ7LqKnkbR_CAeA@mail.gmail.com>
	<1452501788.5027.13.camel@redhat.com>
	<CAOrHB_DL6DpyoLYZroccPR7mjUuMM-JN6p-=o6XE53Ltb_Cq0w@mail.gmail.com>
	<CAEh+42hr8JneX5bufHNqbVFfnCXkU1iz7n0Pc4UQfm==rKF9Dw@mail.gmail.com>
	<CAOrHB_C=GxDbZBdKCo0j2z-dNTKRQ6GcpWYr6qGxuF_SxughJg@mail.gmail.com>
	<CAEh+42hvvNG7LRZtL0HjPFny7p2Cu_Bkv4k1aYQxXAWZST4yQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paolo Abeni <pabeni@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:54556 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbcAMF1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 00:27:16 -0500
Received: from mfilter29-d.gandi.net (mfilter29-d.gandi.net [217.70.178.160])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id CE01741C08F
	for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 06:27:14 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter29-d.gandi.net (mfilter29-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id CPYOlb6e8nnD for <netdev@vger.kernel.org>;
	Wed, 13 Jan 2016 06:27:13 +0100 (CET)
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 5ACF641C08B
	for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 06:27:13 +0100 (CET)
Received: by mail-ig0-f171.google.com with SMTP id z14so143164873igp.1
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 21:27:13 -0800 (PST)
In-Reply-To: <CAEh+42hvvNG7LRZtL0HjPFny7p2Cu_Bkv4k1aYQxXAWZST4yQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 5:08 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Tue, Jan 12, 2016 at 12:44 PM, pravin shelar <pshelar@ovn.org> wrote:
>> On Tue, Jan 12, 2016 at 11:20 AM, Jesse Gross <jesse@kernel.org> wrote:
>>> On Mon, Jan 11, 2016 at 4:34 PM, pravin shelar <pshelar@ovn.org> wrote:
>>>> On Mon, Jan 11, 2016 at 12:43 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>>>> On Fri, 2016-01-08 at 18:44 -0800, pravin shelar wrote:
>>>>>> On Fri, Jan 8, 2016 at 4:42 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>>>> > On Fri, Jan 8, 2016 at 2:53 PM, pravin shelar <pshelar@ovn.org> wrote:
>>>>>> >> On Fri, Jan 8, 2016 at 1:50 PM, Paolo Abeni <pabeni@redhat.com> wrote:
>>>>>> >>> Currently the ovs internal vports always use a default needed_headroom.
>>>>>> >>> This leads to a skb head copy while xmitting on ovs swith via vport
>>>>>> >>> that add some kind of encapsulation (gre, geneve, etc.).
>>>>>> >>>
>>>>>> >>> This patch add book-keeping for the maximum needed_headroom used by
>>>>>> >>> the non internal vports in any dp, updating it on vport creation and
>>>>>> >>> deletion.
>>>>>> >>>
>>>>>> >>> Said value is than used as needed_headroom for internal vports,
>>>>>> >>> avoiding the above copy.
>>>>>> >>>
>>>>>> >> Why is this done only for internal devices? In most common case of
>>>>>> >> traffic the packet enters OVS from tap or other netdev type vport
>>>>>> >> device.
>>>>>> >
>>>>>> > How would you influence the allocation for non-internal devices?
>>>>>>
>>>>>> Today there is no way of influencing this. But we could add new
>>>>>> skb-headroom parameter to netdev for packets that are received on the
>>>>>> device. This new parameter could be controlled from master devices
>>>>>> like OVS, Bridge, etc. To set this value we need new ndo operation. So
>>>>>> that it can work on devices like tap where it would just set this new
>>>>>> value and in case of ovs-internal or veth device, it can also update
>>>>>> needed_headroom.
>>>>>
>>>>> My idea was to continue working along this lines.
>>>>>
>>>>> However I thought to get there incrementally, i.e. handle internal
>>>>> vports only first. Can this be ok for you?
>>>>>
>>>>
>>>> If the final implementation is going to change alot, then I do not see
>>>> much value in this change going in first.
>>>
>>> Even if the code will change in the future, it seems like an
>>> incremental improvement that will help in some cases so I don't see
>>> much reason to not do this part now.
>>
>> I am not sure which cases it help. Can you tell me use cases for
>> internal port in production?
>
> Any traffic coming from the hypervisor itself (as well as tunnels
> although unless you are doing double encapsulation then this patch
> doesn't matter in that case).
>

ok, But majority of traffic comes from VM. So IMO only this patch
would not make much difference.

> Since we're in the merge window now, maybe it makes sense to just go
> for the full version in the next cycle in any case.

ok.

From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH v2.56] datapath: Add basic MPLS support to kernel
Date: Tue, 29 Apr 2014 11:41:57 -0700
Message-ID: <CAEP_g=8Or4axD_1Ztuc8+LHVZUKs6W0bsfNQxOHzGGENS0br-w@mail.gmail.com>
References: <20140424232441.GA6282@verge.net.au> <20140425080639.DDFA371E74@kuma.localdomain>
 <CAEP_g=8y=jXukP=a2xyk4XMTrBLYWPQOgbTO_h8LE_mVMB9tFQ@mail.gmail.com>
 <20140428070012.GB21494@verge.net.au> <CAEP_g=-p1Zrs7ETjRrSLK+ug0Y7tbsF5U77K29tYyMTDk_0b4Q@mail.gmail.com>
 <20140429001317.GB31083@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	ravi kerur <rkerur@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog031.obsmtp.com ([74.125.150.105]:54511 "HELO
	na6sys009bog031.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752496AbaD2SmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 14:42:19 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so658716iec.24
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 11:42:18 -0700 (PDT)
In-Reply-To: <20140429001317.GB31083@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 5:13 PM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Apr 28, 2014 at 02:37:47PM -0700, Jesse Gross wrote:
>> On Mon, Apr 28, 2014 at 12:00 AM, Simon Horman <horms@verge.net.au> wrote:
>> > On Fri, Apr 25, 2014 at 12:57:20PM -0700, Jesse Gross wrote:
>> >> On Fri, Apr 25, 2014 at 1:06 AM, YAMAMOTO Takashi
>> >> <yamamoto@valinux.co.jp> wrote:
>> >> >> On Thu, Apr 24, 2014 at 05:57:29PM +0900, YAMAMOTO Takashi wrote:
>> >> >>> hi,
>> >> >>>
>> >> >>> > + * Due to the sample action there may be multiple possible eth types.
>> >> >>> > + * In order to correctly validate actions all possible types are tracked
>> >> >>> > + * and verified. This is done using struct eth_types.
>> >> >>>
>> >> >>> is there any real-world use cases of these actions inside a sample?
>> >> >>> otherwise, how about just rejecting such combinations?
>> >> >>> it doesn't seem to worth the code complexity to me.
>> >> >>> (sorry if it has been already discussed.  it's the first time for me
>> >> >>> to seriously read this long-lived patch.)
>> >> >>
>> >> >> Good point, the code is rather complex.
>> >> >>
>> >> >> My understanding is that it comes into effect in the case
>> >> >> of sflow or ipfix being configured on the bridge. I tend
>> >> >> to think these are real-world use-cases, though that thinking
>> >> >> is by no means fixed.
>> >> >>
>> >> >> My reading of the code is that in the case of sflow and ipfix a single
>> >> >> sample rule appears at the beginning of the flow. And that it may be
>> >> >> possible to replace the code that you are referring to with something
>> >> >> simpler to handle these cases.
>> >> >
>> >> > it seems that they put only a userland action inside a sample.
>> >> > it's what i expected from its name "sample".
>> >>
>> >> Yes, that's the only current use case. In theory, this could be used
>> >> more generally although nothing has come up yet.
>> >>
>> >> In retrospect, I regret the design of the sample action - not the part
>> >> that allows it to handle different actions but the fact that the
>> >> results can affect things outside of the sample action list. I think
>> >> that if we had made it more like a subroutine then that would have
>> >> retained all of the functionality but none of the complexity here.
>> >> Perhaps if we can find a clean way to restructure it without breaking
>> >> compatibility then that would simplify the validation here.
>> >
>> > I have not thought deeply about this but it seems to me that it should be
>> > easy enough to provide compatibility for a new user-space to work with both
>> > new and old datapaths.  But it is not clear to me how to achieve the
>> > reverse: allowing a new datapath to work with both new and old user-spaces.
>> > I assume that we care about such compatibility.
>>
>> Generally, I would say yes although there is potentially some room for
>> debate here. No version of OVS userspace has ever put an action other
>> than userspace in the sample field. I know that other people have
>> talked about writing different userspaces that run on the OVS kernel
>> module but I highly doubt that they use this action or would do so
>> differently. I can't prove that but it might be OK to bite the bullet.
>
> I am also concerned about the sample() action which is exposed via OpenFlow
> (as a Nicira extension) and in turn ovs-ofctl.  Thus it seems to me that
> there could be users adding flows with sample actions whose behaviour would
> either no longer be supported or would be changed.  But I believe that we
> should reason about this case the same way that you reason about alternate
> user-spaces above.

The sample action exposed through OpenFlow is a little different. It
allows you to specify where in the action list to do sampling but it
doesn't allow arbitrary actions to be embedded. As a result, it still
always embeds a userspace action, which should be safe because it is
idempotent.

> Perhaps a way forward would be (for me) to come up with a prototype to
> alter the sample action. And we can see how clean it is (or could be) and
> what it buys us.
>
> It seems that the motivation for this change is is twofold: To contain the
> sample action in the hope of making it easier to deal with in the future
> and; to avoid some rather complex verification code introduced in the MPLS
> datapath patch. And I think it would be good to keep that in mind when
> assessing any prototype code.

That sounds reasonable to me.

From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 6/6] openvswitch: Support VXLAN Group Policy extension
Date: Tue, 13 Jan 2015 14:15:25 -0800
Message-ID: <CAEP_g=9=am_n_aSjA8mxOaViUMEaJgfr8DpMG9GsbitJm8006w@mail.gmail.com>
References: <cover.1421064100.git.tgraf@suug.ch> <60651d9355f4e34ed6686d95ad837467a1d2c888.1421064100.git.tgraf@suug.ch>
 <CAEP_g=8TnrwdGiTOB_mKeQSsEakV8y2OU7_ARwi+j9WDYh=Wag@mail.gmail.com> <20150113010213.GA20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:37632 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751946AbbAMWPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:15:46 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so4651721qcv.8
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 14:15:45 -0800 (PST)
In-Reply-To: <20150113010213.GA20387@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 5:02 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/12/15 at 01:54pm, Jesse Gross wrote:
>> On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
>> > +       if (!is_mask)
>> > +               SW_FLOW_KEY_PUT(match, tun_opts_len, sizeof(opts), false);
>> > +       else
>> > +               SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff, true);
>>
>> Have you thought carefully about how the masking model work as other
>> extensions are potentially added? This was a little tricky with Geneve
>> because I wanted to be able to match on both "no options present" as
>> well as wildcard all options. The other interesting thing is how you
>> serialize them back correctly to userspace, which was the genesis of
>> the TUNNEL_OPTIONS_PRESENT flag.
>>
>> My guess is that this may basically work fine now that there is only
>> one extension present but it is important to think about how it might
>> work with multiple independent extensions in the future. (I haven't
>> thought about it, I'm just asking.)
>
> I currently don't see a reason why adding another extension would be
> a problem. It should work like Geneve options except that the order
> of the options in the flow is given (struct vxlan_opts).
>
> Matching on "no options present" is supported in the datapath by
> via the TUNNEL_VXLAN_OPT flag although there is no way in user space
> to express this intent yet. I haven't come across a need to support it
> yet.
>
> Since the Netlink API is decoupled from the datapath flow
> representation, all of this can be changed if needed without breaking
> the Netlink ABI.

OK, it seems fine for now.

I agree that "not present" is probably less interesting for VXLAN than
Geneve given the fixed sized header. It would seem to only have
benefit in the event that the port configuration is decoupled from
flow processing in userspace.

>> If you set Geneve options and output to a VXLAN port (or vice versa),
>> you will get garbage, right? Is there any way that we can sanity check
>> that?
>
> What about if we only apply tun_info->options on Geneve if
> TUNNEL_GENEVE_OPT is set and vice versa?

That seems nice and simple to me.

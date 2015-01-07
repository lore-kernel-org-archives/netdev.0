From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/6] vxlan: Allow for VXLAN extensions to be implemented
Date: Wed, 7 Jan 2015 14:45:31 -0800
Message-ID: <CAEP_g=_Xr=6nVoeVT8dgRZoM0bNXDiiua5GrjweZ1GaT1ixhZg@mail.gmail.com>
References: <cover.1420594925.git.tgraf@suug.ch> <7c5e8240263a22a69042c45a632c9940e5ae1062.1420594925.git.tgraf@suug.ch>
 <CA+mtBx_mp1mf_HPp5u9wDfgeOc8pt26Mf1VHFZTAqDhTdZe7cw@mail.gmail.com> <20150107102740.GM21820@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:38261 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750865AbbAGWp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:45:59 -0500
Received: by mail-qa0-f48.google.com with SMTP id k15so4787062qaq.7
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 14:45:53 -0800 (PST)
In-Reply-To: <20150107102740.GM21820@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 2:27 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/06/15 at 07:46pm, Tom Herbert wrote:
>> On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > The VXLAN receive code is currently conservative in what it accepts and
>> > will reject any frame that uses any of the reserved VXLAN protocol fields.
>> > The VXLAN draft specifies that "reserved fields MUST be set to zero on
>> > transmit and ignored on receive.".
>> >
>> IMO it is an unfortunate decision in VXLAN to ignore set reserved
>> fields on receive. Had they not done this, then adding a protocol
>> field to the header would have been feasible and we wouldn't need yet
>> another encapsulation protocol (i.e. VXLAN-GPE). Rejecting frames with
>> reserved bits set is the better behavior, but I think the comment
>> about this needs to be clear about why this diverges from RFC7348.
>
> Agreed. Do you want to give it a shot? I know you have been involved
> on all aspects of this topic for a long time in NVO3 ;-)

There is little chance of this happening. Besides the IETF procedural
aspects, ignoring unknown reserved bits on receive is the long
standing standard way of extending protocols. It's how TCP was
extended to support ECN, for example.

>> > Retain the current conservative parsing behaviour by default but allows
>> > these fields to be used by VXLAN extensions which are explicitly enabled
>> > on the VXLAN socket respectively VXLAN net_device.
>> >
>> Conceptually, VXLAN has both mandatory flags and optional flags for
>> extensions. You may want to look at the VXLAN RCO patches that added
>> an extension and infrastructure for them.
>
> I've seen your proposed changes. I think they could be easily rebased
> on top of this and use the enablement infrastructure. In fact, I see
> this as the only feasible option to deal with VXLAN extensions: Leave
> it to the user to decide which extensions to run. That way we can
> support any combination of extensions, even conflicting ones. All we
> have to do is catch incompatible extension configurations on a socket
> and reject them at configuration time. Expecting that NVO3/IETF will
> find consensus on a list of compatible set of extensions with perfect
> forward and backwards compatibility is unrealistic in my eyes. We have
> Geneve and GUE to solve it properly in the future.

My concern is that having multiple (and potentially overlapping)
extensions is going to make the VXLAN code very messy and hard to
follow. I think there's already quite a big of complexity there from
the DOVE extensions (which are basically dead at this point to the
best of my knowledge). We already see this some with the discussion
over the header struct but that's just the beginning - can you imagine
the code that checks a single bit for several different
interpretations? Not to mention the fact that the location of the bits
in some of these proposals has already been shuffled several times. It
seems very painful...

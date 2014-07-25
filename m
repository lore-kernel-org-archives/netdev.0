From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 10/10] openvswitch: Add support for Geneve tunneling.
Date: Thu, 24 Jul 2014 21:04:20 -0400
Message-ID: <CAEP_g=-qa_DEd_2JjtFvsiuLjpN+F5cY8V8XkQrYjiBZ7CcFDw@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
 <1406024393-6778-11-git-send-email-azhou@nicira.com> <CA+mtBx8UWoQhgGoXtyh=hHkhbodZyC8JSxnCfZFM5CpUT1ZZ9A@mail.gmail.com>
 <CAEP_g=_1q3ACX5NTHxLDnysL+dTMUVzdLpgw1apLKEdDSWPztw@mail.gmail.com>
 <CA+mtBx9umxiFYtnG1kzFkK+Ev=b=4f3q2OOow2QcfCB5rUTUyA@mail.gmail.com>
 <CAEP_g=-ODoKmfk871wZyDfvtM=V5yYGKgCh0cVS0diU=LNSMPQ@mail.gmail.com> <CA+mtBx-A1xAeMtdtLW3LF612ypExVmGPaG3Dz2AwcR5t0Obe4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:51650 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750772AbaGYBEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 21:04:41 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so4259495qgd.5
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 18:04:40 -0700 (PDT)
In-Reply-To: <CA+mtBx-A1xAeMtdtLW3LF612ypExVmGPaG3Dz2AwcR5t0Obe4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2014 at 7:45 PM, Tom Herbert <therbert@google.com> wrote:
> On Thu, Jul 24, 2014 at 3:59 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Thu, Jul 24, 2014 at 12:43 PM, Tom Herbert <therbert@google.com> wrote:
>>> On Wed, Jul 23, 2014 at 9:10 PM, Jesse Gross <jesse@nicira.com> wrote:
>>>> On Wed, Jul 23, 2014 at 4:29 PM, Tom Herbert <therbert@google.com> wrote:
>>>> > This check also applies in the OAM case where there is no data packet
>>>> > but we still enforce the protocol field to be Ethernert (meaning of
>>>> > prot_type when OAM bit is set is ambiguous in the draft). As I
>>>> > mentioned on the nvo3 list, this OAM bit is really a 1-bit packet
>>>> > type. If this bit is donated to version field (make it a type version
>>>> > field) then we can switch on ver_type above and create another
>>>> > processing path for OAM so that the prot_type is at least not
>>>> > unnecessarily verified in that case and the bits could even be reused
>>>> > for some OAM specific purpose.
>>>>
>>>> I think the draft is clear :) The value of the OAM bit does not change
>>>> the interpretation of the protocol field. This is true in the other
>>>> drafts as well.
>>>
>>>
>>>>
>>>> OAM packets are essentially just high priority packets (presumably
>>>> with some kind of control semantics but that depends on the control
>>>> plane). That means that they might be BFD or some other heartbeat,
>>>> header fragments for tracing, or really anything else that should be
>>>> treated as control. In all of these cases, the protocol type still
>>>> needs to indicate the format of the data.
>>>>
>>> I see, I think you're saying that control messages still contain some sort
>>> of message after Geneve header whose type is indicated by protocol field.
>>> So, if OAM doesn't change the interpretation of the protocol field then this
>>> must be an Ether_type protocol, hence control messages must be formatted as
>>> Ether_types. So then I would extrapolate that control messages could be
>>> directled to the control plane based on demux of protocol field (ie. type is
>>> something like NSH, or a new control message Ethertype). Consequently, the
>>> OAM bit is really just a hint to request expedited processing but does not
>>> influence demux so could in theory be ignored without loss of functionality.
>>> Is this interpretation correct?
>>
>> Yes, this is largely correct. There is one other possible significance
>> to the OAM flag, which is to say "do not forward the resulting packet
>> after decapsulation". I think this is slightly less likely to be an
>> issue for Geneve (although I can imagine situations where it might be)
>> but it was a problem with TRILL OAM, which used data-like packets and
>> has no OAM bit. The result is that they had to use all kinds of
>> special addresses and other things to separate out data traffic from
>> OAM.
>>
> Thanks for the clarification.
>
>>> A concrete example of a control message with headers would be useful in
>>> understanding OAM bit. For instance, how would would a mechanism to
>>> implement NAT keepalive of UDP flows be implemented (see RFC3948 for how
>>> this was done in ESP/UDP)?
>>
>> A real example that comes to mind is if you want to have a heartbeat
>> protocol such as CFM or BFD. You would set the appropriate EtherType
>> for this protocol and then run it as the payload. As you said, it
>> would already be obvious that this is a control protocol based on the
>> EtherType and the OAM bit is not strictly required. However, it would
>> allow easy (and generic) separation of control traffic from data
>> traffic so in the event that you have a flood of data packets, the
>> heartbeats can prioritized to avoid detecting a failure.
>>
>
> I don't see a whole lot of value in using a OAM bit as a priority bit,
> we don't have any support in the network which is where we really need
> to apply priority. There are already existing mechanisms in the
> network to deal with prioritization which are more generic (IP TOS,
> Ether priority) and could work today. Sender of these control message
> should be setting priority to reflect it.

Some things can be done with ToS marking but this is really more a
"send to control plane" bit (which could be a special queue in a host
or the management CPU in a physical switch), which is a little
different from priority. Between the semantics of distinguishing
control packets from data packets and different queuing I think it
ends up proving to be fairly useful.

>> If I was trying to implement just a totally simple keep alive, then
>> there's really no need to put anything in the payload. I would
>> probably just set the EtherType to zero (guaranteed to be unused) and
>> leave it at that.
>
> Interesting idea. I don't think 0 has be reserved for this purpose,
> but it does seem like a NULL ether_type might be useful. Has any other
> encapsulation protocol carrying ether_type specific special meaning of
> zero?

This has never come up as something that I've needed, so I haven't
really researched/designed it all that much. An EtherType of zero is
guaranteed to be unused since it is reserved for compatibility with
802.2 frames but I don't know of anyone else using it that way.
However, I agree that having a NULL EtherType seems potentially
useful.

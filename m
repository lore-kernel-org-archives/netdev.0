From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Fri, 24 Oct 2014 22:58:18 +0800
Message-ID: <CAK6E8=fiHrgicTXy2hBGh0GUcZRWWxpYxw_bNVmRD+ueN9mUdw@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
 <20141022.121418.1477947755244353588.davem@davemloft.net> <CAKfDRXgARYe3hw3vgpgup1X4bNjH0cpwYOfKUZK51HcOf2jeJA@mail.gmail.com>
 <CAPh34mechU=aUS422OBFhHUt68Nk2PZBsMiLPw8eLwS_4PnRtw@mail.gmail.com> <CAKfDRXhJ9c+AqqrD38e7RcUSXn21pNMWskRs38H+PnSEwXac+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:41346 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406AbaJXO67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 10:58:59 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so514270igc.12
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 07:58:58 -0700 (PDT)
In-Reply-To: <CAKfDRXhJ9c+AqqrD38e7RcUSXn21pNMWskRs38H+PnSEwXac+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 4:33 AM, Kristian Evensen
<kristian.evensen@gmail.com> wrote:
> Hi,
>
> I am very sorry for not explaining the scenario/use-case properly.
> Freeze-TCP is mostly targeted at TCP connections established through
> mobile broadband networks. One example scenario is that of when a user
> moves outside of an area with LTE coverage. The mobile broadband
> connection will then be downgraded to 2G/3G and this process takes
> 10-15 seconds in the networks I have been able to measure. During this
> handover, the modem/device will in most cases report that it is still
> connected to LTE. So just looking at the state of the link is not good
> enough, as it will appear to be working fine (except for no data
> coming through it). The device does not change IP address, so TCP
> connections will resume normal operation as soon as the network
> connection is re-established and packet is retransmitted. However,
> because of the large "idle" period, this can take another 10-15
> seconds.
>
> On Wed, Oct 22, 2014 at 9:50 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>> At least better. But what userspace daemon would configure this?
>> Likely NetworkManager and friends. But at what conditions?
>
> Yes, that would be my suggestion for tools too. The conditions would
> depend on the kind of network, available information and so on.
>
>> In a NATed scenario there is no gain because IP addreses change and
>> the connection is lost anyway. For the signal strength thing there
>> might be an advantage but it has costs:
>>
>> a) how long did you freeze the connection? What if NetworkManager
>> stops? The connection hang \infty
>> b) is it not better to inform the upper layer - the application - that
>> something happen with the link?
>>
>> I mean when the application experience disruptions, the application
>> can decide what it do: reconnect, reconnect and resend or inform the
>> user. This possibility is now lost/hidden. Maybe it is no problem -
>> maybe it is for some applications.
>
> This is the main reason why I went with a socket option. While I
> worked on this patch I wrote a small daemon for testing purposes. This
> daemon analyses data exported from a mobile broadband modem (QMI),
> looks at total interface throughput and then multicasts a netlink
> message when it determines that a handover might happen. This message
> is only a hint and then it is up to the application developer to
> decide what to do. Another solution would be a hybrid, the module will
> works as I described and the socket option will be used as an opt-in
> for Freeze-TCP.
>
>>
>> Do you have considered to bring this to the IETF (TCPM WG)?
>>
>
> Yes, I am currently considering it, or if I should look into different
> solutions before bringing it up for discussion. The ideal solution
> would be if there was a way to force a retransmit when the handover
> period is over, but that opens a whole net set of problems, potential
> security problems and changes TCP semantics a bit. An advantage of
Do packets actually get dropped during the handover period? if not
then the sender can detect spurious RTOs and undo the cwnd reductions
with timestamps or DSACKs (Eifel). Eifel did not exist when the
freeze-TCP was published at 2000. Even if the connection does not
support these options as major TCP stacks do, slow-start on a path
with new BDP isn't that bad of an idea.

> Freeze-TCP is that it works fine with what we have today.
>
> Thanks for your detailed comments!
>
> Kristian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

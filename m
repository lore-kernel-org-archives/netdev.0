From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Thu, 22 Jun 2017 17:28:25 +0300
Message-ID: <CAJ3xEMhyOiQX_jTpD5zWKY0oNkBoU1jyG3SMTpA091O8TbrjLA@mail.gmail.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
 <20170620122417.0c60582e@cakuba.netronome.com> <CAJ3xEMjTLs0aDLY_zDerm8o0yPmJktzBDE2rJ=QwXQZeS1+qCg@mail.gmail.com>
 <20170621024238.021e1f77@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35710 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdFVO20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 10:28:26 -0400
Received: by mail-oi0-f44.google.com with SMTP id c189so9827097oia.2
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 07:28:26 -0700 (PDT)
In-Reply-To: <20170621024238.021e1f77@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 12:42 PM, Jakub Kicinski <kubakici@wp.pl> wrote:

> Let me try to describe it a bit more instead.  Sorry but I'm not great
> at ASCII art at this level of complexity and while having to stay
> within 80 chars ;)
>
> Driver communicates with the Management FW via a mailbox.
>
> Driver loads, it gets the Application FW from disk.  It pushes the
> entire FW to the mailbox and tells the Management FW to load it.  At
> this point the PCIe datapath is loaded and driver discovers what
> other communication channels are available.
>
> Driver checks which FW is loaded and finds appropriate nfp_app callbacks
> for that FW.  If the nfp_app requires control message channel it will
> map the control message queue/vNIC.  Driver spawn netdevs for
> data vNICs.  Flower nfp_app may upon init spawn physical port
> representors (single NFP chip supports tens of ports so they are not
> all guaranteed a full vNIC in many designs).  Whenever representor is
> spawned Application FW is notified with a control message.
>
> When user enables SR-IOV nfp_app sriov callback will be invoked and
> flower nfp_app will respond by spawning VF reprs.  First version of the
> Flower APP targets only the switchdev mode.  We plan to add legacy mode
> and automatically pre-populate the rules if there is user interest.
> Although I personally hope that people interested in legacy SR-IOV will
> use our simpler CoreNIC app FW...  Flower APP will initially come up in
> switchdev mode, no rules installed, all traffic will simply end up at
> representors.

This is much clearer now, thanks for explaining that over. Will be happy
if you can elaborate a bit on the automatic tables pre-population for
legacy mode emulation, sounds interesting.


>> The VF reps where introduced hand in hand with the devlink way to create/destroy
>> them -- e.g the devlink eswitch commands (mode change, show, enable encap, etc).

> Yes, indeed.  FWIW for programmable HW the question of mode of
> operation is more complex than selection between eswitch modes.  We
> are planning on extending devlink and our driver to handle more
> configurations as well as to expose more useful info.  But we need to
> start somewhere :)  We felt like this set with representors will
> establish a good base.  Next set will introduce basic Flower offload
> (~populating tables and reading stats).  And we can build on top of that.

I think you got it, when sriov is set on the NIC and you load this app,
we're in switchdev mode, so the devlink eswitch mode set need not be
called by user-space. But, further configuration eswitch changes could
(and would) be done through devlink callbacks.

> I think you're referring to the fact that we start in switchdev mode?
> I thought you would be happy to see a driver which doesn't even bother
> with the legacy mode ;)

YES, I am happy to see that you start in switchdev mode. I wasn't sure
why the devlink way of further configuring the eswitch can't apply for npf,
but now you made that clear it does apply.

Or.

From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Wed, 21 Jun 2017 02:42:38 -0700
Message-ID: <20170621024238.021e1f77@cakuba.netronome.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
        <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
        <20170620122417.0c60582e@cakuba.netronome.com>
        <CAJ3xEMjTLs0aDLY_zDerm8o0yPmJktzBDE2rJ=QwXQZeS1+qCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:6335 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751434AbdFUJmt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 05:42:49 -0400
In-Reply-To: <CAJ3xEMjTLs0aDLY_zDerm8o0yPmJktzBDE2rJ=QwXQZeS1+qCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jun 2017 12:00:50 +0300, Or Gerlitz wrote:
> On Tue, Jun 20, 2017 at 10:24 PM, Jakub Kicinski
> <jakub.kicinski@netronome.com> wrote:
> > On Tue, 20 Jun 2017 19:13:43 +0300, Or Gerlitz wrote:  
> 
> >>> Control queues are used to send and receive control messages which are
> >>> used to communicate configuration information with the firmware. These
> >>> are in separate vNIC to the queues belonging to the PF netdev. The control
> >>> queues are not exposed to use-space via a netdev or any other means.  
> 
> >> Do you have documentation for the control channel or I should look on
> >> earlier commits?  
> 
> > We don't have any docs, the ctrl channel was merged in e5c5180a2302
> > ("Merge branch 'nfp-ctrl-vNIC'").  The "control channel" is essentially
> > a normal data queue which is specially marked as carrying control
> > messages.  
> 
> >> The control messages you describe here are also the ones that are used
> >> to load/unload specific app?  
> 
> > No, the app loading, PHY port management and other low-level tasks are
> > handled by management FW.  The control messages are an application FW
> > construct.  The control messages are transported by the datapath and
> > since the datapath is entirely under control of apps the management FW
> > can't depend on it.  The apps today also completely reload the PCIe
> > datapath implementation (which is software defined), so we need to use
> > raw memory mappings to communicate with management FW.  
> 
> > The control messages are mostly used for populating tables and reading
> > statistics, because those two need to be fast and low overhead.  
> 
> Thanks Jakub for that clarification -- I still not sure to see the
> high level picture -
> will appreciate if you can make a simple  text based sketch here of the
> source/dest/sequence of calls/messages (say) from the time the driver is loaded
> to when sriov is set with VFs and VF reps

Let me try to describe it a bit more instead.  Sorry but I'm not great
at ASCII art at this level of complexity and while having to stay
within 80 chars ;)

Driver communicates with the Management FW via a mailbox.

Driver loads, it gets the Application FW from disk.  It pushes the
entire FW to the mailbox and tells the Management FW to load it.  At
this point the PCIe datapath is loaded and driver discovers what
other communication channels are available.

Driver checks which FW is loaded and finds appropriate nfp_app callbacks
for that FW.  If the nfp_app requires control message channel it will
map the control message queue/vNIC.  Driver spawn netdevs for
data vNICs.  Flower nfp_app may upon init spawn physical port
representors (single NFP chip supports tens of ports so they are not
all guaranteed a full vNIC in many designs).  Whenever representor is
spawned Application FW is notified with a control message.

When user enables SR-IOV nfp_app sriov callback will be invoked and
flower nfp_app will respond by spawning VF reprs.  First version of the
Flower APP targets only the switchdev mode.  We plan to add legacy mode
and automatically pre-populate the rules if there is user interest.
Although I personally hope that people interested in legacy SR-IOV will
use our simpler CoreNIC app FW...  Flower APP will initially come up in
switchdev mode, no rules installed, all traffic will simply end up at
representors.

> The VF reps where introduced hand in hand with the devlink way to create/destroy
> them -- e.g the devlink eswitch commands (mode change, show, enable encap, etc).

Yes, indeed.  FWIW for programmable HW the question of mode of
operation is more complex than selection between eswitch modes.  We
are planning on extending devlink and our driver to handle more
configurations as well as to expose more useful info.  But we need to
start somewhere :)  We felt like this set with representors will
establish a good base.  Next set will introduce basic Flower offload
(~populating tables and reading stats).  And we can build on top of
that.

> Taking your comment that the channels are mostly used for table
> population and such,
> is there any real reason for you not to use devlink for applying the
> configuration? you can
> communicate with the FW from your devlink callbacks, isn't that?

I think you're referring to the fact that we start in switchdev mode?
I thought you would be happy to see a driver which doesn't even bother
with the legacy mode ;)

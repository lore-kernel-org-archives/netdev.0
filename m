From: jamal <hadi@cyberus.ca>
Subject: Bug in e1000 + semantics of flow control WAS(Re: [e1000]: flow
	control on by default - good idea really?
Date: Thu, 20 Jul 2006 16:15:57 -0400
Message-ID: <1153426557.5273.132.camel@jzny2>
References: <44AC05A8.9030503@intel.com>
	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
	 <1152191018.5103.48.camel@jzny2>
	 <20060706.235909.78729229.davem@davemloft.net>
	 <1152275283.5341.144.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: olel@ans.pl, jgarzik@pobox.com, greearb@candelatech.com,
	john.ronciak@intel.com, Robert.Olsson@data.slu.se,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:35800 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964788AbWGTUQE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 16:16:04 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G3ewJ-00087Y-Vf
	for netdev@vger.kernel.org; Thu, 20 Jul 2006 16:16:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <1152275283.5341.144.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I went back to this today.  I am typing this from a scribbled sticky
note in a big hurry -  but i still believe I took the correct notes.

It does seem there is no distinction between what ethernet advertises
for flow control capability vs what it ends up negotiating with its
partner i.e there is some ambiguity. I havent checked tg3, this on e1000
only.

On Fri, 2006-07-07 at 08:28 -0400, jamal wrote:
> On Thu, 2006-06-07 at 23:59 -0700, David Miller wrote:
> 
> > 
> > It's autonegotiated, check you kernel message logs when the link
> > came up, you'll see this:
> > 
> > tg3: eth0: Flow control is on for TX and on for RX.
> > 
> 
> yikes - yes, this would be it.
> 
> I  could be wrong and i will double check:
> I think when the e1000 says via ethtool "rx is on" - it means that it 
> is _advertising_ flow control as opposed to detecting partner has flow
> control capability.
> Auke, can you also check this as well?

Semantic #1

For example, configure:
ethtool -A eth0 rx off
ethtool -A eth0 tx on

debopolis:~# ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  on
RX:             off
TX:             on

The other side was set to do symmetric TX flow control only.

Now enforce autonegotiation:
ethtool -r eth0

ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  on
RX:             off
TX:             off

Ok, this is what i expected if this thing (output of ethtool) was
supposed to store state as opposed to configuration.
But if it is state that is stored, then what about that the values
before autonegotian - surely that state is invalid, no?

It would be nice (for debug/usability reasons) to be able to see what i
configured vs what i end up negotiating with the link partner. I think
this may be an ethtool issue, but it could also be a driver issue.

I send 1 Mpps to eth0 and see no flow control packets back. good. So it
does store state

#2: The other semantic

debopolis:~# ethtool -A eth0 rx on
debopolis:~# ethtool -A eth0 tx on

debopolis:~# ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  on
RX:             on
TX:             on

Other side was set to do symmetric TX flow control only.

Now enforce autonegotiation:
debopolis:~# ethtool -r eth0

lets see what we came up with:
debopolis:~# ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  on
RX:             on
TX:             on

Now that is contradictory to #1 semantic - I would have expected this TX
flow control on the e1000 to be off. 
Unless it is meant to store configuration info and not what you have
negotiated.
 
Trying sending traffic to the e1000 at about 1Mpps.
I observe that the e1000 is sending out about 800Kpps of flow control
packets back ;->

So which semantics are correct? I would claim #2 flow control behavior
to be a bug. I just dont have time to chase a fix - hopefully whoever
reads this from the e1000 crowd can fix it.

More importantly can we have two variables storing the two pieces on
information separately instead of the ambiguity of just one?


cheers,
jamal


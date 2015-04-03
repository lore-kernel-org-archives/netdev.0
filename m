From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/2] add fixed_phy_update_state() - update state of fixed_phy
Date: Sat, 04 Apr 2015 00:25:27 +0300
Message-ID: <551F0547.8000202@list.ru>
References: <551C2AB9.8020508@list.ru> <551C2B37.6000100@list.ru> <551EE936.4010700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551EE936.4010700@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

03.04.2015 22:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 01/04/15 10:30, Stas Sergeev wrote:
>> - The callback needs to be registered before of_phy_connect() to
>> avoid running with outdated state, but of_phy_connect() returns the
>> phy_device pointer, which is needed to register the callback. Regist=
ering
>> it before of_phy_connect() will therefore require a hack to get the
>> pointer earlier.
In fact, this can't even be done: registering it before of_phy_connect(=
)
is an asking for troubles with NULL deref.

>> Overall, this addition makes the subsequent patch that implements
>> SGMII link status for mvneta, much cleaner.
> Agreed, now that we have that, we should probably just remove the
> ability to have a fixed link update callback since it suffers from al=
l
> the deficiencies you outlined above, and is creating some overhead by
> polling the hardware.
In fact, there is still a bit of a problem.
You certainly want to set the initial state, so that on of_phy_connect(=
)
time it is already valid. For this I still use of_phy_find_device()...
This, however, differs from registering the callback:
- initial state is set only once; callback should be registered before
_every_ of_phy_connect() (but it can't be registered before because
of the NULL, so only after)
- initial state can be set anywhere anytime, not necessary any near
of_phy_connect().

So the problem is mostly solved, but of_phy_find_device() is still
there. To get rid of this, I guess some addition to of_mdio may be
needed as well. Maybe optionally passing the status directly to
of_phy_connect()? Not sure.

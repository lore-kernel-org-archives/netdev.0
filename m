From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Tue, 27 Oct 2009 01:09:45 -0400
Message-ID: <20091027010945.026d94df.billfink@mindspring.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>
	<1256115421-12714-9-git-send-email-gilad@codefidence.com>
	<4ADED6FA.2030502@gmail.com>
	<4ADEE119.7020803@codefidence.com>
	<4ADF616B.1090405@gmail.com>
	<20091022003245.5cd4885c.billfink@mindspring.com>
	<4ADFE635.4020109@gmail.com>
	<4AE415DD.5050406@codefidence.com>
	<20091025202114.152b94b8.billfink@mindspring.com>
	<4AE52DBD.3030805@gmail.com>
	<4AE5585E.5010108@codefidence.com>
	<20091026110855.98a19f7a.billfink@mindspring.com>
	<4AE5C579.2070104@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev@vger.kernel.org,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:42167 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754291AbZJ0FJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 01:09:43 -0400
In-Reply-To: <4AE5C579.2070104@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Oct 2009, Gilad Ben-Yossef wrote:

> Bill Fink wrote:
> 
> >> OK. It really sounds like we should go with my first suggestion: global 
> >> sysctl based kill switches, just as we have now and in addition, the 
> >> ability to kill TCP options per route. The TCP option will be used if 
> >> and only if both kill switches (global and per route) are not set.
> >>     
> >
> > This wording is confusing.  The global kill switch not being set
> > really means that the sysctl is set.  And this assumes the per-route
> > default is not set.  Correct?
> >   
> Now it is my turn to get confused, because I didn't understand your 
> question :-)

My question was just if I understood you correctly, which apparently
I did.

> What I suggest is to leave the sysctl exactly as they are now:
> 
> - You leave them be (value of 1), the respective TCP option is 
> supported. This is the default.
> - You turn them off (write 0), the respective TCP option is not supported.
> 
> What I suggest to *add* is the following ability:
> 
> - If you have the TCP option support turned on (default, value of one), 
> you can turn support for the option for a specific route using a ip 
> route option.

Should be "turn" -> "turn off" above.

> Hope that made it clearer.

Yes.

> >> What we achieve is:
> >>
> >> 1. Global kill switches work exactly as they do now, whether you use the 
> >> new per route options or not, so backwards compatible.
> >>
> >> 2. In addition, if the global kill switch is not in effect, you can also 
> >> kill the options on a per route basis.
> >>
> >> I'm going to send third version of the patch to this effect, minus the 
> >> new remote DoS possibility that Ilpo pointed out and leaving the global 
> >> sysctl kill switches be.
> >>
> >> If you like it, please ACK ;-)
> >>     
> >
> > IIUC this doesn't seem right to me.  I believe the global setting
> > should be a default and the route specific an override.  Your scheme
> > would mean that if I set a global option to disable timestamps, then
> > I couldn't enable timestamps on specific routes using the per route
> > setting.
> >   
> Yes. You understand my intention perfectly.
> 
> Let me try to explain why I believe this is the correct behavior to 
> implement:
> 
> 1. This is the closest thing to what we have now. Today you write 0 to 
> the sysctl and that TCP option is turned off globally. Period.  My 
> suggestion leaves this behavior as is now regardless if you've used per 
> route settings. The other way make a very subtle change in the meaning 
> of writing 0 to the sysctl.

Continuing to support existing behavior is the most important
consideration for me, so your intention for the per route settings
doesn't cause me any major grief.  I initially thought the per route
setting as an override to a global default setting was more intuitive
than your method of it being a disable switch only, but my thinking
has since evolved (see below).

> I believe very subtle changes to meaning of long established interfaces 
> is bad way to go. It's better to change interfaces on users, but it is 
> even worse to maek something that they have long used do something just 
> slightly different.

I didn't see how my suggestion changed existing behavior.  If you
didn't use the per route settings everything remained as it was
(or so I initially thought).  And if you were using a new feature
then you needed to be aware of its semantics.

> 2. If the per route options needs to be "default, of or off" instead of 
> "on or off", we'd need to move from 1 bit to store the option to, well 
> 2s bit in theory, but probably 32 bits in practice, since we can't use 
> RTAX_FEATURES any longer.
> 
> Yes, we can invent RTAX_FEATURES_TWO_BITS or some such, but I'd say that 
> is ugly :-)

I only intended a single bit for the global default and per route
settings.  The global default would just be enabled (1) or disabled(0).
The per route setting would be inherited from the global default setting,
and also would be just enabled(1) or disabled(0).

Explicitly setting a per route setting to enabled(1) or disabled(0)
would override the initial default setting.

However I didn't fully work through all the ramifications of this
idea, and I now realize this would entail some changes to the existing
behavior of the global setting, which I agree is unacceptable.

I therefore now believe your latest proposal is a better approach
for maintaining backward compatibility and avoiding any nasty
unexpected surprises to existing working configurations.

> 3. I believe that the scenario of needing to set the support of a TCP 
> option globally off and just turn it on for a specific route is not very 
> likely to be needed and losing it is a small price to pay for 1 + 2.

I agree this is probably an uncommon scenario.

> > And it also doesn't seem to address Eric's scenario.  If I understand
> > his concern correctly, what seems to be needed is a third global
> > reset value (not calling it a setting since the actual global setting
> > wouldn't be changed), which would reset any per-route override settings
> > to the global default setting.
> >
> >   
> Well, I do not believe this is what Eric meant (Eric?) but if it is then 
> I fail to see why
> to require from the per route TCP options switches what is not required 
> of any other
> route specific option already existing, since AFAIK we don't have a 
> "reset to default values" to the other options already supported.

I won't try and speak for Eric anymore.

> Having said all that, I have no issue with re-spinning the patch with 
> your suggestion.
> I don't feel all that much which is the correct way- I just want to get 
> as much feedback as possible
> since I'm suggesting to add a new user interface options and we all know 
> it is very hard to back peddle
> on those, so I'm trying to make sure to get enough feedback to do it 
> right the firs time.
> 
> So any feedback from anyone regarding favorite interface? it seems each 
> person fancy a different one :-)

I haven't checked the details of your patch, but I am now fine with
the concepts of the patch as you most recently presented them.

						-Bill

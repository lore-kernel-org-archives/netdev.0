From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Fri, 23 Jun 2006 10:37:58 -0400
Message-ID: <1151073478.2462.26.camel@localhost.localdomain>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
	 <1151063447.2473.6.camel@localhost.localdomain>
	 <20060623124657.GA3256@tuxdriver.com>
	 <43e72e890606230720ta1dc2cm6c9871a71f3872f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:63168 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750794AbWFWOhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 10:37:39 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890606230720ta1dc2cm6c9871a71f3872f0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-23 at 10:20 -0400, Luis R. Rodriguez wrote:
> On 6/23/06, John W. Linville <linville@tuxdriver.com> wrote:
> > On Fri, Jun 23, 2006 at 07:50:47AM -0400, Dan Williams wrote:
> >
> > > Our effort is probably better spent elsewhere, especially since many
> > > popular userspace tools already handle resume for us just fine.  More
> > > useful to have drivers just come back from resume in an initialized
> > > state similar to system boot.
> >
> > I think Dan makes a lot of sense here.  Does anyone disagree?
> 
> How would we handle resume() when using WPA, for example? Dan are you
> suggesting we just bring up the driver clean and expect userspace to
> have handled recovery from anything we were doing? This is important.

Well, for WPA you pretty much need a tool like wpa_supplicant to handle
connections for you, otherwise there wouldn't be a reason for
wpa_supplicant to exist.  I don't think we really want a bunch of code
in the driver to handle the reconnect cases, because this is exactly
what wpa_supplicant already does and does well.

I'm suggesting that instead of trying to stuff more logic in the drivers
to handle reconnect on resume, that the drivers just come back from
resume in the same state as system boot.  They are initialized with
default values and default state.  They allow userspace tools that
already know about policy and security to configure them, as these tools
would do right after a system boot.  We can't assume that policy and
security are exactly the same as before sleep.

> Or should we just expect the driver to re-set all settings again and
> expect wpa_supplicant to pick up well where it left off? If sysfs will
> get cleared after resume then there is no point in using it, but if
> its stateful after suspend then this is where I suspected
> wpa_supplicant could make use of sysfs. Perhaps there is a better way
> -- what I suggested was just an idea while we discussed resume/suspend
> in another thread. The reason I started a new thread was I figured
> configfs/sysfs could be used for other things as well.

I don't know that you can really "pick up where it left off" in many
cases.  Again, the system can be moved, access points can go away, more
networks can appear, and WPA is just more complicated than WEP.  You
simply cannot expect a driver to return to its exact pre-sleep state
when using stuff like 802.1x/WPA[12] Enterprise.  What if your session
keys expired while you were sleeping, for example?

Besides, userspace tools like NetworkManager and wpa_supplicant are just
going to overwrite the config settings the driver restores anyway, since
you need to do another scan, check results, and set the connection back
up after accounting for stuff that may have changed.  Blindly attempting
to connect with all the old settings doesn't make much sense.

It's an optimization to have the driver restore settings, and it might
make things a second or three quicker in some cases, but in many other
cases it's completely useless to do this, possibly detrimental.  I don't
see the overall benefit right now.  We've got better things to do with
drivers at the moment.

Dan



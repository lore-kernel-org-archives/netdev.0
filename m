From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v4 05/24] rocker: use swdev get/set attr for
 bridge port flags
Date: Wed, 15 Apr 2015 17:03:24 +0900
Message-ID: <20150415080321.GB6337@vergenet.net>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
 <1428905838-14920-6-git-send-email-sfeldma@gmail.com>
 <20150415052542.GA5891@vergenet.net>
 <CAE4R7bDoDSeS14Ge1h2mDw-tywdwijkFjqzjF1oe7QGD_8gztw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33245 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbbDOIDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 04:03:36 -0400
Received: by pdbnk13 with SMTP id nk13so43376670pdb.0
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 01:03:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bDoDSeS14Ge1h2mDw-tywdwijkFjqzjF1oe7QGD_8gztw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

On Tue, Apr 14, 2015 at 11:03:21PM -0700, Scott Feldman wrote:
> On Tue, Apr 14, 2015 at 10:25 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Hi Scott,
> >
> > On Sun, Apr 12, 2015 at 11:16:59PM -0700, sfeldma@gmail.com wrote:
> >> From: Scott Feldman <sfeldma@gmail.com>
> >>
> >> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> >> ---
> >>  drivers/net/ethernet/rocker/rocker.c |   31 +++++++++++++++++++++++++++++--
> >>  1 file changed, 29 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> >> index 80c7f6f..9bd4fc6 100644
> >> --- a/drivers/net/ethernet/rocker/rocker.c
> >> +++ b/drivers/net/ethernet/rocker/rocker.c
> >
> > [snip]
> >
> >> @@ -4349,6 +4354,23 @@ static void rocker_port_trans_abort(struct rocker_port *rocker_port)
> >>       }
> >>  }
> >>
> >> +static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
> >> +                                     unsigned long brport_flags)
> >> +{
> >> +     unsigned long orig_flags;
> >> +     int err = 0;
> >> +
> >> +     orig_flags = rocker_port->brport_flags;
> >> +     rocker_port->brport_flags = brport_flags;
> >> +     if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
> >> +             err = rocker_port_set_learning(rocker_port);
> >
> > My understanding is that the two-phase set scheme that this
> > patch-set proposes allows failure, e.g. due resource constraints,
> > during the prepare phase but that failure in the commit phase
> > indicates a hardware or driver bug.
> >
> > It seems to me that this patch doesn't follow the above scheme because
> > I see the following call-chain:
> >
> >         rocker_port_set_learning()
> >         -> rocker_cmd_exec()
> >            -> rocker_wait_create()
> >               -> kmalloc()
> >
> > I am probably missing something but it does seem to me that the above is
> > called in both the prepare and commit phases and that kalloc() may fail in
> > ether case, the latter case being the problem I see.
> 
> Nope, you're not missing something, you found a bug.   A little later
> you'll see we use a desc on the cmd ring to issue the cmd to HW.  If
> we're in prepare phase, we want to put that desc back on the ring so
> commit phase has a desc.  So this needs to be fixed also.  More work
> for v5.  But I'm totally glad you're reviewing at this level and
> finding issues like this.  Thank you very much.

I'm glad its useful :)
FWIW, I also like the direction of this patchset.

> It's been a little tricky retrofitting rocker for this prepare-commit
> scheme.  Prepare phase really forces you to examine all failure paths
> and make sure everything is just how you found it and resources are
> reserved so commit has a happy life.  My hope is this will be easier
> with new drivers knowing the prepare-commit rules up-front.
> 
> -scott

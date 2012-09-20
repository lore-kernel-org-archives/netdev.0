From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 5/6] xfrm_user: ensure user supplied esn replay window
 is valid
Date: Thu, 20 Sep 2012 09:05:09 +0200
Message-ID: <20120920070508.GA4221@secunet.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
 <1348090423-32665-6-git-send-email-minipli@googlemail.com>
 <1348094309.2636.80.camel@bwh-desktop.uk.solarflarecom.com>
 <CA+rthh8Q464Jw5okH5aXds0QZztay9dpcyniahtWFxev8tpN9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Martin Willi <martin@revosec.ch>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+rthh8Q464Jw5okH5aXds0QZztay9dpcyniahtWFxev8tpN9w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 20, 2012 at 08:12:11AM +0200, Mathias Krause wrote:
> On Thu, Sep 20, 2012 at 12:38 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Wed, 2012-09-19 at 23:33 +0200, Mathias Krause wrote:
> 
> > I'm a little worried that the user-provided
> > xfrm_replay_state_esn::bmp_len is not being directly validated anywhere.
> 
> That's what my P.S. in the cover letter tried to hint at -- a missing
> upper limit check. But as I wanted to avoid lengthy discussions about
> the concrete value and the possible need for some sysctl knob to tune
> this even further, I just left this as an exercise for someone else
> who is more familiar with the code ;)
> 

I think we should limit bmp_len to some sane value. RFC 4303 recommends
an anti replay window size of 64 packets, so limiting bmp_len to cover
4096 packets should be more that enough. Also we can increase this value
later without changing the user API if this is needed.

> > Currently xfrm_replay_state_esn_len() may overflow, and as its return
> > type is int it may unexpectedly return a negative value.
> 
> So xfrm_replay_state_esn_len() should return size_t instead as it's
> value should always be positive -- it represents a length. Negative
> lengths make no sense. It can overflow, still. But it cannot get
> negative, at least. Still, the upper limit check would be required to
> avoid other user induced nastiness.
> 
> >
> > [...]
> >> --- a/net/xfrm/xfrm_user.c
> >> +++ b/net/xfrm/xfrm_user.c
> > [...]
> >> @@ -370,14 +378,15 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
> >>                                        struct nlattr *rp)
> >>  {
> >>       struct xfrm_replay_state_esn *up;
> >> +     size_t ulen;
> >
> > I would normally expect to see sizes declared as size_t but mixing
> > size_t and int in comparisons tends to result in bugs.  So I think this
> > should to be int, matching the return types of nla_len() and
> > xfrm_replay_state_esn_len() (and apparently all lengths in netlink...)
> 
> I disagree. The value of nla_len() is ensured to be in the range of
> [sizeof(*up), USHRT_MAX-NLA_HDRLEN], i.e. a positive 16 bit number,
> when it passes nlmsg_parse() in xfrm_user_rcv_msg(). This in turn
> allows us to assume the int value returned by nla_len() is actually
> positive and the compiler can safely make it unsigned for the compare
> -- no sign bit, no hassle.

I think xfrm_replay_state_esn_len() should return the same type as
nla_len(), no matter what we can assume from the current code base.
Also it should not return anything else than the other xfrm length
calculation functions.

Once we limited bmp_len, xfrm_replay_state_esn_len() should return
always a positive value.

From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH 5/6] xfrm_user: ensure user supplied esn replay window is valid
Date: Thu, 20 Sep 2012 09:37:34 +0200
Message-ID: <CA+rthh_tRHpQzy0jpbaqwNZTBk+f8t5=cFE4w7yu=6CM-chTSA@mail.gmail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
	<1348090423-32665-6-git-send-email-minipli@googlemail.com>
	<1348094309.2636.80.camel@bwh-desktop.uk.solarflarecom.com>
	<CA+rthh8Q464Jw5okH5aXds0QZztay9dpcyniahtWFxev8tpN9w@mail.gmail.com>
	<20120920070508.GA4221@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Martin Willi <martin@revosec.ch>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120920070508.GA4221@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 20, 2012 at 9:05 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Sep 20, 2012 at 08:12:11AM +0200, Mathias Krause wrote:
>> On Thu, Sep 20, 2012 at 12:38 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> > On Wed, 2012-09-19 at 23:33 +0200, Mathias Krause wrote:
>>
>> > I'm a little worried that the user-provided
>> > xfrm_replay_state_esn::bmp_len is not being directly validated anywhere.
>>
>> That's what my P.S. in the cover letter tried to hint at -- a missing
>> upper limit check. But as I wanted to avoid lengthy discussions about
>> the concrete value and the possible need for some sysctl knob to tune
>> this even further, I just left this as an exercise for someone else
>> who is more familiar with the code ;)
>>
>
> I think we should limit bmp_len to some sane value. RFC 4303 recommends
> an anti replay window size of 64 packets, so limiting bmp_len to cover
> 4096 packets should be more that enough. Also we can increase this value
> later without changing the user API if this is needed.

Okay. If no-one objects, I'll at add a upper limit check for 4096
packets to verify_replay().

>> [...]
>> I disagree. The value of nla_len() is ensured to be in the range of
>> [sizeof(*up), USHRT_MAX-NLA_HDRLEN], i.e. a positive 16 bit number,
>> when it passes nlmsg_parse() in xfrm_user_rcv_msg(). This in turn
>> allows us to assume the int value returned by nla_len() is actually
>> positive and the compiler can safely make it unsigned for the compare
>> -- no sign bit, no hassle.
>
> I think xfrm_replay_state_esn_len() should return the same type as
> nla_len(), no matter what we can assume from the current code base.

The type of the expression calculated in xfrm_replay_state_esn_len()
is size_t; the functions the value get passed onto (k*alloc, kmemdup,
memcpy, memcmp) expect a size_t argument; expressions where the value
is evaluated to calculate sizes (e.g. in xfrm_sa_len) operate on
size_t types. So size_t feels just natural.

> Also it should not return anything else than the other xfrm length
> calculation functions.

So the other functions should have a return type of size_t, too?

Anyway, such a cleanup should go into a separate patch as the other
functions are not vulnerable to an overflow like it could happen in
xfrm_replay_state_esn_len().

> Once we limited bmp_len, xfrm_replay_state_esn_len() should return
> always a positive value.

True. So int it'll be then again for xfrm_replay_state_esn_len() in v3
of the patch.


Thanks,
Mathias

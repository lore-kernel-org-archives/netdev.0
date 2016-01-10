From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible) division by zero
Date: Sun, 10 Jan 2016 12:23:43 +0200
Message-ID: <8830013.bJO8vnIv9N@spock>
References: <26396443.iDTTxgChSj@spock> <CAK6E8=dSRmf35AaC6mOcRaGSxn81CE76WiOfNx6jb5X8uhDGqw@mail.gmail.com> <CAK6E8=chikkT02ygDHzHN9xP7q7kzWUqHEVgj7g0oW_RUPcuoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=chikkT02ygDHzHN9xP7q7kzWUqHEVgj7g0oW_RUPcuoA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the patch queued for upstream and ECN enabled I get WARN_ON_ONCE()=
=20
triggered. Here is the stacktrace:

https://gist.github.com/89203e77bfcb051f269a

It seems that tp->prior_cwnd is zero.

Ideas?

On =D1=81=D0=B5=D1=80=D0=B5=D0=B4=D0=B0, 6 =D1=81=D1=96=D1=87=D0=BD=D1=8F=
 2016 =D1=80. 10:43:45 EET Yuchung Cheng wrote:
> On Wed, Jan 6, 2016 at 10:19 AM, Yuchung Cheng <ycheng@google.com> wr=
ote:
> > On Wed, Jan 6, 2016 at 8:50 AM, Oleksandr Natalenko
> >=20
> > <oleksandr@natalenko.name> wrote:
> >> Unfortunately, the patch didn't help -- I've got the same stacktra=
ce with
> >> slightly different offset (+3) within the function.
> >>=20
> >> Now trying to get full stacktrace via netconsole. Need more time.
> >>=20
> >> Meanwhile, any other ideas on what went wrong?
> >=20
> > That's odd b/c the patch already checks and avoids div0. Can post m=
e
> > the stacktrace and kernel warnings if any ...
> >=20
> > One possibility is that tcp_cwnd_reduction() may set a cwnd of 0,
> > which then gets used to start another recovery phase. This may or m=
ay
> > not be the culprit of this div0 issue because I wasn't able to
> > reproduce exactly your issue on our servers. But I will post the fi=
x
> > today and CC you.
>=20
> Could you turn off ecn (sysctl net.ipv4.tcp_ecn=3D0) to see if this s=
till
> happen?
> >> On December 22, 2015 4:10:32 AM EET, Yuchung Cheng <ycheng@google.=
com>=20
wrote:
> >> >On Mon, Dec 21, 2015 at 12:25 PM, Oleksandr Natalenko
> >> >
> >> ><oleksandr@natalenko.name> wrote:
> >> >> Commit 3759824da87b30ce7a35b4873b62b0ba38905ef5 (tcp: PRR uses =
CRB
> >> >
> >> >mode by
> >> >
> >> >> default and SS mode conditionally) introduced changes to
> >> >
> >> >net/ipv4/tcp_input.c
> >> >
> >> >> tcp_cwnd_reduction() that, possibly, cause division by zero, an=
d
> >> >
> >> >therefore,
> >> >
> >> >> kernel panic in interrupt handler [1].
> >> >>=20
> >> >> Reverting 3759824da87b30ce7a35b4873b62b0ba38905ef5 seems to fix=
 the
> >> >
> >> >issue.
> >> >
> >> >> I'm able to reproduce the issue on 4.3.0=E2=80=934.3.3 once per=
 several day
> >> >> (occasionally).
> >> >>=20
> >> >> What could be done to help in debugging this issue?
> >> >
> >> >Do you have ECN enabled (i.e. sysctl net.ipv4.tcp_ecn > 0)?
> >> >
> >> >If so I suspect an ACK carrying ECE during CA_Loss causes enterin=
g CWR
> >> >state w/o calling tcp_init_cwnd_reduct() to set tp->prior_cwnd. C=
an
> >> >you try this debug / quick-fix patch and send me the error messag=
e if
> >> >any?
> >> >
> >> >> Regards,
> >> >>=20
> >> >>   Oleksandr.
> >> >>=20
> >> >> [1] http://i.piccy.info/
> >> >
> >> >i9/6f5cb187c4ff282d189f78c63f95af43/1450729403/283985/951663/pani=
c.jpg
> >>=20
> >> --
> >> Sent from my Android device with K-9 Mail. Please excuse my brevit=
y.
